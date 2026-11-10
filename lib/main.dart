import 'package:flutter/material.dart';

import 'package:tifaro/app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

/// Avvio: prepara la cartella delle foto, il database e la
/// sincronizzazione, poi mostra l'app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FotoArchivio foto = await FotoArchivio.apri();
  final AppDatabase database = AppDatabase();
  runApp(
    TiFaroApp(
      database: database,
      foto: foto,
      sincronizzatore: Sincronizzatore(db: database, foto: foto),
    ),
  );
}
