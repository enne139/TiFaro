import 'package:drift/drift.dart';

import 'package:tifaro/features/categorie/data/categorie_tables.dart';

/// Le attività, cioè le cose da fare, e le loro sotto-attività.
///
/// L'albero si tiene con un semplice rimando al genitore: le sotto-attività
/// sono attività come le altre, a qualunque profondità (DECISIONI.md,
/// voce 005).
@DataClassName('Attivita')
class ElencoAttivita extends Table {
  @override
  String get tableName => 'attivita';

  /// UUID: deve restare unico anche fra dispositivi diversi (voce 003).
  TextColumn get id => text()();

  /// Cosa fare.
  TextColumn get titolo => text()();

  /// Testo libero, anche lungo.
  TextColumn get descrizione => text().withDefault(const Constant(''))();

  /// Quando è stata creata, messo in automatico.
  DateTimeColumn get creataIl => dateTime()();

  /// Entro quando completarla. Senza ora vale la mezzanotte di quel giorno,
  /// e [scadenzaConOra] dice se l'ora conta.
  DateTimeColumn get scadenza => dateTime().nullable()();

  /// Se l'ora di [scadenza] è stata scelta o è solo la mezzanotte di comodo.
  BoolColumn get scadenzaConOra =>
      boolean().withDefault(const Constant(false))();

  /// Quando è stata fatta; nullo finché è da fare.
  DateTimeColumn get fattaIl => dateTime().nullable()();

  /// L'argomento. Nelle sotto-attività è sempre quello dell'attività
  /// principale: si ripete su ogni riga per poter filtrare senza risalire
  /// l'albero (voce 005).
  TextColumn get argomentoId => text().references(Argomenti, #id)();

  /// La tipologia, facoltativa. Ogni sotto-attività ha la sua.
  TextColumn get tipologiaId => text().nullable().references(Tipologie, #id)();

  /// L'attività di cui questa è una sotto-attività; nullo per le principali.
  TextColumn get genitoreId =>
      text().nullable().references(ElencoAttivita, #id)();

  /// Posizione fra le sorelle (stesso genitore).
  IntColumn get ordine => integer().withDefault(const Constant(0))();

  /// Se deve comparire su Google Calendar. Per ora si segna soltanto: gli
  /// eventi li creerà il server, nella fase 4 (voce 009).
  BoolColumn get nelCalendario =>
      boolean().withDefault(const Constant(false))();

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  DateTimeColumn get aggiornataIl => dateTime()();

  /// Se non è nulla l'attività è nel cestino. Un sottoalbero cestinato
  /// insieme ha su ogni riga lo stesso istante, ed è così che il ripristino
  /// sa cosa riportare indietro (voce 006).
  DateTimeColumn get cancellataIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Le foto allegate alle attività.
///
/// Il file sta nella cartella delle foto dell'app ([FotoArchivio]); qui c'è
/// solo il suo nome (voce 007).
@DataClassName('Foto')
class ElencoFoto extends Table {
  @override
  String get tableName => 'foto';

  /// UUID.
  TextColumn get id => text()();

  /// L'attività a cui è allegata.
  TextColumn get attivitaId => text().references(ElencoAttivita, #id)();

  /// Nome del file dentro la cartella delle foto.
  TextColumn get nomeFile => text()();

  /// Quando è stata allegata.
  DateTimeColumn get creataIl => dateTime()();

  /// Ultima modifica: servirà alla sincronizzazione (voce 003).
  DateTimeColumn get aggiornataIl => dateTime()();

  /// Se non è nulla la foto è stata tolta (voce 003).
  DateTimeColumn get cancellataIl => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
