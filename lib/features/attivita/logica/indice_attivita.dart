import 'package:tifaro/core/database/app_database.dart';

/// Le attività fuori dal cestino, organizzate ad albero per rispondere alle
/// domande delle schermate: figlie, percorso, avanzamento.
///
/// Si costruisce da zero a ogni cambiamento del database: per qualche
/// migliaio di attività è istantaneo, e tiene tutta la logica in Dart
/// puro, facile da provare (DECISIONI.md, voce 012).
class IndiceAttivita {
  IndiceAttivita(Iterable<Attivita> tutte) {
    for (final Attivita a in tutte) {
      _perId[a.id] = a;
    }
    for (final Attivita a in _perId.values) {
      // Un genitore che non c'è (per esempio cestinato a parte) rende
      // l'attività principale: meglio vederla in cima che perderla.
      final String? genitore = a.genitoreId;
      final String? chiave = genitore != null && _perId.containsKey(genitore)
          ? genitore
          : null;
      _figli.putIfAbsent(chiave, () => <Attivita>[]).add(a);
    }
    for (final List<Attivita> sorelle in _figli.values) {
      sorelle.sort(perOrdine);
    }
  }

  final Map<String, Attivita> _perId = <String, Attivita>{};
  final Map<String?, List<Attivita>> _figli = <String?, List<Attivita>>{};

  /// Ordine fra sorelle: quello scelto, poi la data di creazione.
  static int perOrdine(Attivita a, Attivita b) {
    final int ordine = a.ordine.compareTo(b.ordine);
    return ordine != 0 ? ordine : a.creataIl.compareTo(b.creataIl);
  }

  /// Ordine di creazione, dalla più vecchia; a parità, per titolo.
  static int perCreazione(Attivita a, Attivita b) {
    final int c = a.creataIl.compareTo(b.creataIl);
    return c != 0
        ? c
        : a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase());
  }

  /// L'attività con questo id, se c'è.
  Attivita? operator [](String id) => _perId[id];

  /// Tutte le attività, senza un ordine preciso.
  Iterable<Attivita> get tutte => _perId.values;

  /// Le figlie dirette di [id], in ordine; con `null` le attività principali.
  List<Attivita> figlie(String? id) => _figli[id] ?? const <Attivita>[];

  /// Se [id] ha almeno una sotto-attività.
  bool haFiglie(String id) => figlie(id).isNotEmpty;

  /// Le antenate di [attivita], dalla principale al genitore diretto.
  List<Attivita> percorso(Attivita attivita) {
    final List<Attivita> antenate = <Attivita>[];
    final Set<String> visti = <String>{attivita.id};
    String? genitore = attivita.genitoreId;
    // `visti` protegge da un ciclo nei dati, che girerebbe all'infinito.
    while (genitore != null && visti.add(genitore)) {
      final Attivita? a = _perId[genitore];
      if (a == null) {
        break;
      }
      antenate.insert(0, a);
      genitore = a.genitoreId;
    }
    return antenate;
  }

  /// Tutte le discendenti di [id], a qualunque profondità.
  List<Attivita> discendenti(String id) {
    final List<Attivita> risultato = <Attivita>[];
    final List<String> daVisitare = <String>[id];
    final Set<String> visti = <String>{id};
    while (daVisitare.isNotEmpty) {
      for (final Attivita figlia in figlie(daVisitare.removeLast())) {
        if (visti.add(figlia.id)) {
          risultato.add(figlia);
          daVisitare.add(figlia.id);
        }
      }
    }
    return risultato;
  }

  /// Quante discendenti di [id] sono ancora da fare.
  int discendentiAperte(String id) =>
      discendenti(id).where((Attivita a) => a.fattaIl == null).length;

  /// Fatte e totali fra le figlie dirette di [id], per mostrare "2/5".
  ({int fatte, int totali}) avanzamento(String id) {
    final List<Attivita> sotto = figlie(id);
    return (
      fatte: sotto.where((Attivita a) => a.fattaIl != null).length,
      totali: sotto.length,
    );
  }
}
