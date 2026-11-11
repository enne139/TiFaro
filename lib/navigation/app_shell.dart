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
import 'package:tifaro/features/sincronizzazione/sezione_sync.dart';

/// Una sezione principale dell'app.
class _Sezione {
  const _Sezione(this.titolo, this.icona, this.iconaScelta, this.pagina);

  final String titolo;
  final IconData icona;
  final IconData iconaScelta;
  final Widget pagina;
}

/// Le sezioni principali, nell'ordine della barra.
const List<_Sezione> _sezioni = <_Sezione>[
  _Sezione('Oggi', Icons.today_outlined, Icons.today, OggiPage()),
  _Sezione('Argomenti', Icons.folder_outlined, Icons.folder, ArgomentiPage()),
  _Sezione('Tipologie', Icons.label_outline, Icons.label, TipologiePage()),
];

/// Larghezza oltre la quale la barra va di lato invece che in basso.
const double _larghezzaComputer = 720;

/// L'impalcatura dell'app: le tre sezioni principali, il menu laterale con
/// quelle secondarie e il pulsante «Nuova» per la cattura veloce.
///
/// Sul telefono la barra sta in basso, sul computer di lato.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _sezione = 0;
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
      setState(() => _sezione = 0);
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
    // IndexedStack tiene vive le sezioni: tornando su Argomenti si
    // ritrovano l'argomento scelto e i rami aperti.
    final Widget corpo = IndexedStack(
      index: _sezione,
      children: <Widget>[for (final _Sezione s in _sezioni) s.pagina],
    );

    // Ctrl+N apre la cattura veloce, comodo sul computer (voce 034).
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            apriCattura(context),
      },
      child: Focus(autofocus: true, child: _impalcatura(computer, corpo)),
    );
  }

  Widget _impalcatura(bool computer, Widget corpo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sezioni[_sezione].titolo),
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
                subtitle: const Text('Argomenti, tipologie e server'),
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
                  selectedIndex: _sezione,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (int i) =>
                      setState(() => _sezione = i),
                  destinations: <NavigationRailDestination>[
                    for (final _Sezione s in _sezioni)
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
              selectedIndex: _sezione,
              onDestinationSelected: (int i) => setState(() => _sezione = i),
              destinations: <NavigationDestination>[
                for (final _Sezione s in _sezioni)
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
