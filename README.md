# TiFaro

Le cose da fare, a modo mio: attività divise in sotto-attività (a qualunque
profondità), argomenti, tipologie, scadenze e foto, con una cattura veloce
che capisce una riga scritta di corsa.

App Flutter per Android e Linux, con un server Go sul NAS che tiene
allineati telefono e PC e fa i backup. Sul telefono, le attività «nel
calendario» diventano eventi del calendario scelto (anche Google Calendar).

## Cosa fa

- **Attività ad albero:** ogni attività può avere sotto-attività, che a loro
  volta ne hanno altre. Chi ha sotto-attività mostra l'avanzamento (2/5);
  chiudendola, l'app chiede se chiudere anche quelle aperte.
- **Argomenti** (Lavoro, Personale, Ambulanza…): dove sta un'attività. Le
  sotto-attività prendono quello della principale.
- **Tipologie** (Telefonata, Acquisto, Burocrazia…): che genere di cosa è. La
  schermata Tipologie raggruppa quelle simili da tutti gli argomenti e da
  qualunque livello, per farle tutte insieme.
- **Campi:** cosa fare, descrizione, data di creazione, scadenza (con l'ora
  facoltativa), "nel calendario", foto.
- **Schermate:** Oggi (scadute, oggi, prossimi 7 giorni e, in fondo, le
  attività senza scadenza in ordine di creazione), Argomenti (albero
  da aprire, per un argomento o per tutti insieme con «Tutte»), Tipologie,
  Modelli, Fatte, Cestino (con ripristino), Ricerca, Impostazioni
  (argomenti, tipologie e server).
- **Cattura veloce**, senza AI: una riga come

  ```text
  comprare guanti nitrile #ambulanza @acquisti venerdì 18:00 !cal
  ```

  | Scrivi | Diventa |
  |---|---|
  | `#ambulanza` (anche `#amb`) | argomento |
  | `@acquisti` | tipologia (creata se non c'è) |
  | `oggi`, `domani`, `dopodomani`, `lunedì`…`domenica` | scadenza |
  | `15/11`, `15/11/2027`, `tra 3 giorni`, `fra una settimana`, `tra 2 mesi` | scadenza |
  | `18:00`, `alle 18` | ora della scadenza |
  | `!cal` | da mettere nel calendario |
  | `/turno` | crea dal modello «Turno», con le sue sotto-attività |

  Il resto è il titolo. Prima di salvare si vede cosa è stato capito.
- **Menu delle scelte:** la freccia accanto alla riga apre un menu per
  scegliere modello, argomento, tipologia, scadenza, ora e calendario senza
  scrivere niente. Quello che si sceglie dal menu vale più di quello che si
  scrive.
- **Modelli:** stampi per le cose che si ripetono. Un modello crea
  un'attività con le sue sotto-attività già pronte, a qualunque profondità,
  con scadenze relative: la principale "3 giorni dopo la creazione", le
  sotto-attività "1 giorno prima della principale". Si creano da zero
  (menu a sinistra → Modelli) o da un'attività esistente con «Salva come
  modello»; si usano con `/nome`, dal menu della cattura o dal pulsante
  accanto al modello. Nell'editor, `+2` e `-1` danno i giorni rispetto alla
  principale. **Variabili:** un nome tra graffe, come `Turno a {luogo}`, nel
  nome, nella descrizione o nelle sotto-attività del modello; la cattura
  veloce lo chiede quando si usa il modello. `{data}` (la scadenza) e
  `{oggi}` si riempiono da sole.
- **Dal tasto Condividi di Android:** una foto o un testo da un'altra app
  aprono la cattura veloce già compilata.
- **Sincronizzazione e backup:** con il server sul NAS ([server/](server/)),
  telefono e PC vedono le stesse attività, foto comprese. L'app lavora anche
  senza rete e si allinea quando raggiunge il server: all'apertura, ogni
  cinque minuti e poco dopo ogni modifica. Il server fa un backup al giorno.
  Si collega da Impostazioni → Server; l'icona della nuvola in alto dice
  com'è andata e, toccandola, sincronizza subito.
- **Calendario (Android):** in Impostazioni → Calendario si sceglie un
  calendario del telefono; ogni attività da fare «nel calendario» e con una
  scadenza diventa un evento (tutto il giorno, o di un'ora se la scadenza ha
  l'ora), con il colore dell'argomento. Cambiando titolo o data l'evento si
  aggiorna, facendo l'attività sparisce. Se il calendario è di un account
  Google, è Android a portarlo su Google Calendar. Le attività segnate dal PC
  arrivano nel calendario quando il telefono si sincronizza.

## Fasi

1. App da sola, senza server — **fatta**
2. Modelli, e il menu delle scelte nella cattura — **fatta**
3. Server Go sul NAS, sincronizzazione, backup, versione Linux — **fatta**
4. Calendario, dal telefono — **fatta**
5. Notifiche, release dell'APK per Obtainium, esportazione

Le scelte, con il perché, in [DECISIONI.md](DECISIONI.md).

## Comandi

```sh
flutter run -d linux            # sul PC
flutter run                     # sul telefono collegato
dart run build_runner build     # dopo ogni modifica a tabelle o DAO
dart run drift_dev make-migrations  # dopo aver cambiato schemaVersion
flutter analyze && flutter test # prima di consegnare
```

## Installazione

Le versioni pronte stanno nelle
[release di GitHub](https://github.com/enne139/TiFaro/releases).

- **Android:** l'APK della release, meglio con
  [Obtainium](https://github.com/ImranR98/Obtainium) puntato su questo
  repository, che avvisa e installa gli aggiornamenti.
- **Linux:** l'archivio `TiFaro-vX.Y.Z-linux-x64.tar.gz` della release;
  estratto, `tifaro/installa.sh` lo mette nel menu delle applicazioni con il
  comando `tifaro`. Rilanciarlo aggiorna; `--togli` lo toglie (i dati
  restano). Dal codice: `strumenti/installa_linux.sh` compila e installa.
- **Server:** l'immagine `ghcr.io/enne139/tifaro-server`, vedi
  [server/README.md](server/README.md).

## Build e rilasci su GitHub

Tre flussi in [.github/workflows/](.github/workflows/):

| Flusso | Quando | Cosa fa |
|---|---|---|
| Prove | a ogni push su `main` e nelle pull request | analisi e prove dell'app, prove del server, prova completa app contro un server vero |
| Rilascio | a ogni tag `vX.Y.Z` (o a mano) | APK firmato e versione Linux, allegati alla release |
| Container | a ogni tag `vX.Y.Z` (costruisce soltanto quando cambia il server) | immagine del server su ghcr.io, per amd64 e arm64 |

**Fare una versione:** aggiornare `version` in `pubspec.yaml` (e
`versione` in `server/main.go`), fare il commit, poi
`git tag vX.Y.Z && git push origin vX.Y.Z`.

**Firma dell'APK:** il flusso di rilascio legge la chiave da quattro segreti
del repository (Settings → Secrets and variables → Actions); senza, una
release vera si ferma, perché un APK firmato con una chiave di prova non si
potrebbe aggiornare. Si può usare la stessa chiave delle altre app.

| Segreto | Cosa contiene |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | l'archivio della chiave, `base64 -w0 chiave.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | la password dell'archivio |
| `ANDROID_KEY_ALIAS` | l'alias della chiave |
| `ANDROID_KEY_PASSWORD` | la password della chiave |

Una chiave nuova: `keytool -genkey -v -keystore chiave.jks -keyalg RSA
-keysize 2048 -validity 10000 -alias tifaro` (da conservare: senza, gli
aggiornamenti non si installano più).

## Dove stanno i dati

Un database SQLite (`tifaro.sqlite`) e la cartella `foto/` nella cartella dei
dati dell'app: su Linux `~/.local/share/com.enne139.tifaro/`.
