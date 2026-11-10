import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/features/cattura/sintassi.dart';

void main() {
  // Martedì 10 novembre 2026, alle 14:30.
  final DateTime adesso = DateTime(2026, 11, 10, 14, 30);

  RigaAnalizzata analizza(String riga) => analizzaRiga(riga, adesso);

  test('riconosce argomento, tipologia e giorno della settimana', () {
    final RigaAnalizzata r = analizza(
      'comprare guanti nitrile #ambulanza @acquisti venerdì',
    );
    expect(r.titolo, 'Comprare guanti nitrile');
    expect(r.argomento, 'ambulanza');
    expect(r.tipologia, 'acquisti');
    expect(r.scadenza, DateTime(2026, 11, 13));
    expect(r.conOra, isFalse);
    expect(r.calendario, isFalse);
  });

  test('toglie le parole di collegamento prima della data', () {
    final RigaAnalizzata r = analizza('pagare il bollo entro il 30/11');
    expect(r.titolo, 'Pagare il bollo');
    expect(r.scadenza, DateTime(2026, 11, 30));
  });

  test('"regalo per domani" lascia solo il regalo', () {
    final RigaAnalizzata r = analizza('regalo per domani');
    expect(r.titolo, 'Regalo');
    expect(r.scadenza, DateTime(2026, 11, 11));
  });

  test('data e ora con "alle"', () {
    final RigaAnalizzata r = analizza('chiamare Mario domani alle 18');
    expect(r.titolo, 'Chiamare Mario');
    expect(r.scadenza, DateTime(2026, 11, 11, 18));
    expect(r.conOra, isTrue);
  });

  test('un\'ora senza giorno è oggi, o domani se è già passata', () {
    expect(analizza('riunione 16:00').scadenza, DateTime(2026, 11, 10, 16));
    expect(analizza('riunione 9:00').scadenza, DateTime(2026, 11, 11, 9));
  });

  test('il giorno della settimana di oggi è quello della prossima', () {
    expect(analizza('martedì').scadenza, DateTime(2026, 11, 17));
    expect(analizza('mercoledi').scadenza, DateTime(2026, 11, 11));
  });

  test('una data senza anno già passata è dell\'anno prossimo', () {
    expect(analizza('5/1').scadenza, DateTime(2027, 1, 5));
    expect(analizza('10/11').scadenza, DateTime(2026, 11, 10));
    expect(analizza('15/11/27').scadenza, DateTime(2027, 11, 15));
    expect(analizza('15-11-2028').scadenza, DateTime(2028, 11, 15));
  });

  test('una data impossibile resta nel titolo', () {
    final RigaAnalizzata r = analizza('compleanno 31/02');
    expect(r.titolo, 'Compleanno 31/02');
    expect(r.scadenza, isNull);
    // 18.30 non è un'ora (le ore vogliono i due punti) né una data.
    expect(analizza('treno 18.30').titolo, 'Treno 18.30');
  });

  test('date relative con tra e fra', () {
    expect(analizza('tra 3 giorni').scadenza, DateTime(2026, 11, 13));
    expect(analizza('fra una settimana').scadenza, DateTime(2026, 11, 17));
    expect(analizza('tra 2 mesi').scadenza, DateTime(2027, 1, 10));
    // "tra" senza unità di tempo è una parola come le altre.
    expect(analizza('scegliere tra due cose').titolo, 'Scegliere tra due cose');
  });

  test('un mese dopo il 31 gennaio è l\'ultimo di febbraio', () {
    final RigaAnalizzata r = analizzaRiga(
      'tra 1 mese',
      DateTime(2027, 1, 31, 10),
    );
    expect(r.scadenza, DateTime(2027, 2, 28));
  });

  test('!cal mette nel calendario', () {
    final RigaAnalizzata r = analizza('turno !cal sabato');
    expect(r.titolo, 'Turno');
    expect(r.calendario, isTrue);
    expect(r.scadenza, DateTime(2026, 11, 14));
  });

  test('le abbreviazioni dei giorni non sono date', () {
    final RigaAnalizzata r = analizza('chiamare gio');
    expect(r.titolo, 'Chiamare gio');
    expect(r.scadenza, isNull);
  });

  test('la punteggiatura finale non entra nelle etichette', () {
    final RigaAnalizzata r = analizza('preparare slide #lavoro.');
    expect(r.argomento, 'lavoro');
    expect(r.titolo, 'Preparare slide');
  });

  test('una riga vuota o di sole etichette dà un titolo vuoto', () {
    expect(analizza('').titolo, '');
    expect(analizza('#lavoro domani').titolo, '');
  });
}
