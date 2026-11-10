import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/testo.dart';

void main() {
  String? trova(String etichetta, List<String> nomi) =>
      trovaPerEtichetta(etichetta, nomi, (String n) => n);

  test('chiaveNome ignora maiuscole, accenti, spazi e segni', () {
    expect(chiaveNome('Tempo Libero'), 'tempolibero');
    expect(chiaveNome('tempo-libero'), 'tempolibero');
    expect(chiaveNome('Attività'), 'attivita');
  });

  test('nomeDaEtichetta', () {
    expect(nomeDaEtichetta('tempo-libero'), 'Tempo libero');
    expect(nomeDaEtichetta('spesa'), 'Spesa');
  });

  group('trovaPerEtichetta', () {
    const List<String> nomi = <String>[
      'Lavoro',
      'Ambulanza',
      'Acquisto',
      'Telefonata',
      'Tempo Libero',
    ];

    test('stesso nome', () {
      expect(trova('lavoro', nomi), 'Lavoro');
      expect(trova('tempolibero', nomi), 'Tempo Libero');
    });

    test('singolare e plurale', () {
      expect(trova('acquisti', nomi), 'Acquisto');
      expect(trova('telefonate', nomi), 'Telefonata');
    });

    test('inizio del nome, se basta a riconoscerlo', () {
      expect(trova('amb', nomi), 'Ambulanza');
      expect(trova('tel', nomi), 'Telefonata');
    });

    test('troppo corto o ambiguo: nessuno', () {
      expect(trova('am', nomi), isNull);
      expect(trova('tel', <String>['Telefonata', 'Televisione']), isNull);
      expect(trova('spesa', nomi), isNull);
    });
  });
}
