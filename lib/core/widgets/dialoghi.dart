import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';

/// Chiede un testo con una finestra; `null` se si annulla o si lascia vuoto.
Future<String?> chiediTesto(
  BuildContext context, {
  required String titolo,
  required String etichetta,
  String iniziale = '',
}) async {
  final String? risultato = await showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        _DialogoTesto(titolo: titolo, etichetta: etichetta, iniziale: iniziale),
  );
  final String? pulito = risultato?.trim();
  return pulito == null || pulito.isEmpty ? null : pulito;
}

/// La finestra di [chiediTesto].
///
/// È uno `StatefulWidget` perché il controller del testo va eliminato con
/// la finestra e non appena si chiude: durante l'animazione di chiusura il
/// campo lo usa ancora.
class _DialogoTesto extends StatefulWidget {
  const _DialogoTesto({
    required this.titolo,
    required this.etichetta,
    required this.iniziale,
  });

  final String titolo;
  final String etichetta;
  final String iniziale;

  @override
  State<_DialogoTesto> createState() => _DialogoTestoState();
}

class _DialogoTestoState extends State<_DialogoTesto> {
  late final TextEditingController _testo = TextEditingController(
    text: widget.iniziale,
  );

  @override
  void dispose() {
    _testo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titolo),
      content: TextField(
        controller: _testo,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.etichetta),
        onSubmitted: (String v) => Navigator.pop(context, v),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _testo.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Il risultato di [modificaCategoria].
typedef CategoriaModificata = ({String nome, String icona, int colore});

/// Chiede nome, icona e (per gli argomenti) colore di un argomento o di una
/// tipologia. Con [colore] nullo la scelta del colore non compare.
Future<CategoriaModificata?> modificaCategoria(
  BuildContext context, {
  required String titolo,
  String nome = '',
  String icona = 'etichetta',
  int? colore,
}) {
  return showDialog<CategoriaModificata>(
    context: context,
    builder: (BuildContext context) => _DialogoCategoria(
      titolo: titolo,
      nome: nome,
      icona: icona,
      colore: colore,
    ),
  );
}

class _DialogoCategoria extends StatefulWidget {
  const _DialogoCategoria({
    required this.titolo,
    required this.nome,
    required this.icona,
    required this.colore,
  });

  final String titolo;
  final String nome;
  final String icona;
  final int? colore;

  @override
  State<_DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<_DialogoCategoria> {
  late final TextEditingController _nome = TextEditingController(
    text: widget.nome,
  );
  late String _icona = widget.icona;
  late int? _colore = widget.colore;
  String? _avviso;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _conferma() {
    final String nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _avviso = 'Serve un nome.');
      return;
    }
    Navigator.pop<CategoriaModificata>(context, (
      nome: nome,
      icona: _icona,
      colore: _colore ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final int? colore = _colore;
    final Color coloreIcone = colore == null
        ? tema.colorScheme.primary
        : coloreArgomento(colore).colore;
    return AlertDialog(
      title: Text(widget.titolo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nome,
              autofocus: widget.nome.isEmpty,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nome',
                errorText: _avviso,
              ),
              onSubmitted: (_) => _conferma(),
            ),
            if (colore != null) ...<Widget>[
              const SizedBox(height: 16),
              Text('Colore', style: tema.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (int i = 0; i < paletteArgomenti.length; i++)
                    Tooltip(
                      message: paletteArgomenti[i].nome,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _colore = i),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: paletteArgomenti[i].colore,
                          child: i == colore
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Text('Icona', style: tema.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: <Widget>[
                for (final MapEntry<String, IconData> voce
                    in iconeDisponibili.entries)
                  IconButton(
                    isSelected: voce.key == _icona,
                    icon: Icon(voce.value),
                    color: voce.key == _icona ? coloreIcone : null,
                    style: voce.key == _icona
                        ? IconButton.styleFrom(
                            backgroundColor: coloreIcone.withValues(
                              alpha: 0.15,
                            ),
                          )
                        : null,
                    tooltip: voce.key,
                    onPressed: () => setState(() => _icona = voce.key),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(onPressed: _conferma, child: const Text('Salva')),
      ],
    );
  }
}

/// Chiede conferma per un'azione; `true` se confermata.
Future<bool> conferma(
  BuildContext context, {
  required String titolo,
  required String testo,
  required String azione,
}) async {
  final bool? risposta = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(titolo),
      content: Text(testo),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(azione),
        ),
      ],
    ),
  );
  return risposta == true;
}
