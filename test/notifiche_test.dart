import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/notifiche/logica/avvisi.dart';
import 'package:tifaro/features/notifiche/notifiche_dispositivo.dart';
import 'package:tifaro/features/notifiche/pianificatore_notifiche.dart';

import 'supporto.dart';

/// Le notifiche finte: ricordano cosa è programmato.
class NotificheFinte implements NotificheDispositivo {
  final Map<int, AvvisoVoluto> avvisi = <int, AvvisoVoluto>{};
  int programmazioni = 0;
  bool permesso = true;

  @override
  bool get ancheAppChiusa => true;

  @override
  Future<void> prepara(void Function(String? carico) alTocco) async {}

  @override
  Future<String?> caricoDiAvvio() async => null;

  @override
  Future<bool> haPermesso() async => permesso;

  @override
  Future<bool> chiediPermesso() async => permesso = true;

  @override
  Future<bool> orariPrecisi() async => true;

  @override
  Future<void> chiediOrariPrecisi() async {}

  @override
  Future<List<AvvisoProgrammato>> programmati() async => <AvvisoProgrammato>[
    for (final AvvisoVoluto a in avvisi.values)
      AvvisoProgrammato(id: a.id, firma: a.firma),
  ];

  @override
  Future<void> programma(AvvisoVoluto avviso) async {
    programmazioni += 1;
    avvisi[avviso.id] = avviso;
  }

  @override
  Future<void> togli(int id) async => avvisi.remove(id);

  @override
  Future<void> mostraSubito({
    required String titolo,
    required String testo,
  }) async {}
}

void main() {
  // Martedì 10 novembre 2026, alle 14:30.
  final DateTime adesso = DateTime(2026, 11, 10, 14, 30);

  Attivita attivita(
    String id, {
    DateTime? scadenza,
    bool conOra = false,
    bool fatta = false,
    String? genitore,
    DateTime? creata,
  }) => Attivita(
    id: id,
    titolo: 'Attività $id',
    descrizione: '',
    creataIl: creata ?? DateTime(2026, 11, 1),
    scadenza: scadenza,
    scadenzaConOra: conOra,
    fattaIl: fatta ? DateTime(2026, 11, 2) : null,
    argomentoId: 'argomento-lavoro',
    genitoreId: genitore,
    ordine: 0,
    nelCalendario: false,
    aggiornataIl: DateTime(2026, 11, 1),
  );

  group('avvisiVoluti', () {
    test(
      'un avviso all\'ora per chi ha l\'ora, un riepilogo per gli altri',
      () {
        final List<AvvisoVoluto> avvisi = avvisiVoluti(
          IndiceAttivita(<Attivita>[
            attivita('a', scadenza: DateTime(2026, 11, 10, 18), conOra: true),
            attivita('b', scadenza: DateTime(2026, 11, 11)),
            attivita(
              'c',
              scadenza: DateTime(2026, 11, 11),
              creata: DateTime(2026),
            ),
            attivita('d', scadenza: DateTime(2026, 11, 12)),
          ]),
          adesso: adesso,
        );
        expect(avvisi.map((AvvisoVoluto a) => a.quando), <DateTime>[
          DateTime(2026, 11, 10, 18),
          DateTime(2026, 11, 11, 9),
          DateTime(2026, 11, 12, 9),
        ]);
        expect(avvisi[0].titolo, 'Attività a');
        expect(avvisi[0].testo, 'Scade alle 18:00');
        expect(avvisi[0].attivitaId, 'a');
        // Due lo stesso giorno: un riepilogo, dalla più vecchia, che apre Oggi.
        expect(avvisi[1].titolo, 'Oggi scadono 2 attività');
        expect(avvisi[1].testo, 'Attività c, Attività b');
        expect(avvisi[1].attivitaId, isNull);
        expect(avvisi[1].id, 20261111);
        // Una sola: il riepilogo è lei, e apre lei.
        expect(avvisi[2].titolo, 'Attività d');
        expect(avvisi[2].attivitaId, 'd');
      },
    );

    test('niente per le fatte, le passate e quelle troppo lontane', () {
      final List<AvvisoVoluto> avvisi = avvisiVoluti(
        IndiceAttivita(<Attivita>[
          attivita('fatta', scadenza: DateTime(2026, 11, 12), fatta: true),
          attivita(
            'passata',
            scadenza: DateTime(2026, 11, 10, 9),
            conOra: true,
          ),
          // Oggi senza ora: il riepilogo delle 9 è già passato.
          attivita('oggi', scadenza: DateTime(2026, 11, 10)),
          attivita('lontana', scadenza: DateTime(2027, 3, 1)),
          attivita('senza'),
        ]),
        adesso: adesso,
      );
      expect(avvisi, isEmpty);
    });

    test('l\'ora del riepilogo si sceglie, e il carico porta l\'attività', () {
      final AvvisoVoluto a = avvisiVoluti(
        IndiceAttivita(<Attivita>[
          attivita('x', scadenza: DateTime(2026, 11, 10)),
        ]),
        adesso: adesso,
        oraRiepilogo: 20 * 60 + 15,
      ).single;
      expect(a.quando, DateTime(2026, 11, 10, 20, 15));
      expect(attivitaDelCarico(a.carico), 'x');
      expect(attivitaDelCarico('123|'), isNull);
      expect(attivitaDelCarico(null), isNull);
    });

    test('i numeri degli avvisi sono stabili e non si toccano', () {
      expect(idAvvisoAttivita('abc'), idAvvisoAttivita('abc'));
      expect(idAvvisoAttivita('abc'), isNot(idAvvisoAttivita('abd')));
      expect(idAvvisoAttivita('abc'), greaterThanOrEqualTo(1 << 30));
      expect(idAvvisoGiorno(DateTime(2099, 12, 31)), lessThan(1 << 30));
    });
  });

  group('PianificatoreNotifiche', () {
    late AppDatabase db;
    late NotificheFinte finte;
    late PianificatoreNotifiche p;

    setUp(() async {
      db = databaseInMemoria();
      finte = NotificheFinte();
      p = PianificatoreNotifiche(db: db, dispositivo: finte);
      await p.avvia();
    });

    tearDown(() => db.close());

    test('programma, aggiorna e toglie solo quello che cambia', () async {
      final String id = await db.attivitaDao.crea(
        titolo: 'Telefonare',
        scadenza: DateTime(2026, 11, 12, 10),
        scadenzaConOra: true,
      );
      await db.attivitaDao.crea(
        titolo: 'Spesa',
        scadenza: DateTime(2026, 11, 13),
      );
      await p.allinea(adesso: adesso);
      expect(finte.avvisi, hasLength(2));
      expect(finte.programmazioni, 2);
      expect(p.stato.value.programmati, 2);

      // Un altro giro senza cambiamenti non riprogramma niente.
      await p.allinea(adesso: adesso);
      expect(finte.programmazioni, 2);

      // Fatta: il suo avviso sparisce.
      await db.attivitaDao.segnaFatta(id, true);
      await p.allinea(adesso: adesso);
      expect(finte.avvisi.values.single.titolo, 'Spesa');

      // Cambia l'ora del riepilogo: si riprogramma.
      await p.impostaOraRiepilogo(8 * 60);
      await p.allinea(adesso: adesso);
      expect(finte.avvisi.values.single.quando, DateTime(2026, 11, 13, 8));
    });

    test('spenti, gli avvisi programmati si tolgono', () async {
      await db.attivitaDao.crea(
        titolo: 'Spesa',
        scadenza: DateTime(2026, 11, 13),
      );
      await p.allinea(adesso: adesso);
      expect(finte.avvisi, hasLength(1));
      await db.syncDao.impostaPreferenza(ChiaviNotifiche.attive, 'no');
      await p.allinea(adesso: adesso);
      expect(finte.avvisi, isEmpty);
      expect(await p.attive(), isFalse);
    });

    test('il permesso si chiede una volta sola', () async {
      finte.permesso = false;
      await p.chiediPermessoLaPrimaVolta();
      expect(finte.permesso, isTrue);
      finte.permesso = false;
      await p.chiediPermessoLaPrimaVolta();
      expect(finte.permesso, isFalse);
      await p.allinea(adesso: adesso);
      expect(p.stato.value.permesso, isFalse);
      expect(p.stato.value.messaggio, isNotNull);
    });
  });

  testWidgets('toccando un avviso si apre la sua attività', (
    WidgetTester tester,
  ) async {
    final AppDatabase db = databaseInMemoria();
    final String id = (await tester.runAsync(
      () => db.attivitaDao.crea(titolo: 'Ritirare il pacco'),
    ))!;
    final PianificatoreNotifiche p = PianificatoreNotifiche(
      db: db,
      dispositivo: NotificheFinte(),
    );
    await tester.runAsync(p.avvia);
    await avviaApp(tester, db, notifiche: p);

    p.daAprire.value = AperturaDaAvviso(id);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Attività'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ritirare il pacco'), findsOneWidget);
    expect(p.daAprire.value, isNull);

    await chiudiApp(tester);
  });
}
