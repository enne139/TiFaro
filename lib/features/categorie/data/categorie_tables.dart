import 'package:drift/drift.dart';

/// Gli argomenti: le parti della vita a cui appartiene un'attività
/// (Lavoro, Personale, Ambulanza…).
///
/// Ogni attività ne ha uno solo; le sotto-attività prendono quello
/// dell'attività principale (DECISIONI.md, voce 005).
@DataClassName('Argomento')
class Argomenti extends Table {
  /// UUID, oppure un id fisso per quelli creati al primo avvio (voce 004).
  TextColumn get id => text()();

  /// Il nome che si vede, per esempio "Ambulanza".
  TextColumn get nome => text()();

  /// Indice in `paletteArgomenti`: si salva l'indice, non il colore, così la
  /// tavolozza può corrispondere ai colori di Google Calendar (voce 008).
  IntColumn get colore => integer().withDefault(const Constant(0))();

  /// Chiave di `iconeDisponibili`.
  TextColumn get icona => text().withDefault(const Constant('etichetta'))();

  /// Posizione nell'elenco degli argomenti.
  IntColumn get ordine => integer().withDefault(const Constant(0))();

  /// L'argomento usato dalla cattura veloce quando non se ne scrive uno.
  /// Ce n'è sempre esattamente uno.
  BoolColumn get predefinito => boolean().withDefault(const Constant(false))();

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  DateTimeColumn get aggiornatoIl => dateTime()();

  /// Se non è nullo l'argomento è stato tolto: la riga resta perché la
  /// cancellazione possa arrivare anche agli altri dispositivi (voce 003).
  DateTimeColumn get cancellatoIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Le tipologie: che genere di cosa è un'attività (Telefonata, Acquisto…),
/// per vedere insieme quelle simili anche se stanno in argomenti diversi.
@DataClassName('Tipologia')
class Tipologie extends Table {
  /// UUID, oppure un id fisso per quelle create al primo avvio (voce 004).
  TextColumn get id => text()();

  /// Il nome che si vede, per esempio "Telefonata".
  TextColumn get nome => text()();

  /// Chiave di `iconeDisponibili`.
  TextColumn get icona => text().withDefault(const Constant('etichetta'))();

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  DateTimeColumn get aggiornataIl => dateTime()();

  /// Se non è nullo la tipologia è stata tolta (voce 003).
  DateTimeColumn get cancellataIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
