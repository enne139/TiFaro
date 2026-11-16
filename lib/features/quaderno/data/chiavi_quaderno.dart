/// Le chiavi delle preferenze del Quaderno, che restano su ogni dispositivo
/// e non si sincronizzano (DECISIONI.md, voce 038).
abstract final class ChiaviQuaderno {
  /// `no` se il Quaderno è spento; assente se è acceso, come all'inizio.
  static const String attivo = 'quaderno.attivo';
}
