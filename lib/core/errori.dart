import 'package:flutter/material.dart';

/// Testo leggibile per un errore, da mostrare all'utente.
String messaggioErrore(Object errore) {
  final String testo = errore.toString();
  // Le eccezioni Dart si presentano come "Exception: vero messaggio".
  const String prefisso = 'Exception: ';
  return testo.startsWith(prefisso) ? testo.substring(prefisso.length) : testo;
}

/// Esegue un'operazione nata da un gesto dell'utente e, se fallisce, lo
/// dice con un messaggio in basso.
///
/// Restituisce `true` se è andata bene. Senza questo, una scrittura non
/// riuscita non lascerebbe traccia: si vedrebbe solo un pulsante che non fa
/// niente.
Future<bool> eseguiSegnalandoErrori(
  BuildContext context,
  Future<void> Function() operazione,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ColorScheme colori = Theme.of(context).colorScheme;
  try {
    await operazione();
    return true;
  } catch (errore) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Non riuscito: ${messaggioErrore(errore)}',
          style: TextStyle(color: colori.onErrorContainer),
        ),
        backgroundColor: colori.errorContainer,
        showCloseIcon: true,
        duration: const Duration(seconds: 8),
      ),
    );
    return false;
  }
}
