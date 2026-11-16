import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/features/attivita/argomenti_page.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/elenchi_pages.dart';
import 'package:tifaro/features/attivita/oggi_page.dart';
import 'package:tifaro/features/attivita/tipologie_page.dart';
import 'package:tifaro/features/categorie/impostazioni_page.dart';
import 'package:tifaro/features/cattura/cattura_sheet.dart';
import 'package:tifaro/features/cattura/condivisione.dart';
import 'package:tifaro/features/cattura/scorciatoie.dart';
import 'package:tifaro/features/modelli/modelli_page.dart';
import 'package:tifaro/features/notifiche/pianificatore_notifiche.dart';
import 'package:tifaro/features/quaderno/quaderno_page.dart';
import 'package:tifaro/features/sincronizzazione/sezione_sync.dart';

/// Una sezione principale dell'app.
class _Sezione {
  const _Sezione(this.titolo, this.icona, this.iconaScelta, this.pagina);

  final String titolo;
  final IconData icona;
  final IconData iconaScelta;
  final Widget pagina;
}

/// La sezione con cui parte l'app, e dove porta un avviso toccato.
const _Sezione _oggi = _Sezione(
  'Oggi',
  Icons.today_outlined,
  Icons.today,
  OggiPage(),
);

/// Le sezioni principali nell'ordine della barra. Il Quaderno c'è solo se
/// è acceso nelle impostazioni (DECISIONI.md, voce 038).
List<_Sezione> _sezioni({required bool quaderno}) => <_Sezione>[
  _oggi,
  if (quaderno)
    const _Sezione(
      'Quaderno',
      Icons.menu_book_outlined,
      Icons.menu_book,
      QuadernoPage(),
    ),
  const _Sezione(
    'Argomenti',
    Icons.folder_outlined,
    Icons.folder,
    ArgomentiPage(),
  ),
  const _Sezione(
    'Tipologie',
    Icons.label_outline,
    Icons.label,
    TipologiePage(),
  ),
];

/// Larghezza oltre la quale la barra va di lato invece che in basso.
const double _larghezzaComputer = 720;

/// L'impalcatura dell'app: le sezioni principali, il menu laterale con
/// quelle secondarie e il pulsante «Nuova» per la cattura veloce.
///
/// Sul telefono la barra sta in basso, sul computer di lato.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Il titolo della sezione scelta. Si tiene il titolo e non la posizione
  /// perché accendendo o spegnendo il Quaderno le posizioni cambiano.
  String _sezione = _oggi.titolo;
  late final AscoltoCondivisioni _condivisioni = AscoltoCondivisioni(
    _condivisioneRicevuta,
  );

  /// Gli avvisi, per aprire quello che si tocca.
  PianificatoreNotifiche? _avvisi;

  final ScorciatoieIcona _scorciatoie = ScorciatoieIcona();

  @override
  void initState() {
    super.initState();
    _condivisioni.avvia();
    _scorciatoie.avvia(_scorciatoiaUsata);
  }

  /// Una scorciatoia dell'icona apre la cattura veloce, con la fotocamera
  /// se è «Foto» (voce 034).
  void _scorciatoiaUsata(String tipo) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        apriCattura(context, conFotocamera: tipo == ScorciatoieIcona.foto);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avvisi == null) {
      _avvisi = AppScope.notifiche(context);
      _avvisi?.daAprire.addListener(_avvisoToccato);
      // Un avviso che ha aperto l'app è arrivato prima di questa pagina.
      _avvisoToccato();
    }
  }

  @override
  void dispose() {
    _condivisioni.ferma();
    _avvisi?.daAprire.removeListener(_avvisoToccato);
    super.dispose();
  }

  /// Un avviso toccato apre la sua attività, oppure Oggi se era il
  /// riepilogo di più attività.
  void _avvisoToccato() {
    final PianificatoreNotifiche? avvisi = _avvisi;
    final AperturaDaAvviso? apertura = avvisi?.daAprire.value;
    if (avvisi == null || apertura == null) {
      return;
    }
    avvisi.daAprire.value = null;
    // Dopo il primo disegno, come per il tasto Condividi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _sezione = _oggi.titolo);
      final String? id = apertura.attivitaId;
      if (id != null && DatiApp.leggi(context).indice[id] != null) {
        apriDettaglio(context, id);
      }
    });
    // Senza altri cambiamenti il disegno successivo non arriverebbe, e con
    // lui l'apertura.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// Una foto o un testo arrivati dal tasto Condividi di un'altra app
  /// aprono la cattura veloce già compilata.
  void _condivisioneRicevuta(Condivisione condivisione) {
    // Dopo il primo disegno: all'avvio l'app potrebbe non essere ancora
    // pronta ad aprire un foglio.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final ({String riga, String descrizione}) parti = condivisione.divisa();
      apriCattura(
        context,
        testo: parti.riga,
        descrizione: parti.descrizione,
        foto: condivisione.foto,
      );
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _apri(Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    final bool computer =
        MediaQuery.sizeOf(context).width >= _larghezzaComputer;
    final List<_Sezione> sezioni = _sezioni(
      quaderno: DatiApp.of(context).quadernoAttivo,
    );
    // Una sezione spenta mentre era scelta riporta a Oggi.
    final int scelta = sezioni
        .indexWhere((_Sezione s) => s.titolo == _sezione)
        .clamp(0, sezioni.length - 1);
    // IndexedStack tiene vive le sezioni: tornando su Argomenti si
    // ritrovano l'argomento scelto e i rami aperti. Le chiavi le tengono
    // vive anche quando il Quaderno compare o sparisce e le posizioni
    // cambiano.
    final Widget corpo = IndexedStack(
      index: scelta,
      children: <Widget>[
        for (final _Sezione s in sezioni)
          KeyedSubtree(key: ValueKey<String>(s.titolo), child: s.pagina),
      ],
    );

    // Ctrl+N apre la cattura veloce, comodo sul computer (voce 034).
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            apriCattura(context),
      },
      child: Focus(
        autofocus: true,
        child: _impalcatura(computer, corpo, sezioni, scelta),
      ),
    );
  }

  Widget _impalcatura(
    bool computer,
    Widget corpo,
    List<_Sezione> sezioni,
    int scelta,
  ) {
    void scegli(int i) => setState(() => _sezione = sezioni[i].titolo);
    return Scaffold(
      appBar: AppBar(
        title: Text(sezioni[scelta].titolo),
        actions: <Widget>[
          const IconaSync(),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Cerca',
            onPressed: () => _apri(const RicercaPage()),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.lightbulb_outline),
                title: Text('TiFaro'),
                subtitle: Text('Le cose da fare'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text('Fatte'),
                onTap: () {
                  Navigator.pop(context);
                  _apri(const FattePage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Cestino'),
                onTap: () {
                  Navigator.pop(context);
                  _apri(const CestinoPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy_outlined),
                title: const Text('Modelli'),
                subtitle: const Text('Attività con le sotto-attività pronte'),
                onTap: () {
                  Navigator.pop(context);
                  _apri(const ModelliPage());
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Impostazioni'),
                subtitle: const Text('Argomenti, tipologie, server e altro'),
                onTap: () {
                  Navigator.pop(context);
                  _apri(const ImpostazioniPage());
                },
              ),
            ],
          ),
        ),
      ),
      body: computer
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: scelta,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: scegli,
                  destinations: <NavigationRailDestination>[
                    for (final _Sezione s in sezioni)
                      NavigationRailDestination(
                        icon: Icon(s.icona),
                        selectedIcon: Icon(s.iconaScelta),
                        label: Text(s.titolo),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: corpo),
              ],
            )
          : corpo,
      bottomNavigationBar: computer
          ? null
          : NavigationBar(
              selectedIndex: scelta,
              onDestinationSelected: scegli,
              destinations: <NavigationDestination>[
                for (final _Sezione s in sezioni)
                  NavigationDestination(
                    icon: Icon(s.icona),
                    selectedIcon: Icon(s.iconaScelta),
                    label: s.titolo,
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuova'),
        tooltip: computer ? 'Nuova attività (Ctrl+N)' : 'Nuova attività',
        onPressed: () => apriCattura(context),
      ),
    );
  }
}
