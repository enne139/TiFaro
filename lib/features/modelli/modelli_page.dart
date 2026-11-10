import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';
import 'package:tifaro/features/modelli/modello_page.dart';

/// Apre l'editor del modello [id].
Future<void> apriModello(BuildContext context, String id) {
  return Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ModelloPage(id: id)));
}

/// L'elenco dei modelli, con il pulsante per usarli e quello per crearne uno.
class ModelliPage extends StatelessWidget {
  const ModelliPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Modelli')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuovo modello'),
        onPressed: () => _nuovo(context),
      ),
      body: dati.modelli.isEmpty
          ? const VuotoView(
              icona: Icons.content_copy_outlined,
              titolo: 'Nessun modello',
              testo:
                  'Un modello crea un\'attività con le sue sotto-attività già '
                  'pronte, per le cose che si ripetono. Crealo con «Nuovo '
                  'modello», oppure da un\'attività che hai già, con «Salva '
                  'come modello» nel suo dettaglio.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: <Widget>[
                for (final Modello m in dati.modelli)
                  _RigaModello(modello: m, dati: dati),
              ],
            ),
    );
  }

  Future<void> _nuovo(BuildContext context) async {
    final String? nome = await chiediTesto(
      context,
      titolo: 'Nuovo modello',
      etichetta: 'Nome, es. «Turno in ambulanza»',
    );
    if (nome == null || !context.mounted) {
      return;
    }
    String? id;
    await eseguiSegnalandoErrori(context, () async {
      id = await AppScope.db(context).modelliDao.creaModello(nome);
    });
    final String? creato = id;
    if (creato != null && context.mounted) {
      await apriModello(context, creato);
    }
  }
}

/// Una riga dell'elenco dei modelli.
class _RigaModello extends StatelessWidget {
  const _RigaModello({required this.modello, required this.dati});

  final Modello modello;
  final DatiApp dati;

  @override
  Widget build(BuildContext context) {
    final Argomento? argomento = dati.argomentiPerId[modello.argomentoId];
    final int voci = dati.voci.quante(modello.id);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: argomento == null
            ? Theme.of(context).colorScheme.secondaryContainer
            : coloreArgomento(argomento.colore).colore,
        foregroundColor: argomento == null ? null : Colors.white,
        child: Icon(
          argomento == null
              ? Icons.content_copy_outlined
              : icona(argomento.icona),
        ),
      ),
      title: Text(modello.nome),
      subtitle: Text(
        <String>[
          '/${etichettaDi(modello.nome)}',
          voci == 1 ? '1 sotto-attività' : '$voci sotto-attività',
          if (modello.giorni != null)
            descriviScadenzaPrincipale(modello.giorni, modello.minuti),
        ].join(' · '),
      ),
      onTap: () => apriModello(context, modello.id),
      trailing: IconButton(
        icon: const Icon(Icons.add_task),
        tooltip: 'Crea un\'attività da questo modello',
        onPressed: () => apriCattura(context, modelloId: modello.id),
      ),
    );
  }
}
