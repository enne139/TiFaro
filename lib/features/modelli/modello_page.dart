import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/widgets/selettori.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/cattura/composizione.dart';
import 'package:tifaro/features/modelli/logica/riga_voce.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';
import 'package:tifaro/features/modelli/logica/variabili.dart';
import 'package:tifaro/features/modelli/widgets/dialoghi_modello.dart';

/// L'editor di un modello: i campi dell'attività principale e l'albero delle
/// sotto-attività.
///
/// Nome e descrizione si salvano da soli mentre si scrive, come nel
/// dettaglio delle attività.
class ModelloPage extends StatefulWidget {
  const ModelloPage({required this.id, super.key});

  final String id;

  @override
  State<ModelloPage> createState() => _ModelloPageState();
}

class _ModelloPageState extends State<ModelloPage> {
  late AppDatabase _db;
  TextEditingController? _nome;
  TextEditingController? _descrizione;
  Timer? _ritardo;
  final TextEditingController _nuovaVoce = TextEditingController();
  final FocusNode _focusNuovaVoce = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = AppScope.db(context);
  }

  @override
  void dispose() {
    if (_ritardo?.isActive ?? false) {
      _salvaTesti();
    }
    _nome?.dispose();
    _descrizione?.dispose();
    _nuovaVoce.dispose();
    _focusNuovaVoce.dispose();
    super.dispose();
  }

  void _testoCambiato() {
    _ritardo?.cancel();
    _ritardo = Timer(const Duration(milliseconds: 600), _salvaTesti);
  }

  /// Salva nome e descrizione; un nome vuoto non si salva.
  Future<void> _salvaTesti() async {
    _ritardo?.cancel();
    _ritardo = null;
    // Letti subito: da `dispose` i controller spariscono appena si torna.
    final String nome = _nome?.text.trim() ?? '';
    final String? descrizione = _descrizione?.text.trim();
    final ScaffoldMessengerState? messenger = mounted
        ? ScaffoldMessenger.of(context)
        : null;
    try {
      await _db.modelliDao.modificaModello(
        widget.id,
        ModelliCompanion(
          nome: nome.isEmpty
              ? const Value<String>.absent()
              : Value<String>(nome),
          descrizione: descrizione == null
              ? const Value<String>.absent()
              : Value<String>(descrizione),
        ),
      );
    } catch (errore) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Testo non salvato: ${messaggioErrore(errore)}'),
        ),
      );
    }
  }

  Future<void> _aggiorna(ModelliCompanion modifiche) {
    return eseguiSegnalandoErrori(
      context,
      () => _db.modelliDao.modificaModello(widget.id, modifiche),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final Modello? modello = dati.modelliPerId[widget.id];
    if (modello == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const VuotoView(
          icona: Icons.content_copy_outlined,
          titolo: 'Questo modello non c\'è più',
          testo: 'È stato tolto.',
        ),
      );
    }
    _nome ??= TextEditingController(text: modello.nome);
    _descrizione ??= TextEditingController(text: modello.descrizione);
    final ThemeData tema = Theme.of(context);
    final List<({VoceModello voce, int livello})> voci = dati.voci.inOrdine(
      modello.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modello'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Crea un\'attività da questo modello',
            onPressed: () async {
              if (_ritardo?.isActive ?? false) {
                await _salvaTesti();
              }
              if (context.mounted) {
                await apriCattura(context, modelloId: modello.id);
              }
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Altre azioni',
            onSelected: (_) => _togli(modello),
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'togli',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Togli il modello'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: <Widget>[
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.sentences,
            style: tema.textTheme.headlineSmall,
            decoration: const InputDecoration(
              hintText: 'Nome del modello',
              border: InputBorder.none,
            ),
            onChanged: (_) {
              _testoCambiato();
              // Per aggiornare subito l'etichetta /nome qui sotto.
              setState(() {});
            },
          ),
          Text(
            'Il nome è il titolo dell\'attività creata, se non ne scrivi un '
            'altro. Nella cattura veloce: /${etichettaDi(_nome!.text)}',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _testoVariabili(modello, dati),
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _etichette(modello, dati)),
          const SizedBox(height: 16),
          TextField(
            controller: _descrizione,
            minLines: 2,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descrizione dell\'attività creata',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: (_) {
              _testoCambiato();
              // Per aggiornare l'elenco delle variabili qui sopra.
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          Text('Sotto-attività', style: tema.textTheme.titleMedium),
          Text(
            'Le loro scadenze si contano dalla scadenza della principale, o '
            'dal giorno della creazione se la principale non ne ha.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          for (int i = 0; i < voci.length; i++)
            _RigaVoce(
              key: ValueKey<String>(voci[i].voce.id),
              voce: voci[i].voce,
              livello: voci[i].livello,
              dati: dati,
              onAzione: (String azione) => _azioneVoce(azione, voci[i].voce),
            ),
          TextField(
            controller: _nuovaVoce,
            focusNode: _focusNuovaVoce,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.add),
              hintText: 'Aggiungi una sotto-attività',
              helperText:
                  'Vale la sintassi veloce: @telefonata, !cal, 18:00; per la '
                  'scadenza +2 (giorni dopo la principale) o -1 (prima)',
              helperMaxLines: 2,
            ),
            onSubmitted: (String testo) => _aggiungiVoce(modello, testo),
          ),
        ],
      ),
    );
  }

  /// La spiegazione delle variabili, con quelle che il modello usa.
  String _testoVariabili(Modello modello, DatiApp dati) {
    final List<String> usate = variabiliIn(<String>[
      _nome?.text ?? modello.nome,
      _descrizione?.text ?? modello.descrizione,
      for (final ({VoceModello voce, int livello}) r in dati.voci.inOrdine(
        modello.id,
      )) ...<String>[r.voce.titolo, r.voce.descrizione],
    ]);
    const String regola =
        'Variabili: scrivi un nome tra graffe, per esempio {luogo}, nel nome, '
        'nella descrizione o nelle sotto-attività, e la cattura veloce te lo '
        'chiede quando usi il modello. {data} (la scadenza) e {oggi} si '
        'riempiono da sole.';
    if (usate.isEmpty) {
      return regola;
    }
    return '$regola Questo modello chiede: '
        '${usate.map((String v) => '{$v}').join(', ')}.';
  }

  List<Widget> _etichette(Modello modello, DatiApp dati) {
    final Argomento? argomento = dati.argomentiPerId[modello.argomentoId];
    final Tipologia? tipologia = dati.tipologiePerId[modello.tipologiaId];
    final int? minuti = modello.minuti;
    return <Widget>[
      InputChip(
        avatar: Icon(
          argomento == null ? Icons.folder_outlined : icona(argomento.icona),
          color: argomento == null
              ? null
              : coloreArgomento(argomento.colore).colore,
        ),
        label: Text(argomento?.nome ?? 'Argomento della cattura'),
        tooltip:
            'Senza argomento, l\'attività prende quello scritto o scelto '
            'nella cattura, o il predefinito',
        onPressed: () async {
          final String? scelto = await scegliArgomento(
            context,
            attuale: modello.argomentoId,
          );
          if (scelto != null) {
            await _aggiorna(
              ModelliCompanion(argomentoId: Value<String?>(scelto)),
            );
          }
        },
        deleteButtonTooltipMessage: 'Usa l\'argomento della cattura',
        onDeleted: argomento == null
            ? null
            : () => _aggiorna(
                const ModelliCompanion(argomentoId: Value<String?>(null)),
              ),
      ),
      InputChip(
        avatar: Icon(
          tipologia == null ? Icons.label_outline : icona(tipologia.icona),
        ),
        label: Text(tipologia?.nome ?? 'Tipologia'),
        onPressed: () async {
          final Scelta<String>? scelta = await scegliTipologia(
            context,
            attuale: modello.tipologiaId,
          );
          if (scelta != null) {
            await _aggiorna(
              ModelliCompanion(tipologiaId: Value<String?>(scelta.valore)),
            );
          }
        },
        deleteButtonTooltipMessage: 'Togli la tipologia',
        onDeleted: tipologia == null
            ? null
            : () => _aggiorna(
                const ModelliCompanion(tipologiaId: Value<String?>(null)),
              ),
      ),
      InputChip(
        avatar: const Icon(Icons.event),
        label: Text(descriviScadenzaPrincipale(modello.giorni, null)),
        onPressed: () async {
          final ({int? valore})? scelta = await scegliGiorniPrincipale(
            context,
            attuali: modello.giorni,
          );
          if (scelta != null) {
            await _aggiorna(
              ModelliCompanion(
                giorni: Value<int?>(scelta.valore),
                // Senza giorno non c'è nemmeno l'ora.
                minuti: scelta.valore == null
                    ? const Value<int?>(null)
                    : const Value<int?>.absent(),
              ),
            );
          }
        },
      ),
      if (modello.giorni != null)
        InputChip(
          avatar: const Icon(Icons.schedule),
          label: Text(minuti == null ? 'Ora' : formatoMinuti(minuti)),
          onPressed: () async {
            final TimeOfDay? ora = await showTimePicker(
              context: context,
              initialTime: minuti == null
                  ? const TimeOfDay(hour: 9, minute: 0)
                  : TimeOfDay(hour: minuti ~/ 60, minute: minuti % 60),
            );
            if (ora != null) {
              await _aggiorna(
                ModelliCompanion(
                  minuti: Value<int?>(ora.hour * 60 + ora.minute),
                ),
              );
            }
          },
          deleteButtonTooltipMessage: 'Togli l\'ora',
          onDeleted: minuti == null
              ? null
              : () => _aggiorna(
                  const ModelliCompanion(minuti: Value<int?>(null)),
                ),
        ),
      FilterChip(
        avatar: const Icon(Icons.calendar_month_outlined),
        label: const Text('Nel calendario'),
        selected: modello.nelCalendario,
        showCheckmark: false,
        onSelected: (bool v) =>
            _aggiorna(ModelliCompanion(nelCalendario: Value<bool>(v))),
      ),
    ];
  }

  Future<void> _aggiungiVoce(Modello modello, String testo) async {
    final RigaVoce riga = analizzaRigaVoce(testo);
    if (riga.titolo.isEmpty) {
      return;
    }
    final bool riuscito = await eseguiSegnalandoErrori(context, () async {
      final String? etichetta = riga.tipologia;
      final String? tipologiaId = etichetta == null
          ? null
          : (await _db.categorieDao.trovaOCreaTipologia(etichetta)).id;
      await _db.modelliDao.creaVoce(
        modelloId: modello.id,
        titolo: riga.titolo,
        tipologiaId: tipologiaId,
        giorni: riga.giorni,
        minuti: riga.minuti,
        nelCalendario: riga.calendario,
      );
    });
    if (riuscito && mounted) {
      _nuovaVoce.clear();
      _focusNuovaVoce.requestFocus();
    }
  }

  Future<void> _azioneVoce(String azione, VoceModello voce) async {
    switch (azione) {
      case 'modifica':
        final DatiVoce? dati = await modificaVoceModello(
          context,
          voce: voce,
          titoloFinestra: 'Sotto-attività del modello',
        );
        if (dati == null || !mounted) {
          return;
        }
        await eseguiSegnalandoErrori(
          context,
          () => _db.modelliDao.modificaVoce(
            voce.id,
            VociModelloCompanion(
              titolo: Value<String>(dati.titolo),
              descrizione: Value<String>(dati.descrizione),
              tipologiaId: Value<String?>(dati.tipologiaId),
              giorni: Value<int?>(dati.giorni),
              minuti: Value<int?>(dati.minuti),
              nelCalendario: Value<bool>(dati.nelCalendario),
            ),
          ),
        );
      case 'sotto':
        final DatiVoce? dati = await modificaVoceModello(
          context,
          titoloFinestra: 'Dentro a «${voce.titolo}»',
        );
        if (dati == null || !mounted) {
          return;
        }
        await eseguiSegnalandoErrori(
          context,
          () => _db.modelliDao.creaVoce(
            modelloId: voce.modelloId,
            genitoreId: voce.id,
            titolo: dati.titolo,
            descrizione: dati.descrizione,
            tipologiaId: dati.tipologiaId,
            giorni: dati.giorni,
            minuti: dati.minuti,
            nelCalendario: dati.nelCalendario,
          ),
        );
      case 'su':
      case 'giu':
        await eseguiSegnalandoErrori(
          context,
          () => _db.modelliDao.spostaVoce(
            voce.id,
            azione == 'su' ? Direzione.su : Direzione.giu,
          ),
        );
      case 'togli':
        await eseguiSegnalandoErrori(
          context,
          () => _db.modelliDao.cancellaVoce(voce.id),
        );
    }
  }

  Future<void> _togli(Modello modello) async {
    final bool ok = await conferma(
      context,
      titolo: 'Togliere «${modello.nome}»?',
      testo: 'Le attività già create con questo modello restano come sono.',
      azione: 'Togli',
    );
    if (!ok || !mounted) {
      return;
    }
    final NavigatorState navigator = Navigator.of(context);
    final bool fatto = await eseguiSegnalandoErrori(
      context,
      () => _db.modelliDao.cancellaModello(modello.id),
    );
    if (fatto) {
      navigator.pop();
    }
  }
}

/// Una voce nell'albero dell'editor, con il suo menu.
class _RigaVoce extends StatelessWidget {
  const _RigaVoce({
    required this.voce,
    required this.livello,
    required this.dati,
    required this.onAzione,
    super.key,
  });

  final VoceModello voce;
  final int livello;
  final DatiApp dati;
  final ValueChanged<String> onAzione;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Tipologia? tipologia = dati.tipologiePerId[voce.tipologiaId];
    final List<VoceModello> sorelle = dati.voci.figlie(
      voce.modelloId,
      voce.genitoreId,
    );
    final int posizione = sorelle.indexWhere(
      (VoceModello v) => v.id == voce.id,
    );
    final List<String> info = <String>[
      if (tipologia != null) tipologia.nome,
      if (voce.giorni != null) descriviScadenzaVoce(voce.giorni, voce.minuti),
      if (voce.nelCalendario) 'nel calendario',
    ];

    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(start: livello * 24.0),
      leading: Icon(
        livello == 0
            ? Icons.check_box_outline_blank
            : Icons.subdirectory_arrow_right,
        color: tema.colorScheme.outline,
      ),
      title: Text(voce.titolo),
      subtitle: info.isEmpty ? null : Text(info.join(' · ')),
      onTap: () => onAzione('modifica'),
      trailing: PopupMenuButton<String>(
        tooltip: 'Azioni sulla sotto-attività',
        onSelected: onAzione,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'modifica',
            child: Text('Modifica'),
          ),
          const PopupMenuItem<String>(
            value: 'sotto',
            child: Text('Aggiungi dentro'),
          ),
          PopupMenuItem<String>(
            value: 'su',
            enabled: posizione > 0,
            child: const Text('Sposta su'),
          ),
          PopupMenuItem<String>(
            value: 'giu',
            enabled: posizione >= 0 && posizione < sorelle.length - 1,
            child: const Text('Sposta giù'),
          ),
          const PopupMenuItem<String>(value: 'togli', child: Text('Togli')),
        ],
      ),
    );
  }
}
