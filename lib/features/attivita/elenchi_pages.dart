/// Le schermate secondarie con un elenco di attività: fatte, cestino e
/// ricerca.
library;

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';

/// Le attività fatte, dalla più recente. Togliendo la spunta tornano da
/// fare.
class FattePage extends StatelessWidget {
  const FattePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Attivita> elenco = fatte(DatiApp.of(context).indice);
    return Scaffold(
      appBar: AppBar(title: const Text('Fatte')),
      body: elenco.isEmpty
          ? const VuotoView(
              icona: Icons.done_all,
              titolo: 'Ancora niente di fatto',
              testo: 'Le attività che spunti finiscono qui.',
            )
          : ListView.builder(
              itemCount: elenco.length,
              itemBuilder: (BuildContext context, int i) => RigaAttivita(
                key: ValueKey<String>(elenco[i].id),
                attivita: elenco[i],
                mostraArgomento: true,
              ),
            ),
    );
  }
}

/// Il cestino: le attività cestinate, da cui si possono ripristinare.
///
/// È l'unica schermata che legge per conto suo, perché i dati comuni
/// dell'app non contengono le attività cestinate.
class CestinoPage extends StatefulWidget {
  const CestinoPage({super.key});

  @override
  State<CestinoPage> createState() => _CestinoPageState();
}

class _CestinoPageState extends State<CestinoPage> {
  Stream<List<Attivita>>? _cestinate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Creato una volta sola: ricrearlo a ogni build ripartirebbe da capo.
    _cestinate ??= AppScope.db(context).attivitaDao.osservaCestino();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cestino')),
      body: StreamBuilder<List<Attivita>>(
        stream: _cestinate,
        builder: (BuildContext context, AsyncSnapshot<List<Attivita>> stato) {
          final Object? errore = stato.error;
          if (errore != null) {
            return VuotoView(
              icona: Icons.error_outline,
              titolo: 'Il cestino non si apre',
              testo: messaggioErrore(errore),
            );
          }
          final List<Attivita>? cestinate = stato.data;
          if (cestinate == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Attivita> elenco = radiciDelCestino(cestinate);
          if (elenco.isEmpty) {
            return const VuotoView(
              icona: Icons.delete_outline,
              titolo: 'Il cestino è vuoto',
              testo:
                  'Le attività che togli finiscono qui, con le loro '
                  'sotto-attività, e da qui si possono riprendere.',
            );
          }
          return ListView.builder(
            itemCount: elenco.length,
            itemBuilder: (BuildContext context, int i) =>
                _RigaCestino(attivita: elenco[i], tutte: cestinate),
          );
        },
      ),
    );
  }
}

/// Una riga del cestino, con il pulsante per ripristinarla.
class _RigaCestino extends StatelessWidget {
  const _RigaCestino({required this.attivita, required this.tutte});

  final Attivita attivita;

  /// Tutte le cestinate, per contare quelle finite nel cestino con lei.
  final List<Attivita> tutte;

  @override
  Widget build(BuildContext context) {
    final int insieme = _cestinateInsieme();
    final String quando = formatoDataOra(attivita.cancellataIl!);
    return ListTile(
      leading: const Icon(Icons.delete_outline),
      title: Text(attivita.titolo),
      subtitle: Text(
        insieme == 0
            ? 'Nel cestino dal $quando'
            : 'Nel cestino dal $quando, con $insieme sotto-attività',
      ),
      trailing: TextButton.icon(
        icon: const Icon(Icons.restore),
        label: const Text('Ripristina'),
        onPressed: () => eseguiSegnalandoErrori(
          context,
          () => AppScope.db(context).attivitaDao.ripristina(attivita.id),
        ),
      ),
    );
  }

  /// Le discendenti cestinate nello stesso momento.
  int _cestinateInsieme() {
    final Map<String?, List<Attivita>> figlie = <String?, List<Attivita>>{};
    for (final Attivita a in tutte) {
      figlie.putIfAbsent(a.genitoreId, () => <Attivita>[]).add(a);
    }
    int conto = 0;
    final List<String> daVisitare = <String>[attivita.id];
    while (daVisitare.isNotEmpty) {
      for (final Attivita f
          in figlie[daVisitare.removeLast()] ?? const <Attivita>[]) {
        if (f.cancellataIl == attivita.cancellataIl) {
          conto++;
          daVisitare.add(f.id);
        }
      }
    }
    return conto;
  }
}

/// La ricerca nel titolo e nella descrizione di tutte le attività, fatte
/// comprese.
class RicercaPage extends StatefulWidget {
  const RicercaPage({super.key});

  @override
  State<RicercaPage> createState() => _RicercaPageState();
}

class _RicercaPageState extends State<RicercaPage> {
  String _testo = '';

  @override
  Widget build(BuildContext context) {
    final List<Attivita> trovate = cerca(DatiApp.of(context).indice, _testo);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Cerca nelle attività',
            border: InputBorder.none,
          ),
          onChanged: (String v) => setState(() => _testo = v),
        ),
      ),
      body: _testo.trim().isEmpty
          ? const VuotoView(
              icona: Icons.search,
              titolo: 'Cosa cerchi?',
              testo:
                  'Cerca nel titolo e nella descrizione, anche fra le '
                  'attività fatte.',
            )
          : trovate.isEmpty
          ? const VuotoView(
              icona: Icons.search_off,
              titolo: 'Nessuna attività trovata',
              testo: 'Prova con meno parole o con un\'altra parola.',
            )
          : ListView.builder(
              itemCount: trovate.length,
              itemBuilder: (BuildContext context, int i) => RigaAttivita(
                key: ValueKey<String>(trovate[i].id),
                attivita: trovate[i],
                mostraArgomento: true,
              ),
            ),
    );
  }
}
