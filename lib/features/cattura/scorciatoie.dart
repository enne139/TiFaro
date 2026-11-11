import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

/// Le scorciatoie dell'icona di TiFaro su Android: tenendola premuta
/// compaiono «Nuova attività» e «Foto», che aprono la cattura veloce
/// (DECISIONI.md, voce 034).
class ScorciatoieIcona {
  /// La scorciatoia che apre la cattura veloce.
  static const String nuova = 'nuova';

  /// La scorciatoia che apre la cattura veloce con la fotocamera.
  static const String foto = 'foto';

  final QuickActions _azioni = const QuickActions();

  /// Registra le scorciatoie; [usata] riceve quella toccata, anche quando è
  /// lei ad aprire l'app. Fuori da Android non fa niente.
  void avvia(void Function(String tipo) usata) {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    _azioni.initialize(usata);
    _azioni.setShortcutItems(const <ShortcutItem>[
      // Le icone sono in android/app/src/main/res/drawable.
      ShortcutItem(
        type: nuova,
        localizedTitle: 'Nuova attività',
        icon: 'ic_scorciatoia_nuova',
      ),
      ShortcutItem(
        type: foto,
        localizedTitle: 'Foto',
        icon: 'ic_scorciatoia_foto',
      ),
    ]);
  }
}
