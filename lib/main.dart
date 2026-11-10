import 'package:flutter/material.dart';

import 'package:tifaro/app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';

/// Avvio: prepara la cartella delle foto e il database, poi mostra l'app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FotoArchivio foto = await FotoArchivio.apri();
  runApp(TiFaroApp(database: AppDatabase(), foto: foto));
}
