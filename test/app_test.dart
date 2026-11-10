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
}
