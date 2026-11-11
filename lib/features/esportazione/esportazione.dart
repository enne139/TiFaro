/// Esportare tutti i dati in un file e importarli di nuovo (DECISIONI.md,
/// voce 035).
///
/// Il file è uno zip con dentro `tifaro.json` (le righe di tutte le tabelle
/// che si sincronizzano, cestinate comprese) e la cartella `foto/`. Si
/// importa anche un `tifaro.json` da solo, senza foto.
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_dao.dart';

/// Il nome del file dei dati dentro lo zip.
const String nomeDati = 'tifaro.json';

/// La versione del formato del file; si alza solo se cambia in modo che una
/// versione vecchia dell'app non lo capirebbe più.
const int versioneFormato = 1;

/// Un file che non è un'esportazione di TiFaro, o è rovinato.
class FileNonValido implements Exception {
  const FileNonValido(this.messaggio);

  final String messaggio;

  @override
  String toString() => messaggio;
}

/// Cosa c'è in un file da importare, e cosa succederebbe importandolo.
class AnteprimaImportazione {
  const AnteprimaImportazione({
    required this.esportatoIl,
    required this.righe,
    required this.attivita,
    required this.foto,
    this.flusso,
  });

  /// Quando è stato fatto il file.
  final DateTime? esportatoIl;

  /// Le righe per tabella, già lette.
  final Map<String, List<Map<String, dynamic>>> righe;

  /// Quante attività ci sono, fuori dal cestino.
  final int attivita;

  /// I file delle foto, per nome: il percorso dentro lo zip.
  final Map<String, ArchiveFile> foto;

  /// Lo zip aperto: le foto si leggono da lì solo quando si importano, per
  /// non tenerle tutte in memoria.
  final InputFileStream? flusso;

  /// Chiude il file, importato o no.
  Future<void> chiudi() async => flusso?.close();
}

/// Come è andata un'importazione.
class EsitoImportazione {
  const EsitoImportazione({
    required this.nuove,
    required this.aggiornate,
    required this.uguali,
    required this.foto,
  });

  /// Righe che qui non c'erano.
  final int nuove;

  /// Righe che qui c'erano, ma più vecchie di quelle del file.
  final int aggiornate;

  /// Righe lasciate come sono: uguali, o più recenti qui.
  final int uguali;

  /// File delle foto copiati.
  final int foto;
}

/// Scrive in [destinazione] lo zip con tutti i dati e le foto.
///
/// Le foto tolte non si esportano; le loro righe sì, perché il cestino e la
/// sincronizzazione ne tengono conto.
Future<void> esporta({
  required AppDatabase db,
  required FotoArchivio archivio,
  required File destinazione,
  DateTime? adesso,
}) async {
  final Map<String, List<Map<String, dynamic>>> tabelle =
      <String, List<Map<String, dynamic>>>{};
  final List<String> fotoDaCopiare = <String>[];
  for (final TabellaSync<DataClass> t in db.syncDao.tabelle) {
    final List<DataClass> righe = (await t.tutte(db)).values.toList();
    tabelle[t.nome] = <Map<String, dynamic>>[
      for (final DataClass r in righe) r.toJson(),
    ];
    if (t.nome == 'foto') {
      for (final DataClass r in righe) {
        final Foto f = r as Foto;
        if (f.cancellataIl == null && archivio.file(f.nomeFile).existsSync()) {
          fotoDaCopiare.add(f.nomeFile);
        }
      }
    }
  }
  final String json = const JsonEncoder.withIndent('  ')
      .convert(<String, dynamic>{
        'formato': 'tifaro',
        'versione': versioneFormato,
        'schema': db.schemaVersion,
        'esportatoIl': (adesso ?? DateTime.now()).toIso8601String(),
        'tabelle': tabelle,
      });

  // Lo zip si scrive un file alla volta, senza tenere le foto in memoria.
  final ZipFileEncoder zip = ZipFileEncoder()..create(destinazione.path);
  try {
    zip.addArchiveFile(ArchiveFile.string(nomeDati, json));
    for (final String nome in fotoDaCopiare) {
      await zip.addFile(archivio.file(nome), 'foto/$nome');
    }
  } finally {
    await zip.close();
  }
}

/// Legge il file [sorgente] (uno zip di TiFaro, o un `tifaro.json`) senza
/// cambiare niente.
Future<AnteprimaImportazione> leggiImportazione(File sorgente) async {
  final Map<String, ArchiveFile> foto = <String, ArchiveFile>{};
  String testo;
  InputFileStream? flusso;
  if (p.extension(sorgente.path).toLowerCase() == '.json') {
    testo = await sorgente.readAsString();
  } else {
    final Archive zip;
    flusso = InputFileStream(sorgente.path);
    try {
      zip = ZipDecoder().decodeStream(flusso);
    } catch (_) {
      await flusso.close();
      throw const FileNonValido('Non è un file zip, o è rovinato.');
    }
    final ArchiveFile? dati = zip.findFile(nomeDati);
    if (dati == null) {
      await flusso.close();
      throw const FileNonValido(
        'Nel file manca tifaro.json: non è un\'esportazione di TiFaro.',
      );
    }
    testo = utf8.decode(dati.content as List<int>);
    for (final ArchiveFile f in zip.files) {
      final String nome = f.name;
      // Solo i file direttamente in foto/, con un nome semplice: un nome con
      // ".." o altre barre potrebbe scrivere fuori dalla cartella.
      if (f.isFile &&
          nome.startsWith('foto/') &&
          p.basename(nome) == nome.substring(5) &&
          !nome.contains('..')) {
        foto[p.basename(nome)] = f;
      }
    }
  }

  try {
    return _analizza(testo, foto, flusso);
  } catch (_) {
    await flusso?.close();
    rethrow;
  }
}

/// Controlla e legge il contenuto di `tifaro.json`.
AnteprimaImportazione _analizza(
  String testo,
  Map<String, ArchiveFile> foto,
  InputFileStream? flusso,
) {
  final Object? radice;
  try {
    radice = jsonDecode(testo);
  } on FormatException {
    throw const FileNonValido('tifaro.json non è un JSON valido.');
  }
  if (radice is! Map<String, dynamic> || radice['formato'] != 'tifaro') {
    throw const FileNonValido('Non è un\'esportazione di TiFaro.');
  }
  final Object? versione = radice['versione'];
  if (versione is! int || versione > versioneFormato) {
    throw const FileNonValido(
      'Il file è di una versione più nuova di TiFaro: aggiorna l\'app.',
    );
  }
  final Object? tabelle = radice['tabelle'];
  if (tabelle is! Map<String, dynamic>) {
    throw const FileNonValido('Nel file mancano le tabelle.');
  }
  final Map<String, List<Map<String, dynamic>>> righe =
      <String, List<Map<String, dynamic>>>{};
  for (final MapEntry<String, dynamic> t in tabelle.entries) {
    final Object? elenco = t.value;
    if (elenco is! List) {
      throw FileNonValido('La tabella ${t.key} non è un elenco.');
    }
    righe[t.key] = <Map<String, dynamic>>[
      for (final Object? r in elenco)
        if (r is Map<String, dynamic>) r,
    ];
  }
  final int attivita = (righe['attivita'] ?? const <Map<String, dynamic>>[])
      .where((Map<String, dynamic> r) => r['cancellataIl'] == null)
      .length;
  return AnteprimaImportazione(
    esportatoIl: DateTime.tryParse('${radice['esportatoIl']}'),
    righe: righe,
    attivita: attivita,
    foto: foto,
    flusso: flusso,
  );
}

/// Importa [anteprima] unendola ai dati di qui: una riga entra se qui non
/// c'è o se quella del file è più recente, come con la sincronizzazione
/// (voce 021). Niente si cancella.
///
/// Le righe entrate risultano cambiate e alla prossima sincronizzazione
/// vanno al server, che tiene comunque la versione più recente.
Future<EsitoImportazione> importa({
  required AppDatabase db,
  required FotoArchivio archivio,
  required AnteprimaImportazione anteprima,
}) async {
  // Prima le foto: una riga che rimanda a un file mancante mostrerebbe
  // un'immagine rotta, un file in più non fa danni.
  int foto = 0;
  for (final MapEntry<String, ArchiveFile> f in anteprima.foto.entries) {
    final File destinazione = archivio.file(f.key);
    if (!destinazione.existsSync()) {
      final OutputFileStream uscita = OutputFileStream(destinazione.path);
      try {
        f.value.writeContent(uscita);
      } finally {
        await uscita.close();
      }
      foto += 1;
    }
  }

  int nuove = 0;
  int aggiornate = 0;
  int uguali = 0;
  await db.transaction(() async {
    // I vincoli fra tabelle si controllano alla fine, quando ci sono tutte
    // le righe (come nella sincronizzazione).
    await db.customStatement('PRAGMA defer_foreign_keys = ON');
    for (final TabellaSync<DataClass> t in db.syncDao.tabelle) {
      final List<Map<String, dynamic>> righe =
          anteprima.righe[t.nome] ?? const <Map<String, dynamic>>[];
      if (righe.isEmpty) {
        continue;
      }
      final Map<String, DataClass> locali = await t.tutte(db);
      for (final Map<String, dynamic> dati in righe) {
        final DataClass riga;
        try {
          riga = t.daJson(dati);
        } catch (_) {
          throw FileNonValido('Una riga di ${t.nome} non si legge.');
        }
        final RigaSync delFile = t.perServer(riga);
        final DataClass? locale = locali[delFile.id];
        if (locale == null) {
          nuove += 1;
        } else {
          final RigaSync qui = t.perServer(locale);
          if (qui.impronta == delFile.impronta ||
              qui.aggiornata >= delFile.aggiornata) {
            uguali += 1;
            continue;
          }
          aggiornate += 1;
        }
        await t.scrivi(db, riga.toJson());
        locali[delFile.id] = riga;
      }
    }
  });
  return EsitoImportazione(
    nuove: nuove,
    aggiornate: aggiornate,
    uguali: uguali,
    foto: foto,
  );
}
