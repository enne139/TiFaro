/// Aiuti per confrontare e presentare i nomi di argomenti e tipologie.
library;

/// Lettere accentate e la loro versione senza accento.
const Map<String, String> _senzaAccento = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
};

/// La forma con cui si confrontano due nomi: minuscola, senza accenti, senza
/// spazi né segni.
///
/// Così `#tempo-libero`, `#TempoLibero` e "Tempo Libero" sono la stessa cosa, e
/// nella cattura veloce non serve ricordare come si è scritto il nome
/// (DECISIONI.md, voce 010).
String chiaveNome(String nome) {
  final StringBuffer risultato = StringBuffer();
  for (final String lettera in nome.toLowerCase().split('')) {
    final String base = _senzaAccento[lettera] ?? lettera;
    if (RegExp(r'[a-z0-9]').hasMatch(base)) {
      risultato.write(base);
    }
  }
  return risultato.toString();
}

/// Il nome da dare a un argomento o a una tipologia nati da un'etichetta
/// della cattura veloce: `tempo-libero` diventa "Tempo libero".
String nomeDaEtichetta(String etichetta) {
  final String conSpazi = etichetta.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  return conMaiuscola(conSpazi);
}

/// L'etichetta con cui si scrive un nome nella cattura veloce: "Turno in
/// ambulanza" diventa `turno-in-ambulanza`.
String etichettaDi(String nome) {
  final StringBuffer risultato = StringBuffer();
  for (final String lettera in nome.toLowerCase().split('')) {
    final String base = _senzaAccento[lettera] ?? lettera;
    risultato.write(RegExp(r'[a-z0-9]').hasMatch(base) ? base : '-');
  }
  return risultato
      .toString()
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

/// Il testo con la prima lettera maiuscola.
String conMaiuscola(String testo) {
  if (testo.isEmpty) {
    return testo;
  }
  return testo[0].toUpperCase() + testo.substring(1);
}

/// L'elemento di [elementi] a cui si riferisce un'etichetta della cattura
/// veloce (`#amb`, `@acquisti`), oppure `null` se non ce n'è uno.
///
/// Si prova in quest'ordine (DECISIONI.md, voce 010):
/// 1. stesso nome, a meno di maiuscole, accenti e segni;
/// 2. stesso nome a meno dell'ultima vocale, così `@acquisti` trova
///    "Acquisto" e `@telefonate` trova "Telefonata";
/// 3. un nome che comincia con l'etichetta, se è uno solo e l'etichetta ha
///    almeno tre lettere: `#amb` trova "Ambulanza".
T? trovaPerEtichetta<T>(
  String etichetta,
  Iterable<T> elementi,
  String Function(T elemento) nome,
) {
  final String chiave = chiaveNome(etichetta);
  if (chiave.isEmpty) {
    return null;
  }
  for (final T elemento in elementi) {
    if (chiaveNome(nome(elemento)) == chiave) {
      return elemento;
    }
  }
  final String radice = _senzaVocaleFinale(chiave);
  for (final T elemento in elementi) {
    if (_senzaVocaleFinale(chiaveNome(nome(elemento))) == radice) {
      return elemento;
    }
  }
  if (chiave.length >= 3) {
    final List<T> candidati = elementi
        .where((T e) => chiaveNome(nome(e)).startsWith(chiave))
        .toList();
    if (candidati.length == 1) {
      return candidati.single;
    }
  }
  return null;
}

/// La chiave senza l'ultima vocale, per confrontare singolare e plurale.
///
/// Solo oltre le tre lettere: su parole corte toglierebbe troppo.
String _senzaVocaleFinale(String chiave) {
  if (chiave.length > 3 && 'aeiou'.contains(chiave[chiave.length - 1])) {
    return chiave.substring(0, chiave.length - 1);
  }
  return chiave;
}
