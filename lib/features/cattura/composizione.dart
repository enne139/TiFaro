/// Come si mettono insieme, nella cattura veloce, quello che si scrive,
/// quello che si sceglie dal menu e quello che porta un modello
/// (DECISIONI.md, voce 018).
library;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/attivita/logica/ricorrenza.dart';
import 'package:tifaro/features/cattura/sintassi.dart';
import 'package:tifaro/features/modelli/logica/scadenze_relative.dart';

/// Una scelta del menu che può anche essere "nessuno": `null` vuol dire
/// che nel menu non si è scelto niente, `(valore: null)` che si è scelto
/// "nessuno".
typedef Scelta<T> = ({T? valore});

/// Quello che si è scelto dal menu della cattura veloce. Un campo nullo
/// vuol dire "non scelto": vale il testo, poi il modello.
class SceltaMenu {
  const SceltaMenu({
    this.argomentoId,
    this.tipologia,
    this.scadenza,
    this.calendario,
    this.modello,
    this.ricorrenza,
  });

  final String? argomentoId;
  final Scelta<String>? tipologia;
  final ({DateTime? data, bool conOra})? scadenza;
  final bool? calendario;
  final Scelta<String>? modello;

  /// Ogni quanto si ripete; `(valore: null)` è "non si ripete".
  final Scelta<Ricorrenza>? ricorrenza;
}

/// Il risultato: l'attività che verrà creata.
class CatturaComposta {
  const CatturaComposta({
    required this.titolo,
    required this.scadenza,
    required this.conOra,
    required this.calendario,
    this.modello,
    this.modelloNonTrovato,
    this.argomento,
    this.nuovoArgomento,
    this.tipologia,
    this.nuovaTipologia,
    this.ricorrenza,
  });

  /// Il titolo; vuoto se non c'è né scritto né dal modello.
  final String titolo;

  /// Il modello da usare.
  final Modello? modello;

  /// Un `/etichetta` scritta che non corrisponde a nessun modello.
  final String? modelloNonTrovato;

  /// L'argomento esistente; nullo se ne va creato uno ([nuovoArgomento]).
  final Argomento? argomento;

  /// Il nome dell'argomento da creare.
  final String? nuovoArgomento;

  /// La tipologia esistente; nulla se non c'è o ne va creata una.
  final Tipologia? tipologia;

  /// Il nome della tipologia da creare.
  final String? nuovaTipologia;

  final DateTime? scadenza;
  final bool conOra;
  final bool calendario;

  /// Ogni quanto si ripete; nulla se non si ripete (voce 032).
  final Ricorrenza? ricorrenza;
}

/// Mette insieme riga scritta, menu e modello.
///
/// Per ogni campo vince il primo che c'è, in quest'ordine: il menu, il
/// testo, il modello, il valore predefinito. Una sotto-attività
/// ([argomentoGenitore]) ha sempre l'argomento della principale.
CatturaComposta componiCattura({
  required RigaAnalizzata riga,
  required SceltaMenu menu,
  required List<Argomento> argomenti,
  required List<Tipologia> tipologie,
  required List<Modello> modelli,
  required DateTime adesso,
  Argomento? argomentoGenitore,
}) {
  T? perId<T>(Iterable<T> elenco, String? id, String Function(T) idDi) {
    if (id == null) {
      return null;
    }
    for (final T e in elenco) {
      if (idDi(e) == id) {
        return e;
      }
    }
    return null;
  }

  // Modello.
  Modello? modello;
  String? modelloNonTrovato;
  final Scelta<String>? modelloScelto = menu.modello;
  final String? etichettaModello = riga.modello;
  if (modelloScelto != null) {
    modello = perId(modelli, modelloScelto.valore, (Modello m) => m.id);
  } else if (etichettaModello != null) {
    modello = trovaPerEtichetta(
      etichettaModello,
      modelli,
      (Modello m) => m.nome,
    );
    if (modello == null) {
      modelloNonTrovato = etichettaModello;
    }
  }

  // Argomento.
  Argomento? argomento;
  String? nuovoArgomento;
  final String? etichettaArgomento = riga.argomento;
  if (argomentoGenitore != null) {
    argomento = argomentoGenitore;
  } else if (menu.argomentoId != null) {
    argomento = perId(argomenti, menu.argomentoId, (Argomento a) => a.id);
  } else if (etichettaArgomento != null) {
    argomento = trovaPerEtichetta(
      etichettaArgomento,
      argomenti,
      (Argomento a) => a.nome,
    );
    if (argomento == null) {
      nuovoArgomento = nomeDaEtichetta(etichettaArgomento);
    }
  } else if (modello?.argomentoId != null) {
    argomento = perId(argomenti, modello?.argomentoId, (Argomento a) => a.id);
  }
  if (argomento == null && nuovoArgomento == null) {
    // Il predefinito, o il primo se manca.
    for (final Argomento a in argomenti) {
      if (a.predefinito) {
        argomento = a;
      }
    }
    argomento ??= argomenti.isEmpty ? null : argomenti.first;
  }

  // Tipologia.
  Tipologia? tipologia;
  String? nuovaTipologia;
  final Scelta<String>? tipologiaScelta = menu.tipologia;
  final String? etichettaTipologia = riga.tipologia;
  if (tipologiaScelta != null) {
    tipologia = perId(tipologie, tipologiaScelta.valore, (Tipologia t) => t.id);
  } else if (etichettaTipologia != null) {
    tipologia = trovaPerEtichetta(
      etichettaTipologia,
      tipologie,
      (Tipologia t) => t.nome,
    );
    if (tipologia == null) {
      nuovaTipologia = nomeDaEtichetta(etichettaTipologia);
    }
  } else if (modello != null) {
    tipologia = perId(tipologie, modello.tipologiaId, (Tipologia t) => t.id);
  }

  // Scadenza.
  DateTime? scadenza;
  bool conOra = false;
  final ({DateTime? data, bool conOra})? scadenzaScelta = menu.scadenza;
  if (scadenzaScelta != null) {
    scadenza = scadenzaScelta.data;
    conOra = scadenza != null && scadenzaScelta.conOra;
  } else if (riga.scadenza != null) {
    scadenza = riga.scadenza;
    conOra = riga.conOra;
  } else if (modello != null) {
    final ({DateTime? scadenza, bool conOra}) relativa = scadenzaRelativa(
      adesso,
      modello.giorni,
      modello.minuti,
    );
    scadenza = relativa.scadenza;
    conOra = relativa.conOra;
  }

  return CatturaComposta(
    titolo: riga.titolo.isNotEmpty ? riga.titolo : (modello?.nome ?? ''),
    modello: modello,
    modelloNonTrovato: modelloNonTrovato,
    argomento: argomento,
    nuovoArgomento: nuovoArgomento,
    tipologia: tipologia,
    nuovaTipologia: nuovaTipologia,
    scadenza: scadenza,
    conOra: conOra,
    calendario:
        menu.calendario ??
        (riga.calendario || (modello?.nelCalendario ?? false)),
    // I modelli non si ripetono da soli: vale il menu, poi il testo.
    ricorrenza: menu.ricorrenza != null
        ? menu.ricorrenza!.valore
        : riga.ricorrenza,
  );
}
