/// Date in italiano, senza dipendere da `intl`.
library;

/// Abbreviazioni dei giorni, da lunedì (`DateTime.monday` = 1).
const List<String> giorniBrevi = <String>[
  'lun',
  'mar',
  'mer',
  'gio',
  'ven',
  'sab',
  'dom',
];

/// Abbreviazioni dei mesi, da gennaio.
const List<String> mesiBrevi = <String>[
  'gen',
  'feb',
  'mar',
  'apr',
  'mag',
  'giu',
  'lug',
  'ago',
  'set',
  'ott',
  'nov',
  'dic',
];

/// Il giorno di [data], a mezzanotte.
DateTime giorno(DateTime data) => DateTime(data.year, data.month, data.day);

/// Quanti giorni separano il giorno di [da] da quello di [a].
///
/// Si conta sui giorni del calendario e non sulle ore: dalle 23 di stasera
/// alle 8 di domani c'è un giorno.
int giorniFra(DateTime da, DateTime a) {
  // Con DateTime.utc il cambio dell'ora legale non sposta il conto.
  final DateTime inizio = DateTime.utc(da.year, da.month, da.day);
  final DateTime fine = DateTime.utc(a.year, a.month, a.day);
  return fine.difference(inizio).inDays;
}

/// L'ora come "08:05".
String formatoOra(DateTime data) {
  final String ore = data.hour.toString().padLeft(2, '0');
  final String minuti = data.minute.toString().padLeft(2, '0');
  return '$ore:$minuti';
}

/// Una data come "lun 17 nov", con l'anno solo se diverso da quello di
/// [adesso].
String formatoGiorno(DateTime data, DateTime adesso) {
  final String base =
      '${giorniBrevi[data.weekday - 1]} ${data.day} ${mesiBrevi[data.month - 1]}';
  return data.year == adesso.year ? base : '$base ${data.year}';
}

/// Una scadenza come si legge in un elenco: "oggi", "domani 18:00",
/// "ieri", "ven 14 nov".
String formatoScadenza(DateTime scadenza, bool conOra, DateTime adesso) {
  final int distanza = giorniFra(adesso, scadenza);
  final String quando = switch (distanza) {
    0 => 'oggi',
    1 => 'domani',
    -1 => 'ieri',
    _ => formatoGiorno(scadenza, adesso),
  };
  return conOra ? '$quando ${formatoOra(scadenza)}' : quando;
}

/// Data e ora complete, per i dettagli: "10 nov 2026, 14:32".
String formatoDataOra(DateTime data) {
  return '${data.day} ${mesiBrevi[data.month - 1]} ${data.year}, '
      '${formatoOra(data)}';
}
