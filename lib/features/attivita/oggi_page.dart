import 'package:flutter/material.dart';

import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';

/// La schermata Oggi: cosa è scaduto, cosa scade oggi e nei prossimi sette
/// giorni, di tutti gli argomenti e a qualunque livello dell'albero; in
/// fondo, le attività principali senza scadenza, dalla più vecchia.
class OggiPage extends StatelessWidget {
  const OggiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ColorScheme colori = Theme.of(context).colorScheme;
    final GruppiScadenza gruppi = raggruppaPerScadenza(
      dati.indice,
      DateTime.now(),
    );

    if (gruppi.vuoto) {
      return const VuotoView(
        icona: Icons.wb_sunny_outlined,
        titolo: 'Niente da fare',
        testo:
            'Con «Nuova» aggiungi un\'attività: per darle una scadenza '
            'scrivi per esempio «domani», «venerdì» o «15/11».',
      );
    }

    List<Widget> gruppo(
      String titolo,
      List<Attivita> attivita,
      IconData icona, {
      Color? colore,
    }) {
      if (attivita.isEmpty) {
        return const <Widget>[];
      }
      return <Widget>[
        IntestazioneGruppo(
          titolo: titolo,
          quante: attivita.length,
          icona: icona,
          colore: colore,
        ),
        for (final Attivita a in attivita)
          RigaAttivita(
            key: ValueKey<String>(a.id),
            attivita: a,
            mostraArgomento: true,
          ),
      ];
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        ...gruppo(
          'Scadute',
          gruppi.scadute,
          Icons.warning_amber,
          colore: colori.error,
        ),
        ...gruppo('Oggi', gruppi.oggi, Icons.today),
        ...gruppo('Prossimi 7 giorni', gruppi.prossime, Icons.date_range),
        ...gruppo('Senza scadenza', gruppi.senzaScadenza, Icons.event_busy),
      ],
    );
  }
}
