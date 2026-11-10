// Prove delle migrazioni del database, nate dal modello generato da
// `dart run drift_dev make-migrations` (DECISIONI.md, voce 015).
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  // Da ogni versione a ognuna delle successive, lo schema ottenuto con le
  // migrazioni deve essere identico a quello fotografato in drift_schemas/.
  group('lo schema dopo la migrazione è quello atteso', () {
    const List<int> versioni = GeneratedHelper.versions;
    for (final (int i, int da) in versioni.indexed) {
      group('dalla versione $da', () {
        for (final int a in versioni.skip(i + 1)) {
          test('alla $a', () async {
            final InitializedSchema schema = await verifier.schemaAt(da);
            final AppDatabase db = AppDatabase.conEsecutore(
              schema.newConnection(),
            );
            await verifier.migrateAndValidate(db, a);
            await db.close();
          });
        }
      });
    }
  });

  test('dalla 1 alla 2 le attività restano, senza modello', () async {
    final InitializedSchema schema = await verifier.schemaAt(1);
    // Con la versione 1 il database non ha argomenti di partenza: li si
    // scrive a mano, come li avrebbe lasciati l'app.
    schema.rawDatabase.execute(
      "INSERT INTO argomenti (id, nome, aggiornato_il) "
      "VALUES ('argomento-lavoro', 'Lavoro', 0)",
    );
    schema.rawDatabase.execute(
      "INSERT INTO attivita (id, titolo, creata_il, argomento_id, "
      "aggiornata_il) VALUES ('a1', 'Revisione', 0, 'argomento-lavoro', 0)",
    );

    final AppDatabase db = AppDatabase.conEsecutore(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final Attivita attivita = (await db.attivitaDao.trova('a1'))!;
    expect(attivita.titolo, 'Revisione');
    expect(attivita.modelloId, isNull);
    expect(await db.select(db.modelli).get(), isEmpty);
    await db.close();
  });
}
