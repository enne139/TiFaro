import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';

/// Un'attività finta, con solo i campi che contano nella prova.
Attivita attivita(
  String id, {
  String? genitore,
  int ordine = 0,
  DateTime? scadenza,
  bool conOra = false,
  DateTime? fatta,
  String? tipologia,
  DateTime? cancellata,
  String titolo = '',
}) {
  return Attivita(
    id: id,
    titolo: titolo.isEmpty ? id : titolo,
    descrizione: '',
    creataIl: DateTime(2026, 11, 1),
    scadenza: scadenza,
    scadenzaConOra: conOra,
    fattaIl: fatta,
    argomentoId: 'argomento-lavoro',
    tipologiaId: tipologia,
    genitoreId: genitore,
    ordine: ordine,
    nelCalendario: false,
    aggiornataIl: DateTime(2026, 11, 1),
    cancellataIl: cancellata,
  );
}

void main() {
  final DateTime adesso = DateTime(2026, 11, 10, 14, 30);

  group('IndiceAttivita', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('cena'),
      attivita('ristorante', genitore: 'cena', ordine: 1),
      attivita('invitati', genitore: 'cena', ordine: 0),
      attivita('telefonare', genitore: 'ristorante', fatta: adesso),
      attivita('orfana', genitore: 'non-esiste'),
    ]);

    test('figlie in ordine', () {
      expect(indice.figlie('cena').map((Attivita a) => a.id), <String>[
        'invitati',
        'ristorante',
      ]);
    });

    test('un genitore che non c\'è rende principale', () {
      expect(
        indice.figlie(null).map((Attivita a) => a.id),
        containsAll(<String>['cena', 'orfana']),
      );
    });

    test('percorso dalla principale al genitore', () {
      expect(
        indice.percorso(indice['telefonare']!).map((Attivita a) => a.id),
        <String>['cena', 'ristorante'],
      );
      expect(indice.percorso(indice['cena']!), isEmpty);
    });

    test('discendenti e avanzamento', () {
      expect(indice.discendenti('cena'), hasLength(3));
      expect(indice.discendentiAperte('cena'), 2);
      expect(indice.avanzamento('ristorante'), (fatte: 1, totali: 1));
      expect(indice.avanzamento('cena'), (fatte: 0, totali: 2));
    });
  });

  test('raggruppaPerScadenza divide scadute, oggi e prossime', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('ieri', scadenza: DateTime(2026, 11, 9)),
      attivita('oggi-sera', scadenza: DateTime(2026, 11, 10, 20), conOra: true),
      attivita('oggi', scadenza: DateTime(2026, 11, 10)),
      attivita('fra-una-settimana', scadenza: DateTime(2026, 11, 17)),
      attivita('troppo-avanti', scadenza: DateTime(2026, 11, 18)),
      attivita('fatta', scadenza: DateTime(2026, 11, 9), fatta: adesso),
      attivita('senza-scadenza'),
      attivita(
        'sotto',
        genitore: 'senza-scadenza',
        scadenza: DateTime(2026, 11, 12),
      ),
    ]);
    final GruppiScadenza g = raggruppaPerScadenza(indice, adesso);
    expect(g.scadute.map((Attivita a) => a.id), <String>['ieri']);
    // Quelle con l'ora prima di quelle senza.
    expect(g.oggi.map((Attivita a) => a.id), <String>['oggi-sera', 'oggi']);
    expect(g.prossime.map((Attivita a) => a.id), <String>[
      'sotto',
      'fra-una-settimana',
    ]);
    // Senza scadenza: solo le principali da fare.
    expect(g.senzaScadenza.map((Attivita a) => a.id), <String>[
      'senza-scadenza',
    ]);
  });

  test('senza scadenza: in ordine di creazione, senza sotto-attività', () {
    Attivita creata(String id, DateTime quando, {String? genitore}) => Attivita(
      id: id,
      titolo: id,
      descrizione: '',
      creataIl: quando,
      scadenzaConOra: false,
      argomentoId: 'argomento-lavoro',
      genitoreId: genitore,
      ordine: 0,
      nelCalendario: false,
      aggiornataIl: quando,
    );
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      creata('nuova', DateTime(2026, 11, 9)),
      creata('vecchia', DateTime(2026, 11, 1)),
      creata('passaggio', DateTime(2026, 11, 2), genitore: 'vecchia'),
      creata('media', DateTime(2026, 11, 5)),
    ]);
    expect(
      raggruppaPerScadenza(
        indice,
        adesso,
      ).senzaScadenza.map((Attivita a) => a.id),
      <String>['vecchia', 'media', 'nuova'],
    );
  });

  test('scaduta: senza ora vale fino a fine giornata', () {
    expect(
      scaduta(attivita('a', scadenza: DateTime(2026, 11, 10)), adesso),
      isFalse,
    );
    expect(
      scaduta(
        attivita('b', scadenza: DateTime(2026, 11, 10, 9), conOra: true),
        adesso,
      ),
      isTrue,
    );
    expect(
      scaduta(attivita('c', scadenza: DateTime(2026, 11, 9)), adesso),
      isTrue,
    );
  });

  test(
    'raggruppaPerTipologia prende anche le sotto-attività, non le fatte',
    () {
      final IndiceAttivita indice = IndiceAttivita(<Attivita>[
        attivita('cena'),
        attivita('ristorante', genitore: 'cena', tipologia: 'telefonata'),
        attivita('commercialista', tipologia: 'telefonata'),
        attivita('vecchia', tipologia: 'telefonata', fatta: adesso),
        attivita('guanti', tipologia: 'acquisto'),
      ]);
      final Map<String, List<Attivita>> g = raggruppaPerTipologia(indice);
      expect(g['telefonata']!.map((Attivita a) => a.id).toSet(), <String>{
        'ristorante',
        'commercialista',
      });
      expect(g['acquisto'], hasLength(1));
    },
  );

  test('ordinaPrincipali: prima le scadenze, poi l\'ordine di creazione', () {
    final List<Attivita> ordinate = ordinaPrincipali(<Attivita>[
      attivita('senza-1', ordine: 1),
      attivita('tardi', scadenza: DateTime(2026, 12, 1)),
      attivita('senza-0', ordine: 0),
      attivita('presto', scadenza: DateTime(2026, 11, 12)),
    ]);
    expect(ordinate.map((Attivita a) => a.id), <String>[
      'presto',
      'tardi',
      'senza-0',
      'senza-1',
    ]);
  });

  test('radiciDelCestino: un gruppo cestinato insieme si vede una volta', () {
    final DateTime prima = DateTime(2026, 11, 9);
    final DateTime dopo = DateTime(2026, 11, 10);
    final List<Attivita> radici = radiciDelCestino(<Attivita>[
      attivita('cena', cancellata: dopo),
      attivita('ristorante', genitore: 'cena', cancellata: dopo),
      // Cestinata da sola, prima del genitore: fa gruppo a sé.
      attivita('invitati', genitore: 'cena', cancellata: prima),
      // Il genitore non è nel cestino.
      attivita('guanti', genitore: 'spesa', cancellata: prima),
    ]);
    expect(radici.map((Attivita a) => a.id).toSet(), <String>{
      'cena',
      'invitati',
      'guanti',
    });
  });

  test('cerca ignora maiuscole e accenti, prima le aperte', () {
    final IndiceAttivita indice = IndiceAttivita(<Attivita>[
      attivita('a', titolo: 'Revisione auto', fatta: adesso),
      attivita('b', titolo: 'Prenotare la revisione dell\'Ambulanza'),
      attivita('c', titolo: 'Altro'),
    ]);
    expect(cerca(indice, 'REVISIONE').map((Attivita a) => a.id), <String>[
      'b',
      'a',
    ]);
    expect(
      cerca(indice, 'revisione ambulanza').map((Attivita a) => a.id),
      <String>['b'],
    );
    expect(cerca(indice, '  '), isEmpty);
  });
}
