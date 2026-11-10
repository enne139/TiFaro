import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/widgets.dart';

import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

/// Sincronizza da sola, se nelle impostazioni è accesa: all'apertura, quando
/// l'app torna in primo piano, ogni cinque minuti e poco dopo ogni modifica
/// (DECISIONI.md, voce 021).
///
/// È un widget e non un servizio a sé perché così i suoi orologi nascono e
/// muoiono con l'app, anche nelle prove.
class AutoSync extends StatefulWidget {
  const AutoSync({
    required this.sincronizzatore,
    required this.child,
    super.key,
  });

  final Sincronizzatore sincronizzatore;
  final Widget child;

  @override
  State<AutoSync> createState() => _AutoSyncState();
}

class _AutoSyncState extends State<AutoSync> {
  Timer? _periodico;
  Timer? _dopoModifica;
  StreamSubscription<Set<TableUpdate>>? _modifiche;
  AppLifecycleListener? _ciclo;

  /// Quanto aspettare dopo una modifica: abbastanza per raccogliere una
  /// raffica di cambiamenti (titolo scritto, sotto-attività in fila) in un
  /// giro solo.
  static const Duration _attesaDopoModifica = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    final Sincronizzatore s = widget.sincronizzatore;
    s.carica().then((_) => _sincronizza());
    _periodico = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _sincronizza(),
    );
    _ciclo = AppLifecycleListener(onResume: _sincronizza);
    final Set<String> sincronizzate = s.db.syncDao.nomiTabelle;
    _modifiche = s.db.tableUpdates().listen((Set<TableUpdate> cambiate) {
      // Solo le tabelle che si sincronizzano: le note e le preferenze
      // cambiano proprio durante la sincronizzazione.
      if (!cambiate.any((TableUpdate t) => sincronizzate.contains(t.table))) {
        return;
      }
      _dopoModifica?.cancel();
      _dopoModifica = Timer(
        _attesaDopoModifica,
        () => _sincronizza(soloSeCambiato: true),
      );
    });
  }

  Future<void> _sincronizza({bool soloSeCambiato = false}) async {
    if (!mounted) {
      return;
    }
    final ConfigurazioneSync c = await widget.sincronizzatore.configurazione();
    if (c.pronta && c.automatica && mounted) {
      await widget.sincronizzatore.sincronizza(soloSeCambiato: soloSeCambiato);
    }
  }

  @override
  void dispose() {
    _periodico?.cancel();
    _dopoModifica?.cancel();
    _modifiche?.cancel();
    _ciclo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
