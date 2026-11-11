import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/widgets.dart';

import 'package:tifaro/features/notifiche/pianificatore_notifiche.dart';

/// Riprogramma gli avvisi da solo: all'apertura, al ritorno in primo piano
/// e poco dopo ogni modifica alle attività, comprese quelle arrivate con la
/// sincronizzazione (DECISIONI.md, voce 033).
///
/// Alla prima apertura chiede anche il permesso di mostrare le notifiche.
class AutoNotifiche extends StatefulWidget {
  const AutoNotifiche({
    required this.pianificatore,
    required this.child,
    super.key,
  });

  final PianificatoreNotifiche pianificatore;
  final Widget child;

  @override
  State<AutoNotifiche> createState() => _AutoNotificheState();
}

class _AutoNotificheState extends State<AutoNotifiche> {
  Timer? _dopoModifica;
  StreamSubscription<Set<TableUpdate>>? _modifiche;
  AppLifecycleListener? _ciclo;

  @override
  void initState() {
    super.initState();
    final PianificatoreNotifiche p = widget.pianificatore;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await p.chiediPermessoLaPrimaVolta();
      await p.allinea();
    });
    _ciclo = AppLifecycleListener(onResume: p.allinea);
    _modifiche = p.db.tableUpdates().listen((Set<TableUpdate> cambiate) {
      if (!cambiate.any((TableUpdate t) => t.table == 'attivita')) {
        return;
      }
      // Due secondi: un titolo scritto lettera per lettera diventa un giro
      // solo.
      _dopoModifica?.cancel();
      _dopoModifica = Timer(const Duration(seconds: 2), p.allinea);
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
