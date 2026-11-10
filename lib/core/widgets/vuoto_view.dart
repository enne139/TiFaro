import 'package:flutter/material.dart';

/// Cosa si vede quando un elenco è vuoto: dice perché e cosa fare, così
/// "non c'è niente" non sembra mai un caricamento o un guasto.
class VuotoView extends StatelessWidget {
  const VuotoView({
    required this.icona,
    required this.titolo,
    required this.testo,
    super.key,
  });

  final IconData icona;
  final String titolo;

  /// La spiegazione, con il modo per riempire l'elenco.
  final String testo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icona, size: 56, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              titolo,
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              testo,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// L'intestazione di un gruppo in un elenco ("Scadute 3").
class IntestazioneGruppo extends StatelessWidget {
  const IntestazioneGruppo({
    required this.titolo,
    this.quante,
    this.icona,
    this.colore,
    super.key,
  });

  final String titolo;

  /// Quante voci ha il gruppo, mostrato accanto al titolo.
  final int? quante;
  final IconData? icona;
  final Color? colore;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color c = colore ?? tema.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: <Widget>[
          if (icona != null) ...<Widget>[
            Icon(icona, size: 18, color: c),
            const SizedBox(width: 8),
          ],
          Text(titolo, style: tema.textTheme.titleSmall?.copyWith(color: c)),
          if (quante != null) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              '$quante',
              style: tema.textTheme.labelMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
