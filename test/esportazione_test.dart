import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/esportazione/esportazione.dart';

import 'supporto.dart';

void main() {
  late Directory cartella;
  late AppDatabase origine;
  late AppDatabase destinazione;
  late FotoArchivio fotoOrigine;
  late FotoArchivio fotoDestinazione;
  late File zip;

  setUp(() {
    cartella = Directory.systemTemp.createTempSync('tifaro_esporta_');
    origine = databaseInMemoria();
    destinazione = databaseInMemoria();
    fotoOrigine = FotoArchivio(
      Directory(p.join(cartella.path, 'foto1'))..createSync(),
    );
    fotoDestinazione = FotoArchivio(
      Directory(p.join(cartella.path, 'foto2'))..createSync(),
    );
    zip = File(p.join(cartella.path, 'TiFaro.zip'));
  });

  tearDown(() async {
    await origine.close();
    await destinazione.close();
    cartella.deleteSync(recursive: true);
  });

  /// Riempie il database di partenza: un argomento nuovo, un'attività con
  /// una sotto-attività e una foto, un modello con una voce, una cestinata.
  Future<String> prepara() async {
    final String argomento = await origine.categorieDao.creaArgomento(
      'Tempo libero',
    );
    final String gita = await origine.attivitaDao.crea(
      titolo: 'Gita',
      descrizione: '**Portare** la cartina',
      argomentoId: argomento,
      scadenza: DateTime(2026, 11, 20),
    );
    await origine.attivitaDao.crea(titolo: 'Benzina', genitoreId: gita);
    final String vecchia = await origine.attivitaDao.crea(titolo: 'Vecchia');
    await origine.attivitaDao.spostaNelCestino(vecchia);
    File(p.join(cartella.path, 'scatto.jpg')).writeAsBytesSync(<int>[1, 2, 3]);
    final String nome = await fotoOrigine.importa(
      p.join(cartella.path, 'scatto.jpg'),
    );
    await origine.attivitaDao.aggiungiFoto(gita, nome);
    final String modello = await origine.modelliDao.creaModello('Turno');
    await origine.modelliDao.creaVoce(modelloId: modello, titolo: 'Divisa');
    return nome;
  }

  test('quello che si esporta si ritrova importandolo', () async {
    final String foto = await prepara();
    await esporta(db: origine, archivio: fotoOrigine, destinazione: zip);

    final AnteprimaImportazione anteprima = await leggiImportazione(zip);
    // La cestinata non si conta fra le attività, ma viaggia.
    expect(anteprima.attivita, 2);
    expect(anteprima.foto.keys, <String>[foto]);

    final EsitoImportazione esito = await importa(
      db: destinazione,
      archivio: fotoDestinazione,
      anteprima: anteprima,
    );
    await anteprima.chiudi();
    expect(esito.foto, 1);
    expect(esito.nuove, greaterThanOrEqualTo(7));

    final List<Attivita> attivita = await destinazione
        .select(destinazione.elencoAttivita)
        .get();
    expect(attivita.map((Attivita a) => a.titolo).toSet(), <String>{
      'Gita',
      'Benzina',
      'Vecchia',
    });
    final Attivita gita = attivita.singleWhere(
      (Attivita a) => a.titolo == 'Gita',
    );
    expect(gita.descrizione, '**Portare** la cartina');
    expect(gita.scadenza, DateTime(2026, 11, 20));
    expect(
      attivita.singleWhere((Attivita a) => a.titolo == 'Vecchia').cancellataIl,
      isNotNull,
    );
    expect(
      (await destinazione.categorieDao.leggiArgomenti()).map(
        (Argomento a) => a.nome,
      ),
      contains('Tempo libero'),
    );
    expect(
      await destinazione.select(destinazione.vociModello).get(),
      hasLength(1),
    );
    expect(fotoDestinazione.file(foto).readAsBytesSync(), <int>[1, 2, 3]);

    // Importare di nuovo non cambia niente.
    final EsitoImportazione ancora = await importa(
      db: destinazione,
      archivio: fotoDestinazione,
      anteprima: await leggiImportazione(zip),
    );
    expect(ancora.nuove, 0);
    expect(ancora.aggiornate, 0);
    expect(ancora.foto, 0);
  });

  test('una riga cambiata qui dopo l\'esportazione resta com\'è', () async {
    await prepara();
    await esporta(db: origine, archivio: fotoOrigine, destinazione: zip);
    await importa(
      db: destinazione,
      archivio: fotoDestinazione,
      anteprima: await leggiImportazione(zip),
    );
    final Attivita gita =
        (await destinazione.select(destinazione.elencoAttivita).get())
            .singleWhere((Attivita a) => a.titolo == 'Gita');
    await destinazione.attivitaDao.aggiorna(
      gita.id,
      const ElencoAttivitaCompanion(titolo: Value<String>('Gita al lago')),
    );

    final EsitoImportazione esito = await importa(
      db: destinazione,
      archivio: fotoDestinazione,
      anteprima: await leggiImportazione(zip),
    );
    expect(esito.aggiornate, 0);
    expect(
      (await destinazione.attivitaDao.trova(gita.id))!.titolo,
      'Gita al lago',
    );
  });

  test('si importa anche il solo tifaro.json', () async {
    await prepara();
    await esporta(db: origine, archivio: fotoOrigine, destinazione: zip);
    final Archive letto = ZipDecoder().decodeBytes(zip.readAsBytesSync());
    final File json = File(p.join(cartella.path, 'tifaro.json'))
      ..writeAsBytesSync(letto.findFile(nomeDati)!.content as List<int>);

    final AnteprimaImportazione anteprima = await leggiImportazione(json);
    expect(anteprima.attivita, 2);
    expect(anteprima.foto, isEmpty);
  });

  test('un file che non è di TiFaro viene rifiutato', () async {
    final File altro = File(p.join(cartella.path, 'altro.json'))
      ..writeAsStringSync(jsonEncode(<String, dynamic>{'formato': 'altro'}));
    expect(leggiImportazione(altro), throwsA(isA<FileNonValido>()));

    final File rotto = File(p.join(cartella.path, 'rotto.zip'))
      ..writeAsStringSync('non è uno zip');
    expect(leggiImportazione(rotto), throwsA(isA<FileNonValido>()));

    final File futuro = File(p.join(cartella.path, 'futuro.json'))
      ..writeAsStringSync(
        jsonEncode(<String, dynamic>{
          'formato': 'tifaro',
          'versione': versioneFormato + 1,
          'tabelle': <String, dynamic>{},
        }),
      );
    expect(leggiImportazione(futuro), throwsA(isA<FileNonValido>()));
  });
}
