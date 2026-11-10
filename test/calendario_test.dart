import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/calendario/allineatore_calendario.dart';
import 'package:tifaro/features/calendario/calendario_dispositivo.dart';
import 'package:tifaro/features/calendario/logica/eventi.dart';

import 'supporto.dart';

/// Un calendario finto in memoria, al posto di quello di Android.
class CalendarioFinto implements CalendarioDispositivo {
  bool permesso = true;
  int _prossimo = 100;

  /// Gli eventi per id: in quale calendario e com'è scritto.
  final Map<int, ({int calendario, EventoVoluto evento})> eventi =
      <int, ({int calendario, EventoVoluto evento})>{};

  @override
  bool get disponibile => true;

  @override
  Future<bool> haPermesso() async => permesso;

  @override
  Future<bool> chiediPermesso() async => permesso;

  @override
  Future<List<CalendarioTelefono>> calendari() async =>
      const <CalendarioTelefono>[
        CalendarioTelefono(
          id: 1,
          nome: 'TiFaro',
          account: 'io',
          colore: 0,
          scrivibile: true,
        ),
        CalendarioTelefono(
          id: 2,
          nome: 'Altro',
          account: 'io',
          colore: 0,
          scrivibile: true,
        ),
      ];

  @override
  Future<Map<String, int>> eventiTiFaro(
    int calendarioId,
  ) async => <String, int>{
    for (final MapEntry<int, ({int calendario, EventoVoluto evento})> e
        in eventi.entries)
      if (e.value.calendario == calendarioId) e.value.evento.attivitaId: e.key,
  };

  @override
  Future<int> salva(
    EventoVoluto evento, {
    required int calendarioId,
    int? eventoId,
  }) async {
    // Come Android: si aggiorna solo un evento che c'è ancora, in quel
    // calendario; altrimenti se ne crea uno nuovo.
    final int id =
        eventoId != null && eventi[eventoId]?.calendario == calendarioId
        ? eventoId
        : _prossimo++;
    eventi[id] = (calendario: calendarioId, evento: evento);
    return id;
  }

  @override
  Future<void> togli(int eventoId) async => eventi.remove(eventoId);

  /// I titoli degli eventi nel calendario [calendario].
  List<String> titoli(int calendario) => eventi.values
      .where(
        (({int calendario, EventoVoluto evento}) e) =>
            e.calendario == calendario,
      )
      .map((({int calendario, EventoVoluto evento}) e) => e.evento.titolo)
      .toList();
}

Attivita attivita(
  String id, {
  String? genitore,
  DateTime? scadenza,
  bool conOra = false,
  bool calendario = true,
  DateTime? fatta,
  String argomento = 'argomento-ambulanza',
}) {
  return Attivita(
    id: id,
    titolo: id,
    descrizione: '',
    creataIl: DateTime(2026, 11, 1),
    scadenza: scadenza,
    scadenzaConOra: conOra,
    fattaIl: fatta,
    argomentoId: argomento,
    genitoreId: genitore,
    ordine: 0,
    nelCalendario: calendario,
    aggiornataIl: DateTime(2026, 11, 1),
  );
}

void main() {
  group('eventiVoluti', () {
    final Map<String, Argomento> argomenti = <String, Argomento>{
      'argomento-ambulanza': Argomento(
        id: 'argomento-ambulanza',
        nome: 'Ambulanza',
        // Basilico: colorId 10 di Google Calendar.
        colore: 1,
        icona: 'ambulanza',
        ordine: 0,
        predefinito: false,
        aggiornatoIl: DateTime(2026),
      ),
    };

    test('solo le attività da fare, nel calendario e con una scadenza', () {
      final List<EventoVoluto> eventi = eventiVoluti(
        IndiceAttivita(<Attivita>[
          attivita('si', scadenza: DateTime(2026, 11, 14)),
          attivita('senza-data'),
          attivita(
            'non-segnata',
            scadenza: DateTime(2026, 11, 14),
            calendario: false,
          ),
          attivita(
            'fatta',
            scadenza: DateTime(2026, 11, 14),
            fatta: DateTime(2026, 11, 2),
          ),
        ]),
        argomenti,
      );
      expect(eventi.map((EventoVoluto e) => e.attivitaId), <String>['si']);
    });

    test('senza ora tutto il giorno in UTC, con l\'ora un\'ora', () {
      final List<EventoVoluto> eventi = eventiVoluti(
        IndiceAttivita(<Attivita>[
          attivita('giorno', scadenza: DateTime(2026, 11, 14)),
          attivita('ora', scadenza: DateTime(2026, 11, 14, 20), conOra: true),
        ]),
        argomenti,
      );
      final EventoVoluto giorno = eventi.firstWhere(
        (EventoVoluto e) => e.attivitaId == 'giorno',
      );
      expect(giorno.tuttoIlGiorno, isTrue);
      expect(giorno.inizio, DateTime.utc(2026, 11, 14).millisecondsSinceEpoch);
      expect(giorno.fine, DateTime.utc(2026, 11, 15).millisecondsSinceEpoch);
      final EventoVoluto ora = eventi.firstWhere(
        (EventoVoluto e) => e.attivitaId == 'ora',
      );
      expect(ora.tuttoIlGiorno, isFalse);
      expect(ora.inizio, DateTime(2026, 11, 14, 20).millisecondsSinceEpoch);
      expect(ora.fine, DateTime(2026, 11, 14, 21).millisecondsSinceEpoch);
    });

    test(
      'sotto-attività: la descrizione dice di cosa fa parte; colore di Google',
      () {
        final EventoVoluto e = eventiVoluti(
          IndiceAttivita(<Attivita>[
            attivita('Turno', calendario: false),
            attivita(
              'Divisa',
              genitore: 'Turno',
              scadenza: DateTime(2026, 11, 13),
            ),
          ]),
          argomenti,
        ).single;
        expect(e.descrizione, 'Parte di: Turno');
        expect(e.chiaveColore, '10');
        expect(e.segno, 'tifaro://attivita/Divisa');
      },
    );
  });

  group('pianifica', () {
    EventoVoluto voluto(String id, String titolo) => EventoVoluto(
      attivitaId: id,
      titolo: titolo,
      descrizione: '',
      inizio: 0,
      fine: 1,
      tuttoIlGiorno: true,
    );

    test('crea le nuove, aggiorna le cambiate, toglie le altre', () {
      final EventoVoluto uguale = voluto('uguale', 'Uguale');
      final PianoCalendario piano = pianifica(
        voluti: <EventoVoluto>[
          voluto('nuova', 'Nuova'),
          uguale,
          voluto('cambiata', 'Dopo'),
        ],
        esistenti: <String, EventoEsistente>{
          'uguale': EventoEsistente(
            eventoId: 1,
            calendarioId: 7,
            impronta: uguale.impronta,
          ),
          'cambiata': const EventoEsistente(
            eventoId: 2,
            calendarioId: 7,
            impronta: 'vecchia',
          ),
          'fatta': const EventoEsistente(
            eventoId: 3,
            calendarioId: 7,
            impronta: 'x',
          ),
        },
        calendarioId: 7,
      );
      expect(piano.daCreare.map((EventoVoluto e) => e.attivitaId), <String>[
        'nuova',
      ]);
      expect(piano.daAggiornare.single.eventoId, 2);
      expect(piano.daTogliere.single, (attivitaId: 'fatta', eventoId: 3));
    });

    test('cambiando calendario si toglie dal vecchio e si crea nel nuovo', () {
      final EventoVoluto e = voluto('a', 'A');
      final PianoCalendario piano = pianifica(
        voluti: <EventoVoluto>[e],
        esistenti: <String, EventoEsistente>{
          'a': EventoEsistente(
            eventoId: 1,
            calendarioId: 7,
            impronta: e.impronta,
          ),
        },
        calendarioId: 8,
      );
      expect(piano.daCreare.single.attivitaId, 'a');
      expect(piano.daTogliere.single, (attivitaId: 'a', eventoId: 1));
    });
  });

  group('AllineatoreCalendario', () {
    late AppDatabase db;
    late CalendarioFinto calendario;
    late AllineatoreCalendario allineatore;

    setUp(() {
      db = databaseInMemoria();
      calendario = CalendarioFinto();
      allineatore = AllineatoreCalendario(db: db, dispositivo: calendario);
    });

    tearDown(() => db.close());

    Future<String> nelCalendario(String titolo, DateTime scadenza) => db
        .attivitaDao
        .crea(titolo: titolo, scadenza: scadenza, nelCalendario: true);

    test('spento non fa niente', () async {
      await nelCalendario('Turno', DateTime(2026, 11, 14));
      expect(await allineatore.allinea(), isTrue);
      expect(calendario.eventi, isEmpty);
    });

    test('crea, aggiorna e toglie insieme all\'attività', () async {
      await allineatore.accendi(1);
      final String turno = await nelCalendario('Turno', DateTime(2026, 11, 14));
      await db.attivitaDao.crea(titolo: 'Senza data', nelCalendario: true);
      await allineatore.allinea();
      expect(calendario.titoli(1), <String>['Turno']);
      final int id = calendario.eventi.keys.single;

      await db.attivitaDao.aggiorna(
        turno,
        const ElencoAttivitaCompanion(titolo: Value<String>('Turno di notte')),
      );
      await allineatore.allinea();
      expect(
        calendario.eventi.keys.single,
        id,
        reason: 'stesso evento, aggiornato',
      );
      expect(calendario.titoli(1), <String>['Turno di notte']);

      await db.attivitaDao.segnaFatta(turno, true);
      await allineatore.allinea();
      expect(calendario.eventi, isEmpty);
      expect(await db.calendarioDao.eventi(), isEmpty);
    });

    test(
      'dopo una reinstallazione ritrova gli eventi invece di duplicarli',
      () async {
        await allineatore.accendi(1);
        await nelCalendario('Turno', DateTime(2026, 11, 14));
        await allineatore.allinea();
        // L'app reinstallata non ricorda niente, il calendario sì.
        await db.delete(db.eventiCalendario).go();
        await allineatore.allinea();
        expect(calendario.eventi, hasLength(1));
        expect(await db.calendarioDao.eventi(), hasLength(1));
      },
    );

    test('un evento tolto a mano torna, se l\'attività cambia', () async {
      await allineatore.accendi(1);
      final String turno = await nelCalendario('Turno', DateTime(2026, 11, 14));
      await allineatore.allinea();
      calendario.eventi.clear();
      await db.attivitaDao.aggiorna(
        turno,
        ElencoAttivitaCompanion(
          scadenza: Value<DateTime?>(DateTime(2026, 11, 21)),
        ),
      );
      await allineatore.allinea();
      expect(calendario.titoli(1), <String>['Turno']);
    });

    test('cambiando calendario gli eventi si spostano', () async {
      await allineatore.accendi(1);
      await nelCalendario('Turno', DateTime(2026, 11, 14));
      await allineatore.allinea();
      await allineatore.accendi(2);
      await allineatore.allinea();
      expect(calendario.titoli(1), isEmpty);
      expect(calendario.titoli(2), <String>['Turno']);
    });

    test('spegnendo si possono togliere gli eventi', () async {
      await allineatore.accendi(1);
      await nelCalendario('Turno', DateTime(2026, 11, 14));
      await allineatore.allinea();
      await allineatore.spegni(togliEventi: true);
      expect(calendario.eventi, isEmpty);
      expect(await allineatore.attivo(), isFalse);
    });

    test('senza permesso lo dice', () async {
      await allineatore.accendi(1);
      calendario.permesso = false;
      expect(await allineatore.allinea(), isFalse);
      expect(allineatore.stato.value.messaggio, contains('permesso'));
    });
  });
}
