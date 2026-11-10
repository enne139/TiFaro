import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Quello che arriva da un'altra app con il tasto Condividi.
class Condivisione {
  const Condivisione({required this.testo, required this.foto});

  /// Il testo condiviso (anche un link); vuoto se sono solo foto.
  final String testo;

  /// I percorsi delle foto condivise, copiate dal sistema in una cartella
  /// temporanea.
  final List<String> foto;

  /// Se non è arrivato niente di utile (per esempio solo un video).
  bool get vuota => testo.isEmpty && foto.isEmpty;

  /// Quanto del testo va nella riga della cattura veloce e quanto nella
  /// descrizione.
  ///
  /// Un testo breve su una riga sola diventa il titolo; uno lungo (un
  /// messaggio, un articolo) va nella descrizione e il titolo lo si scrive
  /// a mano.
  ({String riga, String descrizione}) divisa() {
    final String t = testo.trim();
    if (t.contains('\n') || t.length > 100) {
      return (riga: '', descrizione: t);
    }
    return (riga: t, descrizione: '');
  }
}

/// Ascolta le condivisioni da altre app e le passa a [gestisci].
///
/// Funziona solo su Android: altrove non fa niente.
class AscoltoCondivisioni {
  AscoltoCondivisioni(this.gestisci);

  /// Chiamato a ogni condivisione ricevuta.
  final void Function(Condivisione condivisione) gestisci;

  StreamSubscription<List<SharedMediaFile>>? _abbonamento;

  /// Comincia ad ascoltare.
  ///
  /// Due strade: [ReceiveSharingIntent.getInitialMedia] per la condivisione
  /// che ha aperto l'app da chiusa, lo stream per quelle che arrivano con
  /// l'app già aperta.
  void avvia() {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    final ReceiveSharingIntent ricevi = ReceiveSharingIntent.instance;
    _abbonamento = ricevi.getMediaStream().listen(
      _ricevi,
      onError: (Object _) {},
    );
    ricevi.getInitialMedia().then((List<SharedMediaFile> file) {
      _ricevi(file);
      // Senza reset, la stessa condivisione tornerebbe a ogni riavvio.
      ricevi.reset();
    });
  }

  void _ricevi(List<SharedMediaFile> file) {
    final List<String> testi = <String>[];
    final List<String> foto = <String>[];
    for (final SharedMediaFile f in file) {
      switch (f.type) {
        case SharedMediaType.text:
        case SharedMediaType.url:
          // Per testi e link il "percorso" è il testo stesso.
          testi.add(f.path);
        case SharedMediaType.image:
          foto.add(f.path);
        case SharedMediaType.video:
        case SharedMediaType.file:
          break;
      }
    }
    final Condivisione condivisione = Condivisione(
      testo: testi.join('\n').trim(),
      foto: foto,
    );
    if (!condivisione.vuota) {
      gestisci(condivisione);
    }
  }

  /// Smette di ascoltare.
  void ferma() => _abbonamento?.cancel();
}
