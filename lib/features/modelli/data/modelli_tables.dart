import 'package:drift/drift.dart';

import 'package:tifaro/features/categorie/data/categorie_tables.dart';

/// I modelli: stampi da cui creare un'attività con le sue sotto-attività
/// già pronte.
///
/// La riga del modello fa anche da attività principale dello stampo: il suo
/// nome diventa il titolo dell'attività creata, e i suoi campi quelli della
/// principale. Le sotto-attività stanno in [VociModello] (DECISIONI.md,
/// voce 016).
@DataClassName('Modello')
class Modelli extends Table {
  /// UUID.
  TextColumn get id => text()();

  /// Il nome, che è anche il titolo dell'attività creata se nella cattura
  /// non se ne scrive un altro. Con `/nome` si sceglie nella cattura veloce.
  TextColumn get nome => text()();

  /// La descrizione dell'attività creata.
  TextColumn get descrizione => text().withDefault(const Constant(''))();

  /// L'argomento dell'attività creata; nullo vuol dire "quello della
  /// cattura" (scritto, scelto o il predefinito).
  TextColumn get argomentoId => text().nullable().references(Argomenti, #id)();

  /// La tipologia dell'attività creata, facoltativa.
  TextColumn get tipologiaId => text().nullable().references(Tipologie, #id)();

  /// Quanti giorni dopo la creazione scade l'attività; nullo se non ha una
  /// scadenza (voce 017).
  IntColumn get giorni => integer().nullable()();

  /// L'ora della scadenza in minuti dalla mezzanotte; nulla se conta solo il
  /// giorno.
  IntColumn get minuti => integer().nullable()();

  /// Se l'attività creata va nel calendario.
  BoolColumn get nelCalendario =>
      boolean().withDefault(const Constant(false))();

  /// Ultima modifica, per la sincronizzazione (voce 003).
  DateTimeColumn get aggiornatoIl => dateTime()();

  /// Se non è nullo il modello è stato tolto (voce 003).
  DateTimeColumn get cancellatoIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Le voci di un modello, cioè le sue sotto-attività, ad albero come le
/// attività.
@DataClassName('VoceModello')
class VociModello extends Table {
  @override
  String get tableName => 'voci_modello';

  /// UUID.
  TextColumn get id => text()();

  /// Il modello a cui appartiene.
  TextColumn get modelloId => text().references(Modelli, #id)();

  /// La voce di cui questa è una sotto-voce; nulla per le figlie dirette
  /// dell'attività principale (cioè del modello).
  TextColumn get genitoreId => text().nullable().references(VociModello, #id)();

  /// Il titolo della sotto-attività creata.
  TextColumn get titolo => text()();

  /// La descrizione della sotto-attività creata.
  TextColumn get descrizione => text().withDefault(const Constant(''))();

  /// La tipologia, facoltativa.
  TextColumn get tipologiaId => text().nullable().references(Tipologie, #id)();

  /// Giorni rispetto alla scadenza della principale (o alla creazione, se la
  /// principale non ha scadenza): negativi prima, positivi dopo. Nullo se la
  /// sotto-attività non ha scadenza (voce 017).
  IntColumn get giorni => integer().nullable()();

  /// L'ora della scadenza in minuti dalla mezzanotte; nulla se conta solo il
  /// giorno.
  IntColumn get minuti => integer().nullable()();

  /// Se la sotto-attività creata va nel calendario.
  BoolColumn get nelCalendario =>
      boolean().withDefault(const Constant(false))();

  /// Posizione fra le sorelle.
  IntColumn get ordine => integer().withDefault(const Constant(0))();

  /// Ultima modifica, per la sincronizzazione (voce 003).
  DateTimeColumn get aggiornataIl => dateTime()();

  /// Se non è nulla la voce è stata tolta (voce 003).
  DateTimeColumn get cancellataIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
