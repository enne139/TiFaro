import 'package:tifaro/core/database/app_database.dart';

/// Le voci di tutti i modelli, organizzate ad albero per modello.
class AlberoVoci {
  AlberoVoci(Iterable<VoceModello> voci) {
    final Set<String> ids = <String>{for (final VoceModello v in voci) v.id};
    for (final VoceModello v in voci) {
      // Una voce con un genitore che non c'è più sale al primo livello.
      final String? genitore = v.genitoreId;
      final String? chiave = genitore != null && ids.contains(genitore)
          ? genitore
          : null;
      _figlie
          .putIfAbsent(v.modelloId, () => <String?, List<VoceModello>>{})
          .putIfAbsent(chiave, () => <VoceModello>[])
          .add(v);
    }
    for (final Map<String?, List<VoceModello>> modello in _figlie.values) {
      for (final List<VoceModello> sorelle in modello.values) {
        sorelle.sort((VoceModello a, VoceModello b) {
          final int c = a.ordine.compareTo(b.ordine);
          return c != 0 ? c : a.aggiornataIl.compareTo(b.aggiornataIl);
        });
      }
    }
  }

  final Map<String, Map<String?, List<VoceModello>>> _figlie =
      <String, Map<String?, List<VoceModello>>>{};

  /// Le voci figlie di [genitoreId] nel modello [modelloId]; con `null` le
  /// figlie dirette dell'attività principale.
  List<VoceModello> figlie(String modelloId, String? genitoreId) =>
      _figlie[modelloId]?[genitoreId] ?? const <VoceModello>[];

  /// Tutte le voci del modello, in ordine di albero (ogni voce seguita dalle
  /// sue sotto-voci), con il loro livello a partire da 0.
  List<({VoceModello voce, int livello})> inOrdine(String modelloId) {
    final List<({VoceModello voce, int livello})> righe =
        <({VoceModello voce, int livello})>[];
    final Set<String> visti = <String>{};
    void visita(String? genitore, int livello) {
      for (final VoceModello v in figlie(modelloId, genitore)) {
        // `visti` protegge da un ciclo nei dati.
        if (visti.add(v.id)) {
          righe.add((voce: v, livello: livello));
          visita(v.id, livello + 1);
        }
      }
    }

    visita(null, 0);
    return righe;
  }

  /// Quante voci ha il modello, a qualunque livello.
  int quante(String modelloId) => inOrdine(modelloId).length;
}
