package main

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

const tokenDiProva = "token-di-prova-abbastanza-lungo"

func serverDiProva(t *testing.T) *httptest.Server {
	t.Helper()
	a := archivioDiProva(t)
	s := httptest.NewServer(NuovaAPI(a, NuovoBackup(a, t.TempDir(), 0, 5), tokenDiProva))
	t.Cleanup(s.Close)
	return s
}

func chiama(t *testing.T, s *httptest.Server, metodo, percorso string, corpo []byte, token string) *http.Response {
	t.Helper()
	richiesta, _ := http.NewRequest(metodo, s.URL+percorso, bytes.NewReader(corpo))
	if token != "" {
		richiesta.Header.Set("Authorization", "Bearer "+token)
	}
	risposta, err := http.DefaultClient.Do(richiesta)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { risposta.Body.Close() })
	return risposta
}

func sincronizza(t *testing.T, s *httptest.Server, r richiestaSync) rispostaSync {
	t.Helper()
	corpo, _ := json.Marshal(r)
	risposta := chiama(t, s, "POST", "/api/sync", corpo, tokenDiProva)
	if risposta.StatusCode != http.StatusOK {
		testo, _ := io.ReadAll(risposta.Body)
		t.Fatalf("sync: %d %s", risposta.StatusCode, testo)
	}
	var esito rispostaSync
	if err := json.NewDecoder(risposta.Body).Decode(&esito); err != nil {
		t.Fatal(err)
	}
	return esito
}

func TestServeIlToken(t *testing.T) {
	s := serverDiProva(t)
	if r := chiama(t, s, "GET", "/api/salute", nil, ""); r.StatusCode != http.StatusOK {
		t.Fatalf("salute senza token: %d", r.StatusCode)
	}
	for _, token := range []string{"", "sbagliato"} {
		if r := chiama(t, s, "POST", "/api/sync", []byte(`{}`), token); r.StatusCode != http.StatusUnauthorized {
			t.Fatalf("sync con token %q: %d", token, r.StatusCode)
		}
	}
}

func TestDueDispositivi(t *testing.T) {
	s := serverDiProva(t)

	// Il telefono manda un'attività.
	telefono := sincronizza(t, s, richiestaSync{
		Dispositivo: "telefono",
		Modifiche:   []Riga{riga("attivita", "a1", 1000, "dal telefono")},
	})
	if telefono.Revisione != 1 || telefono.Massima != 1 || len(telefono.Righe) != 1 {
		t.Fatalf("telefono: %+v", telefono)
	}

	// Il PC la riceve, la modifica e la rimanda.
	pc := sincronizza(t, s, richiestaSync{Dispositivo: "pc"})
	if len(pc.Righe) != 1 || titoloDi(t, pc.Righe[0]) != "dal telefono" {
		t.Fatalf("pc: %+v", pc)
	}
	sincronizza(t, s, richiestaSync{
		Dispositivo: "pc",
		Dalla:       pc.Revisione,
		Modifiche:   []Riga{riga("attivita", "a1", 2000, "modificata dal pc")},
	})

	// Il telefono, con una modifica più vecchia, viene respinto e riceve
	// quella del PC.
	esito := sincronizza(t, s, richiestaSync{
		Dispositivo: "telefono",
		Dalla:       telefono.Revisione,
		Modifiche:   []Riga{riga("attivita", "a1", 1500, "vecchia")},
	})
	if len(esito.Rifiutate) != 1 || esito.Rifiutate[0] != "attivita/a1" {
		t.Fatalf("rifiutate: %v", esito.Rifiutate)
	}
	for _, r := range esito.Righe {
		if titoloDi(t, r) != "modificata dal pc" {
			t.Fatalf("il telefono doveva ricevere la versione del pc: %+v", esito.Righe)
		}
	}

	// Una riga non valida è un errore 400, non un 500.
	corpo, _ := json.Marshal(richiestaSync{Modifiche: []Riga{{Tabella: "X", ID: "1", Dati: json.RawMessage(`{}`)}}})
	if r := chiama(t, s, "POST", "/api/sync", corpo, tokenDiProva); r.StatusCode != http.StatusBadRequest {
		t.Fatalf("riga non valida: %d", r.StatusCode)
	}
}

func TestFoto(t *testing.T) {
	s := serverDiProva(t)
	nome := "/api/foto/22222222-2222-2222-2222-222222222222.jpg"

	if r := chiama(t, s, "HEAD", nome, nil, tokenDiProva); r.StatusCode != http.StatusNotFound {
		t.Fatalf("prima del caricamento: %d", r.StatusCode)
	}
	if r := chiama(t, s, "PUT", nome, []byte("pixel"), tokenDiProva); r.StatusCode != http.StatusCreated {
		t.Fatalf("caricamento: %d", r.StatusCode)
	}
	// Ricaricarla non la cambia.
	if r := chiama(t, s, "PUT", nome, []byte("altro"), tokenDiProva); r.StatusCode != http.StatusNoContent {
		t.Fatalf("secondo caricamento: %d", r.StatusCode)
	}
	r := chiama(t, s, "GET", nome, nil, tokenDiProva)
	if dati, _ := io.ReadAll(r.Body); string(dati) != "pixel" {
		t.Fatalf("foto letta: %q", dati)
	}
	if r := chiama(t, s, "GET", "/api/foto/..%2F..%2Fetc%2Fpasswd", nil, tokenDiProva); r.StatusCode == http.StatusOK {
		t.Fatal("un nome con ../ non doveva passare")
	}
}

func TestStatoEBackupARichiesta(t *testing.T) {
	s := serverDiProva(t)
	sincronizza(t, s, richiestaSync{Dispositivo: "telefono", Modifiche: []Riga{riga("attivita", "a1", 1, "x")}})
	if r := chiama(t, s, "POST", "/api/backup", nil, tokenDiProva); r.StatusCode != http.StatusOK {
		t.Fatalf("backup: %d", r.StatusCode)
	}
	var st stato
	json.NewDecoder(chiama(t, s, "GET", "/api/stato", nil, tokenDiProva).Body).Decode(&st)
	if st.Righe["attivita"] != 1 || st.Backup.Copie != 1 || st.Backup.Ultimo == nil || len(st.Dispositivi) != 1 {
		t.Fatalf("stato: %+v", st)
	}
	if time.Since(*st.Backup.Ultimo) > time.Minute {
		t.Fatalf("ultimo backup troppo vecchio: %v", st.Backup.Ultimo)
	}
}

func TestServerTornatoIndietro(t *testing.T) {
	s := serverDiProva(t)
	sincronizza(t, s, richiestaSync{Dispositivo: "pc", Modifiche: []Riga{riga("attivita", "a1", 1, "x")}})

	// Un'app che conosce la revisione 7 su un server che arriva a 1: il
	// server è stato ripristinato da un backup più vecchio.
	esito := sincronizza(t, s, richiestaSync{
		Dispositivo: "telefono",
		Dalla:       7,
		Modifiche:   []Riga{riga("attivita", "a2", 1, "persa?")},
	})
	if !esito.Ripartire || esito.Massima != 1 {
		t.Fatalf("atteso ripartire, avuto %+v", esito)
	}
	// La modifica non deve essere entrata: l'app la rimanderà da zero.
	if tutte := sincronizza(t, s, richiestaSync{Dispositivo: "pc"}); len(tutte.Righe) != 1 {
		t.Fatalf("righe sul server: %d", len(tutte.Righe))
	}
}
