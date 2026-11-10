import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/foto_archivio.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/sincronizzazione/client_server.dart';
import 'package:tifaro/features/sincronizzazione/data/sync_dao.dart';

/// A che punto è la sincronizzazione.
enum FaseSync {
  /// Nessun server impostato: i dati restano su questo dispositivo.
  spenta,

  /// Impostata, ma non ancora fatta da quando l'app è aperta.
  pronta,

  /// Sta parlando con il server.
  inCorso,

  /// L'ultima è andata bene.
  riuscita,

  /// L'ultima non è riuscita: vedi il messaggio.
  errore,
}

/// Lo stato da mostrare: fase, ultima riuscita ed eventuale errore.
@immutable
class StatoSync {
  const StatoSync(this.fase, {this.ultima, this.messaggio});

  final FaseSync fase;

  /// Quando è riuscita l'ultima volta.
  final DateTime? ultima;

  /// Cosa è andato storto, se [fase] è [FaseSync.errore].
  final String? messaggio;
}

/// Come raggiungere il server, letto dalle preferenze.
class ConfigurazioneSync {
  const ConfigurazioneSync({
    required this.indirizzo,
    required this.token,
    required this.automatica,
  });

  final String? indirizzo;
  final String? token;

  /// Se sincronizzare da sola (all'apertura, ogni tanto, dopo le modifiche).
  final bool automatica;

  /// Se ci sono indirizzo e token.
  bool get pronta =>
      (indirizzo?.isNotEmpty ?? false) && (token?.isNotEmpty ?? false);
}

/// Tiene allineato questo dispositivo con il server.
///
/// Una sincronizzazione è un giro solo: manda le righe cambiate qui,
/// riceve quelle cambiate altrove, applica tutto insieme, poi sistema le
/// foto (DECISIONI.md, voce 021).
class Sincronizzatore {
  Sincronizzatore({
    required this.db,
    required this.foto,
    ClientServer Function(String indirizzo, String token)? nuovoClient,
  }) : _nuovoClient =
           nuovoClient ??
           ((String indirizzo, String token) =>
               ClientServer(indirizzo: indirizzo, token: token));

  final AppDatabase db;
  final FotoArchivio foto;
  final ClientServer Function(String indirizzo, String token) _nuovoClient;

  /// Lo stato, da ascoltare nell'interfaccia.
  final ValueNotifier<StatoSync> stato = ValueNotifier<StatoSync>(
    const StatoSync(FaseSync.spenta),
  );

  bool _inCorso = false;

  SyncDao get _dao => db.syncDao;

  /// Legge le preferenze e prepara lo stato. Da chiamare all'avvio.
  Future<void> carica() async {
    final ConfigurazioneSync c = await configurazione();
    final String? ultima = await _dao.preferenza(ChiaviPreferenze.ultima);
    stato.value = StatoSync(
      c.pronta ? FaseSync.pronta : FaseSync.spenta,
      ultima: ultima == null ? null : DateTime.tryParse(ultima),
    );
  }

  /// La configurazione attuale.
  Future<ConfigurazioneSync> configurazione() async {
    return ConfigurazioneSync(
      indirizzo: await _dao.preferenza(ChiaviPreferenze.indirizzo),
      token: await _dao.preferenza(ChiaviPreferenze.token),
      automatica: await _dao.preferenza(ChiaviPreferenze.automatica) != 'no',
    );
  }

  /// Salva indirizzo e token; con valori vuoti scollega.
  ///
  /// Cambiando server si riparte da zero: quello nuovo non ha niente di ciò
  /// che si era mandato al vecchio.
  Future<void> imposta({
    required String indirizzo,
    required String token,
  }) async {
    final ConfigurazioneSync prima = await configurazione();
    final String nuovoIndirizzo = indirizzo.trim().isEmpty
        ? ''
        : ClientServer.normalizzaIndirizzo(indirizzo);
    if (nuovoIndirizzo != (prima.indirizzo ?? '')) {
      await _dao.dimenticaNote();
      await _dao.impostaPreferenza(ChiaviPreferenze.revisione, null);
      await _dao.impostaPreferenza(ChiaviPreferenze.ultima, null);
    }
    await _dao.impostaPreferenza(
      ChiaviPreferenze.indirizzo,
      nuovoIndirizzo.isEmpty ? null : nuovoIndirizzo,
    );
    await _dao.impostaPreferenza(
      ChiaviPreferenze.token,
      token.trim().isEmpty ? null : token.trim(),
    );
    await carica();
  }

  /// Accende o spegne la sincronizzazione automatica.
  Future<void> impostaAutomatica(bool accesa) =>
      _dao.impostaPreferenza(ChiaviPreferenze.automatica, accesa ? null : 'no');

  /// Un client per il server impostato, o `null` se non c'è.
  Future<ClientServer?> client() async {
    final ConfigurazioneSync c = await configurazione();
    return c.pronta ? _nuovoClient(c.indirizzo!, c.token!) : null;
  }

  /// Il nome con cui questo dispositivo si presenta al server, creato la
  /// prima volta.
  Future<String> _dispositivo() async {
    final String? salvato = await _dao.preferenza(ChiaviPreferenze.dispositivo);
    if (salvato != null) {
      return salvato;
    }
    final String nuovo =
        '${Platform.operatingSystem}-${const Uuid().v4().substring(0, 8)}';
    await _dao.impostaPreferenza(ChiaviPreferenze.dispositivo, nuovo);
    return nuovo;
  }

  /// Sincronizza adesso. Restituisce `true` se è andata bene (o se non
  /// c'era niente da fare).
  ///
  /// Con [soloSeCambiato] non disturba il server se qui non è cambiato
  /// niente: serve alle sincronizzazioni fatte dopo una modifica.
  Future<bool> sincronizza({bool soloSeCambiato = false}) async {
    if (_inCorso) {
      return true;
    }
    final ClientServer? server = await client();
    if (server == null) {
      stato.value = const StatoSync(FaseSync.spenta);
      return true;
    }
    List<RigaSync> sporche = await _dao.righeDaInviare();
    if (soloSeCambiato && sporche.isEmpty) {
      server.chiudi();
      return true;
    }

    _inCorso = true;
    final DateTime? ultimaPrima = stato.value.ultima;
    stato.value = StatoSync(FaseSync.inCorso, ultima: ultimaPrima);
    try {
      final String dispositivo = await _dispositivo();
      int dalla =
          int.tryParse(
            await _dao.preferenza(ChiaviPreferenze.revisione) ?? '',
          ) ??
          0;

      await _caricaFoto(server, sporche);
      RispostaSync risposta = await server.sincronizza(
        dispositivo: dispositivo,
        dalla: dalla,
        modifiche: sporche,
      );
      if (risposta.ripartire) {
        // Il server è tornato indietro: potrebbe non avere più righe che
        // qui risultano mandate. Si rimanda tutto, da zero.
        await _dao.dimenticaNote();
        sporche = await _dao.righeDaInviare();
        dalla = 0;
        await _caricaFoto(server, sporche);
        risposta = await server.sincronizza(
          dispositivo: dispositivo,
          dalla: dalla,
          modifiche: sporche,
        );
      }

      final List<RigaSync> accettate = sporche
          .where((RigaSync r) => !risposta.rifiutate.contains(r.chiave))
          .toList();
      final List<RigaSync> ricevute = <RigaSync>[...risposta.righe];
      dalla = risposta.revisione;
      // Le altre pagine, senza rimandare le modifiche. Si applica tutto
      // insieme alla fine: una riga può dipendere da una della pagina dopo.
      while (!risposta.fine) {
        risposta = await server.sincronizza(
          dispositivo: dispositivo,
          dalla: dalla,
          modifiche: const <RigaSync>[],
        );
        ricevute.addAll(risposta.righe);
        dalla = risposta.revisione;
      }

      await _dao.applica(
        accettate: accettate,
        ricevute: ricevute,
        revisione: dalla,
      );
      await _scaricaFotoMancanti(server);

      final DateTime adesso = DateTime.now();
      await _dao.impostaPreferenza(
        ChiaviPreferenze.ultima,
        adesso.toIso8601String(),
      );
      stato.value = StatoSync(FaseSync.riuscita, ultima: adesso);
      return true;
    } catch (errore) {
      stato.value = StatoSync(
        FaseSync.errore,
        ultima: ultimaPrima,
        messaggio: messaggioErrore(errore),
      );
      return false;
    } finally {
      server.chiudi();
      _inCorso = false;
    }
  }

  /// Carica le foto delle righe che stanno per partire, prima delle righe:
  /// chi riceve la riga deve poter trovare il file.
  Future<void> _caricaFoto(ClientServer server, List<RigaSync> righe) async {
    for (final RigaSync r in righe) {
      if (r.tabella != 'foto' || r.dati['cancellataIl'] != null) {
        continue;
      }
      final String nome = r.dati['nomeFile'] as String;
      final File file = foto.file(nome);
      if (!file.existsSync() || await server.haFoto(nome)) {
        continue;
      }
      await server.caricaFoto(nome, await file.readAsBytes());
    }
  }

  /// Scarica le foto che qui non ci sono: quelle allegate su un altro
  /// dispositivo.
  Future<void> _scaricaFotoMancanti(ClientServer server) async {
    final List<Foto> tutte = await db.select(db.elencoFoto).get();
    for (final Foto f in tutte) {
      if (f.cancellataIl != null || foto.file(f.nomeFile).existsSync()) {
        continue;
      }
      final List<int>? byte = await server.scaricaFoto(f.nomeFile);
      if (byte == null) {
        // Il server non ce l'ha (il dispositivo che l'ha scattata non l'ha
        // ancora caricata): ci si riprova la prossima volta.
        continue;
      }
      // Prima con un nome provvisorio: una foto scaricata a metà non deve
      // sembrare intera.
      final File provvisorio = File('${foto.file(f.nomeFile).path}.parziale');
      await provvisorio.writeAsBytes(byte, flush: true);
      await provvisorio.rename(foto.file(f.nomeFile).path);
    }
  }
}
