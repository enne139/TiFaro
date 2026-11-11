import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/features/attivita/logica/ricorrenza.dart';

void main() {
  const Ricorrenza ogniGiorno = Ricorrenza(UnitaRicorrenza.giorno);
  const Ricorrenza ogniSettimana = Ricorrenza(UnitaRicorrenza.settimana);
  const Ricorrenza ogniMese = Ricorrenza(UnitaRicorrenza.mese);

  test('si salva come codice e si rilegge', () {
    const Ricorrenza r = Ricorrenza(UnitaRicorrenza.settimana, 2);
    expect(r.codice, 'settimana:2');
    expect(Ricorrenza.daCodice('settimana:2'), r);
    expect(r.descrizione, 'ogni 2 settimane');
    expect(ogniMese.descrizione, 'ogni mese');
    // Codici sconosciuti o rotti valgono come "non si ripete".
    expect(Ricorrenza.daCodice(null), isNull);
    expect(Ricorrenza.daCodice('decennio:1'), isNull);
    expect(Ricorrenza.daCodice('mese:0'), isNull);
    expect(Ricorrenza.daCodice('mese'), isNull);
  });

  test('i mesi finiscono sull\'ultimo giorno se il giorno non c\'è', () {
    expect(ogniMese.avanti(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(ogniMese.avanti(DateTime(2026, 1, 31), 2), DateTime(2026, 3, 31));
    expect(
      const Ricorrenza(UnitaRicorrenza.anno).avanti(DateTime(2028, 2, 29), 1),
      DateTime(2029, 2, 28),
    );
    // L'ora resta, anche passando all'ora legale.
    expect(
      ogniGiorno.avanti(DateTime(2027, 3, 27, 9, 30), 1),
      DateTime(2027, 3, 28, 9, 30),
    );
  });

  test('fatta in tempo, la prossima è una ricorrenza dopo la scadenza', () {
    // Scadeva lunedì 16 novembre, fatta domenica 15.
    expect(
      prossimaScadenza(
        ogniSettimana,
        scadenza: DateTime(2026, 11, 16),
        fattaIl: DateTime(2026, 11, 15, 20),
      ),
      DateTime(2026, 11, 23),
    );
  });

  test('fatta in ritardo, non lascia volte già scadute', () {
    // Scadeva lunedì 2 novembre, fatta mercoledì 18: si salta al 23.
    expect(
      prossimaScadenza(
        ogniSettimana,
        scadenza: DateTime(2026, 11, 2, 18),
        fattaIl: DateTime(2026, 11, 18, 10),
      ),
      DateTime(2026, 11, 23, 18),
    );
    // Ogni giorno, scaduta ieri e fatta oggi: la prossima è domani.
    expect(
      prossimaScadenza(
        ogniGiorno,
        scadenza: DateTime(2026, 11, 9),
        fattaIl: DateTime(2026, 11, 10, 8),
      ),
      DateTime(2026, 11, 11),
    );
  });

  test('senza scadenza si conta dal giorno in cui è fatta', () {
    expect(
      prossimaScadenza(
        ogniMese,
        scadenza: null,
        fattaIl: DateTime(2026, 11, 10, 22, 15),
      ),
      DateTime(2026, 12, 10),
    );
  });
}
