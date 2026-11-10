package main

import (
	"crypto/subtle"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

// richiestaSync è quello che manda l'app per sincronizzarsi.
type richiestaSync struct {
	// Dispositivo è il nome dell'app che chiama, per esempio
	// "android-1a2b3c": serve solo a sapere chi si è visto e quando.
	Dispositivo string `json:"dispositivo"`
	// Dalla è l'ultima revisione che l'app ha già ricevuto.
	Dalla int64 `json:"dalla"`
	// Limite è quante righe al massimo restituire.
	Limite int `json:"limite"`
	// Modifiche sono le righe cambiate sull'app dall'ultima volta.
	Modifiche []Riga `json:"modifiche"`
}

// rispostaSync è quello che il server risponde.
type rispostaSync struct {
	// Righe sono quelle cambiate dopo Dalla, più la versione del server di
	// quelle rifiutate.
	Righe []Riga `json:"righe"`
	// Revisione è da dove ripartire alla prossima richiesta.
	Revisione int64 `json:"revisione"`
	// Fine dice se le righe sono finite o ne servono altre pagine.
	Fine bool `json:"fine"`
	// Massima è la revisione più alta del server. Se l'app ne conosce una
	// più alta, il server è tornato indietro (per esempio ripristinato da un
	// backup) e l'app deve rimandare tutto (DECISIONI.md, voce 019).
	Massima int64 `json:"massima"`
	// Ripartire vale true quando l'app conosce una revisione più alta di
	// quelle del server: le modifiche non sono state prese, e l'app deve
	// rimandare tutto partendo da zero.
	Ripartire bool `json:"ripartire"`
	// Rifiutate sono le modifiche non entrate perché il server ne aveva una
	// più recente, come "tabella/id".
	Rifiutate []string `json:"rifiutate"`
}

// stato è la risposta di /api/stato.
type stato struct {
	Versione    string         `json:"versione"`
	Righe       map[string]int `json:"righe"`
	Foto        int            `json:"foto"`
	Dispositivi []Dispositivo  `json:"dispositivi"`
	Backup      statoBackup    `json:"backup"`
}

type statoBackup struct {
	Ultimo *time.Time `json:"ultimo"`
	Copie  int        `json:"copie"`
	Ogni   string     `json:"ogni"`
}

// I nomi delle foto sono quelli dati dall'app: un UUID e un'estensione. Il
// controllo impedisce anche di uscire dalla cartella con "../".
var reNomeFoto = regexp.MustCompile(`^[0-9a-fA-F-]{36}\.[a-z0-9]{1,5}$`)

const (
	massimoSync = 64 << 20 // 64 MB: la prima sincronizzazione manda tutto.
	massimoFoto = 32 << 20 // 32 MB: l'app riduce le foto, ma un margine serve.
)

// NuovaAPI costruisce le pagine del server.
//
// Tutte chiedono il token, tranne /api/salute che serve al controllo del
// container e non dice niente dei dati.
func NuovaAPI(a *Archivio, b *Backup, token string) http.Handler {
	api := &api{archivio: a, backup: b}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/salute", api.salute)
	mux.Handle("POST /api/sync", conToken(token, api.sync))
	mux.Handle("GET /api/stato", conToken(token, api.stato))
	mux.Handle("POST /api/backup", conToken(token, api.faiBackup))
	// GET risponde anche a HEAD: l'app chiede se una foto c'è senza
	// scaricarla.
	mux.Handle("GET /api/foto/{nome}", conToken(token, api.leggiFoto))
	mux.Handle("PUT /api/foto/{nome}", conToken(token, api.scriviFoto))
	return mux
}

type api struct {
	archivio *Archivio
	backup   *Backup
}

// conToken lascia passare solo chi manda "Authorization: Bearer <token>".
func conToken(token string, h http.HandlerFunc) http.Handler {
	atteso := []byte("Bearer " + token)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Confronto a tempo costante: non si deve poter indovinare il token
		// un carattere alla volta misurando le risposte.
		if subtle.ConstantTimeCompare([]byte(r.Header.Get("Authorization")), atteso) != 1 {
			errore(w, http.StatusUnauthorized, "token mancante o sbagliato")
			return
		}
		h(w, r)
	})
}

func (s *api) salute(w http.ResponseWriter, _ *http.Request) {
	rispondi(w, map[string]any{"ok": true, "versione": versione})
}

func (s *api) sync(w http.ResponseWriter, r *http.Request) {
	var richiesta richiestaSync
	if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, massimoSync)).Decode(&richiesta); err != nil {
		errore(w, http.StatusBadRequest, "richiesta non leggibile: "+err.Error())
		return
	}
	limite := richiesta.Limite
	if limite <= 0 || limite > 2000 {
		limite = 1000
	}

	// Il controllo va fatto prima di salvare: le modifiche alzerebbero la
	// revisione massima e nasconderebbero il salto indietro.
	primaDiSalvare, err := s.archivio.MassimaRevisione()
	if err != nil {
		erroreInterno(w, "sync", err)
		return
	}
	if richiesta.Dalla > primaDiSalvare {
		rispondi(w, rispostaSync{
			Righe: []Riga{}, Fine: true, Massima: primaDiSalvare, Ripartire: true, Rifiutate: []string{},
		})
		return
	}

	rifiutate, err := s.archivio.Applica(richiesta.Dispositivo, richiesta.Modifiche, time.Now())
	if errors.Is(err, ErrRigaNonValida) {
		errore(w, http.StatusBadRequest, err.Error())
		return
	}
	if err != nil {
		erroreInterno(w, "sync", err)
		return
	}

	righe, prossima, fine, err := s.archivio.Dopo(richiesta.Dalla, limite)
	if err != nil {
		erroreInterno(w, "sync", err)
		return
	}
	massima, err := s.archivio.MassimaRevisione()
	if err != nil {
		erroreInterno(w, "sync", err)
		return
	}
	risposta := rispostaSync{
		Righe: righe, Revisione: prossima, Fine: fine, Massima: massima, Rifiutate: []string{},
	}
	for _, rifiutata := range rifiutate {
		risposta.Righe = append(risposta.Righe, rifiutata)
		risposta.Rifiutate = append(risposta.Rifiutate, rifiutata.Tabella+"/"+rifiutata.ID)
	}
	rispondi(w, risposta)
}

func (s *api) stato(w http.ResponseWriter, _ *http.Request) {
	conteggi, err := s.archivio.Conteggi()
	if err != nil {
		erroreInterno(w, "stato", err)
		return
	}
	dispositivi, err := s.archivio.Dispositivi()
	if err != nil {
		erroreInterno(w, "stato", err)
		return
	}
	foto, _ := os.ReadDir(s.archivio.Foto)
	copie, _ := s.backup.Copie()
	risposta := stato{
		Versione:    versione,
		Righe:       conteggi,
		Foto:        len(foto),
		Dispositivi: dispositivi,
		Backup:      statoBackup{Copie: len(copie), Ogni: s.backup.Ogni.String()},
	}
	if ultimo := s.backup.Ultimo(); !ultimo.IsZero() {
		u := ultimo.UTC()
		risposta.Backup.Ultimo = &u
	}
	rispondi(w, risposta)
}

func (s *api) faiBackup(w http.ResponseWriter, _ *http.Request) {
	nome, err := s.backup.Esegui(time.Now())
	if err != nil {
		erroreInterno(w, "backup", err)
		return
	}
	rispondi(w, map[string]any{"copia": nome})
}

func (s *api) leggiFoto(w http.ResponseWriter, r *http.Request) {
	nome := r.PathValue("nome")
	if !reNomeFoto.MatchString(nome) {
		errore(w, http.StatusBadRequest, "nome della foto non valido")
		return
	}
	file, err := os.Open(filepath.Join(s.archivio.Foto, nome))
	if err != nil {
		errore(w, http.StatusNotFound, "foto non trovata")
		return
	}
	defer file.Close()
	info, err := file.Stat()
	if err != nil {
		erroreInterno(w, "foto", err)
		return
	}
	http.ServeContent(w, r, nome, info.ModTime(), file)
}

func (s *api) scriviFoto(w http.ResponseWriter, r *http.Request) {
	nome := r.PathValue("nome")
	if !reNomeFoto.MatchString(nome) {
		errore(w, http.StatusBadRequest, "nome della foto non valido")
		return
	}
	finale := filepath.Join(s.archivio.Foto, nome)
	// Una foto non cambia mai dopo il caricamento: se c'è già, è lei.
	if _, err := os.Stat(finale); err == nil {
		w.WriteHeader(http.StatusNoContent)
		return
	}
	provvisorio := finale + ".parziale"
	file, err := os.Create(provvisorio)
	if err != nil {
		erroreInterno(w, "foto", err)
		return
	}
	_, err = io.Copy(file, http.MaxBytesReader(w, r.Body, massimoFoto))
	if chiusura := file.Close(); err == nil {
		err = chiusura
	}
	if err != nil {
		os.Remove(provvisorio)
		errore(w, http.StatusBadRequest, "foto non ricevuta: "+err.Error())
		return
	}
	if err := os.Rename(provvisorio, finale); err != nil {
		erroreInterno(w, "foto", err)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func rispondi(w http.ResponseWriter, valore any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	if err := json.NewEncoder(w).Encode(valore); err != nil {
		log.Printf("risposta non scritta: %v", err)
	}
}

func errore(w http.ResponseWriter, codice int, messaggio string) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(codice)
	json.NewEncoder(w).Encode(map[string]string{"errore": messaggio})
}

// erroreInterno registra il guasto nel log del container e risponde 500
// senza mostrare i dettagli.
func erroreInterno(w http.ResponseWriter, dove string, err error) {
	log.Printf("errore in %s: %v", dove, err)
	errore(w, http.StatusInternalServerError, "errore del server: "+strings.SplitN(err.Error(), "\n", 2)[0])
}
