import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Un testo scritto in Markdown, come si legge: grassetti, elenchi,
/// caselle, titoli, link (DECISIONI.md, voce 031).
///
/// Un a capo resta un a capo, come lo si è scritto, anche se il Markdown
/// vorrebbe una riga vuota: le descrizioni si scrivono sul telefono e
/// arrivano dal tasto Condividi, non da chi conosce le regole. I link si
/// aprono nel browser.
class TestoMarkdown extends StatelessWidget {
  const TestoMarkdown(this.testo, {super.key});

  /// Il testo in Markdown.
  final String testo;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    return MarkdownBody(
      data: testo,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet.fromTheme(tema).copyWith(
        p: tema.textTheme.bodyLarge,
        blockquoteDecoration: BoxDecoration(
          color: tema.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        codeblockDecoration: BoxDecoration(
          color: tema.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTapLink: (String testo, String? indirizzo, String titolo) {
        if (indirizzo != null) {
          apriLink(context, indirizzo);
        }
      },
    );
  }
}

/// Apre [indirizzo] nell'app giusta (browser, posta, telefono); se non ci
/// riesce lo dice.
Future<void> apriLink(BuildContext context, String indirizzo) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final Uri? uri = Uri.tryParse(indirizzo.trim());
  bool aperto = false;
  if (uri != null) {
    // Un link senza schema ("esempio.it") è quasi sempre un sito.
    final Uri completo = uri.hasScheme ? uri : Uri.parse('https://$indirizzo');
    try {
      aperto = await launchUrl(completo, mode: LaunchMode.externalApplication);
    } catch (_) {
      aperto = false;
    }
  }
  if (!aperto) {
    messenger.showSnackBar(
      SnackBar(content: Text('Non riesco ad aprire «$indirizzo».')),
    );
  }
}
