import 'package:flutter/material.dart';

import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';

/// Un albero di attività da aprire e chiudere, mostrato come elenco con le
/// sotto-attività rientrate.
///
/// Quali rami sono aperti lo decide chi lo usa ([aperte]), così la scelta
/// resta quando l'elenco si ricostruisce per un cambiamento del database.
class AlberoAttivita extends StatelessWidget {
  const AlberoAttivita({
    required this.principali,
    required this.aperte,
    required this.onEspandi,
    this.mostraFatte = false,
    this.mostraArgomento = false,
    super.key,
  });

  /// Le attività al primo livello, già in ordine.
  final List<Attivita> principali;

  /// Gli id delle attività di cui si vedono le sotto-attività.
  final Set<String> aperte;

  /// Chiamato quando si apre o chiude un ramo.
  final ValueChanged<String> onEspandi;

  /// Se mostrare anche le attività fatte.
  final bool mostraFatte;

  /// Se scrivere l'argomento sulle righe: serve quando l'albero mescola
  /// argomenti diversi. Basta sulle principali, le sotto-attività hanno lo
  /// stesso.
  final bool mostraArgomento;

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);

    bool visibile(Attivita a) => mostraFatte || a.fattaIl == null;

    // L'albero si appiattisce in righe con il loro livello: un ListView
    // costruisce così solo le righe che si vedono.
    final List<({Attivita attivita, int livello, bool haFiglie})> righe =
        <({Attivita attivita, int livello, bool haFiglie})>[];
    void visita(Attivita a, int livello) {
      final List<Attivita> figlie = dati.indice
          .figlie(a.id)
          .where(visibile)
          .toList();
      righe.add((attivita: a, livello: livello, haFiglie: figlie.isNotEmpty));
      if (aperte.contains(a.id)) {
        for (final Attivita figlia in figlie) {
          visita(figlia, livello + 1);
        }
      }
    }

    for (final Attivita a in principali.where(visibile)) {
      visita(a, 0);
    }

    return ListView.builder(
      // Spazio in fondo per non finire sotto il pulsante "Nuova".
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: righe.length,
      itemBuilder: (BuildContext context, int i) {
        final ({Attivita attivita, int livello, bool haFiglie}) riga = righe[i];
        return RigaAttivita(
          key: ValueKey<String>(riga.attivita.id),
          attivita: riga.attivita,
          rientro: riga.livello,
          mostraPercorso: false,
          mostraArgomento: mostraArgomento && riga.livello == 0,
          espansa: aperte.contains(riga.attivita.id),
          onEspandi: riga.haFiglie ? () => onEspandi(riga.attivita.id) : null,
        );
      },
    );
  }
}
