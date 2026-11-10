/// Le scelte delle schermate, calcolate dall'indice: cosa scade, cosa
/// raggruppare, cosa mostrare nel cestino.
library;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';

/// Le attività da fare divise come nella schermata Oggi: per scadenza
/// vicina, e in fondo quelle senza scadenza.
class GruppiScadenza {
  const GruppiScadenza({
    required this.scadute,
    required this.oggi,
    required this.prossime,
    this.senzaScadenza = const <Attivita>[],
  });

  /// Scadute nei giorni passati.
  final List<Attivita> scadute;

  /// In scadenza oggi.
  final List<Attivita> oggi;

  /// In scadenza nei prossimi giorni.
  final List<Attivita> prossime;

  /// Le attività principali senza scadenza, dalla più vecchia
  /// (DECISIONI.md, voce 028).
  final List<Attivita> senzaScadenza;

  /// Se non c'è niente in nessun gruppo.
  bool get vuoto =>
      scadute.isEmpty &&
      oggi.isEmpty &&
      prossime.isEmpty &&
      senzaScadenza.isEmpty;
}

/// Ordine per scadenza: prima la più vicina; a parità di giorno quelle con
/// l'ora prima di quelle senza, poi per titolo.
int perScadenza(Attivita a, Attivita b) {
  final DateTime? sa = a.scadenza;
  final DateTime? sb = b.scadenza;
  if (sa == null || sb == null) {
    if (sa != sb) {
      return sa == null ? 1 : -1;
    }
    return a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase());
  }
  final int giorni = giorno(sa).compareTo(giorno(sb));
  if (giorni != 0) {
    return giorni;
  }
  if (a.scadenzaConOra != b.scadenzaConOra) {
    return a.scadenzaConOra ? -1 : 1;
  }
  final int ore = sa.compareTo(sb);
  return ore != 0
      ? ore
      : a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase());
}

/// Ordina le attività principali di un elenco: prima quelle con la
/// scadenza più vicina, poi le altre nell'ordine in cui sono state create.
///
/// Fra le principali l'ordine a mano conta poco (sono tante e di argomenti
/// diversi), mentre fra le sotto-attività resta quello scelto
/// (DECISIONI.md, voce 013).
List<Attivita> ordinaPrincipali(Iterable<Attivita> principali) {
  return principali.toList()..sort((Attivita a, Attivita b) {
    final DateTime? sa = a.scadenza;
    final DateTime? sb = b.scadenza;
    if (sa != null && sb != null) {
      final int c = perScadenza(a, b);
      if (c != 0) {
        return c;
      }
    } else if (sa != sb) {
      return sa == null ? 1 : -1;
    }
    return IndiceAttivita.perOrdine(a, b);
  });
}

/// Le attività da fare che scadono entro [giorni] giorni, sotto-attività
/// comprese, divise in scadute, di oggi e prossime; più le attività
/// principali senza scadenza, in ordine di creazione.
///
/// Fra quelle senza scadenza non ci sono le sotto-attività: sono spesso i
/// passaggi di un'attività più grande (o di un modello), e la loro
/// principale compare già, con l'avanzamento.
GruppiScadenza raggruppaPerScadenza(
  IndiceAttivita indice,
  DateTime adesso, {
  int giorni = 7,
}) {
  final List<Attivita> scadute = <Attivita>[];
  final List<Attivita> oggi = <Attivita>[];
  final List<Attivita> prossime = <Attivita>[];
  final List<Attivita> senzaScadenza = <Attivita>[];
  final Set<String> principali = indice
      .figlie(null)
      .map((Attivita a) => a.id)
      .toSet();
  for (final Attivita a in indice.tutte) {
    final DateTime? scadenza = a.scadenza;
    if (a.fattaIl != null) {
      continue;
    }
    if (scadenza == null) {
      if (principali.contains(a.id)) {
        senzaScadenza.add(a);
      }
      continue;
    }
    final int distanza = giorniFra(adesso, scadenza);
    if (distanza < 0) {
      scadute.add(a);
    } else if (distanza == 0) {
      oggi.add(a);
    } else if (distanza <= giorni) {
      prossime.add(a);
    }
  }
  scadute.sort(perScadenza);
  oggi.sort(perScadenza);
  prossime.sort(perScadenza);
  senzaScadenza.sort(IndiceAttivita.perCreazione);
  return GruppiScadenza(
    scadute: scadute,
    oggi: oggi,
    prossime: prossime,
    senzaScadenza: senzaScadenza,
  );
}

/// Se [attivita] è scaduta rispetto ad [adesso].
///
/// Una scadenza senza ora vale fino a fine giornata; con l'ora, fino a
/// quell'ora.
bool scaduta(Attivita attivita, DateTime adesso) {
  final DateTime? scadenza = attivita.scadenza;
  if (scadenza == null || attivita.fattaIl != null) {
    return false;
  }
  if (attivita.scadenzaConOra) {
    return scadenza.isBefore(adesso);
  }
  return giorniFra(adesso, scadenza) < 0;
}

/// Le attività da fare per ogni tipologia, sotto-attività comprese,
/// ordinate per scadenza. Chi non ha tipologia non compare.
Map<String, List<Attivita>> raggruppaPerTipologia(IndiceAttivita indice) {
  final Map<String, List<Attivita>> gruppi = <String, List<Attivita>>{};
  for (final Attivita a in indice.tutte) {
    final String? tipologia = a.tipologiaId;
    if (a.fattaIl == null && tipologia != null) {
      gruppi.putIfAbsent(tipologia, () => <Attivita>[]).add(a);
    }
  }
  for (final List<Attivita> gruppo in gruppi.values) {
    gruppo.sort(perScadenza);
  }
  return gruppi;
}

/// Le attività fatte, dalla più recente.
List<Attivita> fatte(IndiceAttivita indice) {
  return indice.tutte.where((Attivita a) => a.fattaIl != null).toList()
    ..sort((Attivita a, Attivita b) => b.fattaIl!.compareTo(a.fattaIl!));
}

/// Fra le attività cestinate, quelle da mostrare nel cestino: chi è stata
/// cestinata per prima di un gruppo, non le sotto-attività cestinate con lei.
///
/// Una sotto-attività fa gruppo a sé se il genitore non è nel cestino, o ci
/// è finito in un altro momento (DECISIONI.md, voce 006).
List<Attivita> radiciDelCestino(List<Attivita> cestinate) {
  final Map<String, Attivita> perId = <String, Attivita>{
    for (final Attivita a in cestinate) a.id: a,
  };
  return cestinate.where((Attivita a) {
    final String? genitore = a.genitoreId;
    if (genitore == null) {
      return true;
    }
    return perId[genitore]?.cancellataIl != a.cancellataIl;
  }).toList();
}

/// Le attività il cui titolo o descrizione contiene tutte le parole di
/// [testo], senza badare a maiuscole e accenti. Prima quelle da fare.
List<Attivita> cerca(IndiceAttivita indice, String testo) {
  final List<String> parole = testo
      .split(RegExp(r'\s+'))
      .map(chiaveNome)
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parole.isEmpty) {
    return const <Attivita>[];
  }
  final List<Attivita> trovate = indice.tutte.where((Attivita a) {
    final String dove = chiaveNome('${a.titolo} ${a.descrizione}');
    return parole.every(dove.contains);
  }).toList();
  trovate.sort((Attivita a, Attivita b) {
    if ((a.fattaIl == null) != (b.fattaIl == null)) {
      return a.fattaIl == null ? -1 : 1;
    }
    return perScadenza(a, b);
  });
  return trovate;
}
