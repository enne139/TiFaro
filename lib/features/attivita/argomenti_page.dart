import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/albero_attivita.dart';

/// La schermata Argomenti: si sceglie un argomento, oppure «Tutte», e se ne
/// vede l'albero delle attività, da aprire ramo per ramo.
///
/// «Tutte» è la prima scelta e quella di partenza: mostra le attività di
/// ogni argomento insieme, con l'argomento scritto su ogni riga
/// (DECISIONI.md, voce 024).
class ArgomentiPage extends StatefulWidget {
  const ArgomentiPage({super.key});

  @override
  State<ArgomentiPage> createState() => _ArgomentiPageState();
}

class _ArgomentiPageState extends State<ArgomentiPage> {
  /// L'argomento scelto; `null` vuol dire «Tutte».
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
    // Un argomento tolto nel frattempo fa tornare a «Tutte».
    final String? scelto = dati.argomentiPerId.containsKey(_scelto)
        ? _scelto
        : null;
    final List<Attivita> principali = ordinaPrincipali(
      dati.indice
          .figlie(null)
          .where((Attivita a) => scelto == null || a.argomentoId == scelto),
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: const Icon(Icons.view_list_outlined),
                  label: Text('Tutte ${_aperteDi(dati, null)}'),
                  selected: scelto == null,
                  onSelected: (_) => setState(() => _scelto = null),
                ),
              ),
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
                  // Con tutti gli argomenti insieme, ogni riga dice il suo.
                  mostraArgomento: scelto == null,
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
                      'Con «Nuova» aggiungi un\'attività; per metterla in un '
                      'argomento scrivi il suo nome dopo #, per esempio '
                      '«#lavoro», oppure sceglilo dal menu della freccia.',
                ),
        ),
      ],
    );
  }

  /// Quante attività principali da fare ha l'argomento [id]; con `null`,
  /// tutti gli argomenti.
  int _aperteDi(DatiApp dati, String? id) {
    return dati.indice
        .figlie(null)
        .where(
          (Attivita a) =>
              (id == null || a.argomentoId == id) && a.fattaIl == null,
        )
        .length;
  }
}
