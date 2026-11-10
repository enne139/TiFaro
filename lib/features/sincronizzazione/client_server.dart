import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tifaro/features/sincronizzazione/data/sync_dao.dart';

/// Un problema nel parlare con il server, con un messaggio da mostrare.
class ErroreServer implements Exception {
  const ErroreServer(this.messaggio);

  final String messaggio;

  @override
  String toString() => messaggio;
}

/// La risposta a una richiesta di sincronizzazione.
class RispostaSync {
  const RispostaSync({
    required this.righe,
    required this.revisione,
    required this.fine,
    required this.massima,
    required this.rifiutate,
    required this.ripartire,
  });

  factory RispostaSync.daJson(Map<String, dynamic> json) => RispostaSync(
    righe: ((json['righe'] as List<Object?>?) ?? const <Object?>[])
        .map(
          (Object? r) => RigaSync.daJson((r! as Map<Object?, Object?>).cast()),
        )
        .toList(),
    revisione: (json['revisione'] as num? ?? 0).toInt(),
    fine: json['fine'] as bool? ?? true,
    massima: (json['massima'] as num? ?? 0).toInt(),
    rifiutate: ((json['rifiutate'] as List<Object?>?) ?? const <Object?>[])
        .cast<String>()
        .toSet(),
    ripartire: json['ripartire'] as bool? ?? false,
  );

  /// Le righe cambiate dopo la revisione chiesta, più le versioni del
  /// server di quelle rifiutate.
  final List<RigaSync> righe;

  /// Da dove ripartire alla prossima richiesta.
  final int revisione;

  /// Se le righe sono finite o servono altre pagine.
  final bool fine;

  /// La revisione più alta sul server.
  final int massima;

  /// Le modifiche mandate e non entrate, come "tabella/id".
  final Set<String> rifiutate;

  /// Se il server è tornato indietro (per esempio ripristinato da un
  /// backup): le modifiche non sono state prese, e bisogna ricominciare da
  /// zero rimandando tutto.
  final bool ripartire;
}

/// Lo stato del server, per le impostazioni.
class StatoServer {
  const StatoServer({
    required this.versione,
    required this.ultimoBackup,
    required this.copie,
    required this.ogni,
    required this.dispositivi,
  });

  factory StatoServer.daJson(Map<String, dynamic> json) {
    final Map<String, dynamic> backup =
        (json['backup'] as Map<Object?, Object?>? ?? const <Object?, Object?>{})
            .cast<String, dynamic>();
    final String? ultimo = backup['ultimo'] as String?;
    return StatoServer(
      versione: json['versione'] as String? ?? '?',
      ultimoBackup: ultimo == null ? null : DateTime.parse(ultimo).toLocal(),
      copie: (backup['copie'] as num? ?? 0).toInt(),
      ogni: backup['ogni'] as String? ?? '',
      dispositivi:
          (json['dispositivi'] as List<Object?>? ?? const <Object?>[]).length,
    );
  }

  final String versione;
  final DateTime? ultimoBackup;
  final int copie;

  /// Ogni quanto fa un backup, come lo scrive Go ("24h0m0s").
  final String ogni;

  /// Quanti dispositivi si sono sincronizzati almeno una volta.
  final int dispositivi;
}

/// Parla con il server di TiFaro.
class ClientServer {
  ClientServer({
    required String indirizzo,
    required this.token,
    http.Client? client,
  }) : indirizzo = normalizzaIndirizzo(indirizzo),
       _client = client ?? http.Client();

  /// L'indirizzo del server, per esempio `http://indirizzo-del-nas:8645`.
  final String indirizzo;

  /// Il token, lo stesso di TIFARO_TOKEN sul server.
  final String token;

  final http.Client _client;

  /// Quanto aspettare una risposta. La prima sincronizzazione manda tutto,
  /// quindi il margine è largo.
  static const Duration _attesa = Duration(seconds: 60);

  /// L'indirizzo con `http://` se manca e senza la barra finale.
  static String normalizzaIndirizzo(String indirizzo) {
    String pulito = indirizzo.trim();
    if (!pulito.contains('://')) {
      pulito = 'http://$pulito';
    }
    while (pulito.endsWith('/')) {
      pulito = pulito.substring(0, pulito.length - 1);
    }
    return pulito;
  }

  Uri _uri(String percorso) => Uri.parse('$indirizzo$percorso');

  Map<String, String> get _intestazioni => <String, String>{
    'Authorization': 'Bearer $token',
  };

  /// Esegue una richiesta trasformando gli errori di rete in messaggi
  /// comprensibili.
  Future<http.Response> _chiama(
    Future<http.Response> Function() richiesta,
  ) async {
    final http.Response risposta;
    try {
      risposta = await richiesta().timeout(_attesa);
    } on TimeoutException {
      throw const ErroreServer('Il server non risponde.');
    } on SocketException {
      throw ErroreServer(
        'Server non raggiungibile ($indirizzo): sei sulla rete di casa?',
      );
    } on http.ClientException catch (e) {
      throw ErroreServer('Server non raggiungibile: ${e.message}');
    }
    if (risposta.statusCode == HttpStatus.unauthorized) {
      throw const ErroreServer(
        'Il server rifiuta il token: controlla che sia uguale a TIFARO_TOKEN.',
      );
    }
    return risposta;
  }

  Map<String, dynamic> _json(http.Response risposta) {
    final Object? corpo;
    try {
      corpo = jsonDecode(utf8.decode(risposta.bodyBytes));
    } on FormatException {
      throw ErroreServer(
        'Risposta strana (${risposta.statusCode}): è davvero il server di '
        'TiFaro?',
      );
    }
    if (corpo is! Map) {
      throw const ErroreServer('Risposta strana dal server.');
    }
    final Map<String, dynamic> mappa = corpo.cast<String, dynamic>();
    if (risposta.statusCode >= 400) {
      throw ErroreServer(
        'Errore del server (${risposta.statusCode}): '
        '${mappa['errore'] ?? 'senza spiegazione'}',
      );
    }
    return mappa;
  }

  /// Controlla che il server ci sia e che il token vada, e ne restituisce
  /// lo stato.
  Future<StatoServer> stato() async => StatoServer.daJson(
    _json(
      await _chiama(
        () => _client.get(_uri('/api/stato'), headers: _intestazioni),
      ),
    ),
  );

  /// Manda le [modifiche] e chiede le righe dopo la revisione [dalla].
  Future<RispostaSync> sincronizza({
    required String dispositivo,
    required int dalla,
    required List<RigaSync> modifiche,
    int limite = 1000,
  }) async {
    final http.Response risposta = await _chiama(
      () => _client.post(
        _uri('/api/sync'),
        headers: <String, String>{
          ..._intestazioni,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'dispositivo': dispositivo,
          'dalla': dalla,
          'limite': limite,
          'modifiche': modifiche.map((RigaSync r) => r.toJson()).toList(),
        }),
      ),
    );
    return RispostaSync.daJson(_json(risposta));
  }

  /// Se il server ha già la foto [nome].
  Future<bool> haFoto(String nome) async {
    final http.Response risposta = await _chiama(
      () => _client.head(_uri('/api/foto/$nome'), headers: _intestazioni),
    );
    return risposta.statusCode == HttpStatus.ok;
  }

  /// Carica la foto [nome].
  Future<void> caricaFoto(String nome, List<int> byte) async {
    final http.Response risposta = await _chiama(
      () => _client.put(
        _uri('/api/foto/$nome'),
        headers: _intestazioni,
        body: byte,
      ),
    );
    if (risposta.statusCode >= 400) {
      _json(risposta);
    }
  }

  /// Scarica la foto [nome]; `null` se il server non ce l'ha.
  Future<List<int>?> scaricaFoto(String nome) async {
    final http.Response risposta = await _chiama(
      () => _client.get(_uri('/api/foto/$nome'), headers: _intestazioni),
    );
    if (risposta.statusCode == HttpStatus.notFound) {
      return null;
    }
    if (risposta.statusCode >= 400) {
      _json(risposta);
    }
    return risposta.bodyBytes;
  }

  /// Chiede al server un backup adesso e restituisce il nome della copia.
  Future<String> faiBackup() async {
    final Map<String, dynamic> json = _json(
      await _chiama(
        () => _client.post(_uri('/api/backup'), headers: _intestazioni),
      ),
    );
    return json['copia'] as String? ?? '';
  }

  /// Chiude le connessioni.
  void chiudi() => _client.close();
}
