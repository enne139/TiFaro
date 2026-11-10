# Server di TiFaro

Tiene allineate le app (telefono Android e PC Linux) e fa i backup. Un solo
programma in Go, in un container da 15 MB: dati in SQLite, foto in una
cartella, nessun altro servizio.

## Cosa fa

- **Sincronizzazione:** ogni app manda le righe cambiate e riceve quelle
  cambiate dalle altre. Se la stessa attività è stata modificata su due
  dispositivi, vince la modifica più recente. Il server non sa cosa sia
  un'attività: tiene le righe come le manda l'app (DECISIONI.md, voce 019).
- **Foto:** caricate una volta, poi ogni app scarica quelle che le mancano.
- **Backup:** una copia del database al giorno (si tengono le ultime 30) e
  la copia delle foto nuove, in una cartella a parte. Uno si può chiedere
  anche dall'app: Impostazioni → Backup sul server → «Fanne uno».

## Installazione sul NAS (Dockge)

L'immagine la costruisce GitHub e la pubblica su
`ghcr.io/enne139/tifaro-server`: il NAS deve solo scaricarla.

1. Su Dockge, nuovo stack `tifaro` con il contenuto di
   [docker-compose.yml](docker-compose.yml).
2. Nel `.env` dello stack:

   ```sh
   TIFARO_TOKEN=          # openssl rand -hex 24  (è la password delle app)
   PUID=1000              # output di "id" sul NAS
   PGID=1000
   TIFARO_BACKUP_LOCATION=/percorso/su/un/altro/disco   # facoltativo
   ```

   Se il repository su GitHub è privato, anche l'immagine lo è: una volta,
   sul NAS, `docker login ghcr.io` con un token GitHub che abbia il solo
   permesso `read:packages`.
3. Avvia lo stack.
4. Controlla: `http://<indirizzo del NAS>:8645/api/salute` deve rispondere
   `{"ok":true,...}`.
5. Nell'app: Impostazioni → Server → indirizzo
   `http://<indirizzo del NAS>:8645` e il token → «Prova» → «Salva».

## Aggiornare

Ogni tag `vX.Y.Z` pubblicato su GitHub produce l'immagine `X.Y.Z` e
`latest`. Sul NAS, «Aggiorna» su Dockge, oppure nel terminale dello stack:

```sh
docker compose pull && docker compose up -d
```

Per restare su una versione precisa: `TIFARO_VERSIONE=0.3.0` nel `.env`.

## Ripristinare un backup

1. Ferma lo stack.
2. Copia la copia scelta al posto del database:
   `cp backup/tifaro-AAAAMMGG-hhmmss.sqlite data/tifaro.sqlite` e togli
   `data/tifaro.sqlite-wal` e `data/tifaro.sqlite-shm` se ci sono.
3. Se servono, ricopia le foto: `cp -n backup/foto/* data/foto/`.
4. Riavvia. Le app si accorgono che il server è tornato indietro e
   rimandano quello che hanno di più recente.

## Variabili

| Variabile | Predefinita | A cosa serve |
|---|---|---|
| `TIFARO_TOKEN` | — | obbligatoria, almeno 20 caratteri |
| `TIFARO_BACKUP_OGNI` | `24h` | ogni quanto fare un backup (`6h`, `0` = mai da solo) |
| `TIFARO_BACKUP_TIENI` | `30` | quante copie del database tenere |
| `TZ` | `Europe/Rome` | fuso orario per log e nomi dei backup |
| `TIFARO_DATI` | `/data` | cartella dei dati, nel container |
| `TIFARO_BACKUP` | `/backup` | cartella dei backup, nel container |
| `TIFARO_INDIRIZZO` | `:8645` | dove ascoltare, nel container |

## API

Tutte con `Authorization: Bearer <token>`, tranne `/api/salute`.

| | |
|---|---|
| `GET /api/salute` | il server c'è |
| `POST /api/sync` | `{dispositivo, dalla, limite, modifiche}` → `{righe, revisione, fine, massima, rifiutate, ripartire}` |
| `GET /api/stato` | righe per tabella, foto, dispositivi, ultimo backup |
| `POST /api/backup` | fa un backup adesso |
| `GET\|HEAD\|PUT /api/foto/{nome}` | le foto |

## Sviluppo

```sh
go test ./...                    # prove del server
go run .                         # con TIFARO_TOKEN, TIFARO_DATI e TIFARO_BACKUP impostati
podman build -t tifaro-server .  # l'immagine, in locale
```

La prova completa con l'app (due dispositivi finti contro un server vero)
sta in `../test/sincronizzazione_server_test.dart`: con un server acceso,

```sh
TIFARO_SERVER_PROVA=http://localhost:8645 TIFARO_TOKEN_PROVA=<token> \
  flutter test test/sincronizzazione_server_test.dart
```
