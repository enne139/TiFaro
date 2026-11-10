/// La sintassi della cattura veloce: una riga di testo da cui si ricavano
/// titolo, argomento, tipologia, scadenza e calendario, senza AI
/// (DECISIONI.md, voce 010).
///
/// ```text
/// comprare guanti nitrile #ambulanza @acquisti venerdì 18:00 !cal
/// /turno sabato
/// ```
library;

import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/testo.dart';

/// Quello che si è capito da una riga della cattura veloce.
class RigaAnalizzata {
  const RigaAnalizzata({
    required this.titolo,
    this.argomento,
    this.tipologia,
    this.scadenza,
    this.conOra = false,
    this.calendario = false,
    this.modello,
  });

  /// Le parole rimaste, cioè cosa fare.
  final String titolo;

  /// L'etichetta dopo `#`, così come è stata scritta.
  final String? argomento;

  /// L'etichetta dopo `@`, così come è stata scritta.
  final String? tipologia;

  /// La scadenza: il giorno a mezzanotte, o con l'ora se [conOra].
  final DateTime? scadenza;

  /// Se nella riga c'era un'ora.
  final bool conOra;

  /// Se nella riga c'era `!cal`.
  final bool calendario;

  /// L'etichetta dopo `/`, cioè il modello da usare, così come è stata
  /// scritta.
  final String? modello;
}

/// I giorni della settimana come si scrivono, con e senza accento.
///
/// Solo i nomi interi: le abbreviazioni darebbero falsi allarmi ("chiamare
/// Gio" diventerebbe giovedì).
const Map<String, int> _giorniSettimana = <String, int>{
  'lunedì': DateTime.monday,
  'lunedi': DateTime.monday,
  'martedì': DateTime.tuesday,
  'martedi': DateTime.tuesday,
  'mercoledì': DateTime.wednesday,
  'mercoledi': DateTime.wednesday,
  'giovedì': DateTime.thursday,
  'giovedi': DateTime.thursday,
  'venerdì': DateTime.friday,
  'venerdi': DateTime.friday,
  'sabato': DateTime.saturday,
  'domenica': DateTime.sunday,
};

/// Parole che, subito prima di una data o di un'ora, ne fanno parte e non
/// vanno lasciate nel titolo: "pagare il bollo *entro il* 15/11".
const Set<String> _paroleDiCollegamento = <String>{
  'entro',
  'per',
  'il',
  'di',
  'alle',
  'ore',
};

final RegExp _data = RegExp(r'^(\d{1,2})[/.-](\d{1,2})(?:[/.-](\d{2,4}))?$');
final RegExp _ora = RegExp(r'^(\d{1,2}):(\d{2})$');
final RegExp _numero = RegExp(r'^\d{1,3}$');

/// Un modello: `/` seguita da lettere, cifre, trattini o trattini bassi. Un
/// percorso come `/home/utente` ha altre barre e resta nel titolo.
final RegExp _modello = RegExp(r'^/([\p{L}\p{N}_-]+)$', unicode: true);

/// Analizza una riga della cattura veloce, prendendo [adesso] come
/// riferimento per le date relative.
///
/// Regole sulle date:
/// - un giorno della settimana è il prossimo, mai oggi: per oggi c'è "oggi";
/// - una data senza anno già passata è dell'anno prossimo;
/// - un'ora senza data è oggi, o domani se quell'ora è già passata.
RigaAnalizzata analizzaRiga(String riga, DateTime adesso) {
  final List<String> parole = riga.trim().split(RegExp(r'\s+'));
  final List<String> titolo = <String>[];
  String? argomento;
  String? tipologia;
  DateTime? data;
  ({int ore, int minuti})? ora;
  bool calendario = false;
  String? modello;
  final DateTime oggi = giorno(adesso);

  /// Toglie dal fondo del titolo le parole di collegamento rimaste prima di
  /// una data o di un'ora.
  void togliCollegamenti() {
    while (titolo.isNotEmpty &&
        _paroleDiCollegamento.contains(titolo.last.toLowerCase())) {
      titolo.removeLast();
    }
  }

  for (int i = 0; i < parole.length; i++) {
    final String parola = parole[i];
    if (parola.isEmpty) {
      continue;
    }
    final String minuscola = parola.toLowerCase();
    final String? seguente = i + 1 < parole.length
        ? parole[i + 1].toLowerCase()
        : null;

    // Etichette: quel che segue # o @, senza la punteggiatura finale.
    if (parola.length > 1 &&
        (parola.startsWith('#') || parola.startsWith('@'))) {
      final String etichetta = parola
          .substring(1)
          .replaceAll(RegExp(r'[.,;:!?]+$'), '');
      if (etichetta.isNotEmpty) {
        if (parola.startsWith('#')) {
          argomento = etichetta;
        } else {
          tipologia = etichetta;
        }
        continue;
      }
    }

    final RegExpMatch? partiModello = _modello.firstMatch(parola);
    if (partiModello != null) {
      modello = partiModello.group(1);
      continue;
    }

    if (minuscola == '!cal') {
      calendario = true;
      continue;
    }

    // Giorni con un nome.
    final DateTime? relativa = switch (minuscola) {
      'oggi' => oggi,
      'domani' => _piuGiorni(oggi, 1),
      'dopodomani' => _piuGiorni(oggi, 2),
      _ => null,
    };
    if (relativa != null) {
      data = relativa;
      togliCollegamenti();
      continue;
    }

    final int? giornoSettimana = _giorniSettimana[minuscola];
    if (giornoSettimana != null) {
      // Il prossimo, da 1 a 7 giorni da oggi.
      int distanza = (giornoSettimana - oggi.weekday) % 7;
      if (distanza == 0) {
        distanza = 7;
      }
      data = _piuGiorni(oggi, distanza);
      togliCollegamenti();
      continue;
    }

    // "tra 3 giorni", "fra una settimana", "tra 2 mesi".
    if ((minuscola == 'tra' || minuscola == 'fra') &&
        seguente != null &&
        i + 2 < parole.length) {
      final int? quanti = _numero.hasMatch(seguente)
          ? int.parse(seguente)
          : (seguente == 'un' || seguente == 'una' ? 1 : null);
      final DateTime? dopo = quanti == null
          ? null
          : _dopo(oggi, quanti, parole[i + 2].toLowerCase());
      if (dopo != null) {
        data = dopo;
        togliCollegamenti();
        i += 2;
        continue;
      }
    }

    // Date numeriche: 15/11, 15-11-2027, 15.11.27.
    final RegExpMatch? partiData = _data.firstMatch(minuscola);
    if (partiData != null) {
      final DateTime? numerica = _dataNumerica(partiData, oggi);
      if (numerica != null) {
        data = numerica;
        togliCollegamenti();
        continue;
      }
    }

    // Ore: 18:00, oppure "alle 18" / "ore 18".
    final RegExpMatch? partiOra = _ora.firstMatch(minuscola);
    if (partiOra != null) {
      final int ore = int.parse(partiOra.group(1)!);
      final int minuti = int.parse(partiOra.group(2)!);
      if (ore < 24 && minuti < 60) {
        ora = (ore: ore, minuti: minuti);
        togliCollegamenti();
        continue;
      }
    }
    if ((minuscola == 'alle' || minuscola == 'ore') &&
        seguente != null &&
        _numero.hasMatch(seguente) &&
        int.parse(seguente) < 24) {
      ora = (ore: int.parse(seguente), minuti: 0);
      togliCollegamenti();
      i += 1;
      continue;
    }

    titolo.add(parola);
  }

  DateTime? scadenza = data;
  if (ora != null) {
    DateTime base = data ?? oggi;
    DateTime conOra = DateTime(
      base.year,
      base.month,
      base.day,
      ora.ore,
      ora.minuti,
    );
    // Un'ora senza giorno già passata è quella di domani.
    if (data == null && conOra.isBefore(adesso)) {
      base = _piuGiorni(oggi, 1);
      conOra = DateTime(base.year, base.month, base.day, ora.ore, ora.minuti);
    }
    scadenza = conOra;
  }

  return RigaAnalizzata(
    titolo: conMaiuscola(titolo.join(' ')),
    argomento: argomento,
    tipologia: tipologia,
    scadenza: scadenza,
    conOra: ora != null,
    calendario: calendario,
    modello: modello,
  );
}

/// [giorno] più [quanti] giorni di calendario.
///
/// Si costruisce la data e non si aggiungono ore: con il cambio dell'ora
/// legale `add(Duration(days: 1))` può finire alle 23 del giorno prima.
DateTime _piuGiorni(DateTime giorno, int quanti) =>
    DateTime(giorno.year, giorno.month, giorno.day + quanti);

/// [oggi] più [quanti] unità di tempo, oppure `null` se [unita] non è
/// un'unità conosciuta.
DateTime? _dopo(DateTime oggi, int quanti, String unita) {
  if (unita.startsWith('giorn')) {
    return _piuGiorni(oggi, quanti);
  }
  if (unita.startsWith('settiman')) {
    return _piuGiorni(oggi, quanti * 7);
  }
  if (unita == 'mese' || unita == 'mesi') {
    final DateTime mese = DateTime(oggi.year, oggi.month + quanti);
    // Il 31 gennaio più un mese è l'ultimo di febbraio, non il 3 marzo.
    final int ultimo = DateTime(mese.year, mese.month + 1, 0).day;
    return DateTime(
      mese.year,
      mese.month,
      oggi.day > ultimo ? ultimo : oggi.day,
    );
  }
  return null;
}

/// La data scritta in numeri, oppure `null` se non è una data vera
/// (per esempio 31/02).
DateTime? _dataNumerica(RegExpMatch parti, DateTime oggi) {
  final int g = int.parse(parti.group(1)!);
  final int m = int.parse(parti.group(2)!);
  final String? testoAnno = parti.group(3);
  if (testoAnno != null && testoAnno.length == 3) {
    return null;
  }
  int anno = testoAnno == null
      ? oggi.year
      : (testoAnno.length == 2
            ? 2000 + int.parse(testoAnno)
            : int.parse(testoAnno));

  DateTime? costruisci(int a) {
    final DateTime d = DateTime(a, m, g);
    // DateTime corregge da solo le date impossibili (31/02 → 3/03): se il
    // risultato non è quello scritto, la data non esiste.
    return d.year == a && d.month == m && d.day == g ? d : null;
  }

  DateTime? data = costruisci(anno);
  if (data != null && testoAnno == null && data.isBefore(oggi)) {
    anno += 1;
    data = costruisci(anno);
  }
  return data;
}
