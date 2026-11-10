import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';

/// La schermata Tipologie: le attività da fare raggruppate per tipologia,
/// da tutti gli argomenti e a qualunque livello dell'albero.
///
/// Serve a fare insieme le cose simili: tutte le telefonate, tutti gli
/// acquisti.
class TipologiePage extends StatelessWidget {
  const TipologiePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final Map<String, List<Attivita>> gruppi = raggruppaPerTipologia(
      dati.indice,
    );

    if (gruppi.isEmpty) {
      return const VuotoView(
        icona: Icons.label_off_outlined,
        titolo: 'Nessuna attività con una tipologia',
        testo:
            'Scrivi la tipologia dopo @ nella cattura veloce, per esempio '
            '«@telefonata», oppure sceglila nel dettaglio di un\'attività.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        for (final Tipologia t in dati.tipologie)
          if (gruppi[t.id] case final List<Attivita> attivita) ...<Widget>[
            IntestazioneGruppo(
              titolo: t.nome,
              quante: attivita.length,
              icona: icona(t.icona),
            ),
            for (final Attivita a in attivita)
              RigaAttivita(
                key: ValueKey<String>(a.id),
                attivita: a,
                mostraArgomento: true,
              ),
          ],
      ],
    );
  }
}
