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
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/core/widgets/dialoghi.dart';
import 'package:tifaro/core/widgets/testo_markdown.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/data/attivita_dao.dart';
import 'package:tifaro/features/attivita/logica/ricorrenza.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';
import 'package:tifaro/features/attivita/widgets/selettori.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/cattura/composizione.dart';
import 'package:tifaro/features/cattura/scelta_foto.dart';
import 'package:tifaro/features/cattura/sintassi.dart';
import 'package:tifaro/features/modelli/modelli_page.dart';

/// Le voci del menu in alto nel dettaglio.
enum _Azione { sottoCompleta, sottoDaModello, salvaModello, su, giu, cestino }

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

  /// Se la descrizione si sta scrivendo; altrimenti si vede formattata
  /// (voce 031).
  bool _modificaDescrizione = false;

  /// Il fuoco del campo della descrizione: quando lo prende, il campo resta
  /// aperto anche se era vuoto e ci si scrive la prima lettera.
  late final FocusNode _focusDescrizione = FocusNode()
    ..addListener(() {
      if (_focusDescrizione.hasFocus && !_modificaDescrizione) {
        setState(() => _modificaDescrizione = true);
      }
    });

  /// Dove mostrare gli errori del salvataggio. Si tiene da parte perché il
  /// salvataggio può partire da `dispose`, quando gli antenati non si possono
  /// più cercare.
  ScaffoldMessengerState? _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _db = AppScope.db(context);
    _messenger = ScaffoldMessenger.maybeOf(context);
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
    _focusDescrizione.dispose();
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
    final ScaffoldMessengerState? messenger = _messenger;
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
              const PopupMenuItem<_Azione>(
                value: _Azione.sottoDaModello,
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Sotto-attività da un modello…'),
                ),
              ),
              const PopupMenuItem<_Azione>(
                value: _Azione.salvaModello,
                child: ListTile(
                  leading: Icon(Icons.content_copy_outlined),
                  title: Text('Salva come modello'),
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
                attivita.scadenza == null
                    ? 'Senza una scadenza non può andare nel calendario.'
                    : 'Lo mette nel calendario l\'app sul telefono, se nelle '
                          'sue impostazioni ne hai scelto uno.',
                style: tema.textTheme.bodySmall,
              ),
            ),
          if (Ricorrenza.daCodice(attivita.ricorrenza) case final Ricorrenza r
              when !fatta)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Quando la segni fatta arriva la prossima volta, che scade '
                '${_prossima(attivita, r)}.',
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
          if (dati.modelliPerId[attivita.modelloId] case final Modello modello)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.content_copy_outlined, size: 16),
                label: Text('Nata dal modello «${modello.nome}»'),
                onPressed: () => apriModello(context, modello.id),
              ),
            ),
          const SizedBox(height: 16),
          ..._descrizioneMarkdown(tema),
          ..._sottoAttivita(attivita, dati, tema),
          ..._foto(attivita, dati, tema),
        ],
      ),
    );
  }

  // --- Descrizione in Markdown ---------------------------------------------

  /// La descrizione: formattata quando la si legge, testo semplice quando
  /// la si scrive. Vuota, è subito il campo dove scriverla (voce 031).
  List<Widget> _descrizioneMarkdown(ThemeData tema) {
    final TextEditingController controller = _descrizione!;
    final bool scrivendo =
        _modificaDescrizione || controller.text.trim().isEmpty;
    return <Widget>[
      Row(
        children: <Widget>[
          Text('Descrizione', style: tema.textTheme.titleMedium),
          const Spacer(),
          if (scrivendo)
            // Segue il testo mentre si scrive: con il campo vuoto non c'è
            // niente da mostrare.
            ListenableBuilder(
              listenable: controller,
              builder: (BuildContext context, _) =>
                  controller.text.trim().isEmpty
                  ? const SizedBox.shrink()
                  : TextButton.icon(
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Anteprima'),
                      onPressed: _mostraDescrizione,
                    ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifica la descrizione',
              onPressed: _scriviDescrizione,
            ),
        ],
      ),
      if (scrivendo)
        TextField(
          key: const ValueKey<String>('campo-descrizione'),
          controller: controller,
          focusNode: _focusDescrizione,
          minLines: 3,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Note, link, elenchi…',
            helperText:
                'Markdown: **grassetto**, *corsivo*, - elenco, - [ ] casella, '
                '# titolo, [testo](https://…)',
            helperMaxLines: 2,
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _testoCambiato(),
        )
      else
        // Toccando il testo lo si modifica; i link si aprono lo stesso,
        // perché il loro tocco arriva prima.
        InkWell(
          key: const ValueKey<String>('descrizione-formattata'),
          borderRadius: BorderRadius.circular(8),
          onTap: _scriviDescrizione,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: tema.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TestoMarkdown(controller.text),
          ),
        ),
    ];
  }

  /// Passa al campo per scrivere la descrizione, con il cursore in fondo.
  void _scriviDescrizione() {
    setState(() => _modificaDescrizione = true);
    final TextEditingController? controller = _descrizione;
    if (controller != null) {
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
    _focusDescrizione.requestFocus();
  }

  /// Torna alla descrizione formattata, salvando subito quello che si è
  /// scritto.
  void _mostraDescrizione() {
    _focusDescrizione.unfocus();
    setState(() => _modificaDescrizione = false);
    if (_ritardo?.isActive ?? false) {
      _salvaTesti();
    }
  }

  // --- Etichette: argomento, tipologia, scadenza, calendario ---------------

  List<Widget> _etichette(Attivita attivita, DatiApp dati, ThemeData tema) {
    final Argomento? argomento = dati.argomentiPerId[attivita.argomentoId];
    final Tipologia? tipologia = dati.tipologiePerId[attivita.tipologiaId];
    final DateTime? scadenza = attivita.scadenza;
    final bool principale = attivita.genitoreId == null;
    final Ricorrenza? ricorrenza = Ricorrenza.daCodice(attivita.ricorrenza);
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
          onPressed: principale ? () => _scegliArgomento(attivita) : null,
        ),
      ),
      InputChip(
        avatar: Icon(
          tipologia == null ? Icons.label_outline : icona(tipologia.icona),
        ),
        label: Text(tipologia?.nome ?? 'Tipologia'),
        onPressed: () => _scegliTipologia(attivita),
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
      InputChip(
        avatar: const Icon(Icons.repeat),
        label: Text(
          ricorrenza == null ? 'Ripeti' : conMaiuscola(ricorrenza.descrizione),
        ),
        onPressed: () => _scegliRicorrenza(ricorrenza),
        deleteButtonTooltipMessage: 'Non ripetere',
        onDeleted: ricorrenza == null
            ? null
            : () => _aggiorna(
                const ElencoAttivitaCompanion(ricorrenza: Value<String?>(null)),
              ),
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

  /// La scadenza della prossima volta se la si segnasse fatta adesso.
  String _prossima(Attivita attivita, Ricorrenza ricorrenza) {
    final DateTime adesso = DateTime.now();
    return formatoScadenza(
      prossimaScadenza(
        ricorrenza,
        scadenza: attivita.scadenza,
        fattaIl: adesso,
      ),
      attivita.scadenza != null && attivita.scadenzaConOra,
      adesso,
    );
  }

  Future<void> _scegliRicorrenza(Ricorrenza? attuale) async {
    final Scelta<Ricorrenza>? scelta = await scegliRicorrenza(
      context,
      attuale: attuale,
    );
    if (scelta == null || !mounted) {
      return;
    }
    await _aggiorna(
      ElencoAttivitaCompanion(
        ricorrenza: Value<String?>(scelta.valore?.codice),
      ),
    );
  }

  Future<void> _scegliArgomento(Attivita attivita) async {
    final String? scelto = await scegliArgomento(
      context,
      attuale: attivita.argomentoId,
    );
    if (scelto == null || scelto == attivita.argomentoId || !mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => _db.attivitaDao.cambiaArgomento(attivita.id, scelto),
    );
  }

  Future<void> _scegliTipologia(Attivita attivita) async {
    final Scelta<String>? scelta = await scegliTipologia(
      context,
      attuale: attivita.tipologiaId,
    );
    if (scelta == null || !mounted) {
      return;
    }
    await _aggiorna(
      ElencoAttivitaCompanion(tipologiaId: Value<String?>(scelta.valore)),
    );
  }

  Future<void> _scegliData(Attivita attivita) async {
    final DateTime? attuale = attivita.scadenza;
    final Scelta<DateTime>? scelta = await scegliGiorno(
      context,
      attuale: attuale,
    );
    if (scelta == null) {
      return;
    }
    final DateTime? data = scelta.valore;
    // Cambiando giorno l'ora già scelta resta.
    final bool conOra =
        data != null && attuale != null && attivita.scadenzaConOra;
    final DateTime? nuova = data != null && conOra
        ? DateTime(
            data.year,
            data.month,
            data.day,
            attuale.hour,
            attuale.minute,
          )
        : data;
    await _aggiorna(
      ElencoAttivitaCompanion(
        scadenza: Value<DateTime?>(nuova),
        scadenzaConOra: Value<bool>(conOra),
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

  /// Crea un modello da questa attività e dalle sue sotto-attività.
  Future<void> _salvaComeModello(Attivita attivita) async {
    if (_ritardo?.isActive ?? false) {
      await _salvaTesti();
    }
    if (!mounted) {
      return;
    }
    final String? nome = await chiediTesto(
      context,
      titolo: 'Salva come modello',
      etichetta: 'Nome del modello',
      iniziale: _titolo?.text.trim() ?? attivita.titolo,
    );
    if (nome == null || !mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    String? modelloId;
    await eseguiSegnalandoErrori(context, () async {
      modelloId = await _db.modelliDao.salvaComeModello(attivita.id, nome);
    });
    final String? creato = modelloId;
    if (creato == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text('Modello «$nome» creato'),
        action: SnackBarAction(
          label: 'Apri',
          onPressed: () {
            if (mounted) {
              apriModello(context, creato);
            }
          },
        ),
      ),
    );
  }

  // --- Menu in alto --------------------------------------------------------

  Future<void> _esegui(_Azione azione, Attivita attivita) async {
    switch (azione) {
      case _Azione.sottoCompleta:
        await apriCattura(context, genitoreId: attivita.id);
      case _Azione.sottoDaModello:
        final Scelta<String>? scelta = await scegliModello(context);
        final String? modelloId = scelta?.valore;
        if (modelloId != null && mounted) {
          await apriCattura(
            context,
            genitoreId: attivita.id,
            modelloId: modelloId,
          );
        }
      case _Azione.salvaModello:
        await _salvaComeModello(attivita);
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
