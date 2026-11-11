// Il server di TiFaro: tiene allineate le app (telefono, PC) e fa i backup.
//
// Un solo programma, senza dipendenze esterne: dati in SQLite, foto in una
// cartella, configurazione dalle variabili d'ambiente. Si usa dentro un
// container sul NAS (vedi README.md).
package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"syscall"
	"time"
	// Le zone orarie dentro il programma: l'immagine non le ha, e senza i
	// nomi dei backup e i log sarebbero in UTC invece che con TZ.
	_ "time/tzdata"
)

// versione si può sovrascrivere compilando con
// -ldflags "-X main.versione=1.2.3".
var versione = "0.6.0"

// configurazione è quello che si legge dalle variabili d'ambiente.
type configurazione struct {
	token       string
	indirizzo   string
	dati        string
	backup      string
	backupOgni  time.Duration
	backupTieni int
}

func leggiConfigurazione() (configurazione, error) {
	c := configurazione{
		token:       os.Getenv("TIFARO_TOKEN"),
		indirizzo:   valoreOppure("TIFARO_INDIRIZZO", ":8645"),
		dati:        valoreOppure("TIFARO_DATI", "/data"),
		backup:      valoreOppure("TIFARO_BACKUP", "/backup"),
		backupTieni: 30,
		backupOgni:  24 * time.Hour,
	}
	// Un token corto si indovina: meglio fermarsi subito che girare
	// scoperti.
	if len(c.token) < 20 {
		return c, errors.New("TIFARO_TOKEN mancante o troppo corto (servono almeno 20 caratteri; per esempio: openssl rand -hex 24)")
	}
	if v := os.Getenv("TIFARO_BACKUP_OGNI"); v != "" {
		d, err := time.ParseDuration(v)
		if err != nil {
			return c, fmt.Errorf("TIFARO_BACKUP_OGNI non valido (esempi: 24h, 6h, 0 per mai): %w", err)
		}
		c.backupOgni = d
	}
	if v := os.Getenv("TIFARO_BACKUP_TIENI"); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil || n < 1 {
			return c, fmt.Errorf("TIFARO_BACKUP_TIENI deve essere un numero da 1 in su")
		}
		c.backupTieni = n
	}
	return c, nil
}

func valoreOppure(nome, predefinito string) string {
	if v := os.Getenv(nome); v != "" {
		return v
	}
	return predefinito
}

// controllaSalute è il controllo del container: chiede /api/salute al
// server stesso. Esiste perché l'immagine non ha curl né wget.
func controllaSalute() int {
	indirizzo := valoreOppure("TIFARO_INDIRIZZO", ":8645")
	if indirizzo[0] == ':' {
		indirizzo = "127.0.0.1" + indirizzo
	}
	cliente := http.Client{Timeout: 3 * time.Second}
	risposta, err := cliente.Get("http://" + indirizzo + "/api/salute")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	risposta.Body.Close()
	if risposta.StatusCode != http.StatusOK {
		return 1
	}
	return 0
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "salute" {
		os.Exit(controllaSalute())
	}
	log.SetFlags(log.LstdFlags | log.Lmsgprefix)
	log.SetPrefix("tifaro: ")

	c, err := leggiConfigurazione()
	if err != nil {
		log.Fatal(err)
	}
	if err := os.MkdirAll(c.dati, 0o755); err != nil {
		log.Fatalf("cartella dei dati: %v", err)
	}
	archivio, err := ApriArchivio(filepath.Join(c.dati, "tifaro.sqlite"), filepath.Join(c.dati, "foto"))
	if err != nil {
		log.Fatal(err)
	}
	defer archivio.Chiudi()

	backup := NuovoBackup(archivio, c.backup, c.backupOgni, c.backupTieni)
	ctx, ferma := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer ferma()
	go backup.Ciclo(ctx)

	server := &http.Server{
		Addr:              c.indirizzo,
		Handler:           NuovaAPI(archivio, backup, c.token),
		ReadHeaderTimeout: 10 * time.Second,
	}
	go func() {
		<-ctx.Done()
		// Chi sta sincronizzando ha qualche secondo per finire.
		chiusura, annulla := context.WithTimeout(context.Background(), 10*time.Second)
		defer annulla()
		server.Shutdown(chiusura)
	}()

	log.Printf("versione %s in ascolto su %s, dati in %s, backup in %s (ogni %s, tiene %d copie)",
		versione, c.indirizzo, c.dati, c.backup, c.backupOgni, c.backupTieni)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
	log.Print("fermato")
}
