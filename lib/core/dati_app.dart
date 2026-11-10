import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/modelli/logica/albero_voci.dart';

/// Tutto quello che serve alle schermate, letto una volta per tutta l'app.
///
/// Le schermate non aprono letture proprie: prendono questi dati con
/// [DatiApp.of] e li filtrano in Dart (DECISIONI.md, voce 012).
class DatiApp {
  DatiApp({
    required List<Attivita> attivita,
    required this.argomenti,
    required this.tipologie,
    required List<Foto> foto,
    required this.modelli,
    required List<VoceModello> voci,
  }) : indice = IndiceAttivita(attivita),
       voci = AlberoVoci(voci),
       modelliPerId = <String, Modello>{
         for (final Modello m in modelli) m.id: m,
       },
       argomentiPerId = <String, Argomento>{
         for (final Argomento a in argomenti) a.id: a,
       },
       tipologiePerId = <String, Tipologia>{
         for (final Tipologia t in tipologie) t.id: t,
       },
       fotoPerAttivita = _perAttivita(foto);

  /// Le attività fuori dal cestino, ad albero.
  final IndiceAttivita indice;

  /// Gli argomenti, nell'ordine scelto.
  final List<Argomento> argomenti;

  /// Gli argomenti per id.
  final Map<String, Argomento> argomentiPerId;

  /// Le tipologie, in ordine di nome.
  final List<Tipologia> tipologie;

  /// Le tipologie per id.
  final Map<String, Tipologia> tipologiePerId;

  /// Le foto di ogni attività, dalla più vecchia.
  final Map<String, List<Foto>> fotoPerAttivita;

  /// I modelli, in ordine di nome.
  final List<Modello> modelli;

  /// I modelli per id.
  final Map<String, Modello> modelliPerId;

  /// Le voci dei modelli, ad albero.
  final AlberoVoci voci;

  static Map<String, List<Foto>> _perAttivita(List<Foto> foto) {
    final Map<String, List<Foto>> mappa = <String, List<Foto>>{};
    for (final Foto f in foto) {
      mappa.putIfAbsent(f.attivitaId, () => <Foto>[]).add(f);
    }
    return mappa;
  }

  /// L'argomento predefinito della cattura veloce, o il primo se manca.
  Argomento? get argomentoPredefinito {
    for (final Argomento a in argomenti) {
      if (a.predefinito) {
        return a;
      }
    }
    return argomenti.isEmpty ? null : argomenti.first;
  }

  /// I dati più vicini sopra [context]. Chi li chiede in `build` viene
  /// ricostruito a ogni cambiamento del database.
  static DatiApp of(BuildContext context) {
    final _DatiScope? scope = context
        .dependOnInheritedWidgetOfExactType<_DatiScope>();
    assert(scope != null, 'Nessun FonteDati sopra questo widget.');
    return scope!.dati;
  }

  /// Come [of], ma senza registrare una dipendenza: da usare nei gestori di
  /// eventi, dove servono i dati di quel momento e non le ricostruzioni.
  static DatiApp leggi(BuildContext context) {
    final _DatiScope? scope = context
        .getInheritedWidgetOfExactType<_DatiScope>();
    assert(scope != null, 'Nessun FonteDati sopra questo widget.');
    return scope!.dati;
  }
}

/// Legge dal database i dati di [DatiApp] e li mette a disposizione di
/// tutto quello che sta sotto.
///
/// Sta sopra il `Navigator` (in `MaterialApp.builder`), così anche le
/// pagine aperte sopra e le finestre di dialogo li vedono.
class FonteDati extends StatefulWidget {
  const FonteDati({required this.child, super.key});

  final Widget child;

  @override
  State<FonteDati> createState() => _FonteDatiState();
}

class _FonteDatiState extends State<FonteDati> {
  final List<StreamSubscription<Object?>> _abbonamenti =
      <StreamSubscription<Object?>>[];
  List<Attivita>? _attivita;
  List<Argomento>? _argomenti;
  List<Tipologia>? _tipologie;
  List<Foto>? _foto;
  List<Modello>? _modelli;
  List<VoceModello>? _voci;
  Object? _errore;
  DatiApp? _dati;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_abbonamenti.isNotEmpty) {
      return;
    }
    final AppDatabase db = AppScope.db(context);
    // Letture indipendenti, una per tabella, e nessuna che aspetta
    // l'altra: i dati si ricompongono qui quando ne cambia una.
    _abbonamenti.addAll(<StreamSubscription<Object?>>[
      db.attivitaDao.osservaTutte().listen(
        (List<Attivita> v) => _aggiorna(() => _attivita = v),
        onError: _guasto,
      ),
      db.categorieDao.osservaArgomenti().listen(
        (List<Argomento> v) => _aggiorna(() => _argomenti = v),
        onError: _guasto,
      ),
      db.categorieDao.osservaTipologie().listen(
        (List<Tipologia> v) => _aggiorna(() => _tipologie = v),
        onError: _guasto,
      ),
      db.attivitaDao.osservaFoto().listen(
        (List<Foto> v) => _aggiorna(() => _foto = v),
        onError: _guasto,
      ),
      db.modelliDao.osservaModelli().listen(
        (List<Modello> v) => _aggiorna(() => _modelli = v),
        onError: _guasto,
      ),
      db.modelliDao.osservaVoci().listen(
        (List<VoceModello> v) => _aggiorna(() => _voci = v),
        onError: _guasto,
      ),
    ]);
  }

  void _aggiorna(VoidCallback cambia) {
    setState(() {
      cambia();
      final List<Attivita>? attivita = _attivita;
      final List<Argomento>? argomenti = _argomenti;
      final List<Tipologia>? tipologie = _tipologie;
      final List<Foto>? foto = _foto;
      final List<Modello>? modelli = _modelli;
      final List<VoceModello>? voci = _voci;
      if (attivita != null &&
          argomenti != null &&
          tipologie != null &&
          foto != null &&
          modelli != null &&
          voci != null) {
        _dati = DatiApp(
          attivita: attivita,
          argomenti: argomenti,
          tipologie: tipologie,
          foto: foto,
          modelli: modelli,
          voci: voci,
        );
      }
    });
  }

  void _guasto(Object errore) => setState(() => _errore = errore);

  @override
  void dispose() {
    for (final StreamSubscription<Object?> a in _abbonamenti) {
      a.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object? errore = _errore;
    final DatiApp? dati = _dati;
    if (errore != null) {
      return _Guasto(errore: errore);
    }
    if (dati == null) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }
    return _DatiScope(dati: dati, child: widget.child);
  }
}

class _DatiScope extends InheritedWidget {
  const _DatiScope({required this.dati, required super.child});

  final DatiApp dati;

  @override
  bool updateShouldNotify(_DatiScope oldWidget) => dati != oldWidget.dati;
}

/// Cosa si vede al posto dell'app quando il database non risponde: un
/// guasto deve dire cos'è, non sembrare un caricamento infinito.
class _Guasto extends StatelessWidget {
  const _Guasto({required this.errore});

  final Object errore;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 56,
                color: tema.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Il database non risponde',
                style: tema.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(messaggioErrore(errore), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Se TiFaro è già aperta in un\'altra finestra, chiudila: due '
                'copie non possono scrivere sullo stesso database.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
