/// Le finestre dell'editor dei modelli: la scadenza relativa e la voce
/// completa.
library;

import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';

/// Un contatore di giorni con − e +, con la descrizione a parole accanto.
class _ContaGiorni extends StatelessWidget {
  const _ContaGiorni({
    required this.giorni,
    required this.minimo,
    required this.descrivi,
    required this.onCambia,
  });

  final int giorni;
  final int minimo;
  final String Function(int giorni) descrivi;
  final ValueChanged<int> onCambia;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton.outlined(
          icon: const Icon(Icons.remove),
          tooltip: 'Un giorno prima',
          onPressed: giorni > minimo ? () => onCambia(giorni - 1) : null,
        ),
        Expanded(
          child: Text(
            descrivi(giorni),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton.outlined(
          icon: const Icon(Icons.add),
          tooltip: 'Un giorno dopo',
          onPressed: () => onCambia(giorni + 1),
        ),
      ],
    );
  }
}

/// Sceglie la scadenza della principale di un modello: quanti giorni dopo
/// la creazione, oppure nessuna.
///
/// Restituisce `null` se si annulla, `(valore: null)` per "nessuna".
Future<({int? valore})?> scegliGiorniPrincipale(
  BuildContext context, {
  int? attuali,
}) {
  return showDialog<({int? valore})>(
    context: context,
    builder: (BuildContext context) =>
        _DialogoGiorniPrincipale(iniziali: attuali ?? 0),
  );
}

class _DialogoGiorniPrincipale extends StatefulWidget {
  const _DialogoGiorniPrincipale({required this.iniziali});

  final int iniziali;

  @override
  State<_DialogoGiorniPrincipale> createState() =>
      _DialogoGiorniPrincipaleState();
}

class _DialogoGiorniPrincipaleState extends State<_DialogoGiorniPrincipale> {
  late int _giorni = widget.iniziali;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scadenza'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Quando scade l\'attività creata con questo modello, contando dal '
            'giorno in cui la crei.',
          ),
          const SizedBox(height: 16),
          _ContaGiorni(
            giorni: _giorni,
            minimo: 0,
            descrivi: (int g) => descriviScadenzaPrincipale(g, null),
            onCambia: (int g) => setState(() => _giorni = g),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, (valore: null)),
          child: const Text('Nessuna scadenza'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (valore: _giorni)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// I campi di una voce di modello, come escono dalla finestra.
typedef DatiVoce = ({
  String titolo,
  String descrizione,
  String? tipologiaId,
  int? giorni,
  int? minuti,
  bool nelCalendario,
});

/// Modifica una voce di modello, o ne crea una nuova se [voce] è nulla.
/// `null` se si annulla.
Future<DatiVoce?> modificaVoceModello(
  BuildContext context, {
  VoceModello? voce,
  required String titoloFinestra,
}) {
  return showDialog<DatiVoce>(
    context: context,
    builder: (BuildContext context) =>
        _DialogoVoce(voce: voce, titoloFinestra: titoloFinestra),
  );
}

class _DialogoVoce extends StatefulWidget {
  const _DialogoVoce({required this.voce, required this.titoloFinestra});

  final VoceModello? voce;
  final String titoloFinestra;

  @override
  State<_DialogoVoce> createState() => _DialogoVoceState();
}

class _DialogoVoceState extends State<_DialogoVoce> {
  late final TextEditingController _titolo = TextEditingController(
    text: widget.voce?.titolo ?? '',
  );
  late final TextEditingController _descrizione = TextEditingController(
    text: widget.voce?.descrizione ?? '',
  );
  late String? _tipologiaId = widget.voce?.tipologiaId;
  late int? _giorni = widget.voce?.giorni;
  late int? _minuti = widget.voce?.minuti;
  late bool _calendario = widget.voce?.nelCalendario ?? false;
  String? _avviso;

  @override
  void dispose() {
    _titolo.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  void _conferma() {
    final String titolo = _titolo.text.trim();
    if (titolo.isEmpty) {
      setState(() => _avviso = 'Serve un titolo.');
      return;
    }
    Navigator.pop<DatiVoce>(context, (
      titolo: titolo,
      descrizione: _descrizione.text.trim(),
      tipologiaId: _tipologiaId,
      giorni: _giorni,
      minuti: _giorni == null ? null : _minuti,
      nelCalendario: _calendario,
    ));
  }

  Future<void> _scegliOra() async {
    final int? minuti = _minuti;
    final TimeOfDay? ora = await showTimePicker(
      context: context,
      initialTime: minuti == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: minuti ~/ 60, minute: minuti % 60),
    );
    if (ora != null && mounted) {
      setState(() => _minuti = ora.hour * 60 + ora.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final int? giorni = _giorni;
    final int? minuti = _minuti;
    // Una tipologia tolta nel frattempo non si può più mostrare.
    final String? tipologia = dati.tipologiePerId.containsKey(_tipologiaId)
        ? _tipologiaId
        : null;

    return AlertDialog(
      title: Text(widget.titoloFinestra),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titolo,
              autofocus: widget.voce == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Cosa fare',
                errorText: _avviso,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: tipologia,
              decoration: const InputDecoration(labelText: 'Tipologia'),
              items: <DropdownMenuItem<String?>>[
                const DropdownMenuItem<String?>(child: Text('Nessuna')),
                for (final Tipologia t in dati.tipologie)
                  DropdownMenuItem<String?>(
                    value: t.id,
                    child: Row(
                      children: <Widget>[
                        Icon(icona(t.icona), size: 18),
                        const SizedBox(width: 8),
                        Text(t.nome),
                      ],
                    ),
                  ),
              ],
              onChanged: (String? v) => setState(() => _tipologiaId = v),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Con scadenza'),
              subtitle: const Text(
                'Contata dalla scadenza della principale, o dal giorno della '
                'creazione se la principale non ne ha.',
              ),
              value: giorni != null,
              onChanged: (bool v) => setState(() => _giorni = v ? 0 : null),
            ),
            if (giorni != null) ...<Widget>[
              _ContaGiorni(
                giorni: giorni,
                // Fino a un anno prima: oltre non ha senso.
                minimo: -365,
                descrivi: (int g) => descriviScadenzaVoce(g, null),
                onCambia: (int g) => setState(() => _giorni = g),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(
                  minuti == null ? 'Nessuna ora' : formatoMinuti(minuti),
                ),
                onTap: _scegliOra,
                trailing: minuti == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Togli l\'ora',
                        onPressed: () => setState(() => _minuti = null),
                      ),
              ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.calendar_month_outlined),
              title: const Text('Nel calendario'),
              value: _calendario,
              onChanged: (bool v) => setState(() => _calendario = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descrizione,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Descrizione',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                labelStyle: tema.textTheme.bodyMedium,
              ),
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
