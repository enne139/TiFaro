import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/sincronizzazione/client_server.dart';
import 'package:tifaro/features/sincronizzazione/sincronizzatore.dart';

/// L'icona della sincronizzazione nella barra in alto: dice com'è andata
/// l'ultima e, toccandola, sincronizza subito.
///
/// Non c'è se il server non è impostato.
class IconaSync extends StatelessWidget {
  const IconaSync({super.key});

  @override
  Widget build(BuildContext context) {
    final Sincronizzatore? s = AppScope.sincronizzatore(context);
    if (s == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<StatoSync>(
      valueListenable: s.stato,
      builder: (BuildContext context, StatoSync stato, _) {
        final ColorScheme colori = Theme.of(context).colorScheme;
        final DateTime? ultima = stato.ultima;
        final String quando = ultima == null
            ? 'mai'
            : formatoScadenza(ultima, true, DateTime.now());
        return switch (stato.fase) {
          FaseSync.spenta => const SizedBox.shrink(),
          FaseSync.inCorso => const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          FaseSync.errore => IconButton(
            icon: Icon(Icons.cloud_off_outlined, color: colori.error),
            tooltip: 'Sincronizzazione non riuscita: ${stato.messaggio}',
            onPressed: () => sincronizzaMostrandoEsito(context, s),
          ),
          FaseSync.pronta || FaseSync.riuscita => IconButton(
            icon: const Icon(Icons.cloud_done_outlined),
            tooltip: 'Ultima sincronizzazione: $quando. Tocca per rifarla.',
            onPressed: () => sincronizzaMostrandoEsito(context, s),
          ),
        };
      },
    );
  }
}

/// Sincronizza e, se non riesce, lo dice con un messaggio in basso.
Future<void> sincronizzaMostrandoEsito(
  BuildContext context,
  Sincronizzatore s,
) async {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final ColorScheme colori = Theme.of(context).colorScheme;
  if (!await s.sincronizza()) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Sincronizzazione non riuscita: ${s.stato.value.messaggio}',
          style: TextStyle(color: colori.onErrorContainer),
        ),
        backgroundColor: colori.errorContainer,
        showCloseIcon: true,
        duration: const Duration(seconds: 8),
      ),
    );
  }
}

/// La sezione delle impostazioni per il server: indirizzo e token,
/// sincronizzazione automatica, stato e backup.
class SezioneSync extends StatefulWidget {
  const SezioneSync({super.key});

  @override
  State<SezioneSync> createState() => _SezioneSyncState();
}

class _SezioneSyncState extends State<SezioneSync> {
  Future<ConfigurazioneSync>? _configurazione;
  Future<StatoServer?>? _statoServer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configurazione == null) {
      _ricarica();
    }
  }

  void _ricarica() {
    final Sincronizzatore? s = AppScope.sincronizzatore(context);
    if (s == null) {
      return;
    }
    setState(() {
      _configurazione = s.configurazione();
      _statoServer = _leggiStatoServer(s);
    });
  }

  /// Lo stato del server, o `null` se non è impostato. Un errore si mostra
  /// nella riga del backup.
  Future<StatoServer?> _leggiStatoServer(Sincronizzatore s) async {
    final ClientServer? client = await s.client();
    if (client == null) {
      return null;
    }
    try {
      return await client.stato();
    } finally {
      client.chiudi();
    }
  }

  Future<void> _modificaServer(ConfigurazioneSync attuale) async {
    final Sincronizzatore s = AppScope.sincronizzatore(context)!;
    final bool? salvato = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) =>
          _DialogoServer(sincronizzatore: s, attuale: attuale),
    );
    if (salvato == true && mounted) {
      _ricarica();
      await sincronizzaMostrandoEsito(context, s);
      if (mounted) {
        _ricarica();
      }
    }
  }

  Future<void> _faiBackup() async {
    final ClientServer? client = await AppScope.sincronizzatore(context)!
        .client();
    if (client == null || !mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    String? copia;
    await eseguiSegnalandoErrori(context, () async {
      try {
        copia = await client.faiBackup();
      } finally {
        client.chiudi();
      }
    });
    if (copia != null && mounted) {
      messenger.showSnackBar(SnackBar(content: Text('Backup fatto: $copia')));
      _ricarica();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Sincronizzatore? s = AppScope.sincronizzatore(context);
    final ThemeData tema = Theme.of(context);
    if (s == null) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<ConfigurazioneSync>(
      future: _configurazione,
      builder: (BuildContext context, AsyncSnapshot<ConfigurazioneSync> config) {
        final ConfigurazioneSync? c = config.data;
        if (c == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const IntestazioneGruppo(
              titolo: 'Server e sincronizzazione',
              icona: Icons.cloud_outlined,
            ),
            ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: const Text('Server'),
              subtitle: Text(
                c.pronta
                    ? c.indirizzo!
                    : 'Non collegato: le attività restano solo su questo '
                          'dispositivo.',
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _modificaServer(c),
            ),
            if (c.pronta) ...<Widget>[
              SwitchListTile(
                secondary: const Icon(Icons.sync),
                title: const Text('Sincronizza da sola'),
                subtitle: const Text(
                  'All\'apertura, ogni cinque minuti e poco dopo ogni '
                  'modifica.',
                ),
                value: c.automatica,
                onChanged: (bool v) async {
                  await s.impostaAutomatica(v);
                  _ricarica();
                },
              ),
              ValueListenableBuilder<StatoSync>(
                valueListenable: s.stato,
                builder: (BuildContext context, StatoSync stato, _) {
                  final DateTime? ultima = stato.ultima;
                  final String testo = switch (stato.fase) {
                    FaseSync.inCorso => 'In corso…',
                    FaseSync.errore => 'Non riuscita: ${stato.messaggio}',
                    _ =>
                      ultima == null
                          ? 'Mai fatta'
                          : 'Ultima: ${formatoDataOra(ultima)}',
                  };
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Sincronizzazione'),
                    subtitle: Text(
                      testo,
                      style: stato.fase == FaseSync.errore
                          ? TextStyle(color: tema.colorScheme.error)
                          : null,
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: stato.fase == FaseSync.inCorso
                          ? null
                          : () async {
                              await sincronizzaMostrandoEsito(context, s);
                              if (mounted) {
                                _ricarica();
                              }
                            },
                      child: const Text('Adesso'),
                    ),
                  );
                },
              ),
              FutureBuilder<StatoServer?>(
                future: _statoServer,
                builder: (BuildContext context, AsyncSnapshot<StatoServer?> esito) {
                  final StatoServer? st = esito.data;
                  final Object? errore = esito.error;
                  final DateTime? ultimo = st?.ultimoBackup;
                  final String testo = errore != null
                      ? messaggioErrore(errore)
                      : st == null
                      ? 'Chiedo al server…'
                      : '${ultimo == null ? 'Nessun backup ancora' : 'Ultimo: ${formatoDataOra(ultimo)}'} · '
                            '${st.copie} copie tenute · server ${st.versione}';
                  return ListTile(
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup sul server'),
                    subtitle: Text(testo),
                    trailing: TextButton(
                      onPressed: st == null ? null : _faiBackup,
                      child: const Text('Fanne uno'),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// La finestra per indirizzo e token del server, con la prova di
/// collegamento.
class _DialogoServer extends StatefulWidget {
  const _DialogoServer({required this.sincronizzatore, required this.attuale});

  final Sincronizzatore sincronizzatore;
  final ConfigurazioneSync attuale;

  @override
  State<_DialogoServer> createState() => _DialogoServerState();
}

class _DialogoServerState extends State<_DialogoServer> {
  late final TextEditingController _indirizzo = TextEditingController(
    text: widget.attuale.indirizzo ?? 'http://nas.local:8645',
  );
  late final TextEditingController _token = TextEditingController(
    text: widget.attuale.token ?? '',
  );
  bool _tokenVisibile = false;
  bool _provando = false;

  /// L'esito dell'ultima prova: testo e se è andata bene.
  ({String testo, bool ok})? _esito;

  @override
  void dispose() {
    _indirizzo.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _prova() async {
    setState(() {
      _provando = true;
      _esito = null;
    });
    final ClientServer client = ClientServer(
      indirizzo: _indirizzo.text,
      token: _token.text.trim(),
    );
    try {
      final StatoServer stato = await client.stato();
      _esito = (
        testo:
            'Collegato: server ${stato.versione}, '
            '${stato.dispositivi} dispositivi già visti.',
        ok: true,
      );
    } catch (errore) {
      _esito = (testo: messaggioErrore(errore), ok: false);
    } finally {
      client.chiudi();
    }
    if (mounted) {
      setState(() => _provando = false);
    }
  }

  Future<void> _salva({bool scollega = false}) async {
    await widget.sincronizzatore.imposta(
      indirizzo: scollega ? '' : _indirizzo.text,
      token: scollega ? '' : _token.text,
    );
    if (mounted) {
      Navigator.pop(context, !scollega);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final ({String testo, bool ok})? esito = _esito;
    return AlertDialog(
      title: const Text('Server'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _indirizzo,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Indirizzo',
                helperText: 'Il NAS e la porta del container',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _token,
              obscureText: !_tokenVisibile,
              decoration: InputDecoration(
                labelText: 'Token',
                helperText: 'Lo stesso di TIFARO_TOKEN nel .env del server',
                suffixIcon: IconButton(
                  icon: Icon(
                    _tokenVisibile ? Icons.visibility_off : Icons.visibility,
                  ),
                  tooltip: _tokenVisibile ? 'Nascondi' : 'Mostra',
                  onPressed: () =>
                      setState(() => _tokenVisibile = !_tokenVisibile),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_provando)
              const LinearProgressIndicator()
            else if (esito != null)
              Text(
                esito.testo,
                style: TextStyle(
                  color: esito.ok
                      ? tema.colorScheme.primary
                      : tema.colorScheme.error,
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        if (widget.attuale.pronta)
          TextButton(
            onPressed: () => _salva(scollega: true),
            child: const Text('Scollega'),
          ),
        TextButton(
          onPressed: _provando ? null : _prova,
          child: const Text('Prova'),
        ),
        FilledButton(onPressed: _salva, child: const Text('Salva')),
      ],
    );
  }
}
