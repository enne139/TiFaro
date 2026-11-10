import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/albero_attivita.dart';

/// La schermata Argomenti: si sceglie un argomento e se ne vede l'albero
/// delle attività, da aprire ramo per ramo.
class ArgomentiPage extends StatefulWidget {
  const ArgomentiPage({super.key});

  @override
  State<ArgomentiPage> createState() => _ArgomentiPageState();
}

class _ArgomentiPageState extends State<ArgomentiPage> {
  /// L'argomento scelto; `null` finché non se ne tocca uno.
  String? _scelto;

  /// I rami aperti.
  final Set<String> _aperte = <String>{};

  bool _mostraFatte = false;

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    if (dati.argomenti.isEmpty) {
      return const VuotoView(
        icona: Icons.folder_off_outlined,
        titolo: 'Nessun argomento',
        testo: 'Aggiungine uno dalle impostazioni, nel menu a sinistra.',
      );
    }
    // Un argomento tolto nel frattempo fa tornare al primo.
    final String scelto = dati.argomentiPerId.containsKey(_scelto)
        ? _scelto!
        : dati.argomenti.first.id;
    final List<Attivita> principali = ordinaPrincipali(
      dati.indice.figlie(null).where((Attivita a) => a.argomentoId == scelto),
    );
    final bool tutteChiuse = principali.every(
      (Attivita a) => !_aperte.contains(a.id),
    );

    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: <Widget>[
              for (final Argomento a in dati.argomenti)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      icona(a.icona),
                      color: coloreArgomento(a.colore).colore,
                    ),
                    label: Text('${a.nome} ${_aperteDi(dati, a.id)}'),
                    selected: a.id == scelto,
                    onSelected: (_) => setState(() => _scelto = a.id),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: <Widget>[
              FilterChip(
                label: const Text('Anche le fatte'),
                selected: _mostraFatte,
                onSelected: (bool v) => setState(() => _mostraFatte = v),
              ),
              const Spacer(),
              TextButton.icon(
                icon: Icon(tutteChiuse ? Icons.unfold_more : Icons.unfold_less),
                label: Text(tutteChiuse ? 'Apri tutto' : 'Chiudi tutto'),
                onPressed: () => setState(() {
                  if (tutteChiuse) {
                    for (final Attivita a in principali) {
                      _aperte.add(a.id);
                      _aperte.addAll(
                        dati.indice.discendenti(a.id).map((Attivita d) => d.id),
                      );
                    }
                  } else {
                    _aperte.clear();
                  }
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              principali.any((Attivita a) => _mostraFatte || a.fattaIl == null)
              ? AlberoAttivita(
                  principali: principali,
                  aperte: _aperte,
                  mostraFatte: _mostraFatte,
                  onEspandi: (String id) => setState(() {
                    if (!_aperte.remove(id)) {
                      _aperte.add(id);
                    }
                  }),
                )
              : const VuotoView(
                  icona: Icons.check_circle_outline,
                  titolo: 'Niente da fare qui',
                  testo:
                      'Con «Nuova» aggiungi un\'attività; per metterla in '
                      'questo argomento scrivi il suo nome dopo #, per '
                      'esempio «#lavoro».',
                ),
        ),
      ],
    );
  }

  /// Quante attività principali da fare ha l'argomento [id].
  int _aperteDi(DatiApp dati, String id) {
    return dati.indice
        .figlie(null)
        .where((Attivita a) => a.argomentoId == id && a.fattaIl == null)
        .length;
  }
}
