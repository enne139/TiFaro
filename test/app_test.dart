import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';

import 'supporto.dart';

void main() {
  testWidgets('dalla cattura veloce all\'albero dell\'argomento', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);

    // All'inizio non c'è niente da fare.
    expect(find.text('Niente da fare'), findsOneWidget);

    // Cattura veloce con la sintassi.
    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'comprare guanti #ambulanza @acquisti domani',
    );
    await tester.pump();
    // L'anteprima dice cosa si è capito.
    expect(find.text('Ambulanza'), findsOneWidget);
    expect(find.text('Acquisto'), findsOneWidget);
    expect(find.text('domani'), findsOneWidget);

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    // Compare in Oggi, fra le prossime.
    expect(find.text('Comprare guanti'), findsOneWidget);
    expect(find.text('Prossimi 7 giorni'), findsOneWidget);

    // Un'attività senza data finisce in fondo, fra quelle senza scadenza.
    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'leggere il manuale');
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
    expect(find.text('Senza scadenza'), findsOneWidget);
    expect(find.text('Leggere il manuale'), findsOneWidget);

    // In Argomenti si parte da «Tutte», con l'argomento scritto sulla riga.
    await tester.tap(find.text('Argomenti').last);
    await tester.pumpAndSettle();
    // Due: i guanti (Ambulanza) e il manuale (Personale).
    expect(find.text('Tutte 2'), findsOneWidget);
    expect(find.text('Comprare guanti'), findsWidgets);
    expect(find.text('Ambulanza'), findsOneWidget);

    // E nell'albero dell'argomento Ambulanza.
    await tester.tap(find.text('Ambulanza 1'));
    await tester.pumpAndSettle();
    expect(find.text('Comprare guanti'), findsWidgets);

    // Nel dettaglio si aggiunge una sotto-attività con la sintassi veloce.
    await tester.tap(find.text('Comprare guanti').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Aggiungi una sotto-attività'),
      'chiedere il preventivo @telefonata',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Chiedere il preventivo'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);

    await chiudiApp(tester);
  });

  testWidgets('la freccia apre il menu e le scelte valgono più del testo', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);

    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'telefonare al medico #ambulanza',
    );
    await tester.tap(find.byTooltip('Scegli i dati da un menu'));
    await tester.pumpAndSettle();

    // Argomento dal menu: Lavoro, al posto di #ambulanza.
    await tester.tap(find.text('Argomento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lavoro').last);
    await tester.pumpAndSettle();

    // Scadenza dal menu: domani.
    await tester.tap(find.text('Scadenza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Domani'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    // Le letture dirette vanno fuori dall'orologio finto della prova.
    final Attivita creata = (await tester.runAsync(
      () => db.attivitaDao.osservaTutte().first,
    ))!.single;
    expect(creata.titolo, 'Telefonare al medico');
    expect(creata.argomentoId, 'argomento-lavoro');
    final DateTime oggi = DateTime.now();
    expect(creata.scadenza, DateTime(oggi.year, oggi.month, oggi.day + 1));

    await chiudiApp(tester);
  });

  testWidgets('/modello crea l\'attività con le sue sotto-attività', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    final String modelloId = (await tester.runAsync(() async {
      final String id = await db.modelliDao.creaModello(
        'Turno in ambulanza',
        argomentoId: 'argomento-ambulanza',
      );
      await db.modelliDao.creaVoce(modelloId: id, titolo: 'Divisa');
      await db.modelliDao.creaVoce(modelloId: id, titolo: 'Zaino');
      return id;
    }))!;
    await avviaApp(tester, db);

    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '/turno');
    await tester.pump();
    expect(
      find.text('Modello: Turno in ambulanza (2 sotto-attività)'),
      findsOneWidget,
    );
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    final List<Attivita> tutte = (await tester.runAsync(
      () => db.attivitaDao.osservaTutte().first,
    ))!;
    final Attivita radice = tutte.singleWhere(
      (Attivita a) => a.genitoreId == null,
    );
    expect(radice.titolo, 'Turno in ambulanza');
    expect(radice.argomentoId, 'argomento-ambulanza');
    expect(radice.modelloId, modelloId);
    expect(
      tutte
          .where((Attivita a) => a.genitoreId == radice.id)
          .map((Attivita a) => a.titolo),
      unorderedEquals(<String>['Divisa', 'Zaino']),
    );

    await chiudiApp(tester);
  });

  testWidgets(
    'con la sincronizzazione ma senza server, l\'app lavora da sola',
    (WidgetTester tester) async {
      schermoAlto(tester);
      final AppDatabase db = databaseInMemoria();
      await avviaApp(tester, db, conSincronizzazione: true);

      // Senza server non c'è l'icona nella barra.
      expect(find.byIcon(Icons.cloud_done_outlined), findsNothing);

      // Le impostazioni lo dicono e offrono di collegarlo.
      final ScaffoldState scaffold = tester.firstState<ScaffoldState>(
        find.byType(Scaffold),
      );
      scaffold.openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Impostazioni'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Server e sincronizzazione'),
        200,
      );
      expect(find.textContaining('Non collegato'), findsOneWidget);

      await chiudiApp(tester);
    },
  );

  testWidgets('le variabili del modello si chiedono nella cattura veloce', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await tester.runAsync(() async {
      final String id = await db.modelliDao.creaModello('Turno a {luogo}');
      await db.modelliDao.creaVoce(modelloId: id, titolo: 'Avvisare {luogo}');
    });
    await avviaApp(tester, db);

    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '/turno');
    await tester.pump();
    expect(find.text('Da completare per «Turno a {luogo}»'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey<String>('variabile-luogo')),
      'Gallarate',
    );
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    final List<Attivita> tutte = (await tester.runAsync(
      () => db.attivitaDao.osservaTutte().first,
    ))!;
    expect(
      tutte.map((Attivita a) => a.titolo),
      unorderedEquals(<String>['Turno a Gallarate', 'Avvisare Gallarate']),
    );
    // Nessun avviso in basso dopo l'aggiunta.
    expect(find.byType(SnackBar), findsNothing);

    await chiudiApp(tester);
  });

  testWidgets('un\'attività che si ripete torna quando la si fa', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);

    await tester.tap(find.text('Nuova'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'pagare la bolletta ogni mese domani',
    );
    await tester.pump();
    expect(find.text('Ogni mese'), findsOneWidget);
    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();
    expect(find.text('Pagare la bolletta'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);

    // Fatta: la prossima volta compare al suo posto, da fare.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    final List<Attivita> tutte = (await tester.runAsync(
      () => db.select(db.elencoAttivita).get(),
    ))!;
    expect(tutte, hasLength(2));
    expect(tutte.where((Attivita a) => a.fattaIl == null), hasLength(1));
    // Scade fra un mese: non è in Oggi (i prossimi 7 giorni) ma fra tutte.
    expect(find.text('Pagare la bolletta'), findsNothing);
    await tester.tap(find.text('Argomenti').last);
    await tester.pumpAndSettle();
    expect(find.text('Pagare la bolletta'), findsOneWidget);

    await chiudiApp(tester);
  });

  testWidgets('Ctrl+N apre la cattura veloce', (WidgetTester tester) async {
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Nuova attività'), findsOneWidget);
    expect(find.text('Aggiungi'), findsOneWidget);

    await chiudiApp(tester);
  });
}
