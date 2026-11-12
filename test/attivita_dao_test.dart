import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/logica/ricorrenza.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';

import 'supporto.dart';

void main() {
  late AppDatabase db;
  late AttivitaDao dao;

  setUp(() {
    db = databaseInMemoria();
    dao = db.attivitaDao;
  });

  tearDown(() => db.close());

  Future<Attivita> leggi(String id) async => (await dao.trova(id))!;

  test('il primo avvio crea argomenti e tipologie con id fissi', () async {
    final List<Argomento> argomenti = await db.categorieDao.leggiArgomenti();
    expect(argomenti.map((Argomento a) => a.nome), <String>[
      'Lavoro',
      'Personale',
      'Ambulanza',
    ]);
    expect(
      argomenti.singleWhere((Argomento a) => a.predefinito).id,
      'argomento-personale',
    );
    expect(await db.categorieDao.leggiTipologie(), hasLength(3));
  });

  test('senza argomento si usa il predefinito', () async {
    final String id = await dao.crea(titolo: '  Comprare il pane  ');
    final Attivita a = await leggi(id);
    expect(a.argomentoId, 'argomento-personale');
    expect(a.titolo, 'Comprare il pane');
  });

  test('una sotto-attività prende l\'argomento del genitore', () async {
    final String cena = await dao.crea(
      titolo: 'Cena',
      argomentoId: 'argomento-lavoro',
    );
    final String sotto = await dao.crea(
      titolo: 'Ristorante',
      genitoreId: cena,
      argomentoId: 'argomento-ambulanza',
    );
    expect((await leggi(sotto)).argomentoId, 'argomento-lavoro');
  });

  test('le sorelle vanno in fondo, una dopo l\'altra', () async {
    final String cena = await dao.crea(titolo: 'Cena');
    final String a = await dao.crea(titolo: 'A', genitoreId: cena);
    final String b = await dao.crea(titolo: 'B', genitoreId: cena);
    expect((await leggi(a)).ordine, 0);
    expect((await leggi(b)).ordine, 1);
  });

  test('cambiare argomento sposta tutto il sottoalbero', () async {
    final String cena = await dao.crea(titolo: 'Cena');
    final String figlia = await dao.crea(
      titolo: 'Ristorante',
      genitoreId: cena,
    );
    final String nipote = await dao.crea(
      titolo: 'Chiamare',
      genitoreId: figlia,
    );
    await dao.cambiaArgomento(cena, 'argomento-ambulanza');
    for (final String id in <String>[cena, figlia, nipote]) {
      expect((await leggi(id)).argomentoId, 'argomento-ambulanza');
    }
  });

  test(
    'segnaFatta con ancheSotto chiude le aperte e tiene le date vecchie',
    () async {
      final DateTime ieri = DateTime(2026, 11, 9, 10);
      final DateTime oggi = DateTime(2026, 11, 10, 10);
      final String cena = await dao.crea(titolo: 'Cena');
      final String aperta = await dao.crea(titolo: 'A', genitoreId: cena);
      final String giaFatta = await dao.crea(titolo: 'B', genitoreId: cena);
      await dao.segnaFatta(giaFatta, true, adesso: ieri);

      await dao.segnaFatta(cena, true, ancheSotto: true, adesso: oggi);
      expect((await leggi(cena)).fattaIl, oggi);
      expect((await leggi(aperta)).fattaIl, oggi);
      expect((await leggi(giaFatta)).fattaIl, ieri);

      // Riaprire riapre solo lei.
      await dao.segnaFatta(cena, false);
      expect((await leggi(cena)).fattaIl, isNull);
      expect((await leggi(aperta)).fattaIl, oggi);
    },
  );

  test('segnaFatta senza ancheSotto lascia aperte le sotto-attività', () async {
    final String cena = await dao.crea(titolo: 'Cena');
    final String figlia = await dao.crea(titolo: 'A', genitoreId: cena);
    await dao.segnaFatta(cena, true);
    expect((await leggi(figlia)).fattaIl, isNull);
  });

  test('cestino e ripristino di un sottoalbero', () async {
    final String cena = await dao.crea(titolo: 'Cena');
    final String figlia = await dao.crea(
      titolo: 'Ristorante',
      genitoreId: cena,
    );
    final String sola = await dao.crea(titolo: 'Invitati', genitoreId: cena);

    // Una sotto-attività cestinata prima, da sola.
    await dao.spostaNelCestino(sola, adesso: DateTime(2026, 11, 9, 8));
    await dao.spostaNelCestino(cena, adesso: DateTime(2026, 11, 10, 9));

    final List<Attivita> cestinate = await dao.osservaCestino().first;
    expect(cestinate, hasLength(3));
    expect(
      radiciDelCestino(cestinate).map((Attivita a) => a.id).toSet(),
      <String>{cena, sola},
    );

    // Il ripristino riporta indietro solo quello cestinato insieme.
    await dao.ripristina(cena);
    expect((await leggi(cena)).cancellataIl, isNull);
    expect((await leggi(figlia)).cancellataIl, isNull);
    expect((await leggi(sola)).cancellataIl, isNotNull);
  });

  test(
    'ripristinare una sotto-attività riporta fuori anche il genitore',
    () async {
      final String cena = await dao.crea(titolo: 'Cena');
      final String altra = await dao.crea(titolo: 'Altra', genitoreId: cena);
      final String sola = await dao.crea(titolo: 'Invitati', genitoreId: cena);
      await dao.spostaNelCestino(sola, adesso: DateTime(2026, 11, 9, 8));
      await dao.spostaNelCestino(cena, adesso: DateTime(2026, 11, 10, 9));

      await dao.ripristina(sola);
      expect((await leggi(sola)).cancellataIl, isNull);
      expect((await leggi(cena)).cancellataIl, isNull);
      // L'altra sotto-attività del genitore resta nel cestino.
      expect((await leggi(altra)).cancellataIl, isNotNull);
    },
  );

  test('sposta su e giù fra le sorelle', () async {
    final String cena = await dao.crea(titolo: 'Cena');
    final String a = await dao.crea(titolo: 'A', genitoreId: cena);
    final String b = await dao.crea(titolo: 'B', genitoreId: cena);
    final String c = await dao.crea(titolo: 'C', genitoreId: cena);

    await dao.sposta(c, Direzione.su);
    Future<List<String>> ordine() async {
      final List<Attivita> tutte = await dao.osservaTutte().first;
      final List<Attivita> figlie =
          tutte.where((Attivita x) => x.genitoreId == cena).toList()
            ..sort((Attivita x, Attivita y) => x.ordine.compareTo(y.ordine));
      return figlie.map((Attivita x) => x.titolo).toList();
    }

    expect(await ordine(), <String>['A', 'C', 'B']);
    await dao.sposta(a, Direzione.giu);
    expect(await ordine(), <String>['C', 'A', 'B']);
    // Oltre il bordo non succede niente.
    await dao.sposta(b, Direzione.giu);
    expect(await ordine(), <String>['C', 'A', 'B']);
  });

  test('aggiorna scrive i campi e la data di modifica', () async {
    // Date fisse tutte e due: con la creazione all'ora vera, passato
    // `quando` la data di modifica sarebbe "un secondo dopo la creazione"
    // (voce 021) e la prova fallirebbe a seconda del giorno.
    final String id = await dao.crea(
      titolo: 'Bollo',
      adesso: DateTime(2026, 11, 1),
    );
    final DateTime quando = DateTime(2026, 11, 12, 9);
    await dao.aggiorna(
      id,
      ElencoAttivitaCompanion(
        scadenza: Value<DateTime?>(DateTime(2026, 11, 30)),
      ),
      adesso: quando,
    );
    final Attivita a = await leggi(id);
    expect(a.scadenza, DateTime(2026, 11, 30));
    expect(a.aggiornataIl, quando);
  });

  group('ricorrenze', () {
    test(
      'chiudendola nasce la prossima volta, con le sotto-attività',
      () async {
        final DateTime creata = DateTime(2026, 11, 2, 9);
        final String bolletta = await dao.crea(
          titolo: 'Pagare la bolletta',
          descrizione: 'Dal sito',
          scadenza: DateTime(2026, 11, 10),
          tipologiaId: 'tipologia-burocrazia',
          nelCalendario: true,
          ricorrenza: const Ricorrenza(UnitaRicorrenza.mese),
          adesso: creata,
        );
        final String lettura = await dao.crea(
          titolo: 'Leggere il contatore',
          genitoreId: bolletta,
          scadenza: DateTime(2026, 11, 8, 18),
          scadenzaConOra: true,
          adesso: creata,
        );
        await dao.segnaFatta(lettura, true, adesso: DateTime(2026, 11, 8));

        final String? prossima = await dao.segnaFatta(
          bolletta,
          true,
          adesso: DateTime(2026, 11, 9, 12),
        );

        // La vecchia è fatta e non si ripete più: la ricorrenza è passata.
        final Attivita vecchia = await leggi(bolletta);
        expect(vecchia.fattaIl, isNotNull);
        expect(vecchia.ricorrenza, isNull);

        final Attivita nuova = await leggi(prossima!);
        expect(nuova.titolo, 'Pagare la bolletta');
        expect(nuova.descrizione, 'Dal sito');
        expect(nuova.scadenza, DateTime(2026, 12, 10));
        expect(nuova.fattaIl, isNull);
        expect(nuova.tipologiaId, 'tipologia-burocrazia');
        expect(nuova.nelCalendario, isTrue);
        expect(nuova.ricorrenza, 'mese:1');
        expect(nuova.creataIl, DateTime(2026, 11, 9, 12));

        // La sotto-attività c'è di nuovo, da fare, spostata di un mese (30
        // giorni, come la principale) con la sua ora.
        final List<Attivita> sotto = await (db.select(
          db.elencoAttivita,
        )..where((t) => t.genitoreId.equals(prossima))).get();
        expect(sotto.single.titolo, 'Leggere il contatore');
        expect(sotto.single.fattaIl, isNull);
        expect(sotto.single.scadenza, DateTime(2026, 12, 8, 18));
        expect(sotto.single.scadenzaConOra, isTrue);
      },
    );

    test('riaprire e richiudere la vecchia non crea un doppione', () async {
      final String id = await dao.crea(
        titolo: 'Innaffiare',
        scadenza: DateTime(2026, 11, 10),
        ricorrenza: const Ricorrenza(UnitaRicorrenza.settimana),
      );
      expect(await dao.segnaFatta(id, true), isNotNull);
      await dao.segnaFatta(id, false);
      expect(await dao.segnaFatta(id, true), isNull);
      final List<Attivita> tutte = await db.select(db.elencoAttivita).get();
      expect(tutte, hasLength(2));
    });

    test('chiusa insieme alla principale, una sotto non si ripete', () async {
      final String cena = await dao.crea(titolo: 'Cena');
      final String spesa = await dao.crea(
        titolo: 'Spesa',
        genitoreId: cena,
        ricorrenza: const Ricorrenza(UnitaRicorrenza.giorno),
      );
      await dao.segnaFatta(cena, true, ancheSotto: true);
      expect((await leggi(spesa)).fattaIl, isNotNull);
      expect(await db.select(db.elencoAttivita).get(), hasLength(2));
    });
  });

  group('argomenti e tipologie', () {
    test('trovaOCreaTipologia riconosce il plurale e crea le nuove', () async {
      final Tipologia acquisto = await db.categorieDao.trovaOCreaTipologia(
        'acquisti',
      );
      expect(acquisto.id, 'tipologia-acquisto');
      final Tipologia nuova = await db.categorieDao.trovaOCreaTipologia(
        'manutenzione-mezzi',
      );
      expect(nuova.nome, 'Manutenzione mezzi');
      expect(await db.categorieDao.leggiTipologie(), hasLength(4));
    });

    test('un argomento usato o predefinito non si toglie', () async {
      await dao.crea(titolo: 'Turno', argomentoId: 'argomento-ambulanza');
      expect(
        () => db.categorieDao.cancellaArgomento('argomento-ambulanza'),
        throwsException,
      );
      expect(
        () => db.categorieDao.cancellaArgomento('argomento-personale'),
        throwsException,
      );
      await db.categorieDao.cancellaArgomento('argomento-lavoro');
      expect(await db.categorieDao.leggiArgomenti(), hasLength(2));
    });

    test('togliere una tipologia la toglie dalle attività', () async {
      final String id = await dao.crea(
        titolo: 'Chiamare',
        tipologiaId: 'tipologia-telefonata',
      );
      await db.categorieDao.cancellaTipologia('tipologia-telefonata');
      expect((await leggi(id)).tipologiaId, isNull);
    });

    test('rendiPredefinito lascia un solo predefinito', () async {
      await db.categorieDao.rendiPredefinito('argomento-ambulanza');
      final List<Argomento> argomenti = await db.categorieDao.leggiArgomenti();
      expect(
        argomenti
            .where((Argomento a) => a.predefinito)
            .map((Argomento a) => a.id),
        <String>['argomento-ambulanza'],
      );
    });
  });
}
