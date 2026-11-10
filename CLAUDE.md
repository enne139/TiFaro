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

## Dati

- **Una lettura sola per tutta l'app.** `FonteDati` (in `core/dati_app.dart`)
  legge attività, argomenti, tipologie e foto; le schermate prendono i dati
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

e, se le tabelle sono cambiate, aumentare `schemaVersion` e scrivere la
migrazione in `migration`. Senza migrazione l'app installata non si apre più.

Dentro una `transaction(...)` si legge solo con `get()`: uno stream aspetta
una notifica che arriva dopo il commit, e l'operazione resta appesa.

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
flutter test
```

Le prove con interfaccia usano `test/supporto.dart` e finiscono con
`chiudiApp(tester)`; il database in memoria non va chiuso.

## Verifiche prima di consegnare

- `flutter analyze` senza segnalazioni;
- `flutter test` verde;
- se si è toccato il manifest Android o un plugin: `flutter build apk --debug`.
