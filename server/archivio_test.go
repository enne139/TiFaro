package main

import (
	"encoding/json"
	"errors"
	"path/filepath"
	"testing"
	"time"
)

// archivioDiProva apre un archivio in una cartella temporanea.
func archivioDiProva(t *testing.T) *Archivio {
	t.Helper()
	cartella := t.TempDir()
	a, err := ApriArchivio(filepath.Join(cartella, "tifaro.sqlite"), filepath.Join(cartella, "foto"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { a.Chiudi() })
	return a
}

func riga(tabella, id string, aggiornata int64, titolo string) Riga {
	dati, _ := json.Marshal(map[string]any{"id": id, "titolo": titolo, "aggiornataIl": aggiornata})
	return Riga{Tabella: tabella, ID: id, Aggiornata: aggiornata, Dati: dati}
}

func titoloDi(t *testing.T, r Riga) string {
	t.Helper()
	var dati struct{ Titolo string }
	if err := json.Unmarshal(r.Dati, &dati); err != nil {
		t.Fatal(err)
	}
	return dati.Titolo
}

func TestVinceLaModificaPiuRecente(t *testing.T) {
	a := archivioDiProva(t)
	adesso := time.Now()

	if _, err := a.Applica("telefono", []Riga{riga("attivita", "a1", 1000, "prima")}, adesso); err != nil {
		t.Fatal(err)
	}
	// Più recente: entra.
	if rif, err := a.Applica("pc", []Riga{riga("attivita", "a1", 2000, "dal pc")}, adesso); err != nil || len(rif) != 0 {
		t.Fatalf("rifiutate %v, errore %v", rif, err)
	}
	// Più vecchia: rifiutata, e torna la versione del server.
	rif, err := a.Applica("telefono", []Riga{riga("attivita", "a1", 1500, "vecchia")}, adesso)
	if err != nil {
		t.Fatal(err)
	}
	if len(rif) != 1 || titoloDi(t, rif[0]) != "dal pc" {
		t.Fatalf("attesa la versione del pc fra le rifiutate, avuto %v", rif)
	}
	// Stessa data: entra (stesso secondo, stesso dispositivo).
	if rif, _ := a.Applica("pc", []Riga{riga("attivita", "a1", 2000, "ancora dal pc")}, adesso); len(rif) != 0 {
		t.Fatalf("a parità di data doveva entrare, rifiutate %v", rif)
	}

	righe, _, _, err := a.Dopo(0, 10)
	if err != nil {
		t.Fatal(err)
	}
	if len(righe) != 1 || titoloDi(t, righe[0]) != "ancora dal pc" {
		t.Fatalf("righe %v", righe)
	}
}

func TestRevisioniEPagine(t *testing.T) {
	a := archivioDiProva(t)
	var righe []Riga
	for i, id := range []string{"a", "b", "c", "d", "e"} {
		righe = append(righe, riga("attivita", id, int64(i), id))
	}
	if _, err := a.Applica("telefono", righe, time.Now()); err != nil {
		t.Fatal(err)
	}

	prima, prossima, fine, err := a.Dopo(0, 2)
	if err != nil || len(prima) != 2 || fine || prossima != 2 {
		t.Fatalf("prima pagina: %d righe, prossima %d, fine %v, errore %v", len(prima), prossima, fine, err)
	}
	seconda, prossima, fine, _ := a.Dopo(prossima, 2)
	if len(seconda) != 2 || fine || prossima != 4 {
		t.Fatalf("seconda pagina: %d righe, prossima %d, fine %v", len(seconda), prossima, fine)
	}
	terza, prossima, fine, _ := a.Dopo(prossima, 2)
	if len(terza) != 1 || !fine || prossima != 5 {
		t.Fatalf("terza pagina: %d righe, prossima %d, fine %v", len(terza), prossima, fine)
	}
	vuota, prossima, fine, _ := a.Dopo(5, 2)
	if len(vuota) != 0 || !fine || prossima != 5 {
		t.Fatalf("niente di nuovo: %d righe, prossima %d, fine %v", len(vuota), prossima, fine)
	}

	// Una modifica sposta la riga in fondo, con una revisione nuova.
	a.Applica("pc", []Riga{riga("attivita", "a", 100, "a2")}, time.Now())
	nuove, prossima, _, _ := a.Dopo(5, 10)
	if len(nuove) != 1 || nuove[0].ID != "a" || prossima != 6 {
		t.Fatalf("dopo la modifica: %v, prossima %d", nuove, prossima)
	}
	if massima, _ := a.MassimaRevisione(); massima != 6 {
		t.Fatalf("massima revisione %d", massima)
	}
}

func TestRigheNonValide(t *testing.T) {
	a := archivioDiProva(t)
	casi := []Riga{
		{Tabella: "Attivita", ID: "a", Dati: json.RawMessage(`{}`)},
		{Tabella: "attivita", ID: "../x", Dati: json.RawMessage(`{}`)},
		{Tabella: "attivita", ID: "a", Dati: json.RawMessage(`[1]`)},
		{Tabella: "attivita", ID: "a", Dati: json.RawMessage(`{rotto`)},
	}
	for _, r := range casi {
		if _, err := a.Applica("x", []Riga{r}, time.Now()); !errors.Is(err, ErrRigaNonValida) {
			t.Errorf("%+v: atteso ErrRigaNonValida, avuto %v", r, err)
		}
	}
	// Una riga cattiva ferma tutto il gruppo: niente salvato a metà.
	gruppo := []Riga{riga("attivita", "buona", 1, "x"), casi[0]}
	a.Applica("x", gruppo, time.Now())
	if righe, _, _, _ := a.Dopo(0, 10); len(righe) != 0 {
		t.Fatalf("salvate %d righe di un gruppo non valido", len(righe))
	}
}

func TestDispositivi(t *testing.T) {
	a := archivioDiProva(t)
	a.Applica("telefono", nil, time.UnixMilli(1000))
	a.Applica("pc", nil, time.UnixMilli(2000))
	d, err := a.Dispositivi()
	if err != nil || len(d) != 2 || d[0].Nome != "pc" {
		t.Fatalf("dispositivi %v, errore %v", d, err)
	}
}
