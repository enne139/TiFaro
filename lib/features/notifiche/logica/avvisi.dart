/// Quali avvisi delle scadenze devono essere programmati (DECISIONI.md,
/// voce 033).
library;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';

/// L'ora predefinita del riepilogo delle attività senza ora: le 9, in
/// minuti dalla mezzanotte.
const int oraRiepilogoPredefinita = 9 * 60;

/// Un avviso come deve essere programmato.
class AvvisoVoluto {
  const AvvisoVoluto({
    required this.id,
    required this.quando,
    required this.titolo,
    required this.testo,
    this.attivitaId,
  });

  /// Il numero dell'avviso per il sistema: lo stesso per la stessa
  /// attività (o lo stesso giorno), così si aggiorna invece di duplicarsi.
  final int id;

  /// Quando deve comparire.
  final DateTime quando;

  final String titolo;
  final String testo;

  /// L'attività da aprire toccandolo; nulla per un riepilogo di più
  /// attività, che apre l'app su Oggi.
  final String? attivitaId;

  /// Quello che l'avviso si porta dietro: l'istante e l'attività. L'istante
  /// serve a capire, rileggendo gli avvisi programmati, se l'ora è cambiata
  /// (il sistema non la restituisce).
  String get carico => '${quando.millisecondsSinceEpoch}|${attivitaId ?? ''}';

  /// Tutto quello che, se cambia, obbliga a riprogrammare l'avviso.
  String get firma => '$titolo\n$testo\n$carico';
}

/// L'attività da aprire scritta nel [carico] di un avviso; `null` se è un
/// riepilogo o se il carico non è di TiFaro.
String? attivitaDelCarico(String? carico) {
  if (carico == null) {
    return null;
  }
  final int barra = carico.indexOf('|');
  if (barra < 0) {
    return null;
  }
  final String id = carico.substring(barra + 1);
  return id.isEmpty ? null : id;
}

/// Il numero dell'avviso di un'attività: un'impronta FNV-1a a 32 bit del suo
/// id, fra 2^30 e 2^31 - 1, lontano dai numeri dei riepiloghi.
int idAvvisoAttivita(String attivitaId) {
  int valore = 0x811c9dc5;
  for (final int unita in attivitaId.codeUnits) {
    valore ^= unita;
    valore = (valore * 0x01000193) & 0xFFFFFFFF;
  }
  return 0x40000000 | (valore & 0x3FFFFFFF);
}

/// Il numero del riepilogo del giorno [data]: AAAAMMGG, sotto 2^30.
int idAvvisoGiorno(DateTime data) =>
    data.year * 10000 + data.month * 100 + data.day;

/// Gli avvisi da programmare, dal più vicino, al massimo [massimo] e solo
/// nei prossimi [giorni] giorni: il sistema ne tiene un numero limitato, e
/// a ogni apertura dell'app si riprogrammano.
///
/// - Un'attività da fare con scadenza e ora: un avviso a quell'ora.
/// - Le attività da fare con scadenza ma senza ora: un riepilogo per giorno,
///   all'ora [oraRiepilogo] (minuti dalla mezzanotte), con i loro titoli.
///
/// Solo quelli ancora da venire: una scadenza già passata non suona.
List<AvvisoVoluto> avvisiVoluti(
  IndiceAttivita indice, {
  required DateTime adesso,
  int oraRiepilogo = oraRiepilogoPredefinita,
  int giorni = 30,
  int massimo = 60,
}) {
  final DateTime limite = DateTime(
    adesso.year,
    adesso.month,
    adesso.day + giorni,
  );
  final List<AvvisoVoluto> avvisi = <AvvisoVoluto>[];
  final Map<DateTime, List<Attivita>> senzaOra = <DateTime, List<Attivita>>{};

  for (final Attivita a in indice.tutte) {
    final DateTime? scadenza = a.scadenza;
    if (scadenza == null || a.fattaIl != null) {
      continue;
    }
    if (!a.scadenzaConOra) {
      senzaOra.putIfAbsent(giorno(scadenza), () => <Attivita>[]).add(a);
      continue;
    }
    if (!scadenza.isAfter(adesso) || scadenza.isAfter(limite)) {
      continue;
    }
    final List<Attivita> percorso = indice.percorso(a);
    avvisi.add(
      AvvisoVoluto(
        id: idAvvisoAttivita(a.id),
        quando: scadenza,
        titolo: a.titolo,
        testo: percorso.isEmpty
            ? 'Scade alle ${formatoOra(scadenza)}'
            : 'Scade alle ${formatoOra(scadenza)} · parte di '
                  '${percorso.map((Attivita p) => p.titolo).join(' › ')}',
        attivitaId: a.id,
      ),
    );
  }

  for (final MapEntry<DateTime, List<Attivita>> g in senzaOra.entries) {
    final DateTime quando = DateTime(
      g.key.year,
      g.key.month,
      g.key.day,
      oraRiepilogo ~/ 60,
      oraRiepilogo % 60,
    );
    if (!quando.isAfter(adesso) || quando.isAfter(limite)) {
      continue;
    }
    // Dalla più vecchia, come in Oggi.
    final List<Attivita> elenco = g.value..sort(IndiceAttivita.perCreazione);
    avvisi.add(
      elenco.length == 1
          ? AvvisoVoluto(
              id: idAvvisoGiorno(g.key),
              quando: quando,
              titolo: elenco.single.titolo,
              testo: 'Scade oggi',
              attivitaId: elenco.single.id,
            )
          : AvvisoVoluto(
              id: idAvvisoGiorno(g.key),
              quando: quando,
              titolo: 'Oggi scadono ${elenco.length} attività',
              testo: _elenco(elenco.map((Attivita a) => a.titolo).toList()),
            ),
    );
  }

  avvisi.sort((AvvisoVoluto a, AvvisoVoluto b) => a.quando.compareTo(b.quando));
  return avvisi.length > massimo ? avvisi.sublist(0, massimo) : avvisi;
}

/// I titoli separati da virgole, al massimo cinque.
String _elenco(List<String> titoli) {
  if (titoli.length <= 5) {
    return titoli.join(', ');
  }
  return '${titoli.take(5).join(', ')} e altre ${titoli.length - 5}';
}
