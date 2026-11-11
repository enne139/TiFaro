import 'package:drift/drift.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_tables.dart';
// Con un prefisso, perché dentro RigaSync `impronta` è anche un campo.
import 'package:tifaro/features/sincronizzazione/logica/impronta.dart'
    as logica;

part 'sync_dao.g.dart';

/// Una riga come viaggia fra app e server.
class RigaSync {
  RigaSync({
    required this.tabella,
    required this.id,
    required this.aggiornata,
    required this.dati,
  });

  /// Dalla risposta del server.
  factory RigaSync.daJson(Map<String, dynamic> json) => RigaSync(
    tabella: json['tabella'] as String,
    id: json['id'] as String,
    aggiornata: (json['aggiornata'] as num).toInt(),
    dati: (json['dati'] as Map<Object?, Object?>).cast<String, dynamic>(),
  );

  /// Il nome della tabella, per esempio "attivita".
  final String tabella;

  final String id;

  /// La data di modifica in millisecondi: decide chi vince.
  final int aggiornata;

  /// La riga intera, come la produce `toJson()` di drift.
  final Map<String, dynamic> dati;

  /// L'impronta del contenuto, calcolata una volta.
  ///
  /// I campi vuoti (`null`) non contano: una riga scritta da una versione
  /// dell'app che non ha ancora una colonna nuova (la chiave manca) è uguale
  /// alla stessa riga con la colonna vuota. Senza, due versioni diverse si
  /// rimanderebbero le righe a ogni sincronizzazione (voce 032).
  late final String impronta = logica.impronta(<String, dynamic>{
    for (final MapEntry<String, dynamic> campo in dati.entries)
      if (campo.value != null) campo.key: campo.value,
  });

  /// "tabella/id", come il server indica le righe rifiutate.
  String get chiave => '$tabella/$id';

  /// Per la richiesta al server.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'tabella': tabella,
    'id': id,
    'aggiornata': aggiornata,
    'dati': dati,
  };
}

/// Una tabella dell'app che si sincronizza: come leggerla, scriverla e
/// sapere quando è stata modificata una riga.
class TabellaSync<T extends DataClass> {
  const TabellaSync(this.tabella, this.daJson, this.aggiornata);

  final TableInfo<Table, T> tabella;

  /// Costruisce la riga dal JSON di `toJson()`.
  final T Function(Map<String, dynamic> json) daJson;

  /// La data di modifica della riga.
  final DateTime Function(T riga) aggiornata;

  /// Il nome della tabella nel database, che è anche quello per il server.
  String get nome => tabella.actualTableName;

  /// Tutte le righe, cestinate comprese, per id.
  Future<Map<String, T>> tutte(GeneratedDatabase db) async {
    final List<T> righe = await db.select(tabella).get();
    return <String, T>{for (final T r in righe) r.toJson()['id'] as String: r};
  }

  /// La riga [riga] come viaggia verso il server.
  RigaSync perServer(T riga) {
    final Map<String, dynamic> dati = riga.toJson();
    return RigaSync(
      tabella: nome,
      id: dati['id'] as String,
      aggiornata: aggiornata(riga).millisecondsSinceEpoch,
      dati: dati,
    );
  }

  /// Scrive (o sovrascrive) la riga arrivata dal server.
  Future<void> scrivi(GeneratedDatabase db, Map<String, dynamic> dati) {
    return db
        .into(tabella)
        .insertOnConflictUpdate(daJson(dati) as Insertable<T>);
  }
}

/// Le chiavi delle preferenze.
abstract final class ChiaviPreferenze {
  static const String indirizzo = 'server.indirizzo';
  static const String token = 'server.token';
  static const String revisione = 'sync.revisione';
  static const String dispositivo = 'sync.dispositivo';
  static const String ultima = 'sync.ultima';
  static const String automatica = 'sync.automatica';
}

/// Letture e scritture della sincronizzazione: preferenze, righe da
/// mandare, righe ricevute.
@DriftAccessor(tables: <Type>[NoteSync, Preferenze])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.attachedDatabase);

  /// Le tabelle che si sincronizzano, nell'ordine in cui applicarle: prima
  /// quelle a cui le altre rimandano.
  List<TabellaSync<DataClass>> get tabelle => <TabellaSync<DataClass>>[
    TabellaSync<Argomento>(
      attachedDatabase.argomenti,
      Argomento.fromJson,
      (Argomento r) => r.aggiornatoIl,
    ),
    TabellaSync<Tipologia>(
      attachedDatabase.tipologie,
      Tipologia.fromJson,
      (Tipologia r) => r.aggiornataIl,
    ),
    TabellaSync<Modello>(
      attachedDatabase.modelli,
      Modello.fromJson,
      (Modello r) => r.aggiornatoIl,
    ),
    TabellaSync<VoceModello>(
      attachedDatabase.vociModello,
      VoceModello.fromJson,
      (VoceModello r) => r.aggiornataIl,
    ),
    TabellaSync<Attivita>(
      attachedDatabase.elencoAttivita,
      Attivita.fromJson,
      (Attivita r) => r.aggiornataIl,
    ),
    TabellaSync<Foto>(
      attachedDatabase.elencoFoto,
      Foto.fromJson,
      (Foto r) => r.aggiornataIl,
    ),
  ];

  /// I nomi delle tabelle che si sincronizzano.
  Set<String> get nomiTabelle =>
      tabelle.map((TabellaSync<DataClass> t) => t.nome).toSet();

  // --- Preferenze ----------------------------------------------------------

  /// Il valore di una preferenza, o `null`.
  Future<String?> preferenza(String chiave) async {
    final Preferenza? riga = await (select(
      preferenze,
    )..where((t) => t.chiave.equals(chiave))).getSingleOrNull();
    return riga?.valore;
  }

  /// Imposta una preferenza; con `null` la toglie.
  Future<void> impostaPreferenza(String chiave, String? valore) async {
    if (valore == null) {
      await (delete(preferenze)..where((t) => t.chiave.equals(chiave))).go();
      return;
    }
    await into(preferenze).insertOnConflictUpdate(
      PreferenzeCompanion.insert(chiave: chiave, valore: valore),
    );
  }

  // --- Cosa mandare --------------------------------------------------------

  Future<Map<String, String>> _note() async {
    final List<NotaSync> note = await select(noteSync).get();
    return <String, String>{
      for (final NotaSync n in note) '${n.tabella}/${n.id}': n.impronta,
    };
  }

  /// Le righe cambiate qui dall'ultima volta che il server le ha ricevute,
  /// cioè quelle la cui impronta non è quella annotata.
  Future<List<RigaSync>> righeDaInviare() async {
    final Map<String, String> note = await _note();
    final List<RigaSync> sporche = <RigaSync>[];
    for (final TabellaSync<DataClass> t in tabelle) {
      for (final DataClass riga in (await t.tutte(attachedDatabase)).values) {
        final RigaSync r = t.perServer(riga);
        if (note[r.chiave] != r.impronta) {
          sporche.add(r);
        }
      }
    }
    return sporche;
  }

  /// Dimentica cosa ha il server: alla prossima volta si rimanda tutto.
  ///
  /// Serve quando il server è tornato indietro, per esempio ripristinato da
  /// un backup, e potrebbe non avere più righe che qui risultano mandate.
  Future<void> dimenticaNote() => delete(noteSync).go();

  // --- Cosa è arrivato -----------------------------------------------------

  /// Registra l'esito di una sincronizzazione, tutto insieme o niente.
  ///
  /// [accettate] sono le righe mandate e entrate sul server: da ora il
  /// server le ha. [ricevute] sono quelle arrivate dal server: ognuna
  /// prende il posto di quella qui, tranne quando quella qui è cambiata
  /// dopo l'ultima sincronizzazione ed è più recente; allora resta, e
  /// partirà alla prossima (DECISIONI.md, voce 021). Infine si ricorda da
  /// quale [revisione] ripartire.
  Future<void> applica({
    required List<RigaSync> accettate,
    required List<RigaSync> ricevute,
    required int revisione,
  }) {
    return transaction(() async {
      // Le righe arrivano in ordine di revisione, non di dipendenza: una
      // sotto-attività può arrivare prima della sua principale. I vincoli si
      // controllano alla fine, quando ci sono tutte.
      await customStatement('PRAGMA defer_foreign_keys = ON');

      final Map<String, String> note = await _note();
      final Map<String, String> nuoveNote = <String, String>{};
      void annota(RigaSync r, String imp) {
        note[r.chiave] = imp;
        nuoveNote[r.chiave] = imp;
      }

      for (final RigaSync r in accettate) {
        annota(r, r.impronta);
      }

      final Map<String, List<RigaSync>> perTabella = <String, List<RigaSync>>{};
      for (final RigaSync r in ricevute) {
        perTabella.putIfAbsent(r.tabella, () => <RigaSync>[]).add(r);
      }
      for (final TabellaSync<DataClass> t in tabelle) {
        final List<RigaSync>? arrivate = perTabella[t.nome];
        if (arrivate == null) {
          continue;
        }
        final Map<String, DataClass> locali = await t.tutte(attachedDatabase);
        for (final RigaSync r in arrivate) {
          final DataClass? locale = locali[r.id];
          final RigaSync? qui = locale == null ? null : t.perServer(locale);
          if (qui != null && qui.impronta == r.impronta) {
            // Già uguale: basta ricordare che il server ce l'ha.
            annota(r, r.impronta);
            continue;
          }
          final bool cambiataQui =
              qui != null && note[r.chiave] != qui.impronta;
          if (cambiataQui && qui.aggiornata > r.aggiornata) {
            continue;
          }
          await t.scrivi(attachedDatabase, r.dati);
          annota(r, r.impronta);
          // Una riga arrivata due volte (per esempio rifiutata e anche fra
          // le nuove) deve vedere la versione appena scritta.
          locali[r.id] = t.daJson(r.dati);
        }
      }
      // Righe di tabelle che questa versione dell'app non conosce: si
      // ignorano, arriveranno con l'aggiornamento.

      for (final MapEntry<String, String> nota in nuoveNote.entries) {
        final int barra = nota.key.indexOf('/');
        await into(noteSync).insertOnConflictUpdate(
          NoteSyncCompanion.insert(
            tabella: nota.key.substring(0, barra),
            id: nota.key.substring(barra + 1),
            impronta: nota.value,
          ),
        );
      }
      await impostaPreferenza(ChiaviPreferenze.revisione, '$revisione');
    });
  }
}
