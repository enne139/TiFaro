import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_dao.dart';
import 'package:tifaro/features/sincronizzazione/logica/impronta.dart';

import 'supporto.dart';

void main() {
  late AppDatabase db;
  late SyncDao dao;

  setUp(() {
    db = databaseInMemoria();
    dao = db.syncDao;
  });

  tearDown(() => db.close());

  /// Una riga di attività come la manderebbe il server.
  RigaSync remota(
    String id, {
    required String titolo,
    required DateTime aggiornata,
    String? genitore,
  }) {
    final Attivita a = Attivita(
      id: id,
      titolo: titolo,
      descrizione: '',
      creataIl: DateTime(2026, 11, 1),
      scadenzaConOra: false,
      argomentoId: 'argomento-lavoro',
      genitoreId: genitore,
      ordine: 0,
      nelCalendario: false,
      aggiornataIl: aggiornata,
    );
    return RigaSync(
      tabella: 'attivita',
      id: id,
      aggiornata: aggiornata.millisecondsSinceEpoch,
      dati: a.toJson(),
    );
  }

  /// Segna tutto come già sul server, come dopo una sincronizzazione.
  Future<void> tuttoInviato() async => dao.applica(
    accettate: await dao.righeDaInviare(),
    ricevute: const <RigaSync>[],
    revisione: 1,
  );

  test('l\'impronta non dipende dall\'ordine delle chiavi', () {
    expect(
      impronta(<String, dynamic>{'a': 1, 'b': 'x'}),
      impronta(<String, dynamic>{'b': 'x', 'a': 1}),
    );
    expect(
      impronta(<String, dynamic>{'a': 1}),
      isNot(impronta(<String, dynamic>{'a': 2})),
    );
  });

  test('all\'inizio va mandato tutto, dopo solo quello che cambia', () async {
    // Argomenti e tipologie di partenza.
    expect(await dao.righeDaInviare(), hasLength(6));
    await tuttoInviato();
    expect(await dao.righeDaInviare(), isEmpty);

    final String id = await db.attivitaDao.crea(titolo: 'Pane');
    final List<RigaSync> sporche = await dao.righeDaInviare();
    expect(sporche.single.id, id);

    await tuttoInviato();
    // Una modifica nello stesso secondo si vede lo stesso: si confronta il
    // contenuto, non la data.
    await db.attivitaDao.aggiorna(
      id,
      const ElencoAttivitaCompanion(titolo: Value<String>('Pane integrale')),
      adesso: (await db.attivitaDao.trova(id))!.aggiornataIl,
    );
    expect((await dao.righeDaInviare()).single.id, id);
  });

  test('una riga arrivata più recente sostituisce quella di qui', () async {
    final String id = await db.attivitaDao.crea(
      titolo: 'Vecchio',
      adesso: DateTime(2026, 11, 1),
    );
    await tuttoInviato();
    await dao.applica(
      accettate: const <RigaSync>[],
      ricevute: <RigaSync>[
        remota(id, titolo: 'Dal pc', aggiornata: DateTime(2026, 11, 2)),
      ],
      revisione: 5,
    );
    expect((await db.attivitaDao.trova(id))!.titolo, 'Dal pc');
    expect(await dao.righeDaInviare(), isEmpty);
    expect(await dao.preferenza(ChiaviPreferenze.revisione), '5');
  });

  test('una modifica fatta qui e più recente resta, e partirà dopo', () async {
    final String id = await db.attivitaDao.crea(
      titolo: 'Inizio',
      adesso: DateTime(2026, 11, 1),
    );
    await tuttoInviato();
    await db.attivitaDao.aggiorna(
      id,
      const ElencoAttivitaCompanion(titolo: Value<String>('Cambiato qui')),
      adesso: DateTime(2026, 11, 3),
    );
    await dao.applica(
      accettate: const <RigaSync>[],
      ricevute: <RigaSync>[
        remota(id, titolo: 'Più vecchia', aggiornata: DateTime(2026, 11, 2)),
      ],
      revisione: 6,
    );
    expect((await db.attivitaDao.trova(id))!.titolo, 'Cambiato qui');
    expect((await dao.righeDaInviare()).single.id, id);
  });

  test('una sotto-attività può arrivare prima della sua principale', () async {
    await dao.applica(
      accettate: const <RigaSync>[],
      ricevute: <RigaSync>[
        remota(
          'figlia',
          titolo: 'Figlia',
          aggiornata: DateTime(2026, 11, 2),
          genitore: 'madre',
        ),
        remota('madre', titolo: 'Madre', aggiornata: DateTime(2026, 11, 2)),
      ],
      revisione: 2,
    );
    expect((await db.attivitaDao.trova('figlia'))!.genitoreId, 'madre');
  });

  test(
    'una riga senza una colonna nuova vale come quella colonna vuota',
    () async {
      // Così una versione vecchia dell'app, che non conosce la colonna, e una
      // nuova non si rimandano le righe a ogni giro (voce 032).
      final RigaSync conChiave = remota(
        'a1',
        titolo: 'Riga',
        aggiornata: DateTime(2026, 11, 2),
      );
      final Map<String, dynamic> senza = Map<String, dynamic>.of(conChiave.dati)
        ..remove('ricorrenza');
      expect(conChiave.dati.containsKey('ricorrenza'), isTrue);
      final RigaSync vecchia = RigaSync(
        tabella: 'attivita',
        id: 'a1',
        aggiornata: conChiave.aggiornata,
        dati: senza,
      );
      expect(vecchia.impronta, conChiave.impronta);

      // Arrivata senza la chiave, si scrive con la colonna vuota e non
      // risulta da rimandare.
      await dao.applica(
        accettate: const <RigaSync>[],
        ricevute: <RigaSync>[vecchia],
        revisione: 5,
      );
      expect((await db.attivitaDao.trova('a1'))!.ricorrenza, isNull);
      final List<RigaSync> daMandare = await dao.righeDaInviare();
      expect(daMandare.where((RigaSync r) => r.id == 'a1'), isEmpty);
    },
  );

  test('le tabelle sconosciute si ignorano', () async {
    await dao.applica(
      accettate: const <RigaSync>[],
      ricevute: <RigaSync>[
        RigaSync(
          tabella: 'del_futuro',
          id: 'x',
          aggiornata: 1,
          dati: <String, dynamic>{'id': 'x'},
        ),
      ],
      revisione: 3,
    );
    expect(await dao.preferenza(ChiaviPreferenze.revisione), '3');
  });
}
