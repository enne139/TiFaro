import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/features/modelli/logica/variabili.dart';

void main() {
  test('variabiliIn: in ordine, una volta sola, senza le automatiche', () {
    expect(
      variabiliIn(<String>[
        'Turno a {luogo} con {Persona}',
        'Preparare lo zaino per {luogo} il {data}',
        '{ persona } porta le chiavi, oggi {oggi}',
        'Senza variabili',
      ]),
      <String>['luogo', 'Persona'],
    );
    expect(variabiliIn(<String>['{}', '{ }', 'graffa { aperta']), isEmpty);
  });

  test('sostituisciVariabili: per chiave; senza valore resta scritta', () {
    final Map<String, String> valori = <String, String>{
      'luogo': ' Gallarate ',
      'persona': '',
    };
    expect(
      sostituisciVariabili('Turno a {Luogo} con {persona} e {chi}', valori),
      'Turno a Gallarate con {persona} e {chi}',
    );
  });

  test('valoriAutomatici: la data della scadenza, o di oggi', () {
    final DateTime adesso = DateTime(2026, 11, 11, 9);
    expect(
      valoriAutomatici(scadenza: DateTime(2026, 11, 14), adesso: adesso),
      <String, String>{'data': 'sab 14 nov', 'oggi': 'mer 11 nov'},
    );
    expect(
      valoriAutomatici(scadenza: null, adesso: adesso)['data'],
      'mer 11 nov',
    );
  });
}
