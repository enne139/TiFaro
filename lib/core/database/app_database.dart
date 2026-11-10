import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tifaro/core/database/app_database.steps.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/calendario/data/calendario_dao.dart';
import 'package:tifaro/features/calendario/data/calendario_tables.dart';
import 'package:tifaro/features/attivita/data/attivita_tables.dart';
import 'package:tifaro/features/categorie/data/categorie_dao.dart';
import 'package:tifaro/features/categorie/data/categorie_tables.dart';
import 'package:tifaro/features/modelli/data/modelli_dao.dart';
import 'package:tifaro/features/modelli/data/modelli_tables.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_dao.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_tables.dart';

part 'app_database.g.dart';

/// Il database locale dell'app: un solo file SQLite.
///
/// Le tabelle stanno accanto alla funzionalità che le usa
/// (`features/<nome>/data/`); qui si dichiara solo quali fanno parte del
/// database. L'ordine conta: una tabella viene dopo quelle a cui rimanda.
@DriftDatabase(
  tables: <Type>[
    Argomenti,
    Tipologie,
    Modelli,
    VociModello,
    ElencoAttivita,
    ElencoFoto,
    NoteSync,
    Preferenze,
    EventiCalendario,
  ],
  daos: <Type>[CategorieDao, AttivitaDao, ModelliDao, SyncDao, CalendarioDao],
)
class AppDatabase extends _$AppDatabase {
  /// Database vero, nella cartella dei dati dell'app.
  ///
  /// La cartella va indicata: di suo drift userebbe quella dei documenti,
  /// che su Linux è `~/Documenti`, in vista e a portata di cancellazione.
  AppDatabase()
    : super(
        driftDatabase(
          name: 'tifaro',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
        ),
      );

  /// Database da usare nelle prove, di solito `NativeDatabase.memory()`.
  AppDatabase.conEsecutore(super.esecutore);

  /// Da aumentare di uno a ogni modifica delle tabelle, scrivendo la
  /// migrazione in [migration]: senza, l'app installata non si apre più.
  ///
  /// Storia: 1 attività, argomenti, tipologie e foto; 2 modelli;
  /// 3 sincronizzazione (note e preferenze); 4 eventi del calendario.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _semina();
      },
      // Un passo per ogni versione, generati da `drift_dev make-migrations`
      // con le fotografie dello schema in `drift_schemas/` (voce 015).
      onUpgrade: stepByStep(
        from1To2: (Migrator m, Schema2 schema) async {
          await m.createTable(schema.modelli);
          await m.createTable(schema.vociModello);
          await m.addColumn(schema.attivita, schema.attivita.modelloId);
        },
        from2To3: (Migrator m, Schema3 schema) async {
          await m.createTable(schema.syncNote);
          await m.createTable(schema.preferenze);
        },
        from3To4: (Migrator m, Schema4 schema) async {
          await m.createTable(schema.eventiCalendario);
        },
      ),
      beforeOpen: (OpeningDetails details) async {
        // Senza questo SQLite accetta i rimandi fra tabelle ma non li fa
        // rispettare.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Argomenti e tipologie del primo avvio.
  ///
  /// Hanno id fissi e non UUID: il "Lavoro" creato sul telefono e quello
  /// creato sul PC sono la stessa riga e non due doppioni (DECISIONI.md,
  /// voce 004). E hanno una data di modifica fissa e vecchia: così un
  /// dispositivo installato dopo non sovrascrive con i nomi di partenza
  /// quello che si è già cambiato altrove (voce 021).
  Future<void> _semina() async {
    final DateTime adesso = DateTime.utc(2026);
    await batch((Batch b) {
      b.insertAll(argomenti, <ArgomentiCompanion>[
        ArgomentiCompanion.insert(
          id: 'argomento-lavoro',
          nome: 'Lavoro',
          colore: const Value<int>(0),
          icona: const Value<String>('lavoro'),
          ordine: const Value<int>(0),
          aggiornatoIl: adesso,
        ),
        ArgomentiCompanion.insert(
          id: 'argomento-personale',
          nome: 'Personale',
          colore: const Value<int>(2),
          icona: const Value<String>('personale'),
          ordine: const Value<int>(1),
          predefinito: const Value<bool>(true),
          aggiornatoIl: adesso,
        ),
        ArgomentiCompanion.insert(
          id: 'argomento-ambulanza',
          nome: 'Ambulanza',
          colore: const Value<int>(1),
          icona: const Value<String>('ambulanza'),
          ordine: const Value<int>(2),
          aggiornatoIl: adesso,
        ),
      ]);
      b.insertAll(tipologie, <TipologieCompanion>[
        TipologieCompanion.insert(
          id: 'tipologia-telefonata',
          nome: 'Telefonata',
          icona: const Value<String>('telefono'),
          aggiornataIl: adesso,
        ),
        TipologieCompanion.insert(
          id: 'tipologia-acquisto',
          nome: 'Acquisto',
          icona: const Value<String>('acquisto'),
          aggiornataIl: adesso,
        ),
        TipologieCompanion.insert(
          id: 'tipologia-burocrazia',
          nome: 'Burocrazia',
          icona: const Value<String>('documento'),
          aggiornataIl: adesso,
        ),
      ]);
    });
  }
}
