# TiFaro

Le cose da fare, a modo mio: attività divise in sotto-attività (a qualunque
profondità), argomenti, tipologie, scadenze e foto, con una cattura veloce
che capisce una riga scritta di corsa.

App Flutter per Android e Linux. In futuro un server Go sul NAS terrà
allineati telefono e PC e metterà gli eventi su Google Calendar.

## Cosa fa (fase 1)

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

  Il resto è il titolo. Prima di salvare si vede cosa è stato capito.
- **Dal tasto Condividi di Android:** una foto o un testo da un'altra app
  aprono la cattura veloce già compilata.

## Fasi

1. App da sola, senza server — **fatta**
2. Modelli: attività con sotto-attività già pronte, scadenze relative
3. Server Go sul NAS e sincronizzazione
4. Google Calendar, tramite il server
5. Notifiche, release dell'APK per Obtainium, esportazione

Le scelte, con il perché, in [DECISIONI.md](DECISIONI.md).

## Comandi

```sh
flutter run -d linux            # sul PC
flutter run                     # sul telefono collegato
dart run build_runner build     # dopo ogni modifica a tabelle o DAO
flutter analyze && flutter test # prima di consegnare
```

## Dove stanno i dati

Un database SQLite (`tifaro.sqlite`) e la cartella `foto/` nella cartella dei
dati dell'app: su Linux `~/.local/share/com.enne139.tifaro/`.
