/// Le scadenze dei modelli, scritte come "tanti giorni rispetto a un giorno
/// di riferimento" e trasformate in date vere al momento di usarli
/// (DECISIONI.md, voce 017).
library;

import 'package:tifaro/core/date.dart';

/// La scadenza [giorni] dopo il giorno di [riferimento] (prima, se
/// negativi), all'ora [minuti] dalla mezzanotte se c'è.
///
/// Senza [giorni] non c'è scadenza, anche se ci sono i minuti.
({DateTime? scadenza, bool conOra}) scadenzaRelativa(
  DateTime riferimento,
  int? giorni,
  int? minuti,
) {
  if (giorni == null) {
    return (scadenza: null, conOra: false);
  }
  // Si costruisce la data e non si aggiungono ore: con il cambio dell'ora
  // legale un giorno non dura sempre 24 ore.
  final DateTime giornoScadenza = DateTime(
    riferimento.year,
    riferimento.month,
    riferimento.day + giorni,
  );
  if (minuti == null) {
    return (scadenza: giornoScadenza, conOra: false);
  }
  return (
    scadenza: DateTime(
      giornoScadenza.year,
      giornoScadenza.month,
      giornoScadenza.day,
      minuti ~/ 60,
      minuti % 60,
    ),
    conOra: true,
  );
}

/// Il contrario di [scadenzaRelativa]: giorni e minuti di [scadenza]
/// rispetto al giorno di [riferimento].
({int? giorni, int? minuti}) relativaDi(
  DateTime? scadenza,
  bool conOra,
  DateTime riferimento,
) {
  if (scadenza == null) {
    return (giorni: null, minuti: null);
  }
  return (
    giorni: giorniFra(riferimento, scadenza),
    minuti: conOra ? scadenza.hour * 60 + scadenza.minute : null,
  );
}

/// I minuti dalla mezzanotte come "18:30".
String formatoMinuti(int minuti) {
  final String ore = (minuti ~/ 60).toString().padLeft(2, '0');
  final String resto = (minuti % 60).toString().padLeft(2, '0');
  return '$ore:$resto';
}

String _giorni(int n) => n == 1 ? '1 giorno' : '$n giorni';

/// La scadenza dell'attività principale di un modello, a parole:
/// "3 giorni dopo la creazione, alle 18:00".
String descriviScadenzaPrincipale(int? giorni, int? minuti) {
  if (giorni == null) {
    return 'Nessuna scadenza';
  }
  final String quando = switch (giorni) {
    0 => 'Il giorno della creazione',
    1 => 'Il giorno dopo la creazione',
    _ when giorni > 0 => '${_giorni(giorni)} dopo la creazione',
    _ => '${_giorni(-giorni)} prima della creazione',
  };
  return minuti == null ? quando : '$quando, alle ${formatoMinuti(minuti)}';
}

/// La scadenza di una sotto-attività di un modello, a parole, rispetto
/// alla principale: "1 giorno prima", "stesso giorno, alle 9:00".
String descriviScadenzaVoce(int? giorni, int? minuti) {
  if (giorni == null) {
    return 'Nessuna scadenza';
  }
  final String quando = switch (giorni) {
    0 => 'Stesso giorno',
    _ when giorni > 0 => '${_giorni(giorni)} dopo',
    _ => '${_giorni(-giorni)} prima',
  };
  return minuti == null ? quando : '$quando, alle ${formatoMinuti(minuti)}';
}
