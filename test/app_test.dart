import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';

import 'supporto.dart';

void main() {
  testWidgets('dalla cattura veloce all\'albero dell\'argomento', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = databaseInMemoria();
    await avviaApp(tester, db);

    // All'inizio non scade niente.
    expect(find.text('Niente in scadenza'), findsOneWidget);

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

    // E nell'albero dell'argomento Ambulanza.
    await tester.tap(find.text('Argomenti').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Ambulanza'));
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
}
