# TiFaro

Le cose da fare, a modo mio: attività divise in sotto-attività (a qualunque
profondità), argomenti, tipologie, scadenze e foto, con una cattura veloce
che capisce una riga scritta di corsa.

App Flutter per Android e Linux, con un server Go sul NAS che tiene
allineati telefono e PC e fa i backup. In futuro metterà anche gli eventi su
Google Calendar.

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
- **Schermate:** Oggi (scadute, oggi, prossimi 7 giorni), Argomenti (albero
  da aprire), Tipologie, Fatte, Cestino (con ripristino), Ricerca,
  Impostazioni (argomenti e tipologie).
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
  principale.
- **Dal tasto Condividi di Android:** una foto o un testo da un'altra app
  aprono la cattura veloce già compilata.
- **Sincronizzazione e backup:** con il server sul NAS ([server/](server/)),
  telefono e PC vedono le stesse attività, foto comprese. L'app lavora anche
  senza rete e si allinea quando raggiunge il server: all'apertura, ogni
  cinque minuti e poco dopo ogni modifica. Il server fa un backup al giorno.
  Si collega da Impostazioni → Server; l'icona della nuvola in alto dice
  com'è andata e, toccandola, sincronizza subito.

## Fasi

1. App da sola, senza server — **fatta**
2. Modelli, e il menu delle scelte nella cattura — **fatta**
3. Server Go sul NAS, sincronizzazione, backup, versione Linux — **fatta**
4. Google Calendar, tramite il server
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

- **Linux:** `strumenti/installa_linux.sh` compila la versione definitiva e
  la installa per l'utente, con l'icona nel menu e il comando `tifaro`.
  Rilanciarlo aggiorna; `--togli` la toglie (i dati restano).
- **Android:** per ora l'APK di prova (`flutter build apk`); le release per
  Obtainium arrivano con la fase 5.
- **Server:** vedi [server/README.md](server/README.md).

## Dove stanno i dati

Un database SQLite (`tifaro.sqlite`) e la cartella `foto/` nella cartella dei
dati dell'app: su Linux `~/.local/share/com.enne139.tifaro/`.
