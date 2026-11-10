# Regole di lavoro su TiFaro

App Flutter per le cose da fare (Android e Linux). Cosa fa e a che punto è:
[README.md](README.md). Perché è fatta così: [DECISIONI.md](DECISIONI.md).

## Lingua e commenti

Tutto in italiano: codice, commenti, messaggi, commit.

Ogni file, classe, metodo pubblico e campo ha un commento `///` che dice **a
cosa serve**. Dentro i metodi, un `//` su ogni passaggio non ovvio: il
*perché* di una scelta, un vincolo, un caso limite. Quando il codice cambia si
aggiorna anche il commento.

## Registro delle decisioni

Ogni scelta di progettazione va in [DECISIONI.md](DECISIONI.md) con la
motivazione, nel formato già usato (numero, data, contesto, decisione,
motivazione, alternative scartate). Le voci non si riscrivono: se una scelta
cambia se ne aggiunge una nuova che dice quale supera.

## Struttura

- `lib/core/`: database, aspetto (colori e icone), date, testi, dati comuni,
  widget riusabili.
- `lib/features/<funzionalità>/`: una cartella per funzionalità; le tabelle e
  i DAO in `data/`, la logica pura in `logica/`.
- `lib/navigation/`: l'impalcatura con le sezioni.
- `lib/features/modelli/`: i modelli; `logica/` ha le scadenze relative.
- `lib/features/sincronizzazione/`: la sincronizzazione con il server.
- `server/`: il server in Go, modulo a parte con le sue prove (voce 019).
- `lib/features/cattura/composizione.dart`: come si uniscono testo, menu e
  modello nella cattura veloce (voce 018). Una regola nuova va lì, con la
  sua prova in `test/composizione_test.dart`.

## Dati

- **Una lettura sola per tutta l'app.** `FonteDati` (in `core/dati_app.dart`)
  legge attività, argomenti, tipologie, foto, modelli e voci; le schermate prendono i dati
  con `DatiApp.of(context)` e li filtrano in Dart con le funzioni di
  `features/attivita/logica/`. Non aprire stream nelle schermate (l'unica
  eccezione è il cestino). Voce 012.
- **Mai cancellare righe.** Si scrive la data in `cancellataIl` (o
  `cancellatoIl`): serve al cestino e servirà alla sincronizzazione. Ogni
  scrittura aggiorna anche `aggiornataIl`. Voce 003.
- **Id:** UUID, tranne argomenti e tipologie del primo avvio, che hanno id
  fissi. Voce 004.
- Nei gestori di eventi si usa `DatiApp.leggi(context)`, che non registra
  dipendenze.

Dopo **ogni** modifica a una tabella o a un DAO:

```sh
dart run build_runner build
```

Se le tabelle sono cambiate (voce 015):

1. aumentare `schemaVersion`;
2. `dart run drift_dev make-migrations`: fotografa il nuovo schema in
   `drift_schemas/` e rigenera `app_database.steps.dart` e gli aiuti in
   `test/drift/`;
3. scrivere il passo `fromNToM` in `stepByStep` dentro `migration`;
4. `flutter test test/drift`: verifica che da ogni versione vecchia si arrivi
   esattamente allo schema nuovo.

Senza migrazione l'app installata non si apre più. Le fotografie in
`drift_schemas/` non si toccano a mano.

Dentro una `transaction(...)` si legge solo con `get()`: uno stream aspetta
una notifica che arriva dopo il commit, e l'operazione resta appesa.

## Sincronizzazione

- **Ogni modifica a una riga esistente** scrive la data di modifica presa da
  `dataDiModifica` / `dataDiModificaPerId` (`core/database/data_modifica.dart`),
  mai `DateTime.now()` diretto: deve stare almeno un secondo dopo quella che
  la riga ha già, altrimenti con un orologio indietro la modifica perde
  contro la versione che aveva sostituito (voce 021).
- **Una tabella nuova da sincronizzare** va aggiunta all'elenco `tabelle` di
  `SyncDao`, nell'ordine giusto (dopo quelle a cui rimanda), e deve avere
  `id`, `aggiornataIl`/`aggiornatoIl` e `cancellataIl`/`cancellatoIl`. Il
  server non va toccato: tiene le righe così come arrivano.
- Le tabelle `sync_note` e `preferenze` restano su ogni dispositivo e non si
  sincronizzano.
- Mai cancellare righe di tabelle sincronizzate: una cancellazione vera non
  arriverebbe agli altri dispositivi.

## Interfaccia

- **Ogni gesto ha un pulsante.** L'app gira anche sul computer: niente azioni
  solo per trascinamento o pressione prolungata. Voce 014.
- **Gli errori si vedono.** Ogni scrittura nata da un gesto passa da
  `eseguiSegnalandoErrori`; un elenco vuoto mostra `VuotoView` con cosa fare.
- I colori degli argomenti si salvano come indice di `paletteArgomenti`, che
  ricalca i colori di Google Calendar: si allunga in fondo, non si riordina.
  Voce 008.

## Prove

```sh
flutter analyze
flutter test --exclude-tags server
cd server && go vet ./... && go test ./...
```

La prova completa contro un server vero (`test/sincronizzazione_server_test.dart`,
etichetta `server`) parte solo con le variabili `TIFARO_SERVER_PROVA` e
`TIFARO_TOKEN_PROVA`: vedi [server/README.md](server/README.md).

Le prove con interfaccia usano `test/supporto.dart` e finiscono con
`chiudiApp(tester)`; il database in memoria non va chiuso. Dentro una prova
con interfaccia, le letture e scritture dirette sul database (prepararlo,
controllarlo) vanno in `tester.runAsync(...)`: con l'orologio finto della
prova uno stream di drift non risponde mai e la prova resta appesa.

## Verifiche prima di consegnare

- `flutter analyze` senza segnalazioni;
- `flutter test --exclude-tags server` verde;
- se si è toccato `server/` o la sincronizzazione: `go test ./...` in
  `server/` e la prova completa contro un server acceso;
- se si è toccato il manifest Android o un plugin: `flutter build apk --debug`.
