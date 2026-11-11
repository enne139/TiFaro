/// Le finestre per scegliere argomento, tipologia, modello e scadenza, usate
/// dal dettaglio, dal menu della cattura veloce e dall'editor dei modelli.
library;

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/features/attivita/logica/ricorrenza.dart';
import 'package:tifaro/features/cattura/composizione.dart';

/// Una voce di una finestra di scelta, con la spunta se è quella attuale.
Widget _opzione<T>(
  BuildContext context, {
  required T valore,
  required Widget icona,
  required String titolo,
  String? sottotitolo,
  required bool scelta,
}) {
  return SimpleDialogOption(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    onPressed: () => Navigator.pop(context, valore),
    child: ListTile(
      leading: icona,
      title: Text(titolo),
      subtitle: sottotitolo == null ? null : Text(sottotitolo),
      trailing: scelta ? const Icon(Icons.check) : null,
    ),
  );
}

/// Sceglie un argomento; `null` se si annulla.
Future<String?> scegliArgomento(BuildContext context, {String? attuale}) {
  final DatiApp dati = DatiApp.leggi(context);
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text('Argomento'),
      children: <Widget>[
        for (final Argomento a in dati.argomenti)
          _opzione<String>(
            context,
            valore: a.id,
            icona: Icon(
              icona(a.icona),
              color: coloreArgomento(a.colore).colore,
            ),
            titolo: a.nome,
            scelta: a.id == attuale,
          ),
      ],
    ),
  );
}

/// Sceglie una tipologia, oppure "nessuna", oppure ne crea una nuova.
///
/// Restituisce `null` se si annulla, `(valore: null)` per "nessuna".
Future<Scelta<String>?> scegliTipologia(
  BuildContext context, {
  String? attuale,
}) async {
  final DatiApp dati = DatiApp.leggi(context);
  // '' vuol dire "nessuna", '+' "nuova".
  final String? scelta = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text('Tipologia'),
      children: <Widget>[
        _opzione<String>(
          context,
          valore: '',
          icona: const Icon(Icons.label_off_outlined),
          titolo: 'Nessuna',
          scelta: attuale == null,
        ),
        for (final Tipologia t in dati.tipologie)
          _opzione<String>(
            context,
            valore: t.id,
            icona: Icon(icona(t.icona)),
            titolo: t.nome,
            scelta: t.id == attuale,
          ),
        _opzione<String>(
          context,
          valore: '+',
          icona: const Icon(Icons.add),
          titolo: 'Nuova tipologia…',
          scelta: false,
        ),
      ],
    ),
  );
  if (scelta == null) {
    return null;
  }
  if (scelta == '') {
    return (valore: null);
  }
  if (scelta != '+') {
    return (valore: scelta);
  }
  if (!context.mounted) {
    return null;
  }
  final String? nome = await chiediTesto(
    context,
    titolo: 'Nuova tipologia',
    etichetta: 'Nome',
  );
  if (nome == null || !context.mounted) {
    return null;
  }
  String? id;
  await eseguiSegnalandoErrori(context, () async {
    id = await AppScope.db(context).categorieDao.creaTipologia(nome);
  });
  return id == null ? null : (valore: id);
}

/// Sceglie un modello, oppure "nessuno".
///
/// Restituisce `null` se si annulla, `(valore: null)` per "nessuno".
Future<Scelta<String>?> scegliModello(
  BuildContext context, {
  String? attuale,
}) async {
  final DatiApp dati = DatiApp.leggi(context);
  final String? scelta = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text('Modello'),
      children: <Widget>[
        _opzione<String>(
          context,
          valore: '',
          icona: const Icon(Icons.block),
          titolo: 'Nessun modello',
          scelta: attuale == null,
        ),
        for (final Modello m in dati.modelli)
          _opzione<String>(
            context,
            valore: m.id,
            icona: const Icon(Icons.content_copy_outlined),
            titolo: m.nome,
            sottotitolo: _quanteVoci(dati.voci.quante(m.id)),
            scelta: m.id == attuale,
          ),
        if (dati.modelli.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              'Non ci sono ancora modelli: si creano dal menu a sinistra, '
              'oppure con «Salva come modello» nel dettaglio di '
              'un\'attività.',
            ),
          ),
      ],
    ),
  );
  if (scelta == null) {
    return null;
  }
  return (valore: scelta.isEmpty ? null : scelta);
}

String _quanteVoci(int n) => switch (n) {
  0 => 'Senza sotto-attività',
  1 => '1 sotto-attività',
  _ => '$n sotto-attività',
};

/// Le scorciatoie per la scadenza.
enum _Scorciatoia { oggi, domani, dopodomani, settimana, data, nessuna }

/// Sceglie una scadenza (solo il giorno) con un menu di scorciatoie: oggi,
/// domani, fra una settimana, una data dal calendario o nessuna.
///
/// Restituisce `null` se si annulla, `(valore: null)` per "nessuna".
Future<Scelta<DateTime>?> scegliGiorno(
  BuildContext context, {
  DateTime? attuale,
}) async {
  final DateTime oggi = giorno(DateTime.now());
  DateTime piu(int giorni) =>
      DateTime(oggi.year, oggi.month, oggi.day + giorni);
  final _Scorciatoia? scelta = await showDialog<_Scorciatoia>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text('Scadenza'),
      children: <Widget>[
        for (final (_Scorciatoia s, String titolo, DateTime? quando)
            in <(_Scorciatoia, String, DateTime?)>[
              (_Scorciatoia.oggi, 'Oggi', oggi),
              (_Scorciatoia.domani, 'Domani', piu(1)),
              (_Scorciatoia.dopodomani, 'Dopodomani', piu(2)),
              (_Scorciatoia.settimana, 'Fra una settimana', piu(7)),
            ])
          _opzione<_Scorciatoia>(
            context,
            valore: s,
            icona: const Icon(Icons.event),
            titolo: titolo,
            sottotitolo: formatoGiorno(quando!, oggi),
            scelta: attuale != null && giorno(attuale) == quando,
          ),
        _opzione<_Scorciatoia>(
          context,
          valore: _Scorciatoia.data,
          icona: const Icon(Icons.calendar_month_outlined),
          titolo: 'Scegli una data…',
          scelta: false,
        ),
        _opzione<_Scorciatoia>(
          context,
          valore: _Scorciatoia.nessuna,
          icona: const Icon(Icons.event_busy_outlined),
          titolo: 'Nessuna scadenza',
          scelta: attuale == null,
        ),
      ],
    ),
  );
  switch (scelta) {
    case null:
      return null;
    case _Scorciatoia.oggi:
      return (valore: oggi);
    case _Scorciatoia.domani:
      return (valore: piu(1));
    case _Scorciatoia.dopodomani:
      return (valore: piu(2));
    case _Scorciatoia.settimana:
      return (valore: piu(7));
    case _Scorciatoia.nessuna:
      return (valore: null);
    case _Scorciatoia.data:
      if (!context.mounted) {
        return null;
      }
      final DateTime? data = await showDatePicker(
        context: context,
        initialDate: attuale ?? oggi,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      return data == null ? null : (valore: data);
  }
}

/// Le ricorrenze proposte subito; le altre si scrivono con «Altro…».
const List<Ricorrenza> _ricorrenzePronte = <Ricorrenza>[
  Ricorrenza(UnitaRicorrenza.giorno),
  Ricorrenza(UnitaRicorrenza.settimana),
  Ricorrenza(UnitaRicorrenza.settimana, 2),
  Ricorrenza(UnitaRicorrenza.mese),
  Ricorrenza(UnitaRicorrenza.mese, 3),
  Ricorrenza(UnitaRicorrenza.anno),
];

/// Sceglie ogni quanto si ripete un'attività, oppure "non si ripete"
/// (voce 032).
///
/// Restituisce `null` se si annulla, `(valore: null)` per "non si ripete".
Future<Scelta<Ricorrenza>?> scegliRicorrenza(
  BuildContext context, {
  Ricorrenza? attuale,
}) async {
  // '' vuol dire "non si ripete", '+' "altro".
  final String? scelta = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      title: const Text('Si ripete'),
      children: <Widget>[
        _opzione<String>(
          context,
          valore: '',
          icona: const Icon(Icons.block),
          titolo: 'Non si ripete',
          scelta: attuale == null,
        ),
        for (final Ricorrenza r in _ricorrenzePronte)
          _opzione<String>(
            context,
            valore: r.codice,
            icona: const Icon(Icons.repeat),
            titolo: conMaiuscola(r.descrizione),
            scelta: r == attuale,
          ),
        _opzione<String>(
          context,
          valore: '+',
          icona: const Icon(Icons.tune),
          titolo: 'Altro…',
          sottotitolo: attuale != null && !_ricorrenzePronte.contains(attuale)
              ? conMaiuscola(attuale.descrizione)
              : null,
          scelta: attuale != null && !_ricorrenzePronte.contains(attuale),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Text(
            'Quando la segni fatta arriva la prossima volta, con le sue '
            'sotto-attività da fare.',
          ),
        ),
      ],
    ),
  );
  if (scelta == null) {
    return null;
  }
  if (scelta.isEmpty) {
    return (valore: null);
  }
  if (scelta != '+') {
    return (valore: Ricorrenza.daCodice(scelta));
  }
  if (!context.mounted) {
    return null;
  }
  final Ricorrenza? scritta = await showDialog<Ricorrenza>(
    context: context,
    builder: (BuildContext context) =>
        _RicorrenzaLibera(iniziale: attuale ?? _ricorrenzePronte.first),
  );
  return scritta == null ? null : (valore: scritta);
}

/// La finestra per una ricorrenza qualunque: un numero e un'unità.
class _RicorrenzaLibera extends StatefulWidget {
  const _RicorrenzaLibera({required this.iniziale});

  final Ricorrenza iniziale;

  @override
  State<_RicorrenzaLibera> createState() => _RicorrenzaLiberaState();
}

class _RicorrenzaLiberaState extends State<_RicorrenzaLibera> {
  late final TextEditingController _ogni = TextEditingController(
    text: '${widget.iniziale.ogni}',
  );
  late UnitaRicorrenza _unita = widget.iniziale.unita;

  @override
  void dispose() {
    _ogni.dispose();
    super.dispose();
  }

  /// Il numero scritto, se è valido (da 1 a 999).
  int? get _numero {
    final int? n = int.tryParse(_ogni.text.trim());
    return n != null && n >= 1 && n <= 999 ? n : null;
  }

  @override
  Widget build(BuildContext context) {
    final int? numero = _numero;
    return AlertDialog(
      title: const Text('Ogni quanto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _ogni,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Ogni',
              errorText: numero == null ? 'Un numero da 1 in su' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              for (final UnitaRicorrenza u in UnitaRicorrenza.values)
                ChoiceChip(
                  label: Text(numero == 1 ? u.singolare : u.plurale),
                  selected: u == _unita,
                  onSelected: (_) => setState(() => _unita = u),
                ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: numero == null
              ? null
              : () => Navigator.pop(context, Ricorrenza(_unita, numero)),
          child: const Text('Scegli'),
        ),
      ],
    );
  }
}
