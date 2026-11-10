package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"regexp"
	"sort"
	"sync"
	"time"

	_ "modernc.org/sqlite" // SQLite senza CGO: il programma resta un solo file.
)

// Riga è una riga di una tabella dell'app, così come viaggia fra app e
// server.
//
// Il server non sa cosa sia un'attività: tiene i dati come li manda l'app
// (JSON) e guarda solo tabella, id e data di modifica. Così una colonna nuova
// nell'app non richiede di cambiare il server (DECISIONI.md, voce 019).
type Riga struct {
	// Tabella è il nome della tabella nell'app, per esempio "attivita".
	Tabella string `json:"tabella"`
	// ID è l'id della riga nell'app.
	ID string `json:"id"`
	// Aggiornata è la data di modifica della riga, in millisecondi: decide
	// chi vince fra due versioni.
	Aggiornata int64 `json:"aggiornata"`
	// Dati è la riga intera, in JSON, mai riscritta dal server.
	Dati json.RawMessage `json:"dati"`
}

// Dispositivo è un'app che si è sincronizzata almeno una volta.
type Dispositivo struct {
	Nome        string    `json:"nome"`
	UltimaVolta time.Time `json:"ultimaVolta"`
}

var (
	reTabella = regexp.MustCompile(`^[a-z][a-z_]{0,39}$`)
	reID      = regexp.MustCompile(`^[A-Za-z0-9_-]{1,64}$`)
)

// ErrRigaNonValida segnala una riga con tabella, id o dati che non vanno.
var ErrRigaNonValida = errors.New("riga non valida")

// Archivio tiene le righe di tutti i dispositivi e le foto.
type Archivio struct {
	db *sql.DB
	// Foto è la cartella delle foto.
	Foto string
	// mu mette in fila le scritture: le revisioni devono crescere senza buchi
	// né doppioni.
	mu sync.Mutex
}

const schema = `
CREATE TABLE IF NOT EXISTS righe (
	tabella     TEXT    NOT NULL,
	id          TEXT    NOT NULL,
	dati        TEXT    NOT NULL,
	aggiornata  INTEGER NOT NULL,
	revisione   INTEGER NOT NULL,
	dispositivo TEXT    NOT NULL,
	PRIMARY KEY (tabella, id)
);
CREATE INDEX IF NOT EXISTS righe_per_revisione ON righe (revisione);
CREATE TABLE IF NOT EXISTS dispositivi (
	nome         TEXT    PRIMARY KEY,
	ultima_volta INTEGER NOT NULL
);
`

// ApriArchivio apre (o crea) il database in percorso e la cartella delle
// foto.
func ApriArchivio(percorso, cartellaFoto string) (*Archivio, error) {
	if err := os.MkdirAll(cartellaFoto, 0o755); err != nil {
		return nil, fmt.Errorf("cartella delle foto: %w", err)
	}
	// WAL: chi legge non blocca chi scrive. busy_timeout: un'attesa breve
	// invece di un errore se il backup sta leggendo.
	db, err := sql.Open("sqlite", percorso+
		"?_pragma=journal_mode(WAL)&_pragma=busy_timeout(10000)&_pragma=synchronous(NORMAL)")
	if err != nil {
		return nil, err
	}
	// Una connessione sola: per un uso personale basta, ed evita ogni
	// sorpresa di concorrenza con SQLite.
	db.SetMaxOpenConns(1)
	if _, err := db.Exec(schema); err != nil {
		db.Close()
		return nil, fmt.Errorf("schema del database: %w", err)
	}
	return &Archivio{db: db, Foto: cartellaFoto}, nil
}

// Chiudi chiude il database.
func (a *Archivio) Chiudi() error { return a.db.Close() }

// valida controlla una riga arrivata da un'app.
func valida(r Riga) error {
	if !reTabella.MatchString(r.Tabella) {
		return fmt.Errorf("%w: tabella %q", ErrRigaNonValida, r.Tabella)
	}
	if !reID.MatchString(r.ID) {
		return fmt.Errorf("%w: id %q", ErrRigaNonValida, r.ID)
	}
	dati := bytes.TrimSpace(r.Dati)
	if len(dati) == 0 || dati[0] != '{' || !json.Valid(dati) {
		return fmt.Errorf("%w: dati di %s/%s", ErrRigaNonValida, r.Tabella, r.ID)
	}
	return nil
}

// Applica salva le righe mandate da un dispositivo e restituisce quelle
// rifiutate, ognuna nella versione che il server tiene.
//
// Vince la modifica più recente: una riga entra se è nuova o se la sua data
// di modifica non è più vecchia di quella che c'è. A parità di data entra,
// così due modifiche fatte nello stesso secondo dallo stesso dispositivo
// arrivano entrambe (voce 019). Ogni riga salvata prende una revisione nuova,
// più alta di tutte le altre.
func (a *Archivio) Applica(dispositivo string, righe []Riga, adesso time.Time) ([]Riga, error) {
	for _, r := range righe {
		if err := valida(r); err != nil {
			return nil, err
		}
	}
	a.mu.Lock()
	defer a.mu.Unlock()

	tx, err := a.db.Begin()
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	var revisione int64
	if err := tx.QueryRow(`SELECT COALESCE(MAX(revisione), 0) FROM righe`).Scan(&revisione); err != nil {
		return nil, err
	}

	var rifiutate []Riga
	for _, r := range righe {
		var esistente Riga
		var datiEsistenti string
		err := tx.QueryRow(
			`SELECT tabella, id, aggiornata, dati FROM righe WHERE tabella = ? AND id = ?`,
			r.Tabella, r.ID,
		).Scan(&esistente.Tabella, &esistente.ID, &esistente.Aggiornata, &datiEsistenti)
		// I dati si leggono come testo: json.RawMessage non si legge
		// direttamente da SQL.
		esistente.Dati = json.RawMessage(datiEsistenti)
		switch {
		case errors.Is(err, sql.ErrNoRows):
			// Nuova: entra.
		case err != nil:
			return nil, err
		case r.Aggiornata < esistente.Aggiornata:
			rifiutate = append(rifiutate, esistente)
			continue
		}
		revisione++
		if _, err := tx.Exec(
			`INSERT INTO righe (tabella, id, dati, aggiornata, revisione, dispositivo)
			 VALUES (?, ?, ?, ?, ?, ?)
			 ON CONFLICT (tabella, id) DO UPDATE SET
			   dati = excluded.dati, aggiornata = excluded.aggiornata,
			   revisione = excluded.revisione, dispositivo = excluded.dispositivo`,
			r.Tabella, r.ID, string(bytes.TrimSpace(r.Dati)), r.Aggiornata, revisione, dispositivo,
		); err != nil {
			return nil, err
		}
	}

	if dispositivo != "" {
		if _, err := tx.Exec(
			`INSERT INTO dispositivi (nome, ultima_volta) VALUES (?, ?)
			 ON CONFLICT (nome) DO UPDATE SET ultima_volta = excluded.ultima_volta`,
			dispositivo, adesso.UnixMilli(),
		); err != nil {
			return nil, err
		}
	}
	return rifiutate, tx.Commit()
}

// Dopo restituisce al massimo limite righe con revisione più alta di dalla,
// in ordine di revisione, la revisione da cui ripartire e se sono finite.
func (a *Archivio) Dopo(dalla int64, limite int) ([]Riga, int64, bool, error) {
	if limite <= 0 {
		limite = 1000
	}
	// Una in più per sapere se ce ne sono altre.
	elenco, err := a.db.Query(
		`SELECT tabella, id, aggiornata, dati, revisione FROM righe
		 WHERE revisione > ? ORDER BY revisione LIMIT ?`,
		dalla, limite+1,
	)
	if err != nil {
		return nil, 0, false, err
	}
	defer elenco.Close()

	righe := []Riga{}
	prossima := dalla
	for elenco.Next() {
		if len(righe) == limite {
			return righe, prossima, false, nil
		}
		var r Riga
		var dati string
		var revisione int64
		if err := elenco.Scan(&r.Tabella, &r.ID, &r.Aggiornata, &dati, &revisione); err != nil {
			return nil, 0, false, err
		}
		r.Dati = json.RawMessage(dati)
		righe = append(righe, r)
		prossima = revisione
	}
	return righe, prossima, true, elenco.Err()
}

// MassimaRevisione restituisce la revisione più alta salvata, zero se non
// c'è niente.
func (a *Archivio) MassimaRevisione() (int64, error) {
	var massima int64
	err := a.db.QueryRow(`SELECT COALESCE(MAX(revisione), 0) FROM righe`).Scan(&massima)
	return massima, err
}

// Conteggi restituisce quante righe ci sono per tabella.
func (a *Archivio) Conteggi() (map[string]int, error) {
	elenco, err := a.db.Query(`SELECT tabella, COUNT(*) FROM righe GROUP BY tabella`)
	if err != nil {
		return nil, err
	}
	defer elenco.Close()
	conteggi := map[string]int{}
	for elenco.Next() {
		var tabella string
		var n int
		if err := elenco.Scan(&tabella, &n); err != nil {
			return nil, err
		}
		conteggi[tabella] = n
	}
	return conteggi, elenco.Err()
}

// Dispositivi restituisce i dispositivi conosciuti, dal più recente.
func (a *Archivio) Dispositivi() ([]Dispositivo, error) {
	elenco, err := a.db.Query(`SELECT nome, ultima_volta FROM dispositivi`)
	if err != nil {
		return nil, err
	}
	defer elenco.Close()
	dispositivi := []Dispositivo{}
	for elenco.Next() {
		var d Dispositivo
		var ms int64
		if err := elenco.Scan(&d.Nome, &ms); err != nil {
			return nil, err
		}
		d.UltimaVolta = time.UnixMilli(ms).UTC()
		dispositivi = append(dispositivi, d)
	}
	sort.Slice(dispositivi, func(i, j int) bool {
		return dispositivi[i].UltimaVolta.After(dispositivi[j].UltimaVolta)
	})
	return dispositivi, elenco.Err()
}

// Istantanea scrive una copia coerente del database in percorso, anche
// mentre il server lavora.
func (a *Archivio) Istantanea(percorso string) error {
	_, err := a.db.Exec(`VACUUM INTO ?`, percorso)
	return err
}
