import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';

/// Un database vero ma in memoria: ha i vincoli e le transazioni di SQLite e
/// non lascia file da ripulire.
AppDatabase databaseInMemoria() {
  return AppDatabase.conEsecutore(NativeDatabase.memory());
}

/// Avvia l'app nella prova, con il database indicato e una cartella
/// temporanea per le foto.
Future<void> avviaApp(WidgetTester tester, AppDatabase db) async {
  final Directory cartella = Directory.systemTemp.createTempSync('tifaro_');
  addTearDown(() => cartella.deleteSync(recursive: true));
  await tester.pumpWidget(
    TiFaroApp(database: db, foto: FotoArchivio(cartella)),
  );
  await tester.pumpAndSettle();
}

/// Smonta l'app, da chiamare in fondo a ogni prova con interfaccia.
///
/// Chiudere gli abbonamenti agli stream di drift mette in coda un timer a
/// durata zero: smontando qui, il timer scatta dentro la prova invece di
/// risultare pendente alla fine. Il database non si chiude: `close()`
/// aspetterebbe una coda che l'orologio finto delle prove non fa avanzare.
Future<void> chiudiApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// Allunga lo schermo di prova, così fogli e menu stanno interi.
///
/// Lo schermo predefinito delle prove è 800x600: con il menu della cattura
/// aperto, il pulsante «Aggiungi» finirebbe fuori e non si potrebbe
/// toccare. Il telefono vero è più alto, e il foglio scorre comunque.
void schermoAlto(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
