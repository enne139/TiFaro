import 'package:flutter/material.dart';

import 'package:tifaro/app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/calendario/allineatore_calendario.dart';
import 'package:tifaro/features/calendario/calendario_dispositivo.dart';
import 'package:tifaro/features/notifiche/notifiche_dispositivo.dart';
import 'package:tifaro/features/notifiche/pianificatore_notifiche.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

/// Avvio: prepara la cartella delle foto, il database, la sincronizzazione,
/// il calendario e gli avvisi, poi mostra l'app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FotoArchivio foto = await FotoArchivio.apri();
  final AppDatabase database = AppDatabase();
  final NotificheDispositivo? dispositivoAvvisi =
      NotificheDispositivo.perQuestoDispositivo();
  final PianificatoreNotifiche? notifiche = dispositivoAvvisi == null
      ? null
      : PianificatoreNotifiche(db: database, dispositivo: dispositivoAvvisi);
  // Prima di mostrare l'app: se l'ha aperta un avviso, deve saperlo subito.
  await notifiche?.avvia();
  runApp(
    TiFaroApp(
      database: database,
      foto: foto,
      sincronizzatore: Sincronizzatore(db: database, foto: foto),
      allineatore: AllineatoreCalendario(
        db: database,
        dispositivo: const CalendarioAndroid(),
      ),
      notifiche: notifiche,
    ),
  );
}
