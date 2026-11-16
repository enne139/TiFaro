import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/widgets/riga_attivita.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/cattura/composizione.dart';
import 'package:tifaro/features/cattura/sintassi.dart';
import 'package:tifaro/features/quaderno/azioni_quaderno.dart';
import 'package:tifaro/features/quaderno/logica/pagina.dart';

/// La schermata Quaderno: come la pagina di un quaderno, in cima il giorno,
/// poi al massimo tre cose da fare, sotto le cose veloci e in fondo quello
/// che si è fatto in più. Le cose rimaste dai giorni prima si riscelgono,
/// non passano da sole (DECISIONI.md, voce 038).
///
/// Si guarda la pagina di oggi o quella di domani, che si prepara la sera.
/// Si può spegnere dalle impostazioni.
class QuadernoPage extends StatefulWidget {
  const QuadernoPage({super.key});

  @override
  State<QuadernoPage> createState() => _QuadernoPageState();
}

class _QuadernoPageState extends State<QuadernoPage> {
  /// Se si guarda la pagina di domani invece di quella di oggi.
  bool _domani = false;

  /// Il campo per scrivere una cosa veloce.
  final TextEditingController _veloce = TextEditingController();
  final FocusNode _focusVeloce = FocusNode();

  AppDatabase get _db => AppScope.db(context);

  @override
  void dispose() {
    _veloce.dispose();
    _focusVeloce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final DateTime adesso = DateTime.now();
    final DateTime oggi = giorno(adesso);
    final DateTime pagina = _domani
        ? DateTime(oggi.year, oggi.month, oggi.day + 1)
        : oggi;
    final PaginaQuaderno p = paginaDelGiorno(dati.indice, pagina, adesso);
    final int liberi = cosePerGiorno - p.principali.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Text(
                conMaiuscola(formatoGiornoIntero(pagina)),
                style: tema.textTheme.titleLarge,
              ),
              SegmentedButton<bool>(
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(value: false, label: Text('Oggi')),
                  ButtonSegment<bool>(value: true, label: Text('Domani')),
                ],
                selected: <bool>{_domani},
                showSelectedIcon: false,
                onSelectionChanged: (Set<bool> scelta) =>
                    setState(() => _domani = scelta.first),
              ),
            ],
          ),
        ),

        // Rimaste dai giorni prima: si vedono solo nella pagina di oggi,
        // che è dove si decide se rifarle.
        if (!_domani && p.daRiscegliere.isNotEmpty) ...<Widget>[
          IntestazioneGruppo(
            titolo: 'Da riscegliere',
            quante: p.daRiscegliere.length,
            icona: Icons.history,
          ),
          _Nota(
            'Rimaste dai giorni scorsi. Rimettile in oggi, oppure toglile '
            'dal Quaderno: restano fra le cose da fare.',
          ),
          for (final Attivita a in p.daRiscegliere)
            RigaAttivita(
              key: ValueKey<String>('riscegliere-${a.id}'),
              attivita: a,
              mostraArgomento: true,
              azioni: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () =>
                        _metti(a.id, oggi, veloce: a.quadernoVeloce == true),
                    child: const Text('Oggi'),
                  ),
                  // Anche cestinare: una cosa rimasta può non servire più,
                  // e tolta dal Quaderno resterebbe fra le attività.
                  PopupMenuButton<String>(
                    tooltip: 'Altre azioni',
                    onSelected: (String scelta) =>
                        scelta == 'togli' ? _togli(a.id) : cestina(context, a),
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'togli',
                            child: Text('Togli dal Quaderno'),
                          ),
                          PopupMenuItem<String>(
                            value: 'cestina',
                            child: Text('Nel cestino'),
                          ),
                        ],
                  ),
                ],
              ),
            ),
        ],

        // Senza il numero accanto: «Le 3 cose 2» confonde, e i posti
        // liberi li dice la riga «Scegli».
        IntestazioneGruppo(
          titolo: 'Le $cosePerGiorno cose',
          icona: Icons.flag_outlined,
        ),
        for (final Attivita a in p.principali) ..._principale(a, pagina, dati),
        if (!p.piena)
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(
              p.principali.isEmpty
                  ? 'Scegli la prima cosa'
                  : 'Scegli un\'altra cosa',
            ),
            subtitle: Text(switch ((p.principali.isEmpty, _domani)) {
              (true, false) =>
                'Al massimo $cosePerGiorno: parti dalla più '
                    'semplice, così cominci.',
              (true, true) => 'Sceglile stasera: domani le trovi pronte.',
              _ => liberi == 1 ? 'Ancora un posto' : 'Ancora $liberi posti',
            }),
            onTap: () => _scegli(pagina),
          ),

        IntestazioneGruppo(
          titolo: 'Veloci',
          quante: p.veloci.length,
          icona: Icons.bolt,
        ),
        for (final Attivita a in p.veloci)
          RigaAttivita(
            key: ValueKey<String>(a.id),
            attivita: a,
            mostraPercorso: false,
            mostraArgomento: true,
            azioni: _menu(a, pagina),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _veloce,
            focusNode: _focusVeloce,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.add),
              hintText: 'Aggiungi una cosa veloce',
              helperText:
                  'Pochi minuti: falla appena finisci quello che '
                  'stai facendo. Vale la sintassi veloce (@telefonata, '
                  '#lavoro, domani); con la freccia scegli dal menu.',
              helperMaxLines: 3,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.expand_more),
                    tooltip: 'Più scelte: argomento, tipologia, scadenza',
                    onPressed: () => _veloceDalMenu(pagina),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_return),
                    tooltip: 'Aggiungi',
                    onPressed: () => _aggiungiVeloce(pagina),
                  ),
                ],
              ),
            ),
            onSubmitted: (_) => _aggiungiVeloce(pagina),
          ),
        ),

        // Domani non si è ancora fatto niente.
        if (!_domani) ...<Widget>[
          IntestazioneGruppo(
            titolo: 'Ho fatto anche',
            quante: p.fatteAnche.length,
            icona: Icons.done_all,
          ),
          if (p.fatteAnche.isEmpty)
            _Nota('Quello che fai fuori dal Quaderno compare qui.')
          else
            for (final Attivita a in p.fatteAnche)
              RigaAttivita(
                key: ValueKey<String>('fatta-${a.id}'),
                attivita: a,
                mostraArgomento: true,
              ),
        ],
      ],
    );
  }

  /// Una delle cose del giorno e, sotto, il suo prossimo passo se ha
  /// sotto-attività aperte: di una cosa lunga si guarda un passo alla volta.
  List<Widget> _principale(Attivita a, DateTime pagina, DatiApp dati) {
    final Attivita? passo = passoDaMostrare(dati.indice, a, pagina);
    return <Widget>[
      RigaAttivita(
        key: ValueKey<String>(a.id),
        attivita: a,
        mostraArgomento: true,
        azioni: _menu(a, pagina),
      ),
      if (passo != null)
        RigaAttivita(
          key: ValueKey<String>('passo-${passo.id}'),
          attivita: passo,
          rientro: 1,
          mostraPercorso: false,
        ),
    ];
  }

  /// Il menu di una riga della pagina: spostarla nell'altro giorno,
  /// toglierla dal Quaderno, cestinarla.
  Widget _menu(Attivita a, DateTime pagina) {
    final bool veloce = a.quadernoVeloce == true;
    final DateTime altro = DateTime(
      pagina.year,
      pagina.month,
      pagina.day + (_domani ? -1 : 1),
    );
    return PopupMenuButton<String>(
      tooltip: 'Azioni nel Quaderno',
      onSelected: (String scelta) => switch (scelta) {
        'sposta' => _metti(a.id, altro, veloce: veloce),
        'togli' => _togli(a.id),
        _ => cestina(context, a),
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'sposta',
          child: Text(_domani ? 'Sposta a oggi' : 'Sposta a domani'),
        ),
        const PopupMenuItem<String>(
          value: 'togli',
          child: Text('Togli dal Quaderno'),
        ),
        const PopupMenuItem<String>(
          value: 'cestina',
          child: Text('Nel cestino'),
        ),
      ],
    );
  }

  /// Mette l'attività [id] nella pagina di [pagina], controllando prima che
  /// fra le cose principali ci sia ancora posto.
  Future<bool> _metti(String id, DateTime pagina, {required bool veloce}) =>
      spostaNelQuaderno(context, id, pagina, veloce: veloce);

  Future<bool> _togli(String id) => togliDalQuaderno(context, id);

  /// Sceglie una cosa per la pagina fra le attività da fare, o ne crea una
  /// nuova con la cattura veloce.
  Future<void> _scegli(DateTime pagina) async {
    final String? scelta = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) => _SceltaAttivita(pagina: pagina),
    );
    if (scelta == null || !mounted) {
      return;
    }
    String? id = scelta;
    if (scelta == _SceltaAttivita.nuova) {
      id = await apriCattura(context);
    }
    if (id != null && mounted) {
      await _metti(id, pagina, veloce: false);
    }
  }

  /// Crea una cosa veloce con la cattura veloce, partendo da quello già
  /// scritto e con il menu delle scelte aperto, e la mette fra le veloci
  /// di [pagina] (voce 038).
  Future<void> _veloceDalMenu(DateTime pagina) async {
    final String? id = await apriCattura(
      context,
      testo: _veloce.text,
      conMenu: true,
    );
    if (id == null || !mounted) {
      return;
    }
    _veloce.clear();
    await _metti(id, pagina, veloce: true);
  }

  /// Crea una cosa veloce dalla riga scritta, nella pagina di [pagina].
  ///
  /// Vale la sintassi veloce (`#argomento`, `@tipologia`, una data), ma
  /// non i modelli: una cosa veloce è una riga sola.
  Future<void> _aggiungiVeloce(DateTime pagina) async {
    final DateTime adesso = DateTime.now();
    final DatiApp dati = DatiApp.leggi(context);
    final CatturaComposta c = componiCattura(
      riga: analizzaRiga(_veloce.text, adesso),
      menu: const SceltaMenu(),
      argomenti: dati.argomenti,
      tipologie: dati.tipologie,
      modelli: const <Modello>[],
      adesso: adesso,
    );
    if (c.titolo.isEmpty) {
      return;
    }
    final AppDatabase db = _db;
    final bool riuscito = await eseguiSegnalandoErrori(context, () async {
      await db.transaction(() async {
        final String? nuovoArgomento = c.nuovoArgomento;
        final String? nuovaTipologia = c.nuovaTipologia;
        final String? argomentoId = nuovoArgomento != null
            ? (await db.categorieDao.trovaOCreaArgomento(nuovoArgomento)).id
            : c.argomento?.id;
        final String? tipologiaId = nuovaTipologia != null
            ? (await db.categorieDao.trovaOCreaTipologia(nuovaTipologia)).id
            : c.tipologia?.id;
        await db.attivitaDao.crea(
          titolo: c.titolo,
          argomentoId: argomentoId,
          tipologiaId: tipologiaId,
          scadenza: c.scadenza,
          scadenzaConOra: c.conOra,
          nelCalendario: c.calendario,
          ricorrenza: c.ricorrenza,
          giornoQuaderno: pagina,
          quadernoVeloce: true,
          adesso: adesso,
        );
      });
    });
    if (riuscito && mounted) {
      _veloce.clear();
      // Il campo resta pronto: le cose veloci vengono in mente a raffica.
      _focusVeloce.requestFocus();
    }
  }
}

/// Un testo piccolo di spiegazione sotto un'intestazione.
class _Nota extends StatelessWidget {
  const _Nota(this.testo);

  final String testo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        testo,
        style: tema.textTheme.bodySmall?.copyWith(
          color: tema.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Il foglio per scegliere una cosa da mettere nella pagina: una ricerca,
/// la voce per crearne una nuova e le attività da fare, sotto-attività
/// comprese.
///
/// Si chiude con l'id dell'attività scelta, o con [nuova] per crearne una.
class _SceltaAttivita extends StatefulWidget {
  const _SceltaAttivita({required this.pagina});

  /// Quello con cui si chiude il foglio quando si vuole un'attività nuova.
  static const String nuova = '__nuova__';

  /// Il giorno della pagina: le attività già lì non si propongono.
  final DateTime pagina;

  @override
  State<_SceltaAttivita> createState() => _SceltaAttivitaState();
}

class _SceltaAttivitaState extends State<_SceltaAttivita> {
  final TextEditingController _ricerca = TextEditingController();

  @override
  void dispose() {
    _ricerca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final DateTime adesso = DateTime.now();
    final List<Attivita> candidate = daScegliere(
      dati.indice,
      widget.pagina,
      testo: _ricerca.text,
    );

    return Padding(
      // Il foglio sale sopra la tastiera, così la ricerca resta visibile.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ricerca,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Cerca fra le cose da fare',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Nuova attività'),
              subtitle: const Text('Con la cattura veloce'),
              onTap: () => Navigator.pop(context, _SceltaAttivita.nuova),
            ),
            const Divider(height: 1),
            Expanded(
              child: candidate.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _ricerca.text.trim().isEmpty
                              ? 'Non ci sono altre cose da fare: creane una '
                                    'con «Nuova attività».'
                              : 'Nessuna attività trovata.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: candidate.length,
                      itemBuilder: (BuildContext context, int i) {
                        final Attivita a = candidate[i];
                        return ListTile(
                          key: ValueKey<String>(a.id),
                          title: Text(a.titolo),
                          subtitle: _descrizione(a, dati, adesso),
                          onTap: () => Navigator.pop(context, a.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sotto il titolo: di quale attività fa parte, la scadenza e, se è già
  /// nel Quaderno di un altro giorno, quale (sceglierla la sposta).
  Widget? _descrizione(Attivita a, DatiApp dati, DateTime adesso) {
    final String percorso = dati.indice
        .percorso(a)
        .map((Attivita s) => s.titolo)
        .join(' › ');
    final DateTime? scadenza = a.scadenza;
    final DateTime? giornoA = a.giornoQuaderno;
    final String testo = <String>[
      if (percorso.isNotEmpty) 'parte di $percorso',
      if (scadenza != null)
        'scade ${formatoScadenza(scadenza, a.scadenzaConOra, adesso)}',
      if (giornoA != null)
        'nel Quaderno di ${formatoScadenza(giornoA, false, adesso)}',
    ].join(' · ');
    return testo.isEmpty ? null : Text(testo);
  }
}
