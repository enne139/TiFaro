/// L'impronta di una riga: un riassunto breve del suo contenuto, per capire
/// se è cambiata senza tenerne una copia (DECISIONI.md, voce 021).
library;

import 'dart:collection';
import 'dart:convert';

/// L'impronta di [dati]: FNV-1a a 64 bit del JSON con le chiavi in ordine,
/// in esadecimale.
///
/// Le chiavi si ordinano perché il server potrebbe restituirle in un altro
/// ordine: lo stesso contenuto deve dare sempre la stessa impronta.
/// FNV-1a non è crittografico, e non serve che lo sia: deve solo cambiare
/// quando cambia il contenuto.
String impronta(Map<String, dynamic> dati) {
  // 64 bit con segno: i numeri oltre il massimo si avvolgono, ed è proprio
  // il conto che FNV vuole.
  int valore = 0xcbf29ce484222325;
  const int primo = 0x100000001b3;
  for (final int byte in utf8.encode(jsonEncode(_ordinato(dati)))) {
    valore ^= byte;
    valore *= primo;
  }
  return valore.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

/// [valore] con le chiavi di ogni mappa in ordine alfabetico.
Object? _ordinato(Object? valore) {
  if (valore is Map) {
    return SplayTreeMap<String, Object?>.fromIterables(
      valore.keys.map((Object? k) => k.toString()),
      valore.values.map(_ordinato),
    );
  }
  if (valore is List) {
    return valore.map(_ordinato).toList();
  }
  return valore;
}
