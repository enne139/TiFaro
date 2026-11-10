import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/data/attivita_tables.dart';
import 'package:tifaro/features/categorie/data/categorie_tables.dart';

part 'attivita_dao.g.dart';

/// In che direzione spostare un'attività fra le sorelle.
enum Direzione { su, giu }

/// Letture e scritture delle attività e delle loro foto.
///
/// Le letture per le schermate sono poche e grezze ([osservaTutte]): gli
/// alberi e i raggruppamenti si calcolano in Dart (DECISIONI.md, voce 012).
/// Qui stanno soprattutto le scritture che toccano un sottoalbero intero.
///
/// Dentro le transazioni si legge solo con `get()`: uno stream aspetterebbe
/// una notifica che arriva dopo il commit, e l'operazione resterebbe appesa.
@DriftAccessor(tables: <Type>[ElencoAttivita, ElencoFoto, Argomenti])
class AttivitaDao extends DatabaseAccessor<AppDatabase>
    with _$AttivitaDaoMixin {
  AttivitaDao(super.attachedDatabase);

  static const Uuid _uuid = Uuid();

  // --- Letture -------------------------------------------------------------

  /// Tutte le attività fuori dal cestino, fatte comprese.
  Stream<List<Attivita>> osservaTutte() {
    return (select(
      elencoAttivita,
    )..where((t) => t.cancellataIl.isNull())).watch();
  }

  /// Tutte le attività nel cestino, le più recenti prima.
  Stream<List<Attivita>> osservaCestino() {
    return (select(elencoAttivita)
          ..where((t) => t.cancellataIl.isNotNull())
          ..orderBy(<OrderClauseGenerator<$ElencoAttivitaTable>>[
            (t) => OrderingTerm.desc(t.cancellataIl),
          ]))
        .watch();
  }

  /// Un'attività, cestinata o no; `null` se non esiste.
  Future<Attivita?> trova(String id) {
    return (select(
      elencoAttivita,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gli id di [id] e di tutte le sue discendenti, a qualunque profondità,
  /// cestinate comprese.
  Future<List<String>> _sottoalbero(String id) async {
    final List<QueryRow> righe = await customSelect(
      'WITH RECURSIVE sotto(id) AS ('
      ' SELECT ?'
      ' UNION ALL'
      ' SELECT a.id FROM attivita a JOIN sotto s ON a.genitore_id = s.id'
      ') SELECT id FROM sotto',
      variables: <Variable<Object>>[Variable<String>(id)],
    ).get();
    return righe.map((QueryRow r) => r.read<String>('id')).toList();
  }

  // --- Creazione e modifica ------------------------------------------------

  /// Crea un'attività e ne restituisce l'id.
  ///
  /// Una sotto-attività ([genitoreId]) prende sempre l'argomento del
  /// genitore e ignora [argomentoId]; un'attività principale senza argomento
  /// prende il predefinito. La nuova attività va in fondo alle sorelle.
  /// [modelloId] dice da quale modello nasce, se nasce da uno.
  Future<String> crea({
    required String titolo,
    String descrizione = '',
    String? argomentoId,
    String? genitoreId,
    String? tipologiaId,
    DateTime? scadenza,
    bool scadenzaConOra = false,
    bool nelCalendario = false,
    String? modelloId,
    DateTime? adesso,
  }) {
    return transaction(() async {
      final DateTime ora = adesso ?? DateTime.now();

      String? argomento = argomentoId;
      if (genitoreId != null) {
        final Attivita? genitore = await trova(genitoreId);
        if (genitore == null || genitore.cancellataIl != null) {
          throw Exception('L\'attività principale non c\'è più.');
        }
        argomento = genitore.argomentoId;
      }
      argomento ??= await _argomentoPredefinito();

      final String id = _uuid.v4();
      await into(elencoAttivita).insert(
        ElencoAttivitaCompanion.insert(
          id: id,
          titolo: titolo.trim(),
          descrizione: Value<String>(descrizione.trim()),
          creataIl: ora,
          scadenza: Value<DateTime?>(scadenza),
          scadenzaConOra: Value<bool>(scadenza != null && scadenzaConOra),
          argomentoId: argomento,
          tipologiaId: Value<String?>(tipologiaId),
          genitoreId: Value<String?>(genitoreId),
          ordine: Value<int>(await _prossimoOrdine(genitoreId)),
          nelCalendario: Value<bool>(nelCalendario),
          modelloId: Value<String?>(modelloId),
          aggiornataIl: ora,
        ),
      );
      return id;
    });
  }

  /// L'id dell'argomento predefinito.
  Future<String> _argomentoPredefinito() async {
    final Argomento? predefinito =
        await (select(argomenti)
              ..where(
                (t) => t.predefinito.equals(true) & t.cancellatoIl.isNull(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (predefinito != null) {
      return predefinito.id;
    }
    // Non dovrebbe succedere, ma un'attività senza argomento non si può
    // salvare: meglio il primo argomento che un errore.
    final Argomento? primo =
        await (select(argomenti)
              ..where((t) => t.cancellatoIl.isNull())
              ..orderBy(<OrderClauseGenerator<$ArgomentiTable>>[
                (t) => OrderingTerm.asc(t.ordine),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (primo == null) {
      throw Exception('Non c\'è nessun argomento: creane uno.');
    }
    return primo.id;
  }

  /// La posizione dopo l'ultima sorella fuori dal cestino.
  Future<int> _prossimoOrdine(String? genitoreId) async {
    // `IS ?` confronta anche con NULL, cioè le attività principali.
    final QueryRow riga = await customSelect(
      'SELECT COALESCE(MAX(ordine), -1) + 1 AS prossimo FROM attivita '
      'WHERE genitore_id IS ? AND cancellata_il IS NULL',
      variables: <Variable<Object>>[Variable<String>(genitoreId)],
    ).getSingle();
    return riga.read<int>('prossimo');
  }

  /// Scrive [modifiche] su un'attività, aggiornando la data di modifica.
  Future<void> aggiorna(
    String id,
    ElencoAttivitaCompanion modifiche, {
    DateTime? adesso,
  }) {
    return (update(elencoAttivita)..where((t) => t.id.equals(id))).write(
      modifiche.copyWith(
        aggiornataIl: Value<DateTime>(adesso ?? DateTime.now()),
      ),
    );
  }

  /// Sposta un'attività principale, con tutte le sue sotto-attività, in un
  /// altro argomento.
  Future<void> cambiaArgomento(String id, String argomentoId) {
    return transaction(() async {
      final List<String> ids = await _sottoalbero(id);
      await (update(elencoAttivita)..where((t) => t.id.isIn(ids))).write(
        ElencoAttivitaCompanion(
          argomentoId: Value<String>(argomentoId),
          aggiornataIl: Value<DateTime>(DateTime.now()),
        ),
      );
    });
  }

  /// Segna un'attività come fatta o da fare.
  ///
  /// Con [ancheSotto] chiude anche tutte le sotto-attività ancora aperte;
  /// quelle già fatte tengono la loro data. Riaprire riapre solo questa.
  Future<void> segnaFatta(
    String id,
    bool fatta, {
    bool ancheSotto = false,
    DateTime? adesso,
  }) {
    return transaction(() async {
      final DateTime ora = adesso ?? DateTime.now();
      if (!fatta) {
        await aggiorna(
          id,
          const ElencoAttivitaCompanion(fattaIl: Value<DateTime?>(null)),
          adesso: ora,
        );
        return;
      }
      final List<String> ids = ancheSotto
          ? await _sottoalbero(id)
          : <String>[id];
      await (update(elencoAttivita)..where(
            (t) =>
                t.id.isIn(ids) & t.fattaIl.isNull() & t.cancellataIl.isNull(),
          ))
          .write(
            ElencoAttivitaCompanion(
              fattaIl: Value<DateTime?>(ora),
              aggiornataIl: Value<DateTime>(ora),
            ),
          );
    });
  }

  /// Sposta un'attività di un posto fra le sorelle.
  ///
  /// Rinumera tutte le sorelle invece di scambiare due numeri: così anche
  /// posizioni doppie (per esempio dopo una sincronizzazione) si sistemano.
  Future<void> sposta(String id, Direzione direzione) {
    return transaction(() async {
      final Attivita? attivita = await trova(id);
      if (attivita == null) {
        return;
      }
      final String? genitoreId = attivita.genitoreId;
      final List<Attivita> sorelle =
          await (select(elencoAttivita)
                ..where(
                  (t) =>
                      (genitoreId == null
                          ? t.genitoreId.isNull()
                          : t.genitoreId.equals(genitoreId)) &
                      t.cancellataIl.isNull(),
                )
                ..orderBy(<OrderClauseGenerator<$ElencoAttivitaTable>>[
                  (t) => OrderingTerm.asc(t.ordine),
                  (t) => OrderingTerm.asc(t.creataIl),
                ]))
              .get();

      final int da = sorelle.indexWhere((Attivita a) => a.id == id);
      final int a = direzione == Direzione.su ? da - 1 : da + 1;
      if (da < 0 || a < 0 || a >= sorelle.length) {
        return;
      }
      sorelle.insert(a, sorelle.removeAt(da));

      final DateTime adesso = DateTime.now();
      for (int i = 0; i < sorelle.length; i++) {
        if (sorelle[i].ordine != i) {
          await aggiorna(
            sorelle[i].id,
            ElencoAttivitaCompanion(ordine: Value<int>(i)),
            adesso: adesso,
          );
        }
      }
    });
  }

  // --- Cestino -------------------------------------------------------------

  /// Manda nel cestino un'attività con tutte le sue sotto-attività.
  ///
  /// Tutte prendono lo stesso istante: è quello che [ripristina] usa per
  /// riconoscere cosa è stato cestinato insieme (DECISIONI.md, voce 006).
  Future<void> spostaNelCestino(String id, {DateTime? adesso}) {
    return transaction(() async {
      // Senza millisecondi: nel database le date si tengono al secondo, e
      // l'istante va confrontato con quello riletto.
      final DateTime ora = DateTime.fromMillisecondsSinceEpoch(
        ((adesso ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000) * 1000,
      );
      final List<String> ids = await _sottoalbero(id);
      await (update(
        elencoAttivita,
      )..where((t) => t.id.isIn(ids) & t.cancellataIl.isNull())).write(
        ElencoAttivitaCompanion(
          cancellataIl: Value<DateTime?>(ora),
          aggiornataIl: Value<DateTime>(ora),
        ),
      );
    });
  }

  /// Riporta fuori dal cestino un'attività e quello che è stato cestinato
  /// insieme a lei.
  ///
  /// Se nel frattempo è finito nel cestino anche il genitore, torna fuori
  /// anche lui (solo lui, non le sue altre sotto-attività): altrimenti
  /// l'attività ripristinata non si vedrebbe da nessuna parte.
  Future<void> ripristina(String id) {
    return transaction(() async {
      final Attivita? attivita = await trova(id);
      final DateTime? quando = attivita?.cancellataIl;
      if (attivita == null || quando == null) {
        return;
      }
      final DateTime adesso = DateTime.now();
      final List<String> ids = await _sottoalbero(id);
      await (update(
        elencoAttivita,
      )..where((t) => t.id.isIn(ids) & t.cancellataIl.equals(quando))).write(
        ElencoAttivitaCompanion(
          cancellataIl: const Value<DateTime?>(null),
          aggiornataIl: Value<DateTime>(adesso),
        ),
      );

      String? genitoreId = attivita.genitoreId;
      final Set<String> visti = <String>{id};
      // `visti` protegge da un ciclo nei dati, che girerebbe all'infinito.
      while (genitoreId != null && visti.add(genitoreId)) {
        final Attivita? genitore = await trova(genitoreId);
        if (genitore == null) {
          break;
        }
        if (genitore.cancellataIl != null) {
          await aggiorna(
            genitore.id,
            const ElencoAttivitaCompanion(cancellataIl: Value<DateTime?>(null)),
            adesso: adesso,
          );
        }
        genitoreId = genitore.genitoreId;
      }
    });
  }

  // --- Foto ----------------------------------------------------------------

  /// Tutte le foto allegate, fuori dal cestino.
  Stream<List<Foto>> osservaFoto() {
    return (select(elencoFoto)
          ..where((t) => t.cancellataIl.isNull())
          ..orderBy(<OrderClauseGenerator<$ElencoFotoTable>>[
            (t) => OrderingTerm.asc(t.creataIl),
          ]))
        .watch();
  }

  /// Allega a un'attività la foto già copiata nella cartella delle foto.
  Future<void> aggiungiFoto(String attivitaId, String nomeFile) {
    final DateTime adesso = DateTime.now();
    return into(elencoFoto).insert(
      ElencoFotoCompanion.insert(
        id: _uuid.v4(),
        attivitaId: attivitaId,
        nomeFile: nomeFile,
        creataIl: adesso,
        aggiornataIl: adesso,
      ),
    );
  }

  /// Toglie una foto da un'attività.
  ///
  /// Il file resta nella cartella: servirà a chi dovrà ancora riceverne la
  /// cancellazione con la sincronizzazione, e occupa poco (voce 007).
  Future<void> togliFoto(String id) {
    final DateTime adesso = DateTime.now();
    return (update(elencoFoto)..where((t) => t.id.equals(id))).write(
      ElencoFotoCompanion(
        cancellataIl: Value<DateTime?>(adesso),
        aggiornataIl: Value<DateTime>(adesso),
      ),
    );
  }
}
