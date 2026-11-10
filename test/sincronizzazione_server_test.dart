// Prova completa della sincronizzazione contro un server vero.
//
// Non parte da sola: serve un server di TiFaro acceso e le variabili
//   TIFARO_SERVER_PROVA=http://localhost:18645
//   TIFARO_TOKEN_PROVA=<il suo token>
// Per esempio, dalla cartella server/:
//   go run . con TIFARO_TOKEN, TIFARO_DATI e TIFARO_BACKUP in una cartella
//   temporanea, oppure il container (vedi server/README.md).
@Tags(<String>['server'])
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

import 'supporto.dart';

/// Un dispositivo finto: database in memoria, cartella delle foto,
/// sincronizzatore collegato al server di prova.
class Dispositivo {
  Dispositivo._(this.db, this.foto, this.sync);

  static Future<Dispositivo> nuovo(String indirizzo, String token) async {
    final AppDatabase db = databaseInMemoria();
    final FotoArchivio foto = FotoArchivio(
      Directory.systemTemp.createTempSync('tifaro_foto_'),
    );
    final Sincronizzatore sync = Sincronizzatore(db: db, foto: foto);
    await sync.imposta(indirizzo: indirizzo, token: token);
    return Dispositivo._(db, foto, sync);
  }

  final AppDatabase db;
  final FotoArchivio foto;
  final Sincronizzatore sync;

  Future<void> sincronizza() async {
    final bool riuscita = await sync.sincronizza();
    expect(riuscita, isTrue, reason: sync.stato.value.messaggio);
  }

  Future<void> chiudi() async {
    await db.close();
    foto.cartella.deleteSync(recursive: true);
  }
}

void main() {
  final String? indirizzo = Platform.environment['TIFARO_SERVER_PROVA'];
  final String token = Platform.environment['TIFARO_TOKEN_PROVA'] ?? '';
  final String? salta = indirizzo == null
      ? 'serve un server: imposta TIFARO_SERVER_PROVA e TIFARO_TOKEN_PROVA'
      : null;

  test('telefono e PC restano allineati, foto comprese', () async {
    final Dispositivo telefono = await Dispositivo.nuovo(indirizzo!, token);
    final Dispositivo pc = await Dispositivo.nuovo(indirizzo, token);
    addTearDown(telefono.chiudi);
    addTearDown(pc.chiudi);

    // Il telefono crea un'attività con una sotto-attività e una foto.
    final String guanti = await telefono.db.attivitaDao.crea(
      titolo: 'Comprare guanti',
      argomentoId: 'argomento-ambulanza',
    );
    final String misura = await telefono.db.attivitaDao.crea(
      titolo: 'Chiedere la misura',
      genitoreId: guanti,
    );
    final String nomeFoto = '${const Uuid().v4()}.jpg';
    telefono.foto.file(nomeFoto).writeAsBytesSync(<int>[1, 2, 3, 4]);
    await telefono.db.attivitaDao.aggiungiFoto(guanti, nomeFoto);
    await telefono.sincronizza();

    // Il PC riceve tutto, file della foto compreso.
    await pc.sincronizza();
    final Attivita ricevuta = (await pc.db.attivitaDao.trova(guanti))!;
    expect(ricevuta.titolo, 'Comprare guanti');
    expect(ricevuta.argomentoId, 'argomento-ambulanza');
    expect((await pc.db.attivitaDao.trova(misura))!.genitoreId, guanti);
    expect(pc.foto.file(nomeFoto).readAsBytesSync(), <int>[1, 2, 3, 4]);

    // Il PC la segna fatta; il telefono lo vede.
    await pc.db.attivitaDao.segnaFatta(guanti, true, ancheSotto: true);
    await pc.sincronizza();
    await telefono.sincronizza();
    expect((await telefono.db.attivitaDao.trova(misura))!.fattaIl, isNotNull);

    // Modifiche alla stessa attività su tutti e due: vince la più recente.
    await telefono.db.attivitaDao.aggiorna(
      guanti,
      const ElencoAttivitaCompanion(titolo: Value<String>('Dal telefono')),
      adesso: DateTime.now().add(const Duration(minutes: 1)),
    );
    await pc.db.attivitaDao.aggiorna(
      guanti,
      const ElencoAttivitaCompanion(titolo: Value<String>('Dal PC, dopo')),
      adesso: DateTime.now().add(const Duration(minutes: 2)),
    );
    await telefono.sincronizza();
    await pc.sincronizza();
    await telefono.sincronizza();
    expect(
      (await telefono.db.attivitaDao.trova(guanti))!.titolo,
      'Dal PC, dopo',
    );
    expect((await pc.db.attivitaDao.trova(guanti))!.titolo, 'Dal PC, dopo');

    // Il cestino passa da un dispositivo all'altro.
    await telefono.db.attivitaDao.spostaNelCestino(guanti);
    await telefono.sincronizza();
    await pc.sincronizza();
    expect((await pc.db.attivitaDao.trova(misura))!.cancellataIl, isNotNull);

    // Alla fine nessuno ha più niente da mandare: niente ping-pong.
    expect(await telefono.db.syncDao.righeDaInviare(), isEmpty);
    expect(await pc.db.syncDao.righeDaInviare(), isEmpty);
  }, skip: salta);

  test('un argomento rinominato non torna al nome di partenza', () async {
    final Dispositivo telefono = await Dispositivo.nuovo(indirizzo!, token);
    addTearDown(telefono.chiudi);
    await telefono.db.categorieDao.modificaArgomento(
      'argomento-personale',
      nome: 'Casa e famiglia',
      colore: 2,
      icona: 'casa',
    );
    await telefono.sincronizza();

    // Un dispositivo installato dopo ha "Personale" appena creato: non deve
    // vincere sul nome cambiato.
    final Dispositivo nuovo = await Dispositivo.nuovo(indirizzo, token);
    addTearDown(nuovo.chiudi);
    await nuovo.sincronizza();
    await telefono.sincronizza();
    final List<Argomento> argomenti = await nuovo.db.categorieDao
        .leggiArgomenti();
    expect(
      argomenti
          .singleWhere((Argomento a) => a.id == 'argomento-personale')
          .nome,
      'Casa e famiglia',
    );
  }, skip: salta);
}
