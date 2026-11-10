/// Le azioni su un'attività che si fanno da più schermate: aprirla,
/// segnarla fatta, cestinarla.
library;

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/attivita/dettaglio_page.dart';

/// Apre il dettaglio dell'attività [id].
Future<void> apriDettaglio(BuildContext context, String id) {
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => DettaglioPage(id: id)));
}

/// Segna [attivita] come fatta o da fare.
///
/// Se ha sotto-attività ancora aperte chiede se chiuderle tutte: a volte si
/// chiude il lavoro saltando dei passaggi, a volte no.
Future<void> cambiaFatta(
  BuildContext context,
  Attivita attivita,
  bool fatta,
) async {
  final AppDatabase db = AppScope.db(context);
  bool ancheSotto = false;
  if (fatta) {
    final int aperte = DatiApp.leggi(context).indice
        .discendentiAperte(attivita.id);
    if (aperte > 0) {
      final bool? scelta = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Sotto-attività ancora aperte'),
          content: Text(
            aperte == 1
                ? 'Ha ancora una sotto-attività da fare. Chiudi anche quella?'
                : 'Ha ancora $aperte sotto-attività da fare. Chiudi anche '
                      'quelle?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Solo questa'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Chiudi tutte'),
            ),
          ],
        ),
      );
      if (scelta == null) {
        return;
      }
      ancheSotto = scelta;
    }
  }
  if (!context.mounted) {
    return;
  }
  await eseguiSegnalandoErrori(
    context,
    () => db.attivitaDao.segnaFatta(attivita.id, fatta, ancheSotto: ancheSotto),
  );
}

/// Manda [attivita] nel cestino con le sue sotto-attività, chiedendo
/// conferma se ne ha, e offre di annullare.
///
/// Restituisce `true` se l'attività è finita nel cestino.
Future<bool> cestina(BuildContext context, Attivita attivita) async {
  final AppDatabase db = AppScope.db(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final int sotto = DatiApp.leggi(context).indice
      .discendenti(attivita.id)
      .length;
  if (sotto > 0) {
    final bool? conferma = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Nel cestino?'),
        content: Text(
          sotto == 1
              ? 'Finisce nel cestino anche la sua sotto-attività.'
              : 'Finiscono nel cestino anche le sue $sotto sotto-attività.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nel cestino'),
          ),
        ],
      ),
    );
    if (conferma != true) {
      return false;
    }
  }
  if (!context.mounted) {
    return false;
  }
  final bool fatto = await eseguiSegnalandoErrori(
    context,
    () => db.attivitaDao.spostaNelCestino(attivita.id),
  );
  if (fatto) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('«${attivita.titolo}» è nel cestino'),
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () => db.attivitaDao.ripristina(attivita.id),
        ),
      ),
    );
  }
  return fatto;
}
