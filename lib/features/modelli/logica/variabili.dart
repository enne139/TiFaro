/// Le variabili dei modelli: segnaposto tra graffe, come `{luogo}`, scritti
/// nel nome, nella descrizione o nelle sotto-attività di un modello e
/// riempiti quando lo si usa (DECISIONI.md, voce 029).
library;

import 'package:tifaro/core/date.dart';

/// Una variabile: una graffa, da 1 a 40 caratteri che non siano graffe o a
/// capo, una graffa.
final RegExp _variabile = RegExp(r'\{([^{}\n]{1,40})\}');

/// Le variabili che si riempiono da sole: `{data}`, la scadenza
/// dell'attività creata (oppure oggi, se non ne ha), e `{oggi}`.
const Set<String> variabiliAutomatiche = <String>{'data', 'oggi'};

/// La chiave con cui si confrontano i nomi delle variabili: `{Luogo}` e
/// `{ luogo }` sono la stessa.
String chiaveVariabile(String nome) => nome.trim().toLowerCase();

/// Le variabili da chiedere che compaiono in [testi], nell'ordine in cui
/// si incontrano e una volta sola, scritte come la prima volta. Quelle
/// automatiche non ci sono.
List<String> variabiliIn(Iterable<String> testi) {
  final List<String> trovate = <String>[];
  final Set<String> viste = <String>{};
  for (final String testo in testi) {
    for (final RegExpMatch m in _variabile.allMatches(testo)) {
      final String nome = m.group(1)!.trim();
      final String chiave = chiaveVariabile(nome);
      if (nome.isEmpty || variabiliAutomatiche.contains(chiave)) {
        continue;
      }
      if (viste.add(chiave)) {
        trovate.add(nome);
      }
    }
  }
  return trovate;
}

/// I valori delle variabili automatiche: la data della [scadenza]
/// dell'attività creata (o di oggi, se non ne ha) e quella di oggi, come
/// "lun 17 nov".
Map<String, String> valoriAutomatici({
  required DateTime? scadenza,
  required DateTime adesso,
}) {
  return <String, String>{
    'data': formatoGiorno(scadenza ?? adesso, adesso),
    'oggi': formatoGiorno(adesso, adesso),
  };
}

/// [testo] con le variabili sostituite dai [valori] (per chiave, vedi
/// [chiaveVariabile]).
///
/// Una variabile senza valore, o con un valore vuoto, resta com'è scritta:
/// così si vede che manca e si può sistemare dopo, invece di sparire
/// lasciando una frase a metà.
String sostituisciVariabili(String testo, Map<String, String> valori) {
  return testo.replaceAllMapped(_variabile, (Match m) {
    final String? valore = valori[chiaveVariabile(m.group(1)!)];
    return valore == null || valore.trim().isEmpty
        ? m.group(0)!
        : valore.trim();
  });
}
