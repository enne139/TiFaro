import 'package:flutter/material.dart';

/// Un colore che si può dare a un argomento.
class ColoreArgomento {
  const ColoreArgomento(this.nome, this.idGoogle, this.colore);

  /// Il nome che usa Google Calendar in italiano.
  final String nome;

  /// Il `colorId` dell'evento in Google Calendar: servirà nella fase 4 per
  /// colorare gli eventi come l'argomento (DECISIONI.md, voce 008).
  final int idGoogle;

  /// Il colore come lo mostra Google Calendar.
  final Color colore;
}

/// I colori degli argomenti: sono gli undici colori degli eventi di Google
/// Calendar, così un'attività ha lo stesso colore nell'app e nel calendario.
///
/// Nel database si salva la posizione in questo elenco: non va riordinato,
/// solo allungato in fondo.
const List<ColoreArgomento> paletteArgomenti = <ColoreArgomento>[
  ColoreArgomento('Mirtillo', 9, Color(0xFF3F51B5)),
  ColoreArgomento('Basilico', 10, Color(0xFF0B8043)),
  ColoreArgomento('Mandarino', 6, Color(0xFFF4511E)),
  ColoreArgomento('Pomodoro', 11, Color(0xFFD50000)),
  ColoreArgomento('Pavone', 7, Color(0xFF039BE5)),
  ColoreArgomento('Salvia', 2, Color(0xFF33B679)),
  ColoreArgomento('Banana', 5, Color(0xFFF6BF26)),
  ColoreArgomento('Fenicottero', 4, Color(0xFFE67C73)),
  ColoreArgomento('Lavanda', 1, Color(0xFF7986CB)),
  ColoreArgomento('Uva', 3, Color(0xFF8E24AA)),
  ColoreArgomento('Grafite', 8, Color(0xFF616161)),
];

/// Il colore salvato con l'indice [indice]; un indice fuori elenco (per
/// esempio da una versione futura) ripiega sul primo.
ColoreArgomento coloreArgomento(int indice) {
  if (indice < 0 || indice >= paletteArgomenti.length) {
    return paletteArgomenti.first;
  }
  return paletteArgomenti[indice];
}

/// Le icone fra cui scegliere per argomenti e tipologie.
///
/// Nel database si salva la chiave: le icone devono essere costanti perché
/// Flutter, compilando, tiene nel carattere solo le icone usate davvero.
const Map<String, IconData> iconeDisponibili = <String, IconData>{
  'etichetta': Icons.label_outline,
  'lavoro': Icons.work_outline,
  'personale': Icons.person_outline,
  'ambulanza': Icons.emergency_outlined,
  'casa': Icons.home_outlined,
  'soldi': Icons.euro,
  'salute': Icons.favorite_outline,
  'studio': Icons.school_outlined,
  'auto': Icons.directions_car_outlined,
  'computer': Icons.computer,
  'telefono': Icons.phone_outlined,
  'acquisto': Icons.shopping_cart_outlined,
  'documento': Icons.description_outlined,
  'attrezzi': Icons.build_outlined,
  'evento': Icons.event_outlined,
  'viaggio': Icons.flight_outlined,
  'persone': Icons.groups_outlined,
  'posta': Icons.mail_outline,
};

/// L'icona salvata con la chiave [chiave].
IconData icona(String chiave) =>
    iconeDisponibili[chiave] ?? Icons.label_outline;
