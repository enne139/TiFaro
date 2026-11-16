import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/quaderno/data/chiavi_quaderno.dart';
import 'package:tifaro/features/quaderno/logica/pagina.dart';

/// La sezione delle impostazioni per accendere e spegnere il Quaderno
/// (DECISIONI.md, voce 038).
///
/// Spento, sparisce la sua sezione dalla barra; le attività tengono il
/// loro giorno, e riaccendendolo si ritrovano dove erano.
class SezioneQuaderno extends StatelessWidget {
  const SezioneQuaderno({super.key});

  @override
  Widget build(BuildContext context) {
    final bool attivo = DatiApp.of(context).quadernoAttivo;
    final AppDatabase db = AppScope.db(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const IntestazioneGruppo(
          titolo: 'Quaderno',
          icona: Icons.menu_book_outlined,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.menu_book),
          title: const Text('Mostra il Quaderno'),
          subtitle: const Text(
            'Una pagina al giorno con al massimo $cosePerGiorno cose da fare, '
            'le cose veloci e quelle fatte in più. Vale solo su questo '
            'dispositivo.',
          ),
          value: attivo,
          onChanged: (bool acceso) => eseguiSegnalandoErrori(
            context,
            () => db.syncDao.impostaPreferenza(
              ChiaviQuaderno.attivo,
              acceso ? null : 'no',
            ),
          ),
        ),
      ],
    );
  }
}
