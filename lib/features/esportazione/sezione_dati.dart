import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/esportazione/esportazione.dart';

/// La sezione delle impostazioni per esportare e importare tutti i dati
/// (DECISIONI.md, voce 035).
class SezioneDati extends StatefulWidget {
  const SezioneDati({super.key});

  @override
  State<SezioneDati> createState() => _SezioneDatiState();
}

class _SezioneDatiState extends State<SezioneDati> {
  bool _occupata = false;

  /// Il nome proposto per il file: `TiFaro-2026-11-11.zip`.
  String _nomeFile() {
    final DateTime oggi = DateTime.now();
    String due(int n) => n.toString().padLeft(2, '0');
    return 'TiFaro-${oggi.year}-${due(oggi.month)}-${due(oggi.day)}.zip';
  }

  Future<void> _esporta() async {
    final AppDatabase db = AppScope.db(context);
    final FotoArchivio archivio = AppScope.archivio(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _occupata = true);
    final Directory temporanea = await getTemporaryDirectory();
    final File file = File(p.join(temporanea.path, _nomeFile()));
    Uri? salvato;
    if (!mounted) {
      return;
    }
    final bool riuscito = await eseguiSegnalandoErrori(context, () async {
      await esporta(db: db, archivio: archivio, destinazione: file);
      // La finestra per salvare vuole i byte: su Android il file finisce
      // dove si sceglie (Download, Drive…) attraverso il sistema.
      salvato = await FilePicker.saveFile(
        dialogTitle: 'Salva l\'esportazione di TiFaro',
        fileName: _nomeFile(),
        bytes: await file.readAsBytes(),
        mimeType: 'application/zip',
      );
    });
    if (file.existsSync()) {
      await file.delete();
    }
    if (mounted) {
      setState(() => _occupata = false);
    }
    if (riuscito && salvato != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Esportazione salvata.')),
      );
    }
  }

  Future<void> _importa() async {
    final AppDatabase db = AppScope.db(context);
    final FotoArchivio archivio = AppScope.archivio(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final List<PlatformFile> scelti = await FilePicker.pickFiles(
      dialogTitle: 'Scegli l\'esportazione di TiFaro (.zip)',
      // Su Android il filtro per estensione dipende da come l'app dei file
      // classifica lo zip, e a volte lo nasconde: lì si sceglie fra tutti.
      type: !kIsWeb && Platform.isAndroid ? FileType.any : FileType.custom,
      allowedExtensions: !kIsWeb && Platform.isAndroid
          ? null
          : <String>['zip', 'json'],
    );
    final String? percorso = scelti.isEmpty ? null : scelti.first.path;
    if (percorso == null || !mounted) {
      return;
    }

    AnteprimaImportazione? anteprima;
    await eseguiSegnalandoErrori(context, () async {
      anteprima = await leggiImportazione(File(percorso));
    });
    final AnteprimaImportazione? letta = anteprima;
    if (letta == null || !mounted) {
      return;
    }
    final DateTime? quando = letta.esportatoIl;
    EsitoImportazione? esito;
    final bool? conferma;
    try {
      conferma = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Importare?'),
          content: Text(
            '${quando == null ? 'Il file' : 'Il file del ${formatoDataOra(quando)}'} '
            'ha ${letta.attivita} attività e ${letta.foto.length} foto.\n\n'
            'Entra quello che qui non c\'è o è più vecchio; quello che qui è '
            'più recente resta. Niente viene cancellato.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importa'),
            ),
          ],
        ),
      );
      if (conferma != true || !mounted) {
        return;
      }
      setState(() => _occupata = true);
      await eseguiSegnalandoErrori(context, () async {
        esito = await importa(db: db, archivio: archivio, anteprima: letta);
      });
    } finally {
      await letta.chiudi();
    }
    if (mounted) {
      setState(() => _occupata = false);
    }
    final EsitoImportazione? fatto = esito;
    if (fatto != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Importazione fatta: ${fatto.nuove} elementi nuovi, '
            '${fatto.aggiornate} aggiornati, ${fatto.foto} foto '
            '(${fatto.uguali} c\'erano già).',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const IntestazioneGruppo(titolo: 'Dati', icona: Icons.save_outlined),
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Esporta tutto'),
          subtitle: const Text(
            'Attività, modelli, argomenti, tipologie e foto in un file .zip, '
            'da tenere come copia o portare su un altro dispositivo.',
          ),
          enabled: !_occupata,
          onTap: _esporta,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Importa da un file'),
          subtitle: const Text(
            'Unisce un\'esportazione ai dati di qui, senza cancellare niente.',
          ),
          enabled: !_occupata,
          onTap: _importa,
        ),
        if (_occupata)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
