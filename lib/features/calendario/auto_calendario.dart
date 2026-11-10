import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/widgets.dart';

import 'package:tifaro/features/calendario/allineatore_calendario.dart';

/// Riallinea il calendario da solo: all'apertura, al ritorno in primo piano
/// e poco dopo ogni modifica alle attività o agli argomenti, comprese
/// quelle arrivate con la sincronizzazione da un altro dispositivo.
///
/// Su un dispositivo senza calendario (Linux) non fa niente.
class AutoCalendario extends StatefulWidget {
  const AutoCalendario({
    required this.allineatore,
    required this.child,
    super.key,
  });

  final AllineatoreCalendario allineatore;
  final Widget child;

  @override
  State<AutoCalendario> createState() => _AutoCalendarioState();
}

class _AutoCalendarioState extends State<AutoCalendario> {
  Timer? _dopoModifica;
  StreamSubscription<Set<TableUpdate>>? _modifiche;
  AppLifecycleListener? _ciclo;

  /// Le tabelle da cui dipendono gli eventi: titoli e date dalle attività,
  /// colori dagli argomenti.
  static const Set<String> _tabelle = <String>{'attivita', 'argomenti'};

  @override
  void initState() {
    super.initState();
    final AllineatoreCalendario a = widget.allineatore;
    if (!a.dispositivo.disponibile) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => a.allinea());
    _ciclo = AppLifecycleListener(onResume: a.allinea);
    _modifiche = a.db.tableUpdates().listen((Set<TableUpdate> cambiate) {
      if (!cambiate.any((TableUpdate t) => _tabelle.contains(t.table))) {
        return;
      }
      // Due secondi: un titolo scritto lettera per lettera diventa un
      // aggiornamento solo.
      _dopoModifica?.cancel();
      _dopoModifica = Timer(const Duration(seconds: 2), a.allinea);
    });
  }

  @override
  void dispose() {
    _dopoModifica?.cancel();
    _modifiche?.cancel();
    _ciclo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
