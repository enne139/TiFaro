import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/database/data_modifica.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/attivita/data/attivita_tables.dart';
import 'package:tifaro/features/categorie/data/categorie_tables.dart';
import 'package:tifaro/features/modelli/data/modelli_tables.dart';

part 'categorie_dao.g.dart';

/// Letture e scritture di argomenti e tipologie.
@DriftAccessor(
  tables: <Type>[Argomenti, Tipologie, ElencoAttivita, Modelli, VociModello],
)
class CategorieDao extends DatabaseAccessor<AppDatabase>
    with _$CategorieDaoMixin {
  CategorieDao(super.attachedDatabase);

  static const Uuid _uuid = Uuid();

  // --- Argomenti -----------------------------------------------------------

  /// Gli argomenti attivi, nell'ordine scelto.
  Stream<List<Argomento>> osservaArgomenti() => _selezioneArgomenti().watch();

  /// Gli argomenti attivi, una volta sola.
  Future<List<Argomento>> leggiArgomenti() => _selezioneArgomenti().get();

  SimpleSelectStatement<$ArgomentiTable, Argomento> _selezioneArgomenti() {
    return select(argomenti)
      ..where((t) => t.cancellatoIl.isNull())
      ..orderBy(<OrderClauseGenerator<$ArgomentiTable>>[
        (t) => OrderingTerm.asc(t.ordine),
        (t) => OrderingTerm.asc(t.nome),
      ]);
  }

  /// Crea un argomento in fondo all'elenco e ne restituisce l'id.
  Future<String> creaArgomento(
    String nome, {
    int colore = 0,
    String icona = 'etichetta',
  }) async {
    final QueryRow riga = await customSelect(
      'SELECT COALESCE(MAX(ordine), -1) + 1 AS prossimo FROM argomenti',
    ).getSingle();
    final String id = _uuid.v4();
    await into(argomenti).insert(
      ArgomentiCompanion.insert(
        id: id,
        nome: nome.trim(),
        colore: Value<int>(colore),
        icona: Value<String>(icona),
        ordine: Value<int>(riga.read<int>('prossimo')),
        aggiornatoIl: DateTime.now(),
      ),
    );
    return id;
  }

  /// Cambia nome, colore o icona di un argomento.
  Future<void> modificaArgomento(
    String id, {
    required String nome,
    required int colore,
    required String icona,
  }) async {
    await (update(argomenti)..where((t) => t.id.equals(id))).write(
      ArgomentiCompanion(
        nome: Value<String>(nome.trim()),
        colore: Value<int>(colore),
        icona: Value<String>(icona),
        aggiornatoIl: Value<DateTime>(await _dataArgomenti(<String>[id])),
      ),
    );
  }

  /// La data di modifica per gli argomenti [ids] (`dataDiModifica`).
  Future<DateTime> _dataArgomenti(List<String> ids) => dataDiModificaPerId(
    attachedDatabase,
    'argomenti',
    ids,
    colonna: 'aggiornato_il',
  );

  /// Fa di [id] l'argomento predefinito della cattura veloce.
  Future<void> rendiPredefinito(String id) {
    return transaction(() async {
      final DateTime adesso = await _dataArgomenti(
        (await leggiArgomenti()).map((Argomento a) => a.id).toList(),
      );
      // Si tocca solo chi cambia davvero, perché ogni riga toccata andrà
      // poi sincronizzata.
      await (update(argomenti)
            ..where((t) => t.predefinito.equals(true) & t.id.equals(id).not()))
          .write(
            ArgomentiCompanion(
              predefinito: const Value<bool>(false),
              aggiornatoIl: Value<DateTime>(adesso),
            ),
          );
      await (update(argomenti)..where((t) => t.id.equals(id))).write(
        ArgomentiCompanion(
          predefinito: const Value<bool>(true),
          aggiornatoIl: Value<DateTime>(adesso),
        ),
      );
    });
  }

  /// Toglie un argomento.
  ///
  /// Si rifiuta se è il predefinito o se qualche attività lo usa ancora,
  /// cestino compreso: un'attività senza argomento non saprebbe dove stare
  /// (DECISIONI.md, voce 011). I modelli che lo usavano passano a "quello
  /// della cattura", perché nei modelli l'argomento è facoltativo.
  Future<void> cancellaArgomento(String id) {
    return transaction(() async {
      final Argomento? argomento = await (select(
        argomenti,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (argomento == null) {
        return;
      }
      if (argomento.predefinito) {
        throw Exception(
          'È l\'argomento predefinito: prima scegline un altro come '
          'predefinito.',
        );
      }
      final List<Attivita> usate = await (select(
        elencoAttivita,
      )..where((t) => t.argomentoId.equals(id))).get();
      if (usate.isNotEmpty) {
        throw Exception(
          'Lo usano ancora ${usate.length} attività (cestino compreso): '
          'spostale in un altro argomento prima di toglierlo.',
        );
      }
      final DateTime adesso = DateTime.now();
      await (update(modelli)..where((t) => t.argomentoId.equals(id))).write(
        ModelliCompanion(
          argomentoId: const Value<String?>(null),
          aggiornatoIl: Value<DateTime>(
            await dataDiModifica(
              attachedDatabase,
              'modelli',
              dove: 'argomento_id = ?',
              variabili: <Variable<Object>>[Variable<String>(id)],
              colonna: 'aggiornato_il',
              adesso: adesso,
            ),
          ),
        ),
      );
      await (update(argomenti)..where((t) => t.id.equals(id))).write(
        ArgomentiCompanion(
          cancellatoIl: Value<DateTime>(adesso),
          aggiornatoIl: Value<DateTime>(await _dataArgomenti(<String>[id])),
        ),
      );
    });
  }

  /// L'argomento che corrisponde a un'etichetta della cattura veloce
  /// (`#ambulanza`), creato se non c'è (voce 010).
  Future<Argomento> trovaOCreaArgomento(String etichetta) {
    return transaction(() async {
      final Argomento? esistente = trovaPerEtichetta(
        etichetta,
        await leggiArgomenti(),
        (Argomento a) => a.nome,
      );
      if (esistente != null) {
        return esistente;
      }
      final String id = await creaArgomento(nomeDaEtichetta(etichetta));
      return (select(argomenti)..where((t) => t.id.equals(id))).getSingle();
    });
  }

  // --- Tipologie -----------------------------------------------------------

  /// Le tipologie attive, in ordine di nome.
  Stream<List<Tipologia>> osservaTipologie() => _selezioneTipologie().watch();

  /// Le tipologie attive, una volta sola.
  Future<List<Tipologia>> leggiTipologie() => _selezioneTipologie().get();

  SimpleSelectStatement<$TipologieTable, Tipologia> _selezioneTipologie() {
    return select(tipologie)
      ..where((t) => t.cancellataIl.isNull())
      ..orderBy(<OrderClauseGenerator<$TipologieTable>>[
        (t) => OrderingTerm.asc(t.nome),
      ]);
  }

  /// Crea una tipologia e ne restituisce l'id.
  Future<String> creaTipologia(
    String nome, {
    String icona = 'etichetta',
  }) async {
    final String id = _uuid.v4();
    await into(tipologie).insert(
      TipologieCompanion.insert(
        id: id,
        nome: nome.trim(),
        icona: Value<String>(icona),
        aggiornataIl: DateTime.now(),
      ),
    );
    return id;
  }

  /// Cambia nome o icona di una tipologia.
  Future<void> modificaTipologia(
    String id, {
    required String nome,
    required String icona,
  }) async {
    await (update(tipologie)..where((t) => t.id.equals(id))).write(
      TipologieCompanion(
        nome: Value<String>(nome.trim()),
        icona: Value<String>(icona),
        aggiornataIl: Value<DateTime>(
          await dataDiModificaPerId(attachedDatabase, 'tipologie', <String>[
            id,
          ]),
        ),
      ),
    );
  }

  /// Toglie una tipologia: le attività, i modelli e le voci che l'avevano
  /// restano senza.
  ///
  /// A differenza dell'argomento la tipologia è facoltativa, quindi toglierla
  /// non lascia nessuno senza posto (voce 011).
  Future<void> cancellaTipologia(String id) {
    return transaction(() async {
      final DateTime adesso = DateTime.now();
      // La data di modifica per le righe di [tabella] con questa tipologia.
      Future<DateTime> data(
        String tabella, {
        String colonna = 'aggiornata_il',
      }) => dataDiModifica(
        attachedDatabase,
        tabella,
        dove: 'tipologia_id = ?',
        variabili: <Variable<Object>>[Variable<String>(id)],
        colonna: colonna,
        adesso: adesso,
      );
      await (update(
        elencoAttivita,
      )..where((t) => t.tipologiaId.equals(id))).write(
        ElencoAttivitaCompanion(
          tipologiaId: const Value<String?>(null),
          aggiornataIl: Value<DateTime>(await data('attivita')),
        ),
      );
      await (update(modelli)..where((t) => t.tipologiaId.equals(id))).write(
        ModelliCompanion(
          tipologiaId: const Value<String?>(null),
          aggiornatoIl: Value<DateTime>(
            await data('modelli', colonna: 'aggiornato_il'),
          ),
        ),
      );
      await (update(vociModello)..where((t) => t.tipologiaId.equals(id))).write(
        VociModelloCompanion(
          tipologiaId: const Value<String?>(null),
          aggiornataIl: Value<DateTime>(await data('voci_modello')),
        ),
      );
      await (update(tipologie)..where((t) => t.id.equals(id))).write(
        TipologieCompanion(
          cancellataIl: Value<DateTime>(adesso),
          aggiornataIl: Value<DateTime>(
            await dataDiModificaPerId(attachedDatabase, 'tipologie', <String>[
              id,
            ], adesso: adesso),
          ),
        ),
      );
    });
  }

  /// La tipologia che corrisponde a un'etichetta della cattura veloce
  /// (`@acquisti`), creata se non c'è (voce 010).
  Future<Tipologia> trovaOCreaTipologia(String etichetta) {
    return transaction(() async {
      final Tipologia? esistente = trovaPerEtichetta(
        etichetta,
        await leggiTipologie(),
        (Tipologia t) => t.nome,
      );
      if (esistente != null) {
        return esistente;
      }
      final String id = await creaTipologia(nomeDaEtichetta(etichetta));
      return (select(tipologie)..where((t) => t.id.equals(id))).getSingle();
    });
  }
}
