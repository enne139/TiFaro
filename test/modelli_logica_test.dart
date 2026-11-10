import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/cattura/sintassi.dart';
import 'package:tifaro/features/modelli/logica/riga_voce.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';

void main() {
  group('scadenze relative', () {
    final DateTime riferimento = DateTime(2026, 11, 10, 14, 30);

    test('giorni prima e dopo, con e senza ora', () {
      expect(scadenzaRelativa(riferimento, 3, null), (
        scadenza: DateTime(2026, 11, 13),
        conOra: false,
      ));
      expect(scadenzaRelativa(riferimento, -1, 9 * 60 + 15), (
        scadenza: DateTime(2026, 11, 9, 9, 15),
        conOra: true,
      ));
      expect(scadenzaRelativa(riferimento, null, 60), (
        scadenza: null,
        conOra: false,
      ));
      // Oltre la fine del mese.
      expect(
        scadenzaRelativa(DateTime(2026, 11, 29), 3, null).scadenza,
        DateTime(2026, 12, 2),
      );
    });

    test('relativaDi è il contrario', () {
      expect(relativaDi(DateTime(2026, 11, 13, 18), true, riferimento), (
        giorni: 3,
        minuti: 18 * 60,
      ));
      expect(relativaDi(DateTime(2026, 11, 8), false, riferimento), (
        giorni: -2,
        minuti: null,
      ));
      expect(relativaDi(null, false, riferimento), (
        giorni: null,
        minuti: null,
      ));
    });

    test('a parole', () {
      expect(descriviScadenzaPrincipale(null, null), 'Nessuna scadenza');
      expect(descriviScadenzaPrincipale(0, null), 'Il giorno della creazione');
      expect(
        descriviScadenzaPrincipale(3, 18 * 60),
        '3 giorni dopo la creazione, alle 18:00',
      );
      expect(descriviScadenzaVoce(0, null), 'Stesso giorno');
      expect(descriviScadenzaVoce(-1, null), '1 giorno prima');
      expect(descriviScadenzaVoce(2, 9 * 60), '2 giorni dopo, alle 09:00');
    });
  });

  group('riga dell\'editor dei modelli', () {
    test('spostamenti, tipologia, ora e calendario', () {
      final RigaVoce r = analizzaRigaVoce(
        'controllare la divisa @controllo -1 !cal',
      );
      expect(r.titolo, 'Controllare la divisa');
      expect(r.tipologia, 'controllo');
      expect(r.giorni, -1);
      expect(r.minuti, isNull);
      expect(r.calendario, isTrue);
    });

    test('un\'ora da sola vale lo stesso giorno', () {
      final RigaVoce r = analizzaRigaVoce('firmare il foglio alle 20');
      expect(r.titolo, 'Firmare il foglio');
      expect(r.giorni, 0);
      expect(r.minuti, 20 * 60);
      expect(analizzaRigaVoce('preparare +2 9:30').minuti, 9 * 60 + 30);
      expect(analizzaRigaVoce('preparare +2 9:30').giorni, 2);
    });

    test('senza niente, nessuna scadenza', () {
      final RigaVoce r = analizzaRigaVoce('portare i documenti');
      expect(r.giorni, isNull);
      expect(r.minuti, isNull);
    });
  });

  group('/modello nella cattura veloce', () {
    final DateTime adesso = DateTime(2026, 11, 10, 14, 30);

    test('riconosce il modello e lo toglie dal titolo', () {
      final RigaAnalizzata r = analizzaRiga(
        '/turno-in-ambulanza sabato',
        adesso,
      );
      expect(r.modello, 'turno-in-ambulanza');
      expect(r.titolo, '');
      expect(r.scadenza, DateTime(2026, 11, 14));
    });

    test('un percorso non è un modello', () {
      final RigaAnalizzata r = analizzaRiga('pulire /home/utente', adesso);
      expect(r.modello, isNull);
      expect(r.titolo, 'Pulire /home/utente');
    });
  });

  test('etichettaDi', () {
    expect(etichettaDi('Turno in ambulanza'), 'turno-in-ambulanza');
    expect(etichettaDi('Città: è ora!'), 'citta-e-ora');
  });
}
