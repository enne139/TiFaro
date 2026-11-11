import 'package:flutter_test/flutter_test.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/ricorrenza.dart';
import 'package:tifaro/features/cattura/composizione.dart';
import 'package:tifaro/features/cattura/sintassi.dart';

void main() {
  final DateTime adesso = DateTime(2026, 11, 10, 14, 30);
  final DateTime dataFinta = DateTime(2026, 11, 1);

  Argomento argomento(String id, String nome, {bool predefinito = false}) =>
      Argomento(
        id: id,
        nome: nome,
        colore: 0,
        icona: 'etichetta',
        ordine: 0,
        predefinito: predefinito,
        aggiornatoIl: dataFinta,
      );

  Tipologia tipologia(String id, String nome) => Tipologia(
    id: id,
    nome: nome,
    icona: 'etichetta',
    aggiornataIl: dataFinta,
  );

  final List<Argomento> argomenti = <Argomento>[
    argomento('lavoro', 'Lavoro'),
    argomento('personale', 'Personale', predefinito: true),
    argomento('ambulanza', 'Ambulanza'),
  ];
  final List<Tipologia> tipologie = <Tipologia>[
    tipologia('telefonata', 'Telefonata'),
    tipologia('acquisto', 'Acquisto'),
  ];
  final List<Modello> modelli = <Modello>[
    Modello(
      id: 'turno',
      nome: 'Turno in ambulanza',
      descrizione: '',
      argomentoId: 'ambulanza',
      tipologiaId: 'acquisto',
      giorni: 4,
      minuti: 8 * 60,
      nelCalendario: true,
      aggiornatoIl: dataFinta,
    ),
  ];

  CatturaComposta componi(
    String riga, {
    SceltaMenu menu = const SceltaMenu(),
    Argomento? argomentoGenitore,
  }) {
    return componiCattura(
      riga: analizzaRiga(riga, adesso),
      menu: menu,
      argomenti: argomenti,
      tipologie: tipologie,
      modelli: modelli,
      adesso: adesso,
      argomentoGenitore: argomentoGenitore,
    );
  }

  test('senza niente: argomento predefinito, nient\'altro', () {
    final CatturaComposta c = componi('comprare il pane');
    expect(c.titolo, 'Comprare il pane');
    expect(c.argomento?.id, 'personale');
    expect(c.tipologia, isNull);
    expect(c.scadenza, isNull);
    expect(c.calendario, isFalse);
    expect(c.modello, isNull);
  });

  test('il testo: etichette esistenti e nuove', () {
    final CatturaComposta c = componi('fare la spesa #casa @spese domani');
    expect(c.argomento, isNull);
    expect(c.nuovoArgomento, 'Casa');
    expect(c.nuovaTipologia, 'Spese');
    expect(c.scadenza, DateTime(2026, 11, 11));
  });

  test('il menu vale più del testo', () {
    final CatturaComposta c = componi(
      'chiamare #lavoro @acquisto domani',
      menu: SceltaMenu(
        argomentoId: 'ambulanza',
        tipologia: (valore: 'telefonata'),
        scadenza: (data: DateTime(2026, 11, 20, 9), conOra: true),
        calendario: true,
      ),
    );
    expect(c.argomento?.id, 'ambulanza');
    expect(c.tipologia?.id, 'telefonata');
    expect(c.scadenza, DateTime(2026, 11, 20, 9));
    expect(c.conOra, isTrue);
    expect(c.calendario, isTrue);
  });

  test('"nessuna" dal menu toglie anche quello scritto', () {
    final CatturaComposta c = componi(
      'chiamare @telefonata domani !cal',
      menu: const SceltaMenu(
        tipologia: (valore: null),
        scadenza: (data: null, conOra: false),
        calendario: false,
      ),
    );
    expect(c.tipologia, isNull);
    expect(c.nuovaTipologia, isNull);
    expect(c.scadenza, isNull);
    expect(c.calendario, isFalse);
  });

  test('il modello riempie quello che manca', () {
    final CatturaComposta c = componi('/turno');
    expect(c.modello?.id, 'turno');
    expect(c.titolo, 'Turno in ambulanza');
    expect(c.argomento?.id, 'ambulanza');
    expect(c.tipologia?.id, 'acquisto');
    expect(c.scadenza, DateTime(2026, 11, 14, 8));
    expect(c.conOra, isTrue);
    expect(c.calendario, isTrue);
  });

  test('testo e menu valgono più del modello', () {
    final CatturaComposta c = componi(
      'turno di Natale /turno #lavoro 24/12',
      menu: const SceltaMenu(tipologia: (valore: null)),
    );
    expect(c.titolo, 'Turno di Natale');
    expect(c.argomento?.id, 'lavoro');
    expect(c.tipologia, isNull);
    expect(c.scadenza, DateTime(2026, 12, 24));
    expect(c.conOra, isFalse);
  });

  test('il modello scelto dal menu, e "nessun modello" dal menu', () {
    expect(
      componi(
        '',
        menu: const SceltaMenu(modello: (valore: 'turno')),
      ).modello?.id,
      'turno',
    );
    expect(
      componi(
        '/turno',
        menu: const SceltaMenu(modello: (valore: null)),
      ).modello,
      isNull,
    );
  });

  test('un modello che non c\'è viene segnalato', () {
    final CatturaComposta c = componi('qualcosa /inesistente');
    expect(c.modello, isNull);
    expect(c.modelloNonTrovato, 'inesistente');
    expect(c.titolo, 'Qualcosa');
  });

  test('una sotto-attività ha sempre l\'argomento della principale', () {
    final CatturaComposta c = componi(
      'passo #ambulanza /turno',
      menu: const SceltaMenu(argomentoId: 'personale'),
      argomentoGenitore: argomenti.first,
    );
    expect(c.argomento?.id, 'lavoro');
    expect(c.nuovoArgomento, isNull);
  });

  test('la ricorrenza: il menu vale più del testo, il modello non ne ha', () {
    expect(
      componi('bolletta ogni mese').ricorrenza,
      const Ricorrenza(UnitaRicorrenza.mese),
    );
    expect(
      componi(
        'bolletta ogni mese',
        menu: const SceltaMenu(
          ricorrenza: (valore: Ricorrenza(UnitaRicorrenza.mese, 2)),
        ),
      ).ricorrenza,
      const Ricorrenza(UnitaRicorrenza.mese, 2),
    );
    expect(
      componi(
        'bolletta ogni mese',
        menu: const SceltaMenu(ricorrenza: (valore: null)),
      ).ricorrenza,
      isNull,
    );
    expect(componi('/turno').ricorrenza, isNull);
  });
}
