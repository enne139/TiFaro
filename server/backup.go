package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"
)

// Backup fa le copie di sicurezza: un'istantanea del database a ogni giro,
// tenendo le ultime, e la copia delle foto nuove (DECISIONI.md, voce 020).
type Backup struct {
	archivio *Archivio
	// Cartella è dove finiscono le copie. Conviene che stia su un altro
	// disco rispetto ai dati.
	Cartella string
	// Ogni quanto farne una; zero vuol dire mai da solo, solo a richiesta.
	Ogni time.Duration
	// Quante istantanee del database tenere.
	Tieni int

	mu     sync.Mutex
	ultimo time.Time
}

const (
	prefissoCopia = "tifaro-"
	suffissoCopia = ".sqlite"
)

// NuovoBackup prepara i backup e ricorda quando è stato fatto l'ultimo,
// guardando le copie già presenti nella cartella.
func NuovoBackup(a *Archivio, cartella string, ogni time.Duration, tieni int) *Backup {
	b := &Backup{archivio: a, Cartella: cartella, Ogni: ogni, Tieni: tieni}
	if copie, err := b.Copie(); err == nil && len(copie) > 0 {
		if info, err := os.Stat(filepath.Join(cartella, copie[len(copie)-1])); err == nil {
			b.ultimo = info.ModTime()
		}
	}
	return b
}

// Ultimo restituisce quando è stato fatto l'ultimo backup; zero se mai.
func (b *Backup) Ultimo() time.Time {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.ultimo
}

// Copie restituisce i nomi delle istantanee nella cartella, dalla più
// vecchia. Il nome contiene la data, quindi l'ordine alfabetico è quello del
// tempo.
func (b *Backup) Copie() ([]string, error) {
	voci, err := os.ReadDir(b.Cartella)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	var copie []string
	for _, v := range voci {
		nome := v.Name()
		if !v.IsDir() && strings.HasPrefix(nome, prefissoCopia) && strings.HasSuffix(nome, suffissoCopia) {
			copie = append(copie, nome)
		}
	}
	sort.Strings(copie)
	return copie, nil
}

// Esegui fa un backup adesso e restituisce il nome dell'istantanea.
func (b *Backup) Esegui(adesso time.Time) (string, error) {
	b.mu.Lock()
	defer b.mu.Unlock()

	if err := os.MkdirAll(b.Cartella, 0o755); err != nil {
		return "", err
	}
	nome := prefissoCopia + adesso.Format("20060102-150405") + suffissoCopia
	finale := filepath.Join(b.Cartella, nome)
	// Prima con un nome provvisorio, poi rinominata: una copia interrotta a
	// metà non deve mai sembrare un backup buono.
	provvisoria := finale + ".parziale"
	os.Remove(provvisoria)
	if err := b.archivio.Istantanea(provvisoria); err != nil {
		os.Remove(provvisoria)
		return "", fmt.Errorf("istantanea del database: %w", err)
	}
	if err := os.Rename(provvisoria, finale); err != nil {
		return "", err
	}
	if err := copiaFotoNuove(b.archivio.Foto, filepath.Join(b.Cartella, "foto")); err != nil {
		return "", fmt.Errorf("copia delle foto: %w", err)
	}
	if err := b.ruota(); err != nil {
		return "", fmt.Errorf("pulizia delle copie vecchie: %w", err)
	}
	b.ultimo = adesso
	return nome, nil
}

// ruota toglie le istantanee più vecchie oltre le ultime Tieni.
func (b *Backup) ruota() error {
	if b.Tieni <= 0 {
		return nil
	}
	copie, err := b.Copie()
	if err != nil {
		return err
	}
	for len(copie) > b.Tieni {
		if err := os.Remove(filepath.Join(b.Cartella, copie[0])); err != nil {
			return err
		}
		copie = copie[1:]
	}
	return nil
}

// copiaFotoNuove copia in destinazione le foto che non ci sono ancora.
//
// Le foto non cambiano mai dopo essere state caricate (il nome è un UUID):
// basta copiare quelle nuove, e non se ne cancella nessuna.
func copiaFotoNuove(sorgente, destinazione string) error {
	if err := os.MkdirAll(destinazione, 0o755); err != nil {
		return err
	}
	voci, err := os.ReadDir(sorgente)
	if err != nil {
		return err
	}
	for _, v := range voci {
		if v.IsDir() || strings.HasSuffix(v.Name(), ".parziale") {
			continue
		}
		arrivo := filepath.Join(destinazione, v.Name())
		if _, err := os.Stat(arrivo); err == nil {
			continue
		}
		if err := copiaFile(filepath.Join(sorgente, v.Name()), arrivo); err != nil {
			return err
		}
	}
	return nil
}

// copiaFile copia un file passando da un nome provvisorio.
func copiaFile(da, a string) error {
	in, err := os.Open(da)
	if err != nil {
		return err
	}
	defer in.Close()
	provvisorio := a + ".parziale"
	out, err := os.Create(provvisorio)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		os.Remove(provvisorio)
		return err
	}
	if err := out.Close(); err != nil {
		os.Remove(provvisorio)
		return err
	}
	return os.Rename(provvisorio, a)
}

// Ciclo fa un backup ogni Ogni finché ctx non finisce.
//
// Controlla ogni dieci minuti se è ora, invece di dormire per tutto
// l'intervallo: se il NAS resta spento o sospeso, il backup arriva appena si
// riaccende e non un giorno dopo.
func (b *Backup) Ciclo(ctx context.Context) {
	if b.Ogni <= 0 {
		return
	}
	controlla := func() {
		if time.Since(b.Ultimo()) < b.Ogni {
			return
		}
		nome, err := b.Esegui(time.Now())
		if err != nil {
			log.Printf("backup non riuscito: %v", err)
			return
		}
		log.Printf("backup fatto: %s", nome)
	}
	controlla()
	orologio := time.NewTicker(10 * time.Minute)
	defer orologio.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-orologio.C:
			controlla()
		}
	}
}
