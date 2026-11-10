import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/cattura/scelta_foto.dart';
import 'package:tifaro/features/cattura/sintassi.dart';

/// Le voci del menu in alto nel dettaglio.
enum _Azione { sottoCompleta, su, giu, cestino }

/// Il dettaglio di un'attività: tutti i campi, le sotto-attività e le foto.
///
/// Titolo e descrizione si salvano da soli mentre si scrive, senza un
/// pulsante Salva.
class DettaglioPage extends StatefulWidget {
  const DettaglioPage({required this.id, super.key});

  final String id;

  @override
  State<DettaglioPage> createState() => _DettaglioPageState();
}

class _DettaglioPageState extends State<DettaglioPage> {
  late AppDatabase _db;

  /// Creati alla prima costruzione con i dati, e poi non più toccati dal
  /// database: riscriverli a ogni aggiornamento sposterebbe il cursore
  /// mentre si scrive.
  TextEditingController? _titolo;
  TextEditingController? _descrizione;

  /// Il salvataggio di titolo e descrizione in attesa: parte quando si
  /// smette di scrivere per un attimo.
  Timer? _ritardo;

  final TextEditingController _nuovaSotto = TextEditingController();
  final FocusNode _focusNuovaSotto = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = AppScope.db(context);
  }

  @override
  void dispose() {
    // Quello che si è scritto nell'ultimo attimo non va perso uscendo.
    if (_ritardo?.isActive ?? false) {
      _salvaTesti();
    }
    _titolo?.dispose();
    _descrizione?.dispose();
    _nuovaSotto.dispose();
    _focusNuovaSotto.dispose();
    super.dispose();
  }

  void _testoCambiato() {
    _ritardo?.cancel();
    _ritardo = Timer(const Duration(milliseconds: 600), _salvaTesti);
  }

  /// Salva titolo e descrizione. Un titolo vuoto non si salva: resta
  /// quello di prima.
  Future<void> _salvaTesti() async {
    _ritardo?.cancel();
    _ritardo = null;
    // I testi si leggono subito, prima di qualunque attesa: da `dispose` i
    // controller vengono eliminati appena questa funzione restituisce.
    final String titolo = _titolo?.text.trim() ?? '';
    final String? descrizione = _descrizione?.text.trim();
    final ScaffoldMessengerState? messenger = mounted
        ? ScaffoldMessenger.of(context)
        : null;
    try {
      await _db.attivitaDao.aggiorna(
        widget.id,
        ElencoAttivitaCompanion(
          titolo: titolo.isEmpty
              ? const Value<String>.absent()
              : Value<String>(titolo),
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

  /// Scrive un cambiamento di un campo, segnalando un eventuale errore.
  Future<void> _aggiorna(ElencoAttivitaCompanion modifiche) {
    return eseguiSegnalandoErrori(
      context,
      () => _db.attivitaDao.aggiorna(widget.id, modifiche),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final Attivita? attivita = dati.indice[widget.id];
    if (attivita == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const VuotoView(
          icona: Icons.delete_outline,
          titolo: 'Questa attività non c\'è più',
          testo: 'Forse è nel cestino: da lì si può ripristinare.',
        ),
      );
    }
    _titolo ??= TextEditingController(text: attivita.titolo);
    _descrizione ??= TextEditingController(text: attivita.descrizione);

    final ThemeData tema = Theme.of(context);
    final bool fatta = attivita.fattaIl != null;
    final List<Attivita> percorso = dati.indice.percorso(attivita);
    final List<Attivita> sorelle = dati.indice.figlie(attivita.genitoreId);
    final int posizione = sorelle.indexWhere(
      (Attivita a) => a.id == attivita.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          attivita.genitoreId == null ? 'Attività' : 'Sotto-attività',
        ),
        actions: <Widget>[
          PopupMenuButton<_Azione>(
            tooltip: 'Altre azioni',
            onSelected: (_Azione azione) => _esegui(azione, attivita),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<_Azione>>[
              const PopupMenuItem<_Azione>(
                value: _Azione.sottoCompleta,
                child: ListTile(
                  leading: Icon(Icons.add_a_photo_outlined),
                  title: Text('Sotto-attività con foto…'),
                ),
              ),
              // Fra le principali l'ordine lo dà la scadenza (voce 013):
              // spostarle a mano non avrebbe effetto visibile.
              if (attivita.genitoreId != null) ...<PopupMenuEntry<_Azione>>[
                PopupMenuItem<_Azione>(
                  value: _Azione.su,
                  enabled: posizione > 0,
                  child: const ListTile(
                    leading: Icon(Icons.arrow_upward),
                    title: Text('Sposta su'),
                  ),
                ),
                PopupMenuItem<_Azione>(
                  value: _Azione.giu,
                  enabled: posizione >= 0 && posizione < sorelle.length - 1,
                  child: const ListTile(
                    leading: Icon(Icons.arrow_downward),
                    title: Text('Sposta giù'),
                  ),
                ),
              ],
              const PopupMenuItem<_Azione>(
                value: _Azione.cestino,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Nel cestino'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: <Widget>[
          if (percorso.isNotEmpty)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                for (final Attivita antenata in percorso) ...<Widget>[
                  TextButton(
                    onPressed: () => apriDettaglio(context, antenata.id),
                    child: Text(antenata.titolo),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: tema.colorScheme.outline,
                  ),
                ],
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Checkbox(
                  value: fatta,
                  onChanged: (bool? v) =>
                      cambiaFatta(context, attivita, v ?? false),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _titolo,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: tema.textTheme.headlineSmall?.copyWith(
                    decoration: fatta ? TextDecoration.lineThrough : null,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cosa fare',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _testoCambiato(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _etichette(attivita, dati, tema),
          ),
          if (attivita.nelCalendario)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Su Google Calendar arriverà quando ci sarà il server.',
                style: tema.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            fatta
                ? 'Creata il ${formatoDataOra(attivita.creataIl)} · fatta il '
                      '${formatoDataOra(attivita.fattaIl!)}'
                : 'Creata il ${formatoDataOra(attivita.creataIl)}',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descrizione,
            minLines: 3,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descrizione',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: (_) => _testoCambiato(),
          ),
          ..._sottoAttivita(attivita, dati, tema),
          ..._foto(attivita, dati, tema),
        ],
      ),
    );
  }

  // --- Etichette: argomento, tipologia, scadenza, calendario ---------------

  List<Widget> _etichette(Attivita attivita, DatiApp dati, ThemeData tema) {
    final Argomento? argomento = dati.argomentiPerId[attivita.argomentoId];
    final Tipologia? tipologia = dati.tipologiePerId[attivita.tipologiaId];
    final DateTime? scadenza = attivita.scadenza;
    final bool principale = attivita.genitoreId == null;
    final Color? coloreScadenza = scaduta(attivita, DateTime.now())
        ? tema.colorScheme.error
        : null;

    return <Widget>[
      Tooltip(
        message: principale
            ? 'Cambia argomento'
            : 'Le sotto-attività hanno l\'argomento della principale',
        child: ActionChip(
          avatar: Icon(
            argomento == null ? Icons.folder_outlined : icona(argomento.icona),
            color: argomento == null
                ? null
                : coloreArgomento(argomento.colore).colore,
          ),
          label: Text(argomento?.nome ?? 'Argomento'),
          onPressed: principale ? () => _scegliArgomento(attivita, dati) : null,
        ),
      ),
      InputChip(
        avatar: Icon(
          tipologia == null ? Icons.label_outline : icona(tipologia.icona),
        ),
        label: Text(tipologia?.nome ?? 'Tipologia'),
        onPressed: () => _scegliTipologia(dati),
        deleteButtonTooltipMessage: 'Togli la tipologia',
        onDeleted: tipologia == null
            ? null
            : () => _aggiorna(
                const ElencoAttivitaCompanion(
                  tipologiaId: Value<String?>(null),
                ),
              ),
      ),
      InputChip(
        avatar: Icon(Icons.event, color: coloreScadenza),
        label: Text(
          scadenza == null
              ? 'Scadenza'
              : formatoScadenza(scadenza, false, DateTime.now()),
          style: TextStyle(color: coloreScadenza),
        ),
        onPressed: () => _scegliData(attivita),
        deleteButtonTooltipMessage: 'Togli la scadenza',
        onDeleted: scadenza == null
            ? null
            : () => _aggiorna(
                const ElencoAttivitaCompanion(
                  scadenza: Value<DateTime?>(null),
                  scadenzaConOra: Value<bool>(false),
                ),
              ),
      ),
      if (scadenza != null)
        InputChip(
          avatar: const Icon(Icons.schedule),
          label: Text(attivita.scadenzaConOra ? formatoOra(scadenza) : 'Ora'),
          onPressed: () => _scegliOra(attivita),
          deleteButtonTooltipMessage: 'Togli l\'ora',
          onDeleted: attivita.scadenzaConOra
              ? () => _aggiorna(
                  ElencoAttivitaCompanion(
                    scadenza: Value<DateTime?>(giorno(scadenza)),
                    scadenzaConOra: const Value<bool>(false),
                  ),
                )
              : null,
        ),
      FilterChip(
        avatar: const Icon(Icons.calendar_month_outlined),
        label: const Text('Nel calendario'),
        selected: attivita.nelCalendario,
        showCheckmark: false,
        onSelected: (bool v) =>
            _aggiorna(ElencoAttivitaCompanion(nelCalendario: Value<bool>(v))),
      ),
    ];
  }

  Future<void> _scegliArgomento(Attivita attivita, DatiApp dati) async {
    final String? scelto = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Argomento'),
        children: <Widget>[
          for (final Argomento a in dati.argomenti)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, a.id),
              child: ListTile(
                leading: Icon(
                  icona(a.icona),
                  color: coloreArgomento(a.colore).colore,
                ),
                title: Text(a.nome),
                trailing: a.id == attivita.argomentoId
                    ? const Icon(Icons.check)
                    : null,
              ),
            ),
        ],
      ),
    );
    if (scelto == null || scelto == attivita.argomentoId || !mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => _db.attivitaDao.cambiaArgomento(attivita.id, scelto),
    );
  }

  Future<void> _scegliTipologia(DatiApp dati) async {
    // '' vuol dire "nuova tipologia".
    final String? scelta = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Tipologia'),
        children: <Widget>[
          for (final Tipologia t in dati.tipologie)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, t.id),
              child: ListTile(
                leading: Icon(icona(t.icona)),
                title: Text(t.nome),
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: const ListTile(
              leading: Icon(Icons.add),
              title: Text('Nuova tipologia…'),
            ),
          ),
        ],
      ),
    );
    if (scelta == null || !mounted) {
      return;
    }
    if (scelta.isNotEmpty) {
      await _aggiorna(
        ElencoAttivitaCompanion(tipologiaId: Value<String?>(scelta)),
      );
      return;
    }
    final String? nome = await chiediTesto(
      context,
      titolo: 'Nuova tipologia',
      etichetta: 'Nome',
    );
    if (nome == null || !mounted) {
      return;
    }
    await eseguiSegnalandoErrori(context, () async {
      final String id = await _db.categorieDao.creaTipologia(nome);
      await _db.attivitaDao.aggiorna(
        widget.id,
        ElencoAttivitaCompanion(tipologiaId: Value<String?>(id)),
      );
    });
  }

  Future<void> _scegliData(Attivita attivita) async {
    final DateTime? attuale = attivita.scadenza;
    final DateTime? scelta = await showDatePicker(
      context: context,
      initialDate: attuale ?? giorno(DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (scelta == null) {
      return;
    }
    // Cambiando giorno l'ora già scelta resta.
    final DateTime nuova = attuale != null && attivita.scadenzaConOra
        ? DateTime(
            scelta.year,
            scelta.month,
            scelta.day,
            attuale.hour,
            attuale.minute,
          )
        : scelta;
    await _aggiorna(
      ElencoAttivitaCompanion(
        scadenza: Value<DateTime?>(nuova),
        scadenzaConOra: Value<bool>(attivita.scadenzaConOra),
      ),
    );
  }

  Future<void> _scegliOra(Attivita attivita) async {
    final DateTime? scadenza = attivita.scadenza;
    if (scadenza == null) {
      return;
    }
    final TimeOfDay? ora = await showTimePicker(
      context: context,
      initialTime: attivita.scadenzaConOra
          ? TimeOfDay.fromDateTime(scadenza)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (ora == null) {
      return;
    }
    await _aggiorna(
      ElencoAttivitaCompanion(
        scadenza: Value<DateTime?>(
          DateTime(
            scadenza.year,
            scadenza.month,
            scadenza.day,
            ora.hour,
            ora.minute,
          ),
        ),
        scadenzaConOra: const Value<bool>(true),
      ),
    );
  }

  // --- Sotto-attività ------------------------------------------------------

  List<Widget> _sottoAttivita(Attivita attivita, DatiApp dati, ThemeData tema) {
    final List<Attivita> figlie = dati.indice.figlie(attivita.id);
    final ({int fatte, int totali}) avanzamento = dati.indice.avanzamento(
      attivita.id,
    );
    return <Widget>[
      const SizedBox(height: 24),
      Row(
        children: <Widget>[
          Text('Sotto-attività', style: tema.textTheme.titleMedium),
          if (avanzamento.totali > 0) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              '${avanzamento.fatte}/${avanzamento.totali}',
              style: tema.textTheme.labelLarge?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      for (int i = 0; i < figlie.length; i++)
        RigaAttivita(
          key: ValueKey<String>(figlie[i].id),
          attivita: figlie[i],
          mostraPercorso: false,
          azioni: _MenuSotto(
            primaRiga: i == 0,
            ultimaRiga: i == figlie.length - 1,
            onSposta: (Direzione d) => eseguiSegnalandoErrori(
              context,
              () => _db.attivitaDao.sposta(figlie[i].id, d),
            ),
            onCestina: () => cestina(context, figlie[i]),
          ),
        ),
      TextField(
        controller: _nuovaSotto,
        focusNode: _focusNuovaSotto,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.add),
          hintText: 'Aggiungi una sotto-attività',
          helperText: 'Vale la sintassi veloce: domani, @telefonata, !cal',
        ),
        onSubmitted: (String testo) => _aggiungiSotto(attivita, testo),
      ),
    ];
  }

  Future<void> _aggiungiSotto(Attivita attivita, String testo) async {
    final RigaAnalizzata riga = analizzaRiga(testo, DateTime.now());
    if (riga.titolo.isEmpty) {
      return;
    }
    final bool riuscito = await eseguiSegnalandoErrori(context, () async {
      final String? etichetta = riga.tipologia;
      final String? tipologiaId = etichetta == null
          ? null
          : (await _db.categorieDao.trovaOCreaTipologia(etichetta)).id;
      await _db.attivitaDao.crea(
        titolo: riga.titolo,
        genitoreId: attivita.id,
        tipologiaId: tipologiaId,
        scadenza: riga.scadenza,
        scadenzaConOra: riga.conOra,
        nelCalendario: riga.calendario,
      );
    });
    if (riuscito && mounted) {
      _nuovaSotto.clear();
      // Il campo resta pronto per la prossima: le sotto-attività di solito
      // si scrivono a raffica.
      _focusNuovaSotto.requestFocus();
    }
  }

  // --- Foto ----------------------------------------------------------------

  List<Widget> _foto(Attivita attivita, DatiApp dati, ThemeData tema) {
    final List<Foto> foto = dati.fotoPerAttivita[attivita.id] ?? const <Foto>[];
    final FotoArchivio archivio = AppScope.archivio(context);
    return <Widget>[
      const SizedBox(height: 24),
      Row(
        children: <Widget>[
          Text('Foto', style: tema.textTheme.titleMedium),
          const Spacer(),
          if (fotocameraDisponibile)
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined),
              tooltip: 'Scatta una foto',
              onPressed: () => _aggiungiFoto(scattaFoto),
            ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Aggiungi foto dalla galleria',
            onPressed: () => _aggiungiFoto(scegliDallaGalleria),
          ),
        ],
      ),
      if (foto.isEmpty)
        Text(
          'Nessuna foto.',
          style: tema.textTheme.bodySmall?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final Foto f in foto)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _mostraFoto(f, archivio),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    archivio.file(f.nomeFile),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    cacheWidth: 288,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 96,
                      height: 96,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
          ],
        ),
    ];
  }

  Future<void> _aggiungiFoto(Future<List<String>> Function() scegli) async {
    final FotoArchivio archivio = AppScope.archivio(context);
    await eseguiSegnalandoErrori(context, () async {
      for (final String percorso in await scegli()) {
        final String nome = await archivio.importa(percorso);
        await _db.attivitaDao.aggiungiFoto(widget.id, nome);
      }
    });
  }

  Future<void> _mostraFoto(Foto foto, FotoArchivio archivio) async {
    final bool? togli = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Togli la foto',
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
          body: InteractiveViewer(
            maxScale: 6,
            child: Center(child: Image.file(archivio.file(foto.nomeFile))),
          ),
        ),
      ),
    );
    if (togli == true && mounted) {
      await eseguiSegnalandoErrori(
        context,
        () => _db.attivitaDao.togliFoto(foto.id),
      );
    }
  }

  // --- Menu in alto --------------------------------------------------------

  Future<void> _esegui(_Azione azione, Attivita attivita) async {
    switch (azione) {
      case _Azione.sottoCompleta:
        await apriCattura(context, genitoreId: attivita.id);
      case _Azione.su:
      case _Azione.giu:
        await eseguiSegnalandoErrori(
          context,
          () => _db.attivitaDao.sposta(
            attivita.id,
            azione == _Azione.su ? Direzione.su : Direzione.giu,
          ),
        );
      case _Azione.cestino:
        if (_ritardo?.isActive ?? false) {
          await _salvaTesti();
        }
        if (!mounted) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        if (await cestina(context, attivita)) {
          navigator.pop();
        }
    }
  }
}

/// Il menu di una sotto-attività nel dettaglio: spostarla o cestinarla.
///
/// Spostare si fa con le voci del menu e non trascinando, perché l'app gira
/// anche sul computer e ogni gesto deve avere un pulsante (voce 014).
class _MenuSotto extends StatelessWidget {
  const _MenuSotto({
    required this.primaRiga,
    required this.ultimaRiga,
    required this.onSposta,
    required this.onCestina,
  });

  final bool primaRiga;
  final bool ultimaRiga;
  final ValueChanged<Direzione> onSposta;
  final VoidCallback onCestina;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Azioni sulla sotto-attività',
      onSelected: (String scelta) => switch (scelta) {
        'su' => onSposta(Direzione.su),
        'giu' => onSposta(Direzione.giu),
        _ => onCestina(),
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'su',
          enabled: !primaRiga,
          child: const Text('Sposta su'),
        ),
        PopupMenuItem<String>(
          value: 'giu',
          enabled: !ultimaRiga,
          child: const Text('Sposta giù'),
        ),
        const PopupMenuItem<String>(
          value: 'cestino',
          child: Text('Nel cestino'),
        ),
      ],
    );
  }
}
