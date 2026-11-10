/// Quali eventi devono stare nel calendario, e cosa fare per arrivarci:
/// creare, aggiornare, togliere (DECISIONI.md, voce 027).
library;

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
// Con un prefisso, perché dentro EventoVoluto `impronta` è anche un campo.
import 'package:tifaro/features/sincronizzazione/logica/impronta.dart'
    as logica;

/// Il segno che sta su ogni evento di TiFaro, seguito dall'id dell'attività.
const String prefissoSegno = 'tifaro://attivita/';

/// Un evento come deve essere nel calendario.
class EventoVoluto {
  const EventoVoluto({
    required this.attivitaId,
    required this.titolo,
    required this.descrizione,
    required this.inizio,
    required this.fine,
    required this.tuttoIlGiorno,
    this.chiaveColore,
    this.colore,
  });

  final String attivitaId;
  final String titolo;
  final String descrizione;

  /// Inizio e fine in millisecondi. Per gli eventi di tutto il giorno sono
  /// mezzanotti UTC, come vuole Android.
  final int inizio;
  final int fine;
  final bool tuttoIlGiorno;

  /// La chiave del colore di Google Calendar dell'argomento.
  final String? chiaveColore;

  /// Il colore dell'argomento, per i calendari che non conoscono le chiavi.
  final int? colore;

  /// Il segno da mettere sull'evento per ritrovarlo.
  String get segno => '$prefissoSegno$attivitaId';

  /// L'impronta di quello che si vede dell'evento: se cambia, va aggiornato.
  String get impronta => logica.impronta(<String, dynamic>{
    'titolo': titolo,
    'descrizione': descrizione,
    'inizio': inizio,
    'fine': fine,
    'tuttoIlGiorno': tuttoIlGiorno,
    'chiaveColore': chiaveColore,
    'colore': colore,
  });
}

/// Gli eventi che devono stare nel calendario: uno per ogni attività da
/// fare, segnata "nel calendario" e con una scadenza.
///
/// Senza ora l'evento dura tutto il giorno della scadenza; con l'ora dura
/// un'ora. Il titolo è quello dell'attività; per una sotto-attività la
/// descrizione comincia dicendo di cosa fa parte.
List<EventoVoluto> eventiVoluti(
  IndiceAttivita indice,
  Map<String, Argomento> argomenti,
) {
  final List<EventoVoluto> eventi = <EventoVoluto>[];
  for (final Attivita a in indice.tutte) {
    final DateTime? scadenza = a.scadenza;
    if (!a.nelCalendario || scadenza == null || a.fattaIl != null) {
      continue;
    }
    final int inizio;
    final int fine;
    if (a.scadenzaConOra) {
      inizio = scadenza.millisecondsSinceEpoch;
      fine = scadenza.add(const Duration(hours: 1)).millisecondsSinceEpoch;
    } else {
      inizio = DateTime.utc(
        scadenza.year,
        scadenza.month,
        scadenza.day,
      ).millisecondsSinceEpoch;
      fine = DateTime.utc(
        scadenza.year,
        scadenza.month,
        scadenza.day + 1,
      ).millisecondsSinceEpoch;
    }

    final List<Attivita> percorso = indice.percorso(a);
    final String descrizione = <String>[
      if (percorso.isNotEmpty)
        'Parte di: ${percorso.map((Attivita p) => p.titolo).join(' › ')}',
      if (a.descrizione.isNotEmpty) a.descrizione,
    ].join('\n\n');

    final Argomento? argomento = argomenti[a.argomentoId];
    final ColoreArgomento? colore = argomento == null
        ? null
        : coloreArgomento(argomento.colore);

    eventi.add(
      EventoVoluto(
        attivitaId: a.id,
        titolo: a.titolo,
        descrizione: descrizione,
        inizio: inizio,
        fine: fine,
        tuttoIlGiorno: !a.scadenzaConOra,
        chiaveColore: colore == null ? null : '${colore.idGoogle}',
        colore: colore?.colore.toARGB32(),
      ),
    );
  }
  return eventi;
}

/// Un evento già nel calendario, come lo ricorda questo telefono.
class EventoEsistente {
  const EventoEsistente({
    required this.eventoId,
    required this.calendarioId,
    required this.impronta,
  });

  final int eventoId;
  final int calendarioId;

  /// L'impronta dell'ultima versione scritta; vuota se non si sa (evento
  /// ritrovato dopo una reinstallazione), e allora si riscrive.
  final String impronta;
}

/// Cosa fare per portare il calendario dov'è a dove deve essere.
class PianoCalendario {
  const PianoCalendario({
    required this.daCreare,
    required this.daAggiornare,
    required this.daTogliere,
  });

  final List<EventoVoluto> daCreare;

  /// Gli eventi da riscrivere, con l'id di quello che c'è.
  final List<({EventoVoluto evento, int eventoId})> daAggiornare;

  /// Gli eventi da togliere: attività fatte, cestinate, tolte dal
  /// calendario, o eventi rimasti in un calendario che non è più quello
  /// scelto.
  final List<({String attivitaId, int eventoId})> daTogliere;

  bool get vuoto =>
      daCreare.isEmpty && daAggiornare.isEmpty && daTogliere.isEmpty;
}

/// Confronta gli eventi [voluti] con quelli [esistenti] nel calendario
/// [calendarioId].
PianoCalendario pianifica({
  required List<EventoVoluto> voluti,
  required Map<String, EventoEsistente> esistenti,
  required int calendarioId,
}) {
  final List<EventoVoluto> daCreare = <EventoVoluto>[];
  final List<({EventoVoluto evento, int eventoId})> daAggiornare =
      <({EventoVoluto evento, int eventoId})>[];
  final List<({String attivitaId, int eventoId})> daTogliere =
      <({String attivitaId, int eventoId})>[];
  final Set<String> volutiIds = <String>{};

  for (final EventoVoluto v in voluti) {
    volutiIds.add(v.attivitaId);
    final EventoEsistente? e = esistenti[v.attivitaId];
    if (e == null || e.calendarioId != calendarioId) {
      // Un evento in un altro calendario si toglie (sotto) e si rifà qui.
      daCreare.add(v);
    } else if (e.impronta != v.impronta) {
      daAggiornare.add((evento: v, eventoId: e.eventoId));
    }
  }
  for (final MapEntry<String, EventoEsistente> e in esistenti.entries) {
    if (!volutiIds.contains(e.key) || e.value.calendarioId != calendarioId) {
      daTogliere.add((attivitaId: e.key, eventoId: e.value.eventoId));
    }
  }
  return PianoCalendario(
    daCreare: daCreare,
    daAggiornare: daAggiornare,
    daTogliere: daTogliere,
  );
}
