import 'package:flutter/widgets.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/calendario/allineatore_calendario.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

/// Rende database e archivio delle foto raggiungibili da qualunque punto
/// dell'app.
///
/// È un `InheritedWidget` e non una variabile globale perché così le prove
/// possono metterci un database in memoria e una cartella temporanea, e le
/// schermate non sanno da dove arrivano.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.database,
    required this.foto,
    required super.child,
    this.sync,
    this.allineatore,
    super.key,
  });

  /// Il database dell'app.
  final AppDatabase database;

  /// La cartella delle foto.
  final FotoArchivio foto;

  /// La sincronizzazione con il server; nulla nelle prove che non la
  /// usano.
  final Sincronizzatore? sync;

  /// Il calendario del telefono; nullo nelle prove che non lo usano.
  final AllineatoreCalendario? allineatore;

  static AppScope _di(BuildContext context) {
    final AppScope? scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'Nessun AppScope sopra questo widget.');
    return scope!;
  }

  /// Il database. Non registra dipendenze: non cambia mai durante la vita
  /// dell'app, quindi si può chiamare anche nei gestori di eventi.
  static AppDatabase db(BuildContext context) => _di(context).database;

  /// L'archivio delle foto.
  static FotoArchivio archivio(BuildContext context) => _di(context).foto;

  /// La sincronizzazione, se c'è.
  static Sincronizzatore? sincronizzatore(BuildContext context) =>
      _di(context).sync;

  /// Il calendario del telefono, se c'è.
  static AllineatoreCalendario? calendario(BuildContext context) =>
      _di(context).allineatore;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      database != oldWidget.database ||
      foto != oldWidget.foto ||
      sync != oldWidget.sync ||
      allineatore != oldWidget.allineatore;
}
