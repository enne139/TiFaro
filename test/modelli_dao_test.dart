import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/modelli/data/modelli_dao.dart';
import 'package:tifaro/features/modelli/logica/albero_voci.dart';

import 'supporto.dart';

void main() {
  late AppDatabase db;
  late ModelliDao modelli;
  late AttivitaDao attivita;

  // Martedì 10 novembre 2026, alle 14:30.
  final DateTime adesso = DateTime(2026, 11, 10, 14, 30);

  setUp(() {
    db = databaseInMemoria();
    modelli = db.modelliDao;
    attivita = db.attivitaDao;
  });

  tearDown(() => db.close());

  Future<IndiceAttivita> indice() async =>
      IndiceAttivita(await attivita.osservaTutte().first);

  Future<AlberoVoci> voci() async =>
      AlberoVoci(await modelli.osservaVoci().first);

  /// Il modello "Turno": scade 4 giorni dopo la creazione, con tre voci.
  Future<String> modelloTurno() async {
    final String id = await modelli.creaModello(
      'Turno in ambulanza',
      descrizione: 'Il turno del sabato',
      argomentoId: 'argomento-ambulanza',
      giorni: 4,
      nelCalendario: true,
    );
    final String divisa = await modelli.creaVoce(
      modelloId: id,
      titolo: 'Controllare la divisa',
      giorni: -1,
    );
    await modelli.creaVoce(
      modelloId: id,
      genitoreId: divisa,
      titolo: 'Lavarla',
      giorni: -2,
    );
    await modelli.creaVoce(
      modelloId: id,
      titolo: 'Firmare il foglio',
      giorni: 0,
      minuti: 20 * 60,
      tipologiaId: 'tipologia-burocrazia',
    );
    await modelli.creaVoce(modelloId: id, titolo: 'Senza scadenza');
    return id;
  }

  test('creaDaModello copia l\'albero con le scadenze relative', () async {
    final String modelloId = await modelloTurno();
    final String id = await modelli.creaDaModello(modelloId, adesso: adesso);

    final IndiceAttivita i = await indice();
    final Attivita radice = i[id]!;
    expect(radice.titolo, 'Turno in ambulanza');
    expect(radice.descrizione, 'Il turno del sabato');
    expect(radice.argomentoId, 'argomento-ambulanza');
    expect(radice.scadenza, DateTime(2026, 11, 14));
    expect(radice.nelCalendario, isTrue);
    expect(radice.modelloId, modelloId);

    final List<Attivita> figlie = i.figlie(id);
    expect(figlie.map((Attivita a) => a.titolo), <String>[
      'Controllare la divisa',
      'Firmare il foglio',
      'Senza scadenza',
    ]);
    expect(figlie[0].scadenza, DateTime(2026, 11, 13));
    expect(figlie[1].scadenza, DateTime(2026, 11, 14, 20));
    expect(figlie[1].scadenzaConOra, isTrue);
    expect(figlie[1].tipologiaId, 'tipologia-burocrazia');
    expect(figlie[2].scadenza, isNull);
    // Le sotto-attività prendono l'argomento della principale e non il
    // modello: il modello si segna solo sulla principale.
    expect(figlie[0].argomentoId, 'argomento-ambulanza');
    expect(figlie[0].modelloId, isNull);

    final Attivita nipote = i.figlie(figlie[0].id).single;
    expect(nipote.titolo, 'Lavarla');
    expect(nipote.scadenza, DateTime(2026, 11, 12));
  });

  test(
    'con una scadenza scelta, le sotto-attività si spostano con lei',
    () async {
      final String modelloId = await modelloTurno();
      final String id = await modelli.creaDaModello(
        modelloId,
        titolo: 'Turno di Natale',
        scadenza: Value<DateTime?>(DateTime(2026, 12, 24)),
        adesso: adesso,
      );
      final IndiceAttivita i = await indice();
      expect(i[id]!.titolo, 'Turno di Natale');
      expect(i[id]!.scadenza, DateTime(2026, 12, 24));
      final List<Attivita> figlie = i.figlie(id);
      expect(figlie[0].scadenza, DateTime(2026, 12, 23));
      expect(figlie[1].scadenza, DateTime(2026, 12, 24, 20));
    },
  );

  test('senza scadenza della principale, si conta dalla creazione', () async {
    final String modelloId = await modelloTurno();
    final String id = await modelli.creaDaModello(
      modelloId,
      scadenza: const Value<DateTime?>(null),
      adesso: adesso,
    );
    final IndiceAttivita i = await indice();
    expect(i[id]!.scadenza, isNull);
    expect(i.figlie(id)[0].scadenza, DateTime(2026, 11, 9));
  });

  test(
    'creaDaModello sotto un\'altra attività eredita il suo argomento',
    () async {
      final String modelloId = await modelloTurno();
      final String padre = await attivita.crea(
        titolo: 'Dicembre',
        argomentoId: 'argomento-lavoro',
      );
      final String id = await modelli.creaDaModello(
        modelloId,
        genitoreId: padre,
        adesso: adesso,
      );
      final IndiceAttivita i = await indice();
      expect(i[id]!.genitoreId, padre);
      expect(i[id]!.argomentoId, 'argomento-lavoro');
      expect(i.discendenti(padre), hasLength(5));
    },
  );

  test('salvaComeModello rende relative le date e salta il cestino', () async {
    final String radice = await attivita.crea(
      titolo: 'Revisione auto',
      argomentoId: 'argomento-personale',
      tipologiaId: 'tipologia-burocrazia',
      scadenza: DateTime(2026, 11, 5),
      adesso: DateTime(2026, 11, 1, 9),
    );
    final String prenotare = await attivita.crea(
      titolo: 'Prenotare',
      genitoreId: radice,
      scadenza: DateTime(2026, 11, 4, 18),
      scadenzaConOra: true,
    );
    await attivita.segnaFatta(prenotare, true);
    await attivita.crea(titolo: 'Portare i documenti', genitoreId: prenotare);
    final String tolta = await attivita.crea(
      titolo: 'Tolta',
      genitoreId: radice,
    );
    await attivita.spostaNelCestino(tolta);

    final String modelloId = await modelli.salvaComeModello(
      radice,
      'Revisione',
    );
    final Modello m = (await modelli.trovaModello(modelloId))!;
    expect(m.nome, 'Revisione');
    expect(m.argomentoId, 'argomento-personale');
    expect(m.tipologiaId, 'tipologia-burocrazia');
    expect(m.giorni, 4);
    expect(m.minuti, isNull);

    final AlberoVoci v = await voci();
    final List<({VoceModello voce, int livello})> righe = v.inOrdine(modelloId);
    expect(righe.map((r) => (r.voce.titolo, r.livello)), <(String, int)>[
      ('Prenotare', 0),
      ('Portare i documenti', 1),
    ]);
    expect(righe[0].voce.giorni, -1);
    expect(righe[0].voce.minuti, 18 * 60);
    expect(righe[1].voce.giorni, isNull);
  });

  test('cancellaVoce toglie anche le sotto-voci', () async {
    final String modelloId = await modelloTurno();
    final String divisa = (await voci())
        .figlie(modelloId, null)
        .firstWhere((VoceModello x) => x.titolo == 'Controllare la divisa')
        .id;
    await modelli.cancellaVoce(divisa);
    expect((await voci()).quante(modelloId), 2);
  });

  test('spostaVoce cambia l\'ordine fra sorelle', () async {
    final String modelloId = await modelloTurno();
    final String ultima = (await voci()).figlie(modelloId, null).last.id;
    await modelli.spostaVoce(ultima, Direzione.su);
    expect(
      (await voci()).figlie(modelloId, null).map((VoceModello x) => x.titolo),
      <String>['Controllare la divisa', 'Senza scadenza', 'Firmare il foglio'],
    );
  });

  test(
    'cancellaModello toglie modello e voci, non le attività create',
    () async {
      final String modelloId = await modelloTurno();
      final String id = await modelli.creaDaModello(modelloId, adesso: adesso);
      await modelli.cancellaModello(modelloId);
      expect(await modelli.osservaModelli().first, isEmpty);
      expect((await voci()).quante(modelloId), 0);
      expect((await indice())[id], isNotNull);
    },
  );

  test('togliere una tipologia o un argomento sistema i modelli', () async {
    final String modelloId = await modelloTurno();
    await db.categorieDao.cancellaTipologia('tipologia-burocrazia');
    final AlberoVoci v = await voci();
    expect(
      v.inOrdine(modelloId).every((r) => r.voce.tipologiaId == null),
      isTrue,
    );
    await db.categorieDao.cancellaArgomento('argomento-ambulanza');
    expect((await modelli.trovaModello(modelloId))!.argomentoId, isNull);
  });

  test(
    'creaDaModello riempie le variabili, anche nelle sotto-attività',
    () async {
      final String modelloId = await modelli.creaModello(
        'Turno a {luogo}',
        descrizione: 'Con {persona}, il {data}',
        giorni: 3,
      );
      await modelli.creaVoce(
        modelloId: modelloId,
        titolo: 'Chiamare {persona}',
        descrizione: 'Preparato il {oggi}',
      );
      await modelli.creaVoce(modelloId: modelloId, titolo: 'Portare {cosa}');
      final String id = await modelli.creaDaModello(
        modelloId,
        variabili: <String, String>{'Luogo': 'Gallarate', 'persona': 'Marco'},
        adesso: adesso,
      );
      final IndiceAttivita i = await indice();
      expect(i[id]!.titolo, 'Turno a Gallarate');
      // {data} è la scadenza della principale: tre giorni dopo.
      expect(i[id]!.descrizione, 'Con Marco, il ven 13 nov');
      final List<Attivita> figlie = i.figlie(id);
      expect(figlie[0].titolo, 'Chiamare Marco');
      expect(figlie[0].descrizione, 'Preparato il mar 10 nov');
      // Una variabile senza valore resta scritta, per sistemarla dopo.
      expect(figlie[1].titolo, 'Portare {cosa}');
    },
  );
}
