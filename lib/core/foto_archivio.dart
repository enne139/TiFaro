import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// La cartella dove stanno le foto allegate alle attività.
///
/// Le foto sono file e non righe del database: il database resta piccolo e
/// le foto si potranno mandare al server una per una (DECISIONI.md,
/// voce 007).
class FotoArchivio {
  FotoArchivio(this.cartella);

  /// La cartella delle foto.
  final Directory cartella;

  /// L'archivio vero, nella cartella dei dati dell'app.
  static Future<FotoArchivio> apri() async {
    final Directory base = await getApplicationSupportDirectory();
    final Directory cartella = Directory(p.join(base.path, 'foto'));
    await cartella.create(recursive: true);
    return FotoArchivio(cartella);
  }

  /// Il file della foto chiamata [nomeFile].
  File file(String nomeFile) => File(p.join(cartella.path, nomeFile));

  /// Copia nell'archivio la foto in [percorso] e restituisce il nome che ha
  /// preso.
  ///
  /// Si copia e non si sposta: le foto condivise o scelte dalla galleria
  /// stanno in cartelle temporanee che il sistema svuota quando vuole.
  Future<String> importa(String percorso) async {
    final String estensione = p.extension(percorso).toLowerCase();
    final String nome =
        '${const Uuid().v4()}${estensione.isEmpty ? '.jpg' : estensione}';
    await File(percorso).copy(file(nome).path);
    return nome;
  }
}
