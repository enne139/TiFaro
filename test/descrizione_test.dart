import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';

import 'supporto.dart';

void main() {
  testWidgets('la descrizione si legge formattata e si modifica in Markdown', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await tester.runAsync(
      () => db.attivitaDao.crea(
        titolo: 'Preparare la gita',
        descrizione: '**Portare:**\n- [ ] acqua\n- [x] cartina',
      ),
    );
    await avviaApp(tester, db);

    await tester.tap(find.text('Preparare la gita'));
    await tester.pumpAndSettle();

    // Si legge formattata: niente asterischi, le caselle sono caselle.
    expect(
      find.byKey(const ValueKey<String>('descrizione-formattata')),
      findsOneWidget,
    );
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);

    // Con la matita torna il testo da scrivere, con il Markdown in vista.
    await tester.tap(find.byTooltip('Modifica la descrizione'));
    await tester.pumpAndSettle();
    final Finder campo = find.byKey(
      const ValueKey<String>('campo-descrizione'),
    );
    expect(campo, findsOneWidget);
    await tester.enterText(campo, '# Gita\nsabato *presto*');
    await tester.pump();

    // «Anteprima» la mostra di nuovo formattata e la salva.
    await tester.tap(find.text('Anteprima'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('descrizione-formattata')),
      findsOneWidget,
    );
    expect(find.text('Gita'), findsOneWidget);
    final Attivita salvata = (await tester.runAsync(
      () async => (await db.select(db.elencoAttivita).get()).single,
    ))!;
    expect(salvata.descrizione, '# Gita\nsabato *presto*');

    await chiudiApp(tester);
  });

  testWidgets('senza descrizione c\'è subito il campo per scriverla', (
    WidgetTester tester,
  ) async {
    schermoAlto(tester);
    final AppDatabase db = databaseInMemoria();
    await tester.runAsync(() => db.attivitaDao.crea(titolo: 'Telefonare'));
    await avviaApp(tester, db);

    await tester.tap(find.text('Telefonare'));
    await tester.pumpAndSettle();
    final Finder campo = find.byKey(
      const ValueKey<String>('campo-descrizione'),
    );
    expect(campo, findsOneWidget);

    // Scrivendo la prima lettera il campo resta aperto.
    await tester.tap(campo);
    await tester.pump();
    await tester.enterText(campo, 'chiedere al **fornitore**');
    await tester.pump();
    expect(campo, findsOneWidget);
    expect(find.text('Anteprima'), findsOneWidget);

    await chiudiApp(tester);
  });
}
