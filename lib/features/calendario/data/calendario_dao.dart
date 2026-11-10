import 'package:drift/drift.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/calendario/data/calendario_tables.dart';

part 'calendario_dao.g.dart';

/// Le chiavi delle preferenze del calendario (nella tabella delle
/// preferenze, che resta su questo dispositivo).
abstract final class ChiaviCalendario {
  static const String attivo = 'calendario.attivo';
  static const String id = 'calendario.id';
}

/// Letture e scritture degli eventi creati da questo telefono.
@DriftAccessor(tables: <Type>[EventiCalendario])
class CalendarioDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarioDaoMixin {
  CalendarioDao(super.attachedDatabase);

  /// Gli eventi creati, per id dell'attività.
  Future<Map<String, EventoCalendario>> eventi() async {
    final List<EventoCalendario> righe = await select(eventiCalendario).get();
    return <String, EventoCalendario>{
      for (final EventoCalendario e in righe) e.attivitaId: e,
    };
  }

  /// Ricorda l'evento dell'attività [attivitaId].
  Future<void> ricorda({
    required String attivitaId,
    required int eventoId,
    required int calendarioId,
    required String impronta,
  }) {
    return into(eventiCalendario).insertOnConflictUpdate(
      EventiCalendarioCompanion.insert(
        attivitaId: attivitaId,
        eventoId: eventoId,
        calendarioId: calendarioId,
        impronta: impronta,
      ),
    );
  }

  /// Dimentica l'evento dell'attività [attivitaId].
  Future<void> dimentica(String attivitaId) {
    return (delete(
      eventiCalendario,
    )..where((t) => t.attivitaId.equals(attivitaId))).go();
  }
}
