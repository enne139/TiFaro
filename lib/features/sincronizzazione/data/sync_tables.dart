import 'package:drift/drift.dart';

/// Per ogni riga sincronizzata, l'impronta della versione che il server ha
/// di sicuro.
///
/// Una riga la cui impronta attuale è diversa da questa è cambiata qui e va
/// mandata. Si confronta il contenuto e non la data di modifica, che nel
/// database ha la precisione del secondo: due modifiche nello stesso secondo
/// sembrerebbero una (DECISIONI.md, voce 021). Questa tabella resta su
/// questo dispositivo e non si sincronizza.
@DataClassName('NotaSync')
class NoteSync extends Table {
  @override
  String get tableName => 'sync_note';

  /// Il nome della tabella della riga, come lo conosce il server.
  TextColumn get tabella => text()();

  /// L'id della riga.
  TextColumn get id => text()();

  /// L'impronta del contenuto (`impronta()`).
  TextColumn get impronta => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{tabella, id};
}

/// Le preferenze di questo dispositivo (indirizzo del server, token, ultima
/// revisione ricevuta…), come chiave e valore. Non si sincronizzano.
@DataClassName('Preferenza')
class Preferenze extends Table {
  TextColumn get chiave => text()();
  TextColumn get valore => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{chiave};
}
