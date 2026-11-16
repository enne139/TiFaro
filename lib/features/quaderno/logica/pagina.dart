/// Il Quaderno: una pagina per giorno con al massimo tre cose da fare, le
/// cose veloci e quello che si è fatto in più (DECISIONI.md, voce 038).
///
/// Qui c'è solo la logica, in Dart puro: cosa sta in una pagina, cosa è
/// rimasto dai giorni prima, qual è il prossimo passo di una cosa lunga.
library;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/testo.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';

/// Quante cose principali si scelgono per un giorno. Poche, perché una
/// lista che a sera resta a metà scoraggia (voce 038).
const int cosePerGiorno = 3;

/// Quello che sta nella pagina del Quaderno di un giorno.
class PaginaQuaderno {
  const PaginaQuaderno({
    required this.principali,
    required this.veloci,
    required this.fatteAnche,
    required this.daRiscegliere,
  });

  /// Le cose scelte per il giorno, anche quelle già fatte, per scadenza.
  final List<Attivita> principali;

  /// Le cose veloci del giorno, nell'ordine in cui sono state scritte.
  final List<Attivita> veloci;

  /// Le attività fatte quel giorno che non erano nella pagina: quello che
  /// si è fatto in più, per vedere la giornata intera e non solo cosa manca.
  final List<Attivita> fatteAnche;

  /// Le attività lasciate nelle pagine dei giorni prima di oggi e non fatte.
  /// Non passano da sole al giorno dopo: si riscelgono o si tolgono.
  final List<Attivita> daRiscegliere;

  /// Se le cose principali sono già [cosePerGiorno], fatte comprese.
  bool get piena => principali.length >= cosePerGiorno;
}

/// La pagina del Quaderno del giorno di [pagina], vista [adesso].
PaginaQuaderno paginaDelGiorno(
  IndiceAttivita indice,
  DateTime pagina,
  DateTime adesso,
) {
  final List<Attivita> principali = <Attivita>[];
  final List<Attivita> veloci = <Attivita>[];
  final List<Attivita> daRiscegliere = <Attivita>[];
  for (final Attivita a in indice.tutte) {
    final DateTime? giornoA = a.giornoQuaderno;
    if (giornoA == null) {
      continue;
    }
    if (giorniFra(giornoA, pagina) == 0) {
      (a.quadernoVeloce == true ? veloci : principali).add(a);
    } else if (a.fattaIl == null && giorniFra(giornoA, adesso) > 0) {
      daRiscegliere.add(a);
    }
  }

  // Fra le fatte in più non contano le sotto-attività di una cosa della
  // pagina: chiudendo la principale con «Chiudi tutte» comparirebbero
  // tutte, e sono già parte di quella.
  final Set<String> nellaPagina = <String>{
    for (final Attivita a in principali) a.id,
    for (final Attivita a in veloci) a.id,
  };
  final List<Attivita> fatteAnche = indice.tutte.where((Attivita a) {
    final DateTime? fatta = a.fattaIl;
    return fatta != null &&
        giorniFra(fatta, pagina) == 0 &&
        !nellaPagina.contains(a.id) &&
        !indice
            .percorso(a)
            .any((Attivita sopra) => nellaPagina.contains(sopra.id));
  }).toList();

  principali.sort(perScadenza);
  veloci.sort(IndiceAttivita.perCreazione);
  fatteAnche.sort((Attivita a, Attivita b) => a.fattaIl!.compareTo(b.fattaIl!));
  daRiscegliere.sort((Attivita a, Attivita b) {
    final int giorni = a.giornoQuaderno!.compareTo(b.giornoQuaderno!);
    return giorni != 0 ? giorni : perScadenza(a, b);
  });
  return PaginaQuaderno(
    principali: principali,
    veloci: veloci,
    fatteAnche: fatteAnche,
    daRiscegliere: daRiscegliere,
  );
}

/// Il prossimo passo di [attivita]: la prima sotto-attività da fare,
/// scendendo finché ce ne sono; nullo se non ne ha di aperte.
///
/// Di una cosa lunga si guarda un passo alla volta: scritti tutti insieme
/// sembrano una montagna (voce 038).
Attivita? prossimoPasso(IndiceAttivita indice, Attivita attivita) {
  Attivita? passo;
  String corrente = attivita.id;
  // `visti` protegge da un ciclo nei dati.
  final Set<String> visti = <String>{corrente};
  while (true) {
    Attivita? aperta;
    for (final Attivita figlia in indice.figlie(corrente)) {
      if (figlia.fattaIl == null && !visti.contains(figlia.id)) {
        aperta = figlia;
        break;
      }
    }
    if (aperta == null) {
      return passo;
    }
    passo = aperta;
    corrente = aperta.id;
    visti.add(corrente);
  }
}

/// Il prossimo passo da mostrare sotto [attivita] nella pagina di
/// [pagina]: nessuno se è già fatta, o se il passo è a sua volta nella
/// pagina, dove comparirebbe due volte.
Attivita? passoDaMostrare(
  IndiceAttivita indice,
  Attivita attivita,
  DateTime pagina,
) {
  if (attivita.fattaIl != null) {
    return null;
  }
  final Attivita? passo = prossimoPasso(indice, attivita);
  final DateTime? giornoPasso = passo?.giornoQuaderno;
  if (giornoPasso != null && giorniFra(giornoPasso, pagina) == 0) {
    return null;
  }
  return passo;
}

/// Le attività da fare che si possono scegliere per la pagina di [pagina],
/// sotto-attività comprese (così si sceglie il passo di una cosa lunga),
/// tranne quelle già in quella pagina. Prima quelle con la scadenza più
/// vicina.
///
/// Con [testo] solo quelle che ne contengono tutte le parole nel titolo o
/// nella descrizione, senza badare a maiuscole e accenti.
List<Attivita> daScegliere(
  IndiceAttivita indice,
  DateTime pagina, {
  String testo = '',
}) {
  final List<String> parole = testo
      .split(RegExp(r'\s+'))
      .map(chiaveNome)
      .where((String p) => p.isNotEmpty)
      .toList();
  return indice.tutte.where((Attivita a) {
    if (a.fattaIl != null) {
      return false;
    }
    final DateTime? giornoA = a.giornoQuaderno;
    if (giornoA != null && giorniFra(giornoA, pagina) == 0) {
      return false;
    }
    if (parole.isEmpty) {
      return true;
    }
    final String dove = chiaveNome('${a.titolo} ${a.descrizione}');
    return parole.every(dove.contains);
  }).toList()..sort(perScadenza);
}
