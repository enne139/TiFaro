import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/widgets/selettori.dart';
import 'package:tifaro/features/cattura/composizione.dart';
import 'package:tifaro/features/cattura/scelta_foto.dart';
import 'package:tifaro/features/cattura/sintassi.dart';

/// Apre la cattura veloce dal basso.
///
/// [testo], [descrizione] e [foto] la precompilano, per esempio con quello
/// che arriva dal tasto Condividi di un'altra app. Con [genitoreId] crea una
/// sotto-attività; con [modelloId] parte con quel modello già scelto.
Future<void> apriCattura(
  BuildContext context, {
  String? genitoreId,
  String? modelloId,
  String testo = '',
  String descrizione = '',
  List<String> foto = const <String>[],
}) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ({String id, String titolo})? creata =
      await showModalBottomSheet<({String id, String titolo})>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (BuildContext context) => CatturaSheet(
          genitoreId: genitoreId,
          modelloId: modelloId,
          testo: testo,
          descrizione: descrizione,
          foto: foto,
        ),
      );
  // Una sotto-attività si vede subito nel dettaglio: l'avviso serve solo
  // per quelle principali, che possono finire in un'altra schermata.
  if (creata == null || genitoreId != null) {
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text('Aggiunta «${creata.titolo}»'),
      action: SnackBarAction(
        label: 'Apri',
        onPressed: () {
          if (context.mounted) {
            apriDettaglio(context, creata.id);
          }
        },
      ),
    ),
  );
}

/// La cattura veloce: una riga con la sintassi veloce e, aprendo la
/// freccia accanto, un menu per scegliere gli stessi dati senza scriverli.
///
/// Sotto, le etichette mostrano cosa verrà creato, qualunque sia la strada
/// usata (DECISIONI.md, voce 018).
class CatturaSheet extends StatefulWidget {
  const CatturaSheet({
    this.genitoreId,
    this.modelloId,
    this.testo = '',
    this.descrizione = '',
    this.foto = const <String>[],
    super.key,
  });

  final String? genitoreId;
  final String? modelloId;
  final String testo;
  final String descrizione;
  final List<String> foto;

  @override
  State<CatturaSheet> createState() => _CatturaSheetState();
}

class _CatturaSheetState extends State<CatturaSheet> {
  late final TextEditingController _riga = TextEditingController(
    text: widget.testo,
  );
  late final TextEditingController _descrizione = TextEditingController(
    text: widget.descrizione,
  );

  /// Le foto da allegare, ancora nei loro percorsi temporanei.
  late final List<String> _foto = <String>[...widget.foto];

  late bool _conDescrizione = widget.descrizione.isNotEmpty;
  bool _salvando = false;
  String? _avviso;

  /// Se il menu delle scelte è aperto. Parte aperto se si arriva con un
  /// modello già scelto, così si vede cosa porta.
  late bool _menuAperto = widget.modelloId != null;

  // Le scelte fatte dal menu; `null` vuol dire "non scelto" e allora vale
  // quello scritto (voce 018).
  String? _argomentoScelto;
  Scelta<String>? _tipologiaScelta;
  ({DateTime? data, bool conOra})? _scadenzaScelta;
  bool? _calendarioScelto;
  late Scelta<String>? _modelloScelto = widget.modelloId == null
      ? null
      : (valore: widget.modelloId);

  @override
  void dispose() {
    _riga.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  SceltaMenu get _menu => SceltaMenu(
    argomentoId: _argomentoScelto,
    tipologia: _tipologiaScelta,
    scadenza: _scadenzaScelta,
    calendario: _calendarioScelto,
    modello: _modelloScelto,
  );

  /// Mette insieme riga, menu e modello con i dati di adesso.
  CatturaComposta _componi(DatiApp dati) {
    final String? genitoreId = widget.genitoreId;
    final Attivita? genitore = genitoreId == null
        ? null
        : dati.indice[genitoreId];
    return componiCattura(
      riga: analizzaRiga(_riga.text, DateTime.now()),
      menu: _menu,
      argomenti: dati.argomenti,
      tipologie: dati.tipologie,
      modelli: dati.modelli,
      adesso: DateTime.now(),
      argomentoGenitore: genitore == null
          ? null
          : dati.argomentiPerId[genitore.argomentoId],
    );
  }

  /// Il titolo da usare: quello composto, oppure uno di comodo se c'è solo
  /// una descrizione o solo una foto, così una condivisione si salva con un
  /// tocco e si sistema dopo.
  String _titolo(CatturaComposta composta) {
    if (composta.titolo.isNotEmpty) {
      return composta.titolo;
    }
    final String descrizione = _descrizione.text.trim();
    if (descrizione.isNotEmpty) {
      final String prima = descrizione.split('\n').first.trim();
      return prima.length > 80 ? '${prima.substring(0, 80)}…' : prima;
    }
    if (_foto.isNotEmpty) {
      return 'Foto del ${formatoDataOra(DateTime.now())}';
    }
    return '';
  }

  Future<void> _salva() async {
    if (_salvando) {
      return;
    }
    final CatturaComposta composta = _componi(DatiApp.leggi(context));
    final String titolo = _titolo(composta);
    if (titolo.isEmpty) {
      setState(() => _avviso = 'Scrivi cosa fare.');
      return;
    }
    setState(() {
      _salvando = true;
      _avviso = null;
    });

    final AppDatabase db = AppScope.db(context);
    final FotoArchivio archivio = AppScope.archivio(context);
    final NavigatorState navigator = Navigator.of(context);
    ({String id, String titolo})? creata;

    final bool riuscito = await eseguiSegnalandoErrori(context, () async {
      // Le foto si copiano prima: se la copia fallisce non resta
      // un'attività a metà.
      final List<String> nomiFoto = <String>[
        for (final String percorso in _foto) await archivio.importa(percorso),
      ];
      await db.transaction(() async {
        final String? nuovoArgomento = composta.nuovoArgomento;
        final String? nuovaTipologia = composta.nuovaTipologia;
        // Una sotto-attività prende l'argomento del genitore da sola.
        final String? argomentoId = widget.genitoreId != null
            ? null
            : nuovoArgomento != null
            ? (await db.categorieDao.trovaOCreaArgomento(nuovoArgomento)).id
            : composta.argomento?.id;
        final String? tipologiaId = nuovaTipologia != null
            ? (await db.categorieDao.trovaOCreaTipologia(nuovaTipologia)).id
            : composta.tipologia?.id;
        final Modello? modello = composta.modello;
        // Tutti i campi sono già composti, modello compreso: si passano
        // per intero, così vale quello che mostrava l'anteprima.
        final String id = modello != null
            ? await db.modelliDao.creaDaModello(
                modello.id,
                titolo: titolo,
                descrizione: _descrizione.text,
                genitoreId: widget.genitoreId,
                argomentoId: argomentoId,
                tipologiaId: Value<String?>(tipologiaId),
                scadenza: Value<DateTime?>(composta.scadenza),
                scadenzaConOra: composta.conOra,
                nelCalendario: composta.calendario,
              )
            : await db.attivitaDao.crea(
                titolo: titolo,
                descrizione: _descrizione.text,
                argomentoId: argomentoId,
                genitoreId: widget.genitoreId,
                tipologiaId: tipologiaId,
                scadenza: composta.scadenza,
                scadenzaConOra: composta.conOra,
                nelCalendario: composta.calendario,
              );
        for (final String nome in nomiFoto) {
          await db.attivitaDao.aggiungiFoto(id, nome);
        }
        creata = (id: id, titolo: titolo);
      });
    });

    if (!mounted) {
      return;
    }
    if (riuscito) {
      navigator.pop(creata);
    } else {
      setState(() => _salvando = false);
    }
  }

  Future<void> _aggiungiFoto(Future<List<String>> Function() scegli) async {
    List<String> nuove = const <String>[];
    // Se la scelta fallisce (permesso negato, nessuna galleria) lo si dice.
    await eseguiSegnalandoErrori(context, () async {
      nuove = await scegli();
    });
    if (mounted && nuove.isNotEmpty) {
      setState(() => _foto.addAll(nuove));
    }
  }

  // --- Scelte dal menu -----------------------------------------------------

  Future<void> _scegliModello(CatturaComposta composta) async {
    final Scelta<String>? scelta = await scegliModello(
      context,
      attuale: composta.modello?.id,
    );
    if (scelta != null && mounted) {
      setState(() => _modelloScelto = scelta);
    }
  }

  Future<void> _scegliArgomento(CatturaComposta composta) async {
    final String? scelto = await scegliArgomento(
      context,
      attuale: composta.argomento?.id,
    );
    if (scelto != null && mounted) {
      setState(() => _argomentoScelto = scelto);
    }
  }

  Future<void> _scegliTipologia(CatturaComposta composta) async {
    final Scelta<String>? scelta = await scegliTipologia(
      context,
      attuale: composta.tipologia?.id,
    );
    if (scelta != null && mounted) {
      setState(() => _tipologiaScelta = scelta);
    }
  }

  Future<void> _scegliGiorno(CatturaComposta composta) async {
    final DateTime? attuale = composta.scadenza;
    final Scelta<DateTime>? scelta = await scegliGiorno(
      context,
      attuale: attuale,
    );
    if (scelta == null || !mounted) {
      return;
    }
    final DateTime? data = scelta.valore;
    // Cambiando giorno l'ora già scelta resta.
    final bool conOra = data != null && attuale != null && composta.conOra;
    setState(
      () => _scadenzaScelta = (
        data: data != null && conOra
            ? DateTime(
                data.year,
                data.month,
                data.day,
                attuale.hour,
                attuale.minute,
              )
            : data,
        conOra: conOra,
      ),
    );
  }

  Future<void> _scegliOra(CatturaComposta composta) async {
    final DateTime? scadenza = composta.scadenza;
    if (scadenza == null) {
      return;
    }
    final TimeOfDay? ora = await showTimePicker(
      context: context,
      initialTime: composta.conOra
          ? TimeOfDay.fromDateTime(scadenza)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (ora != null && mounted) {
      setState(
        () => _scadenzaScelta = (
          data: DateTime(
            scadenza.year,
            scadenza.month,
            scadenza.day,
            ora.hour,
            ora.minute,
          ),
          conOra: true,
        ),
      );
    }
  }

  // --- Interfaccia ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final CatturaComposta composta = _componi(dati);
    final String? genitoreId = widget.genitoreId;
    final Attivita? genitore = genitoreId == null
        ? null
        : dati.indice[genitoreId];

    return Padding(
      // Il foglio sale sopra la tastiera invece di finirci sotto.
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              genitore == null
                  ? 'Nuova attività'
                  : 'Sotto-attività di «${genitore.titolo}»',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _riga,
                    autofocus: !_menuAperto,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: composta.modello != null
                          ? composta.modello!.nome
                          : 'es. comprare guanti #ambulanza @acquisti venerdì',
                      errorText: _avviso,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        tooltip: 'Come si scrive',
                        onPressed: () => mostraAiutoSintassi(context),
                      ),
                    ),
                    onChanged: (_) => setState(() => _avviso = null),
                    onSubmitted: (_) => _salva(),
                  ),
                ),
                const SizedBox(width: 4),
                // La freccia che apre il menu delle scelte.
                IconButton.filledTonal(
                  icon: AnimatedRotation(
                    turns: _menuAperto ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                  tooltip: _menuAperto
                      ? 'Chiudi il menu delle scelte'
                      : 'Scegli i dati da un menu',
                  onPressed: () => setState(() => _menuAperto = !_menuAperto),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _anteprima(composta, genitore),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _menuAperto
                  ? _menuScelte(composta, genitore != null, tema)
                  : const SizedBox(width: double.infinity),
            ),
            if (_conDescrizione) ...<Widget>[
              const SizedBox(height: 12),
              TextField(
                controller: _descrizione,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  hintText: composta.modello?.descrizione,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
            if (_foto.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _foto.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int i) => _Miniatura(
                    percorso: _foto[i],
                    onTogli: () => setState(() => _foto.removeAt(i)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
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
                IconButton(
                  icon: Icon(
                    _conDescrizione ? Icons.notes : Icons.note_add_outlined,
                  ),
                  tooltip: _conDescrizione
                      ? 'Descrizione aperta'
                      : 'Aggiungi una descrizione',
                  onPressed: () => setState(() => _conDescrizione = true),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi'),
                  onPressed: _salvando ? null : _salva,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Il menu delle scelte: una riga per dato, che apre la finestra per
  /// sceglierlo. Accanto a quelli scelti qui c'è la crocetta per tornare a
  /// quello scritto.
  Widget _menuScelte(
    CatturaComposta composta,
    bool sottoAttivita,
    ThemeData tema,
  ) {
    final Argomento? argomento = composta.argomento;
    final DateTime? scadenza = composta.scadenza;
    final Modello? modello = composta.modello;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Quello che scegli qui vale più di quello che scrivi.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _RigaMenu(
            icona: const Icon(Icons.content_copy_outlined),
            titolo: 'Modello',
            valore: modello == null
                ? 'Nessuno'
                : '${modello.nome} · ${_sotto(DatiApp.of(context).voci.quante(modello.id))}',
            onTap: () => _scegliModello(composta),
            onAzzera: _modelloScelto == null
                ? null
                : () => setState(() => _modelloScelto = null),
          ),
          if (!sottoAttivita)
            _RigaMenu(
              icona: Icon(
                argomento == null
                    ? Icons.folder_outlined
                    : icona(argomento.icona),
                color: argomento == null
                    ? null
                    : coloreArgomento(argomento.colore).colore,
              ),
              titolo: 'Argomento',
              valore:
                  argomento?.nome ?? 'Nuovo: ${composta.nuovoArgomento ?? ''}',
              onTap: () => _scegliArgomento(composta),
              onAzzera: _argomentoScelto == null
                  ? null
                  : () => setState(() => _argomentoScelto = null),
            ),
          _RigaMenu(
            icona: Icon(
              composta.tipologia == null
                  ? Icons.label_outline
                  : icona(composta.tipologia!.icona),
            ),
            titolo: 'Tipologia',
            valore:
                composta.tipologia?.nome ??
                (composta.nuovaTipologia != null
                    ? 'Nuova: ${composta.nuovaTipologia}'
                    : 'Nessuna'),
            onTap: () => _scegliTipologia(composta),
            onAzzera: _tipologiaScelta == null
                ? null
                : () => setState(() => _tipologiaScelta = null),
          ),
          _RigaMenu(
            icona: const Icon(Icons.event),
            titolo: 'Scadenza',
            valore: scadenza == null
                ? 'Nessuna'
                : formatoScadenza(scadenza, false, DateTime.now()),
            onTap: () => _scegliGiorno(composta),
            onAzzera: _scadenzaScelta == null
                ? null
                : () => setState(() => _scadenzaScelta = null),
          ),
          _RigaMenu(
            icona: const Icon(Icons.schedule),
            titolo: 'Ora',
            valore: scadenza == null
                ? 'Prima scegli il giorno'
                : (composta.conOra ? formatoOra(scadenza) : 'Nessuna'),
            onTap: scadenza == null ? null : () => _scegliOra(composta),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.calendar_month_outlined),
            title: const Text('Nel calendario'),
            value: composta.calendario,
            onChanged: (bool v) => setState(() => _calendarioScelto = v),
          ),
        ],
      ),
    );
  }

  String _sotto(int n) => n == 1 ? '1 sotto-attività' : '$n sotto-attività';

  /// Le etichette che mostrano cosa verrà creato: così un errore di
  /// battitura o una scelta sbagliata si vedono prima di salvare.
  List<Widget> _anteprima(CatturaComposta composta, Attivita? genitore) {
    final List<Widget> etichette = <Widget>[];
    final DatiApp dati = DatiApp.of(context);
    final RigaAnalizzata riga = analizzaRiga(_riga.text, DateTime.now());

    final Modello? modello = composta.modello;
    if (modello != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.content_copy_outlined),
          label: Text(
            'Modello: ${modello.nome} (${_sotto(dati.voci.quante(modello.id))})',
          ),
        ),
      );
    }
    final String? nonTrovato = composta.modelloNonTrovato;
    if (nonTrovato != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.warning_amber),
          label: Text('Nessun modello «$nonTrovato»'),
        ),
      );
    }

    final Argomento? argomento = composta.argomento;
    final String? nuovoArgomento = composta.nuovoArgomento;
    if (argomento != null) {
      final bool predefinito =
          genitore == null &&
          _argomentoScelto == null &&
          riga.argomento == null &&
          modello?.argomentoId == null;
      etichette.add(
        Chip(
          avatar: Icon(
            icona(argomento.icona),
            color: coloreArgomento(argomento.colore).colore,
          ),
          label: Text(
            predefinito ? '${argomento.nome} (predefinito)' : argomento.nome,
          ),
        ),
      );
    } else if (nuovoArgomento != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.create_new_folder_outlined),
          label: Text('Nuovo argomento: $nuovoArgomento'),
        ),
      );
    }
    if (genitore != null && riga.argomento != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.info_outline),
          label: Text(
            '#${riga.argomento} ignorato: vale l\'argomento della principale',
          ),
        ),
      );
    }

    final Tipologia? tipologia = composta.tipologia;
    final String? nuovaTipologia = composta.nuovaTipologia;
    if (tipologia != null || nuovaTipologia != null) {
      etichette.add(
        Chip(
          avatar: Icon(
            tipologia != null
                ? icona(tipologia.icona)
                : Icons.new_label_outlined,
          ),
          label: Text(tipologia?.nome ?? 'Nuova tipologia: $nuovaTipologia'),
        ),
      );
    }

    final DateTime? scadenza = composta.scadenza;
    if (scadenza != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.event),
          label: Text(
            formatoScadenza(scadenza, composta.conOra, DateTime.now()),
          ),
        ),
      );
    }
    if (composta.calendario) {
      etichette.add(
        const Chip(
          avatar: Icon(Icons.calendar_month_outlined),
          label: Text('Nel calendario'),
        ),
      );
    }
    return etichette;
  }
}

/// Una riga del menu delle scelte: icona, nome del dato, valore attuale e,
/// se il valore viene dal menu, la crocetta per toglierlo.
class _RigaMenu extends StatelessWidget {
  const _RigaMenu({
    required this.icona,
    required this.titolo,
    required this.valore,
    required this.onTap,
    this.onAzzera,
  });

  final Widget icona;
  final String titolo;
  final String valore;

  /// Apre la scelta; nullo se per ora non si può scegliere.
  final VoidCallback? onTap;

  /// Toglie la scelta fatta dal menu; nullo se il valore non viene dal menu.
  final VoidCallback? onAzzera;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icona,
      title: Text(titolo),
      subtitle: Text(valore),
      enabled: onTap != null,
      onTap: onTap,
      trailing: onAzzera != null
          ? IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Torna a quello scritto',
              onPressed: onAzzera,
            )
          : const Icon(Icons.arrow_drop_down),
    );
  }
}

/// La miniatura di una foto non ancora salvata, con la crocetta per
/// toglierla.
class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.percorso, required this.onTogli});

  final String percorso;
  final VoidCallback onTogli;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(percorso),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            cacheWidth: 216,
            errorBuilder: (_, _, _) => const SizedBox(
              width: 72,
              height: 72,
              child: Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton.filledTonal(
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            tooltip: 'Togli la foto',
            onPressed: onTogli,
          ),
        ),
      ],
    );
  }
}

/// Spiega la sintassi della cattura veloce.
Future<void> mostraAiutoSintassi(BuildContext context) {
  const List<(String, String)> voci = <(String, String)>[
    ('#ambulanza', 'argomento (anche abbreviato: #amb)'),
    ('@acquisti', 'tipologia; se non c\'è, viene creata'),
    ('/turno', 'crea dal modello «Turno», con le sue sotto-attività'),
    ('oggi, domani, dopodomani', 'scadenza'),
    ('lunedì … domenica', 'il prossimo, mai oggi'),
    ('15/11, 15/11/2027', 'una data'),
    ('tra 3 giorni, fra una settimana, tra 2 mesi', 'scadenza da oggi'),
    ('18:00, alle 18', 'ora della scadenza'),
    ('!cal', 'da mettere nel calendario'),
  ];
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final ThemeData tema = Theme.of(context);
      return AlertDialog(
        title: const Text('Come si scrive'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Quello che non viene riconosciuto è il titolo. Esempio:\n'
                '«pagare il bollo #personale @burocrazia entro il 30/11»\n\n'
                'Se preferisci non scrivere, apri la freccia accanto alla '
                'riga e scegli dal menu.',
              ),
              const SizedBox(height: 12),
              for (final (String scrivi, String diventa) in voci)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: scrivi,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: tema.colorScheme.primary,
                          ),
                        ),
                        TextSpan(text: ' → $diventa'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      );
    },
  );
}
