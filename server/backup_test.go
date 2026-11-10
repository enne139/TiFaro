package main

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestBackupIstantaneeFotoERotazione(t *testing.T) {
	a := archivioDiProva(t)
	a.Applica("telefono", []Riga{riga("attivita", "a1", 1, "da salvare")}, time.Now())
	os.WriteFile(filepath.Join(a.Foto, "11111111-1111-1111-1111-111111111111.jpg"), []byte("foto"), 0o644)

	cartella := t.TempDir()
	b := NuovoBackup(a, cartella, time.Hour, 2)
	inizio := time.Date(2026, 11, 10, 3, 0, 0, 0, time.UTC)
	for i := 0; i < 3; i++ {
		if _, err := b.Esegui(inizio.Add(time.Duration(i) * time.Minute)); err != nil {
			t.Fatal(err)
		}
	}

	copie, _ := b.Copie()
	if len(copie) != 2 || copie[0] != "tifaro-20261110-030100.sqlite" {
		t.Fatalf("copie tenute: %v", copie)
	}
	if b.Ultimo() != inizio.Add(2*time.Minute) {
		t.Fatalf("ultimo backup %v", b.Ultimo())
	}

	// L'istantanea si apre ed è completa.
	copia, err := ApriArchivio(filepath.Join(cartella, copie[1]), t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	defer copia.Chiudi()
	if righe, _, _, _ := copia.Dopo(0, 10); len(righe) != 1 || titoloDi(t, righe[0]) != "da salvare" {
		t.Fatalf("righe nella copia: %v", righe)
	}

	// La foto è stata copiata.
	if dati, err := os.ReadFile(filepath.Join(cartella, "foto", "11111111-1111-1111-1111-111111111111.jpg")); err != nil || string(dati) != "foto" {
		t.Fatalf("foto nel backup: %q, %v", dati, err)
	}

	// Riaprendo, si ricorda dell'ultimo backup.
	if NuovoBackup(a, cartella, time.Hour, 2).Ultimo().IsZero() {
		t.Fatal("l'ultimo backup andava ritrovato dalla cartella")
	}
}
