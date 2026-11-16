import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';
import 'package:tifaro/features/quaderno/data/chiavi_quaderno.dart';
import 'package:tifaro/features/quaderno/logica/pagina.dart';

import 'supporto.dart';

/// Un'attività finta, con solo i campi che contano nella prova.
Attivita attivita(
  String id, {
  String? genitore,
  int ordine = 0,
  DateTime? scadenza,
  DateTime? fatta,
  DateTime? quaderno,
  bool veloce = false,
  DateTime? creata,
  String descrizione = '',
}) {
  return Attivita(
    id: id,
    titolo: id,
    descrizione: descrizione,
    creataIl: creata ?? DateTime(2026, 11, 1),
    scadenza: scadenza,
    scadenzaConOra: false,
    fattaIl: fatta,
    argomentoId: 'argomento-lavoro',
    genitoreId: genitore,
    ordine: ordine,
    nelCalendario: false,
    giornoQuaderno: quaderno,
    quadernoVeloce: veloce ? true : null,
    aggiornataIl: DateTime(2026, 11, 1),
  );
}

List<String> ids(List<Attivita> elenco) =>
    elenco.map((Attivita a) => a.id).toList();

void main() {
  final DateTime adesso = DateTime(2026, 11, 16, 15, 30);
  final DateTime oggi = DateTime(2026, 11, 16);
  final DateTime ieri = DateTime(2026, 11, 15);
  final DateTime domani = DateTime(2026, 11, 17);

  group('la pagina del giorno', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('urgente', quaderno: oggi, scadenza: oggi),
      attivita('senza-data', quaderno: oggi),
      attivita('fatta-nella-pagina', quaderno: oggi, fatta: adesso),
      attivita('carta', quaderno: oggi, veloce: true),
      attivita('passo', genitore: 'senza-data', fatta: adesso),
      attivita('in-piu', fatta: adesso),
      attivita('fatta-ieri', fatta: ieri),
      attivita('rimasta', quaderno: ieri),
      attivita('rimasta-veloce', quaderno: ieri, veloce: true),
      attivita('rimasta-ma-fatta', quaderno: ieri, fatta: ieri),
      attivita('di-domani', quaderno: domani),
      attivita('altro'),
    ]);
    final PaginaQuaderno p = paginaDelGiorno(indice, oggi, adesso);

    test('le cose del giorno, anche fatte, prima quelle che scadono', () {
      expect(ids(p.principali), <String>[
        'urgente',
        'fatta-nella-pagina',
        'senza-data',
      ]);
      expect(p.piena, isTrue);
    });

    test('le veloci a parte', () {
      expect(ids(p.veloci), <String>['carta']);
    });

    test('fatte in più: non quelle della pagina né le loro sotto', () {
      expect(ids(p.fatteAnche), <String>['in-piu']);
    });

    test('da riscegliere: dei giorni prima e non fatte', () {
      expect(
        ids(p.daRiscegliere),
        unorderedEquals(<String>['rimasta', 'rimasta-veloce']),
      );
    });

    test('la pagina di domani ha le sue', () {
      final PaginaQuaderno d = paginaDelGiorno(indice, domani, adesso);
      expect(ids(d.principali), <String>['di-domani']);
      expect(d.veloci, isEmpty);
      expect(d.fatteAnche, isEmpty);
      expect(d.piena, isFalse);
    });
  });

  group('il prossimo passo', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('redditi'),
      attivita('cu', genitore: 'redditi', ordine: 0, fatta: adesso),
      attivita('caf', genitore: 'redditi', ordine: 1),
      attivita('telefono', genitore: 'caf', ordine: 0),
      attivita('firma', genitore: 'redditi', ordine: 2),
      attivita('sola'),
    ]);

    test('la prima sotto-attività aperta, scendendo', () {
      expect(prossimoPasso(indice, indice['redditi']!)?.id, 'telefono');
    });

    test('nessuno senza sotto-attività aperte', () {
      expect(prossimoPasso(indice, indice['sola']!), isNull);
      expect(prossimoPasso(indice, indice['telefono']!), isNull);
    });

    test('non si mostra se è già nella pagina, o se la cosa è fatta', () {
      final IndiceAttivita doppio = IndiceAttivita(<Attivita>[
        attivita('lunga', quaderno: oggi),
        attivita('passo', genitore: 'lunga', quaderno: oggi),
        attivita('chiusa', quaderno: oggi, fatta: adesso),
        attivita('aperta', genitore: 'chiusa'),
      ]);
      expect(passoDaMostrare(doppio, doppio['lunga']!, oggi), isNull);
      expect(passoDaMostrare(doppio, doppio['lunga']!, domani)?.id, 'passo');
      expect(passoDaMostrare(doppio, doppio['chiusa']!, oggi), isNull);
    });

    test('un ciclo nei dati non lo blocca', () {
      final IndiceAttivita ciclo = IndiceAttivita(<Attivita>[
        attivita('radice'),
        attivita('a', genitore: 'b'),
        attivita('b', genitore: 'a'),
        attivita('figlia', genitore: 'radice'),
      ]);
      expect(prossimoPasso(ciclo, ciclo['radice']!)?.id, 'figlia');
    });
  });

  group('cosa si può scegliere', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('già-oggi', quaderno: oggi),
      attivita('domani', quaderno: domani),
      attivita('scade', scadenza: domani),
      attivita('fatta', fatta: adesso),
      attivita('libera', descrizione: 'Il modulo è in cucina'),
      attivita('sotto', genitore: 'libera'),
    ]);

    test('le da fare non già nella pagina, sotto-attività comprese', () {
      final List<String> scelte = ids(daScegliere(indice, oggi));
      expect(scelte.first, 'scade');
      expect(
        scelte,
        unorderedEquals(<String>['scade', 'domani', 'libera', 'sotto']),
      );
    });

    test('la ricerca guarda anche la descrizione, senza accenti', () {
      expect(ids(daScegliere(indice, oggi, testo: 'modulo E')), <String>[
        'libera',
      ]);
    });
  });

  group('nel database', () {
    late AppDatabase db;

    setUp(() => db = databaseInMemoria());
    tearDown(() => db.close());

    test('una cosa veloce nasce nella pagina, a mezzanotte', () async {
      final String id = await db.attivitaDao.crea(
        titolo: 'Buttare la carta',
        giornoQuaderno: DateTime(2026, 11, 16, 15, 30),
        quadernoVeloce: true,
      );
      final Attivita a = (await db.attivitaDao.trova(id))!;
      expect(a.giornoQuaderno, oggi);
      expect(a.quadernoVeloce, isTrue);
    });

    test('senza giorno non è veloce, e il campo resta vuoto', () async {
      final String id = await db.attivitaDao.crea(
        titolo: 'Leggere',
        quadernoVeloce: true,
      );
      final Attivita a = (await db.attivitaDao.trova(id))!;
      expect(a.giornoQuaderno, isNull);
      expect(a.quadernoVeloce, isNull);
    });

    test('mettere sposta di pagina, togliere svuota', () async {
      final String id = await db.attivitaDao.crea(titolo: 'Chiamare');
      await db.attivitaDao.mettiNelQuaderno(id, oggi, veloce: true);
      await db.attivitaDao.mettiNelQuaderno(
        id,
        DateTime(2026, 11, 17, 9),
        adesso: DateTime.now().add(const Duration(seconds: 1)),
      );
      Attivita a = (await db.attivitaDao.trova(id))!;
      expect(a.giornoQuaderno, domani);
      expect(a.quadernoVeloce, isNull);

      final DateTime prima = a.aggiornataIl;
      await db.attivitaDao.togliDalQuaderno(id);
      a = (await db.attivitaDao.trova(id))!;
      expect(a.giornoQuaderno, isNull);
      expect(a.aggiornataIl.isAfter(prima), isTrue);
    });

    test('la preferenza si ascolta e arriva solo quando cambia', () async {
      final List<String?> visti = <String?>[];
      final sub = db.syncDao
          .osservaPreferenza(ChiaviQuaderno.attivo)
          .listen(visti.add);
      await pumpEventQueue();
      await db.syncDao.impostaPreferenza(ChiaviQuaderno.attivo, 'no');
      await pumpEventQueue();
      // Un'altra preferenza cambia la tabella, ma non questa.
      await db.syncDao.impostaPreferenza('sync.ultima', '1');
      await pumpEventQueue();
      await db.syncDao.impostaPreferenza(ChiaviQuaderno.attivo, null);
      await pumpEventQueue();
      await sub.cancel();
      expect(visti, <String?>[null, 'no', null]);
    });
  });

  testWidgets('nel Quaderno si scelgono le cose del giorno e le veloci', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await tester.runAsync(() async {
      final String redditi = await db.attivitaDao.crea(
        titolo: 'Dichiarazione dei redditi',
      );
      await db.attivitaDao.crea(titolo: 'Trovare la CU', genitoreId: redditi);
      final String dentista = await db.attivitaDao.crea(
        titolo: 'Chiamare il dentista',
      );
      final DateTime ora = DateTime.now();
      await db.attivitaDao.mettiNelQuaderno(
        dentista,
        DateTime(ora.year, ora.month, ora.day - 1),
      );
    });
    await avviaApp(tester, db);

    await tester.tap(find.text('Quaderno'));
    await tester.pumpAndSettle();

    // Rimasta da ieri: si rimette in oggi.
    expect(find.text('Da riscegliere'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(RigaAttivita, 'Chiamare il dentista'),
        matching: find.text('Oggi'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Da riscegliere'), findsNothing);
    expect(find.text('Chiamare il dentista'), findsOneWidget);

    // Si sceglie una cosa lunga: sotto compare il suo prossimo passo.
    await tester.tap(find.text('Scegli un\'altra cosa'));
    await tester.pumpAndSettle();
    expect(find.text('Nuova attività'), findsOneWidget);
    expect(find.text('parte di Dichiarazione dei redditi'), findsOneWidget);
    await tester.tap(find.text('Dichiarazione dei redditi'));
    await tester.pumpAndSettle();
    expect(find.text('Dichiarazione dei redditi'), findsOneWidget);
    expect(find.text('Trovare la CU'), findsOneWidget);
    expect(find.text('Ancora un posto'), findsOneWidget);

    // Una cosa veloce, con la sintassi veloce.
    await tester.enterText(
      find.widgetWithText(TextField, 'Aggiungi una cosa veloce'),
      'buttare la carta',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Buttare la carta'), findsOneWidget);

    // Con la freccia si apre la cattura con il menu, per la tipologia.
    await tester.enterText(
      find.widgetWithText(TextField, 'Aggiungi una cosa veloce'),
      'chiamare il comune',
    );
    await tester.tap(
      find.byTooltip('Più scelte: argomento, tipologia, scadenza'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tipologia'), findsOneWidget);
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(RigaAttivita, 'Chiamare il comune'),
        matching: find.byType(PopupMenuButton<String>),
      ),
      findsOneWidget,
    );

    // Fatta resta nella pagina, barrata, e non va fra le fatte in più.
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(RigaAttivita, 'Buttare la carta'),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buttare la carta'), findsOneWidget);
    expect(
      find.text('Quello che fai fuori dal Quaderno compare qui.'),
      findsOneWidget,
    );

    // La pagina di domani è ancora da preparare.
    await tester.tap(find.text('Domani'));
    await tester.pumpAndSettle();
    expect(find.text('Scegli la prima cosa'), findsOneWidget);
    expect(find.text('Buttare la carta'), findsNothing);
    expect(find.text('Ho fatto anche'), findsNothing);

    await chiudiApp(tester);
  });

  testWidgets('il Quaderno si spegne dalle impostazioni', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);
    expect(find.text('Quaderno'), findsOneWidget);

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Mostra il Quaderno'), 200);
    await tester.tap(find.text('Mostra il Quaderno'));
    await tester.pumpAndSettle();
    // L'app è in italiano: `pageBack` cercherebbe il tooltip «Back».
    await tester.tap(find.byTooltip('Indietro'));
    await tester.pumpAndSettle();

    expect(find.text('Quaderno'), findsNothing);
    expect(find.text('Argomenti'), findsOneWidget);
    final String? valore = await tester.runAsync<String?>(
      () => db.syncDao.preferenza(ChiaviQuaderno.attivo),
    );
    expect(valore, 'no');

    await chiudiApp(tester);
  });

  testWidgets('dal dettaglio si mette nel Quaderno e si toglie', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    final String? id = await tester.runAsync<String>(() async {
      // La pagina di oggi ha già le sue tre cose.
      for (final String titolo in <String>['Uno', 'Due', 'Tre']) {
        final String altra = await db.attivitaDao.crea(titolo: titolo);
        await db.attivitaDao.mettiNelQuaderno(altra, DateTime.now());
      }
      return db.attivitaDao.crea(titolo: 'Chiamare il comune');
    });
    await avviaApp(tester, db);

    await tester.tap(find.text('Chiamare il comune'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quaderno'));
    await tester.pumpAndSettle();
    expect(find.text('Nel Quaderno'), findsOneWidget);

    // Fra le tre cose di oggi non c'è posto, e lo si vede subito.
    final ListTile piena = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Oggi, fra le 3 cose'),
    );
    expect(piena.enabled, isFalse);
    expect(find.text('Ci sono già 3 cose: prima togline una'), findsOneWidget);

    await tester.tap(find.text('Oggi, fra le veloci'));
    await tester.pumpAndSettle();
    expect(find.text('Quaderno: oggi (veloce)'), findsOneWidget);
    final Attivita? messa = await tester.runAsync<Attivita?>(
      () => db.attivitaDao.trova(id!),
    );
    expect(messa?.quadernoVeloce, isTrue);

    await tester.tap(find.byTooltip('Togli dal Quaderno'));
    await tester.pumpAndSettle();
    expect(find.text('Quaderno'), findsOneWidget);
    final Attivita? tolta = await tester.runAsync<Attivita?>(
      () => db.attivitaDao.trova(id!),
    );
    expect(tolta?.giornoQuaderno, isNull);

    await chiudiApp(tester);
  });
}
