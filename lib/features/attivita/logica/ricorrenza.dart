/// Le attività che si ripetono: ogni quanto, e quando scade la prossima
/// (DECISIONI.md, voce 032).
library;

import 'package:tifaro/core/date.dart';

/// L'unità di tempo di una ricorrenza.
enum UnitaRicorrenza {
  giorno('giorno', 'giorni'),
  settimana('settimana', 'settimane'),
  mese('mese', 'mesi'),
  anno('anno', 'anni');

  const UnitaRicorrenza(this.singolare, this.plurale);

  /// Il nome per una volta sola: "ogni *mese*".
  final String singolare;

  /// Il nome per più volte: "ogni 3 *mesi*".
  final String plurale;
}

/// Ogni quanto si ripete un'attività: "ogni 2 settimane".
///
/// Nel database sta come testo, `settimana:2` ([codice]): una colonna sola,
/// leggibile, e facile da allungare con regole nuove.
class Ricorrenza {
  const Ricorrenza(this.unita, [this.ogni = 1]) : assert(ogni >= 1);

  /// La ricorrenza scritta come [codice]; `null` se il testo è vuoto o non
  /// è una ricorrenza conosciuta (per esempio scritta da una versione più
  /// nuova dell'app).
  static Ricorrenza? daCodice(String? codice) {
    if (codice == null) {
      return null;
    }
    final List<String> parti = codice.split(':');
    if (parti.length != 2) {
      return null;
    }
    final int? ogni = int.tryParse(parti[1]);
    if (ogni == null || ogni < 1) {
      return null;
    }
    for (final UnitaRicorrenza u in UnitaRicorrenza.values) {
      if (u.name == parti[0]) {
        return Ricorrenza(u, ogni);
      }
    }
    return null;
  }

  /// L'unità di tempo.
  final UnitaRicorrenza unita;

  /// Quante unità fra una volta e la successiva, da 1 in su.
  final int ogni;

  /// Come si salva nel database: `mese:1`.
  String get codice => '${unita.name}:$ogni';

  /// Come si legge: "ogni mese", "ogni 2 settimane".
  String get descrizione =>
      ogni == 1 ? 'ogni ${unita.singolare}' : 'ogni $ogni ${unita.plurale}';

  /// [data] spostata avanti di [volte] ricorrenze, con la stessa ora.
  ///
  /// Si conta sul calendario e non in ore, così il cambio dell'ora legale
  /// non sposta niente. Un giorno del mese che nel mese d'arrivo non c'è
  /// diventa l'ultimo: il 31 gennaio più un mese è il 28 febbraio.
  DateTime avanti(DateTime data, int volte) {
    final int passi = ogni * volte;
    switch (unita) {
      case UnitaRicorrenza.giorno:
      case UnitaRicorrenza.settimana:
        final int giorni = unita == UnitaRicorrenza.giorno ? passi : passi * 7;
        return DateTime(
          data.year,
          data.month,
          data.day + giorni,
          data.hour,
          data.minute,
        );
      case UnitaRicorrenza.mese:
      case UnitaRicorrenza.anno:
        final int mesi = unita == UnitaRicorrenza.mese ? passi : passi * 12;
        final DateTime mese = DateTime(data.year, data.month + mesi);
        final int ultimo = DateTime(mese.year, mese.month + 1, 0).day;
        return DateTime(
          mese.year,
          mese.month,
          data.day > ultimo ? ultimo : data.day,
          data.hour,
          data.minute,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Ricorrenza && other.unita == unita && other.ogni == ogni;

  @override
  int get hashCode => Object.hash(unita, ogni);

  @override
  String toString() => codice;
}

/// La scadenza della prossima volta, per un'attività che si ripete con
/// [ricorrenza] e che è stata fatta il giorno [fattaIl].
///
/// Si parte dalla [scadenza] che aveva, così il ritmo resta quello (il
/// lunedì resta il lunedì anche se la si fa di martedì), e si va avanti
/// finché si arriva dopo il giorno in cui è stata fatta: una cosa fatta in
/// ritardo non lascia dietro di sé altre volte già scadute. Senza scadenza
/// si conta dal giorno in cui è stata fatta. L'ora, se c'era, resta.
DateTime prossimaScadenza(
  Ricorrenza ricorrenza, {
  required DateTime? scadenza,
  required DateTime fattaIl,
}) {
  final DateTime fatta = giorno(fattaIl);
  final DateTime base = scadenza ?? fatta;
  int volte = 1;
  DateTime prossima = ricorrenza.avanti(base, volte);
  // Si riparte ogni volta dalla base e non dall'ultima trovata: con i mesi,
  // il 31 che diventa 28 a febbraio torna 31 a marzo.
  while (!giorno(prossima).isAfter(fatta)) {
    volte += 1;
    prossima = ricorrenza.avanti(base, volte);
  }
  return prossima;
}
