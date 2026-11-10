import 'package:drift/drift.dart';

/// Gli eventi che questo telefono ha messo nel calendario, uno per attività.
///
/// Resta su questo dispositivo e non si sincronizza: l'id di un evento vale
/// solo nel calendario di questo telefono (DECISIONI.md, voce 027).
@DataClassName('EventoCalendario')
class EventiCalendario extends Table {
  @override
  String get tableName => 'eventi_calendario';

  /// L'attività da cui nasce l'evento.
  TextColumn get attivitaId => text()();

  /// L'id dell'evento nel calendario del telefono.
  IntColumn get eventoId => integer()();

  /// Il calendario in cui sta l'evento.
  IntColumn get calendarioId => integer()();

  /// L'impronta di titolo, date e colore dell'ultima versione scritta: se
  /// cambia, l'evento va aggiornato.
  TextColumn get impronta => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{attivitaId};
}
