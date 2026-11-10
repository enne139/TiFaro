import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/data/attivita_tables.dart';
import 'package:tifaro/features/modelli/data/modelli_tables.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';

part 'modelli_dao.g.dart';

/// Letture e scritture dei modelli e delle loro voci, e il passaggio da
/// modello ad attività e ritorno.
///
/// Dentro le transazioni si legge solo con `get()`.
@DriftAccessor(tables: <Type>[Modelli, VociModello, ElencoAttivita])
class ModelliDao extends DatabaseAccessor<AppDatabase> with _$ModelliDaoMixin {
  ModelliDao(super.attachedDatabase);

  static const Uuid _uuid = Uuid();

  AttivitaDao get _attivita => attachedDatabase.attivitaDao;

  // --- Letture -------------------------------------------------------------

  /// I modelli attivi, in ordine di nome.
  Stream<List<Modello>> osservaModelli() {
    return (select(modelli)
          ..where((t) => t.cancellatoIl.isNull())
          ..orderBy(<OrderClauseGenerator<$ModelliTable>>[
            (t) => OrderingTerm.asc(t.nome),
          ]))
        .watch();
  }

  /// Le voci di tutti i modelli, fuori da quelle tolte.
  Stream<List<VoceModello>> osservaVoci() {
    return (select(vociModello)..where((t) => t.cancellataIl.isNull())).watch();
  }

  /// Un modello, tolto o no; `null` se non esiste.
  Future<Modello?> trovaModello(String id) {
    return (select(modelli)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Le voci attive di un modello, già in ordine fra sorelle.
  Future<List<VoceModello>> _vociDi(String modelloId) {
    return (select(vociModello)
          ..where(
            (t) => t.modelloId.equals(modelloId) & t.cancellataIl.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$VociModelloTable>>[
            (t) => OrderingTerm.asc(t.ordine),
            (t) => OrderingTerm.asc(t.aggiornataIl),
          ]))
        .get();
  }

  // --- Modelli -------------------------------------------------------------

  /// Crea un modello e ne restituisce l'id.
  Future<String> creaModello(
    String nome, {
    String descrizione = '',
    String? argomentoId,
    String? tipologiaId,
    int? giorni,
    int? minuti,
    bool nelCalendario = false,
  }) async {
    final String id = _uuid.v4();
    await into(modelli).insert(
      ModelliCompanion.insert(
        id: id,
        nome: nome.trim(),
        descrizione: Value<String>(descrizione.trim()),
        argomentoId: Value<String?>(argomentoId),
        tipologiaId: Value<String?>(tipologiaId),
        giorni: Value<int?>(giorni),
        minuti: Value<int?>(giorni == null ? null : minuti),
        nelCalendario: Value<bool>(nelCalendario),
        aggiornatoIl: DateTime.now(),
      ),
    );
    return id;
  }

  /// Scrive [modifiche] su un modello, aggiornando la data di modifica.
  Future<void> modificaModello(String id, ModelliCompanion modifiche) {
    return (update(modelli)..where((t) => t.id.equals(id))).write(
      modifiche.copyWith(aggiornatoIl: Value<DateTime>(DateTime.now())),
    );
  }

  /// Toglie un modello con tutte le sue voci.
  ///
  /// Le attività già create restano come sono: il modello era solo lo
  /// stampo.
  Future<void> cancellaModello(String id) {
    return transaction(() async {
      final DateTime adesso = DateTime.now();
      await (update(
        vociModello,
      )..where((t) => t.modelloId.equals(id) & t.cancellataIl.isNull())).write(
        VociModelloCompanion(
          cancellataIl: Value<DateTime?>(adesso),
          aggiornataIl: Value<DateTime>(adesso),
        ),
      );
      await modificaModello(
        id,
        ModelliCompanion(cancellatoIl: Value<DateTime?>(adesso)),
      );
    });
  }

  // --- Voci ----------------------------------------------------------------

  /// Aggiunge una voce in fondo alle sorelle e ne restituisce l'id.
  Future<String> creaVoce({
    required String modelloId,
    required String titolo,
    String? genitoreId,
    String descrizione = '',
    String? tipologiaId,
    int? giorni,
    int? minuti,
    bool nelCalendario = false,
  }) async {
    // `IS ?` confronta anche con NULL, cioè le figlie dirette del modello.
    final QueryRow riga = await customSelect(
      'SELECT COALESCE(MAX(ordine), -1) + 1 AS prossimo FROM voci_modello '
      'WHERE modello_id = ? AND genitore_id IS ? AND cancellata_il IS NULL',
      variables: <Variable<Object>>[
        Variable<String>(modelloId),
        Variable<String>(genitoreId),
      ],
    ).getSingle();
    final String id = _uuid.v4();
    await into(vociModello).insert(
      VociModelloCompanion.insert(
        id: id,
        modelloId: modelloId,
        genitoreId: Value<String?>(genitoreId),
        titolo: titolo.trim(),
        descrizione: Value<String>(descrizione.trim()),
        tipologiaId: Value<String?>(tipologiaId),
        giorni: Value<int?>(giorni),
        minuti: Value<int?>(giorni == null ? null : minuti),
        nelCalendario: Value<bool>(nelCalendario),
        ordine: Value<int>(riga.read<int>('prossimo')),
        aggiornataIl: DateTime.now(),
      ),
    );
    return id;
  }

  /// Scrive [modifiche] su una voce, aggiornando la data di modifica.
  Future<void> modificaVoce(String id, VociModelloCompanion modifiche) {
    return (update(vociModello)..where((t) => t.id.equals(id))).write(
      modifiche.copyWith(aggiornataIl: Value<DateTime>(DateTime.now())),
    );
  }

  /// Toglie una voce con tutte le sue sotto-voci.
  Future<void> cancellaVoce(String id) {
    return transaction(() async {
      final List<QueryRow> righe = await customSelect(
        'WITH RECURSIVE sotto(id) AS ('
        ' SELECT ?'
        ' UNION ALL'
        ' SELECT v.id FROM voci_modello v JOIN sotto s ON v.genitore_id = s.id'
        ') SELECT id FROM sotto',
        variables: <Variable<Object>>[Variable<String>(id)],
      ).get();
      final List<String> ids = righe
          .map((QueryRow r) => r.read<String>('id'))
          .toList();
      final DateTime adesso = DateTime.now();
      await (update(
        vociModello,
      )..where((t) => t.id.isIn(ids) & t.cancellataIl.isNull())).write(
        VociModelloCompanion(
          cancellataIl: Value<DateTime?>(adesso),
          aggiornataIl: Value<DateTime>(adesso),
        ),
      );
    });
  }

  /// Sposta una voce di un posto fra le sorelle, rinumerandole tutte.
  Future<void> spostaVoce(String id, Direzione direzione) {
    return transaction(() async {
      final VoceModello? voce = await (select(
        vociModello,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (voce == null) {
        return;
      }
      final List<VoceModello> sorelle = (await _vociDi(voce.modelloId))
          .where((VoceModello v) => v.genitoreId == voce.genitoreId)
          .toList();
      final int da = sorelle.indexWhere((VoceModello v) => v.id == id);
      final int a = direzione == Direzione.su ? da - 1 : da + 1;
      if (da < 0 || a < 0 || a >= sorelle.length) {
        return;
      }
      sorelle.insert(a, sorelle.removeAt(da));
      for (int i = 0; i < sorelle.length; i++) {
        if (sorelle[i].ordine != i) {
          await modificaVoce(
            sorelle[i].id,
            VociModelloCompanion(ordine: Value<int>(i)),
          );
        }
      }
    });
  }

  // --- Da attività a modello e ritorno -------------------------------------

  /// Crea un modello copiando l'attività [attivitaId] con le sue
  /// sotto-attività (fuori dal cestino), e ne restituisce l'id.
  ///
  /// Le date diventano relative: la scadenza della principale si conta dal
  /// giorno in cui era stata creata, quelle delle sotto-attività dalla
  /// scadenza della principale (o dalla sua creazione, se non ne ha). Lo
  /// stato fatto/da fare non si copia (DECISIONI.md, voce 017).
  Future<String> salvaComeModello(String attivitaId, String nome) {
    return transaction(() async {
      final Attivita? radice = await _attivita.trova(attivitaId);
      if (radice == null || radice.cancellataIl != null) {
        throw Exception('L\'attività non c\'è più.');
      }
      final ({int? giorni, int? minuti}) principale = relativaDi(
        radice.scadenza,
        radice.scadenzaConOra,
        radice.creataIl,
      );
      final int? giorniPrincipale = principale.giorni;
      final String modelloId = await creaModello(
        nome,
        descrizione: radice.descrizione,
        argomentoId: radice.argomentoId,
        tipologiaId: radice.tipologiaId,
        // Una scadenza già passata quando l'attività è nata diventa "il
        // giorno della creazione": un modello che crea attività già scadute
        // non serve.
        giorni: giorniPrincipale == null
            ? null
            : (giorniPrincipale < 0 ? 0 : giorniPrincipale),
        minuti: principale.minuti,
        nelCalendario: radice.nelCalendario,
      );

      final List<Attivita> tutte = await (select(
        elencoAttivita,
      )..where((t) => t.cancellataIl.isNull())).get();
      final Map<String, List<Attivita>> figlie = <String, List<Attivita>>{};
      for (final Attivita a in tutte) {
        final String? genitore = a.genitoreId;
        if (genitore != null) {
          figlie.putIfAbsent(genitore, () => <Attivita>[]).add(a);
        }
      }
      for (final List<Attivita> sorelle in figlie.values) {
        sorelle.sort((Attivita a, Attivita b) {
          final int c = a.ordine.compareTo(b.ordine);
          return c != 0 ? c : a.creataIl.compareTo(b.creataIl);
        });
      }

      final DateTime riferimento = radice.scadenza ?? radice.creataIl;
      final Set<String> visti = <String>{radice.id};
      Future<void> copia(String attivitaGenitore, String? voceGenitore) async {
        for (final Attivita a in figlie[attivitaGenitore] ?? <Attivita>[]) {
          // `visti` protegge da un ciclo nei dati.
          if (!visti.add(a.id)) {
            continue;
          }
          final ({int? giorni, int? minuti}) relativa = relativaDi(
            a.scadenza,
            a.scadenzaConOra,
            riferimento,
          );
          final String voceId = await creaVoce(
            modelloId: modelloId,
            genitoreId: voceGenitore,
            titolo: a.titolo,
            descrizione: a.descrizione,
            tipologiaId: a.tipologiaId,
            giorni: relativa.giorni,
            minuti: relativa.minuti,
            nelCalendario: a.nelCalendario,
          );
          await copia(a.id, voceId);
        }
      }

      await copia(radice.id, null);
      return modelloId;
    });
  }

  /// Crea un'attività, con le sue sotto-attività, dal modello [modelloId], e
  /// ne restituisce l'id.
  ///
  /// Ogni campo passato prende il posto di quello del modello; quelli non
  /// passati (o, per [tipologiaId] e [scadenza], `Value.absent()`) vengono
  /// dal modello. Un titolo o una descrizione vuoti valgono come non
  /// passati. Le scadenze delle sotto-attività si contano dalla scadenza
  /// finale della principale, o da [adesso] se non ne ha (voce 017).
  Future<String> creaDaModello(
    String modelloId, {
    String? titolo,
    String? descrizione,
    String? genitoreId,
    String? argomentoId,
    Value<String?> tipologiaId = const Value<String?>.absent(),
    Value<DateTime?> scadenza = const Value<DateTime?>.absent(),
    bool scadenzaConOra = false,
    bool? nelCalendario,
    DateTime? adesso,
  }) {
    return transaction(() async {
      final DateTime ora = adesso ?? DateTime.now();
      final Modello? modello = await trovaModello(modelloId);
      if (modello == null || modello.cancellatoIl != null) {
        throw Exception('Il modello non c\'è più.');
      }

      final ({DateTime? scadenza, bool conOra}) principale = scadenza.present
          ? (scadenza: scadenza.value, conOra: scadenzaConOra)
          : scadenzaRelativa(ora, modello.giorni, modello.minuti);
      final String? titoloScritto = titolo?.trim();
      final String? descrizioneScritta = descrizione?.trim();

      final String radiceId = await _attivita.crea(
        titolo: titoloScritto == null || titoloScritto.isEmpty
            ? modello.nome
            : titoloScritto,
        descrizione: descrizioneScritta == null || descrizioneScritta.isEmpty
            ? modello.descrizione
            : descrizioneScritta,
        argomentoId: argomentoId ?? modello.argomentoId,
        genitoreId: genitoreId,
        tipologiaId: tipologiaId.present
            ? tipologiaId.value
            : modello.tipologiaId,
        scadenza: principale.scadenza,
        scadenzaConOra: principale.conOra,
        nelCalendario: nelCalendario ?? modello.nelCalendario,
        modelloId: modello.id,
        adesso: ora,
      );

      final Map<String?, List<VoceModello>> figlie =
          <String?, List<VoceModello>>{};
      for (final VoceModello v in await _vociDi(modelloId)) {
        figlie.putIfAbsent(v.genitoreId, () => <VoceModello>[]).add(v);
      }
      final DateTime riferimento = principale.scadenza ?? ora;
      final Set<String> visti = <String>{};
      Future<void> copia(String? voceGenitore, String attivitaGenitore) async {
        for (final VoceModello v in figlie[voceGenitore] ?? <VoceModello>[]) {
          if (!visti.add(v.id)) {
            continue;
          }
          final ({DateTime? scadenza, bool conOra}) sua = scadenzaRelativa(
            riferimento,
            v.giorni,
            v.minuti,
          );
          final String id = await _attivita.crea(
            titolo: v.titolo,
            descrizione: v.descrizione,
            genitoreId: attivitaGenitore,
            tipologiaId: v.tipologiaId,
            scadenza: sua.scadenza,
            scadenzaConOra: sua.conOra,
            nelCalendario: v.nelCalendario,
            adesso: ora,
          );
          await copia(v.id, id);
        }
      }

      await copia(null, radiceId);
      return radiceId;
    });
  }
}
