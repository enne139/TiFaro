import 'dart:io';

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/cattura/scelta_foto.dart';
import 'package:tifaro/features/cattura/sintassi.dart';

/// Apre la cattura veloce dal basso.
///
/// [testo], [descrizione] e [foto] la precompilano, per esempio con quello
/// che arriva dal tasto Condividi di un'altra app. Con [genitoreId] crea una
/// sotto-attività.
Future<void> apriCattura(
  BuildContext context, {
  String? genitoreId,
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

/// La cattura veloce: una riga con la sintassi veloce, l'anteprima di cosa
/// si è capito, foto e descrizione facoltative.
class CatturaSheet extends StatefulWidget {
  const CatturaSheet({
    this.genitoreId,
    this.testo = '',
    this.descrizione = '',
    this.foto = const <String>[],
    super.key,
  });

  final String? genitoreId;
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

  @override
  void dispose() {
    _riga.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  /// Il titolo da usare: quello scritto, oppure uno di comodo se c'è solo
  /// una descrizione o solo una foto, così una condivisione si salva con un
  /// tocco e si sistema dopo.
  String _titolo(RigaAnalizzata riga) {
    if (riga.titolo.isNotEmpty) {
      return riga.titolo;
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
    final RigaAnalizzata riga = analizzaRiga(_riga.text, DateTime.now());
    final String titolo = _titolo(riga);
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
        final String? etichettaArgomento = riga.argomento;
        final String? etichettaTipologia = riga.tipologia;
        final String? argomentoId =
            widget.genitoreId == null && etichettaArgomento != null
            ? (await db.categorieDao.trovaOCreaArgomento(etichettaArgomento)).id
            : null;
        final String? tipologiaId = etichettaTipologia != null
            ? (await db.categorieDao.trovaOCreaTipologia(etichettaTipologia)).id
            : null;
        final String id = await db.attivitaDao.crea(
          titolo: titolo,
          descrizione: _descrizione.text,
          argomentoId: argomentoId,
          genitoreId: widget.genitoreId,
          tipologiaId: tipologiaId,
          scadenza: riga.scadenza,
          scadenzaConOra: riga.conOra,
          nelCalendario: riga.calendario,
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
    final List<String> nuove = await eseguiOppureVuoto(scegli);
    if (mounted && nuove.isNotEmpty) {
      setState(() => _foto.addAll(nuove));
    }
  }

  /// Esegue la scelta delle foto; se fallisce (permesso negato, nessuna app
  /// galleria) lo dice e restituisce un elenco vuoto.
  Future<List<String>> eseguiOppureVuoto(
    Future<List<String>> Function() scegli,
  ) async {
    List<String> risultato = const <String>[];
    await eseguiSegnalandoErrori(context, () async {
      risultato = await scegli();
    });
    return risultato;
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final RigaAnalizzata riga = analizzaRiga(_riga.text, DateTime.now());
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
            TextField(
              controller: _riga,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'es. comprare guanti #ambulanza @acquisti venerdì',
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _anteprima(dati, riga, genitore),
            ),
            if (_conDescrizione) ...<Widget>[
              const SizedBox(height: 12),
              TextField(
                controller: _descrizione,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
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

  /// Le etichette che mostrano cosa si è capito dalla riga, prima di
  /// salvare: così un errore di battitura si vede subito.
  List<Widget> _anteprima(
    DatiApp dati,
    RigaAnalizzata riga,
    Attivita? genitore,
  ) {
    final List<Widget> etichette = <Widget>[];
    final String? etichettaArgomento = riga.argomento;

    if (genitore != null) {
      final Argomento? argomento = dati.argomentiPerId[genitore.argomentoId];
      if (argomento != null) {
        etichette.add(_etichettaArgomento(argomento, ''));
      }
      if (etichettaArgomento != null) {
        etichette.add(
          Chip(
            avatar: const Icon(Icons.info_outline),
            label: Text(
              '#$etichettaArgomento ignorato: vale l\'argomento della '
              'principale',
            ),
          ),
        );
      }
    } else if (etichettaArgomento != null) {
      final Argomento? trovato = trovaPerEtichetta(
        etichettaArgomento,
        dati.argomenti,
        (Argomento a) => a.nome,
      );
      etichette.add(
        trovato != null
            ? _etichettaArgomento(trovato, '')
            : Chip(
                avatar: const Icon(Icons.create_new_folder_outlined),
                label: Text(
                  'Nuovo argomento: ${nomeDaEtichetta(etichettaArgomento)}',
                ),
              ),
      );
    } else if (dati.argomentoPredefinito case final Argomento predefinito) {
      etichette.add(_etichettaArgomento(predefinito, ' (predefinito)'));
    }

    final String? etichettaTipologia = riga.tipologia;
    if (etichettaTipologia != null) {
      final Tipologia? trovata = trovaPerEtichetta(
        etichettaTipologia,
        dati.tipologie,
        (Tipologia t) => t.nome,
      );
      etichette.add(
        Chip(
          avatar: Icon(
            trovata != null ? icona(trovata.icona) : Icons.new_label_outlined,
          ),
          label: Text(
            trovata?.nome ??
                'Nuova tipologia: ${nomeDaEtichetta(etichettaTipologia)}',
          ),
        ),
      );
    }

    final DateTime? scadenza = riga.scadenza;
    if (scadenza != null) {
      etichette.add(
        Chip(
          avatar: const Icon(Icons.event),
          label: Text(formatoScadenza(scadenza, riga.conOra, DateTime.now())),
        ),
      );
    }
    if (riga.calendario) {
      etichette.add(
        const Chip(
          avatar: Icon(Icons.calendar_month_outlined),
          label: Text('Nel calendario'),
        ),
      );
    }
    return etichette;
  }

  Widget _etichettaArgomento(Argomento argomento, String nota) {
    return Chip(
      avatar: Icon(
        icona(argomento.icona),
        color: coloreArgomento(argomento.colore).colore,
      ),
      label: Text('${argomento.nome}$nota'),
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
                '«pagare il bollo #personale @burocrazia entro il 30/11»',
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
