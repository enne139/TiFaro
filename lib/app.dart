import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/sincronizzazione/auto_sync.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';
import 'package:tifaro/navigation/app_shell.dart';

/// Il colore da cui nasce il tema: il blu del mare di notte, dove si
/// accende un faro.
const Color _coloreBase = Color(0xFF1E4F8C);

/// L'app TiFaro.
class TiFaroApp extends StatelessWidget {
  const TiFaroApp({
    required this.database,
    required this.foto,
    this.sincronizzatore,
    super.key,
  });

  final AppDatabase database;
  final FotoArchivio foto;

  /// La sincronizzazione con il server; senza, l'app lavora solo in locale
  /// (succede nelle prove).
  final Sincronizzatore? sincronizzatore;

  @override
  Widget build(BuildContext context) {
    final Sincronizzatore? sync = sincronizzatore;
    final Widget app = MaterialApp(
      title: 'TiFaro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _coloreBase),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _coloreBase,
          brightness: Brightness.dark,
        ),
      ),
      // In italiano anche le parti di Flutter: calendario, orologio,
      // pulsanti delle finestre.
      locale: const Locale('it'),
      supportedLocales: const <Locale>[Locale('it')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // I dati stanno sopra il Navigator, così li vedono anche le pagine
      // aperte sopra e le finestre (DECISIONI.md, voce 012).
      builder: (BuildContext context, Widget? child) =>
          FonteDati(child: child ?? const SizedBox.shrink()),
      home: const AppShell(),
    );
    return AppScope(
      database: database,
      foto: foto,
      sync: sync,
      child: sync == null ? app : AutoSync(sincronizzatore: sync, child: app),
    );
  }
}
