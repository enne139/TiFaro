import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/calendario/sezione_calendario.dart';
import 'package:tifaro/features/esportazione/sezione_dati.dart';
import 'package:tifaro/features/notifiche/sezione_notifiche.dart';
import 'package:tifaro/features/sincronizzazione/sezione_sync.dart';

/// Le impostazioni: argomenti e tipologie da aggiungere, modificare e
/// togliere, avvisi, server, calendario, esportazione e, in fondo, la
/// versione dell'app.
class ImpostazioniPage extends StatelessWidget {
  const ImpostazioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final AppDatabase db = AppScope.db(context);

    // Quante attività usano ogni argomento e ogni tipologia.
    final Map<String, int> perArgomento = <String, int>{};
    final Map<String, int> perTipologia = <String, int>{};
    for (final Attivita a in dati.indice.tutte) {
      perArgomento.update(a.argomentoId, (int n) => n + 1, ifAbsent: () => 1);
      final String? t = a.tipologiaId;
      if (t != null) {
        perTipologia.update(t, (int n) => n + 1, ifAbsent: () => 1);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: <Widget>[
          const IntestazioneGruppo(
            titolo: 'Argomenti',
            icona: Icons.folder_outlined,
          ),
          for (final (int i, Argomento a) in dati.argomenti.indexed)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: coloreArgomento(a.colore).colore,
                foregroundColor: Colors.white,
                child: Icon(icona(a.icona)),
              ),
              title: Text(a.nome),
              subtitle: Text(
                <String>[
                  if (a.predefinito) 'Predefinito',
                  '${perArgomento[a.id] ?? 0} attività',
                ].join(' · '),
              ),
              onTap: () => _modificaArgomento(context, db, a),
              trailing: PopupMenuButton<String>(
                tooltip: 'Azioni sull\'argomento',
                onSelected: (String scelta) => switch (scelta) {
                  'modifica' => _modificaArgomento(context, db, a),
                  'predefinito' => eseguiSegnalandoErrori(
                    context,
                    () => db.categorieDao.rendiPredefinito(a.id),
                  ),
                  'su' => eseguiSegnalandoErrori(
                    context,
                    () => db.categorieDao.spostaArgomento(a.id, Direzione.su),
                  ),
                  'giu' => eseguiSegnalandoErrori(
                    context,
                    () => db.categorieDao.spostaArgomento(a.id, Direzione.giu),
                  ),
                  _ => _togliArgomento(context, db, a),
                },
                // Spostare si fa con le voci del menu e non trascinando:
                // ogni gesto ha un pulsante (voce 014).
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'modifica',
                    child: Text('Modifica'),
                  ),
                  PopupMenuItem<String>(
                    value: 'su',
                    enabled: i > 0,
                    child: const Text('Sposta su'),
                  ),
                  PopupMenuItem<String>(
                    value: 'giu',
                    enabled: i < dati.argomenti.length - 1,
                    child: const Text('Sposta giù'),
                  ),
                  if (!a.predefinito)
                    const PopupMenuItem<String>(
                      value: 'predefinito',
                      child: Text('Rendi predefinito'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'togli',
                    child: Text('Togli'),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nuovo argomento'),
            onTap: () => _nuovoArgomento(context, db, dati),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Il predefinito è quello che prende la cattura veloce quando '
              'non scrivi #argomento. L\'ordine è quello di Argomenti e dei '
              'menu: si cambia con «Sposta su» e «Sposta giù».',
            ),
          ),
          const IntestazioneGruppo(
            titolo: 'Tipologie',
            icona: Icons.label_outline,
          ),
          for (final Tipologia t in dati.tipologie)
            ListTile(
              leading: Icon(icona(t.icona)),
              title: Text(t.nome),
              subtitle: Text('${perTipologia[t.id] ?? 0} attività'),
              onTap: () => _modificaTipologia(context, db, t),
              trailing: PopupMenuButton<String>(
                tooltip: 'Azioni sulla tipologia',
                onSelected: (String scelta) => scelta == 'modifica'
                    ? _modificaTipologia(context, db, t)
                    : _togliTipologia(context, db, t, perTipologia[t.id] ?? 0),
                itemBuilder: (BuildContext context) =>
                    const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'modifica',
                        child: Text('Modifica'),
                      ),
                      PopupMenuItem<String>(
                        value: 'togli',
                        child: Text('Togli'),
                      ),
                    ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nuova tipologia'),
            onTap: () => _nuovaTipologia(context, db),
          ),
          const SezioneNotifiche(),
          const SezioneSync(),
          const SezioneCalendario(),
          const SezioneDati(),
          const IntestazioneGruppo(
            titolo: 'Informazioni',
            icona: Icons.info_outline,
          ),
          const _Versione(),
        ],
      ),
    );
  }

  Future<void> _nuovoArgomento(
    BuildContext context,
    AppDatabase db,
    DatiApp dati,
  ) async {
    final CategoriaModificata? scelta = await modificaCategoria(
      context,
      titolo: 'Nuovo argomento',
      // Un colore non ancora usato, se ce n'è uno.
      colore: _primoColoreLibero(dati),
    );
    if (scelta == null || !context.mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => db.categorieDao.creaArgomento(
        scelta.nome,
        colore: scelta.colore,
        icona: scelta.icona,
      ),
    );
  }

  int _primoColoreLibero(DatiApp dati) {
    final Set<int> usati = dati.argomenti
        .map((Argomento a) => a.colore)
        .toSet();
    for (int i = 0; i < paletteArgomenti.length; i++) {
      if (!usati.contains(i)) {
        return i;
      }
    }
    return 0;
  }

  Future<void> _modificaArgomento(
    BuildContext context,
    AppDatabase db,
    Argomento argomento,
  ) async {
    final CategoriaModificata? scelta = await modificaCategoria(
      context,
      titolo: 'Modifica argomento',
      nome: argomento.nome,
      icona: argomento.icona,
      colore: argomento.colore,
    );
    if (scelta == null || !context.mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => db.categorieDao.modificaArgomento(
        argomento.id,
        nome: scelta.nome,
        colore: scelta.colore,
        icona: scelta.icona,
      ),
    );
  }

  Future<void> _togliArgomento(
    BuildContext context,
    AppDatabase db,
    Argomento argomento,
  ) async {
    final bool ok = await conferma(
      context,
      titolo: 'Togliere «${argomento.nome}»?',
      testo: 'Si può togliere solo un argomento che nessuna attività usa.',
      azione: 'Togli',
    );
    if (ok && context.mounted) {
      await eseguiSegnalandoErrori(
        context,
        () => db.categorieDao.cancellaArgomento(argomento.id),
      );
    }
  }

  Future<void> _nuovaTipologia(BuildContext context, AppDatabase db) async {
    final CategoriaModificata? scelta = await modificaCategoria(
      context,
      titolo: 'Nuova tipologia',
    );
    if (scelta == null || !context.mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => db.categorieDao.creaTipologia(scelta.nome, icona: scelta.icona),
    );
  }

  Future<void> _modificaTipologia(
    BuildContext context,
    AppDatabase db,
    Tipologia tipologia,
  ) async {
    final CategoriaModificata? scelta = await modificaCategoria(
      context,
      titolo: 'Modifica tipologia',
      nome: tipologia.nome,
      icona: tipologia.icona,
    );
    if (scelta == null || !context.mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => db.categorieDao.modificaTipologia(
        tipologia.id,
        nome: scelta.nome,
        icona: scelta.icona,
      ),
    );
  }

  Future<void> _togliTipologia(
    BuildContext context,
    AppDatabase db,
    Tipologia tipologia,
    int usata,
  ) async {
    final bool ok = await conferma(
      context,
      titolo: 'Togliere «${tipologia.nome}»?',
      testo: usata == 0
          ? 'Nessuna attività la usa.'
          : 'Le $usata attività che la usano resteranno senza tipologia.',
      azione: 'Togli',
    );
    if (ok && context.mounted) {
      await eseguiSegnalandoErrori(
        context,
        () => db.categorieDao.cancellaTipologia(tipologia.id),
      );
    }
  }
}

/// La riga con la versione installata (DECISIONI.md, voce 037).
///
/// La versione si legge da quello che è stato compilato (`version` di
/// `pubspec.yaml`), così non c'è un numero in più da cambiare a ogni
/// rilascio.
class _Versione extends StatefulWidget {
  const _Versione();

  @override
  State<_Versione> createState() => _VersioneState();
}

class _VersioneState extends State<_Versione> {
  /// La lettura si fa una volta sola: la pagina si ricostruisce a ogni
  /// cambiamento dei dati, e la versione non cambia mentre l'app è aperta.
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        final String versione = snapshot.data?.version ?? '';
        final String testo;
        if (versione.isNotEmpty) {
          testo = versione;
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Lettura finita senza numero (o con un errore): meglio dirlo
          // che lasciare la riga vuota.
          testo = 'Non disponibile';
        } else {
          testo = '…';
        }
        return ListTile(
          leading: const Icon(Icons.tag),
          title: const Text('Versione'),
          subtitle: Text(testo),
        );
      },
    );
  }
}
