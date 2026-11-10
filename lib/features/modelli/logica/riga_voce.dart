import 'package:tifaro/features/cattura/sintassi.dart';

/// Quello che si è capito da una riga scritta nell'editor di un modello per
/// aggiungere una voce.
class RigaVoce {
  const RigaVoce({
    required this.titolo,
    this.tipologia,
    this.giorni,
    this.minuti,
    this.calendario = false,
  });

  final String titolo;

  /// L'etichetta dopo `@`.
  final String? tipologia;

  /// I giorni rispetto alla principale, da `+2` o `-1`.
  final int? giorni;

  /// L'ora in minuti dalla mezzanotte, da `18:00` o `alle 18`.
  final int? minuti;

  /// Se c'era `!cal`.
  final bool calendario;
}

final RegExp _spostamento = RegExp(r'^([+-])(\d{1,3})$');

/// Analizza una riga dell'editor dei modelli.
///
/// È la sintassi della cattura veloce, con una differenza: le scadenze non
/// sono date ma spostamenti rispetto alla principale, `+2` (due giorni dopo)
/// o `-1` (un giorno prima). `+N` vale solo qui: nella cattura veloce un
/// numero di telefono come `+39` diventerebbe una data (DECISIONI.md,
/// voce 017). Un'ora senza spostamento vale per lo stesso giorno.
RigaVoce analizzaRigaVoce(String riga) {
  int? giorni;
  final List<String> resto = <String>[];
  for (final String parola in riga.trim().split(RegExp(r'\s+'))) {
    final RegExpMatch? parti = _spostamento.firstMatch(parola);
    if (parti != null) {
      final int n = int.parse(parti.group(2)!);
      giorni = parti.group(1) == '-' ? -n : n;
    } else {
      resto.add(parola);
    }
  }
  // Il giorno di riferimento non conta: dell'analisi si usano solo titolo,
  // tipologia, calendario e l'ora. Mezzanotte, così nessuna ora è "già
  // passata" e spostata a domani.
  final RigaAnalizzata analizzata = analizzaRiga(
    resto.join(' '),
    DateTime(2000),
  );
  final DateTime? scadenza = analizzata.scadenza;
  final int? minuti = analizzata.conOra && scadenza != null
      ? scadenza.hour * 60 + scadenza.minute
      : null;
  return RigaVoce(
    titolo: analizzata.titolo,
    tipologia: analizzata.tipologia,
    // Un'ora da sola vuol dire "lo stesso giorno della principale".
    giorni: giorni ?? (minuti != null ? 0 : null),
    minuti: minuti,
    calendario: analizzata.calendario,
  );
}
