import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/calendario/allineatore_calendario.dart';
import 'package:tifaro/features/calendario/calendario_dispositivo.dart';

/// La sezione delle impostazioni per il calendario del telefono.
///
/// Su Linux dice soltanto che il calendario lo gestisce l'app Android.
class SezioneCalendario extends StatefulWidget {
  const SezioneCalendario({super.key});

  @override
  State<SezioneCalendario> createState() => _SezioneCalendarioState();
}

class _SezioneCalendarioState extends State<SezioneCalendario> {
  Future<({bool attivo, CalendarioTelefono? scelto})>? _stato;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stato ??= _leggi();
  }

  AllineatoreCalendario? get _allineatore => AppScope.calendario(context);

  /// Se è acceso e quale calendario è scelto (con nome e account, se si
  /// riescono a leggere).
  Future<({bool attivo, CalendarioTelefono? scelto})> _leggi() async {
    final AllineatoreCalendario? a = _allineatore;
    if (a == null || !a.dispositivo.disponibile) {
      return (attivo: false, scelto: null);
    }
    final bool attivo = await a.attivo();
    final int? id = await a.calendarioScelto();
    CalendarioTelefono? scelto;
    if (attivo && id != null && await a.dispositivo.haPermesso()) {
      for (final CalendarioTelefono c in await a.dispositivo.calendari()) {
        if (c.id == id) {
          scelto = c;
        }
      }
    }
    return (attivo: attivo, scelto: scelto);
  }

  void _ricarica() => setState(() => _stato = _leggi());

  /// Chiede il permesso e fa scegliere un calendario; `null` se si annulla.
  Future<CalendarioTelefono?> _scegliCalendario() async {
    final AllineatoreCalendario a = _allineatore!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (!await a.dispositivo.chiediPermesso()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Senza il permesso del calendario non si possono creare eventi.',
          ),
        ),
      );
      return null;
    }
    final List<CalendarioTelefono> calendari = (await a.dispositivo.calendari())
        .where((CalendarioTelefono c) => c.scrivibile)
        .toList();
    if (!mounted) {
      return null;
    }
    if (calendari.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Sul telefono non c\'è nessun calendario in cui scrivere: '
            'aggiungi un account Google nelle impostazioni di Android.',
          ),
        ),
      );
      return null;
    }
    return showDialog<CalendarioTelefono>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Calendario'),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Meglio uno dedicato: crealo su Google Calendar, dal sito, con '
              'il nome «TiFaro»; dopo qualche minuto compare qui.',
            ),
          ),
          for (final CalendarioTelefono c in calendari)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(c.colore | 0xFF000000),
                ),
                title: Text(c.nome),
                subtitle: Text(c.account),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _accendi() async {
    final CalendarioTelefono? scelto = await _scegliCalendario();
    if (scelto == null || !mounted) {
      return;
    }
    final AllineatoreCalendario a = _allineatore!;
    await a.accendi(scelto.id);
    _ricarica();
    await _allineaMostrandoEsito();
  }

  Future<void> _cambia() async {
    final CalendarioTelefono? scelto = await _scegliCalendario();
    if (scelto == null || !mounted) {
      return;
    }
    // Gli eventi nel calendario di prima si spostano al prossimo giro.
    await _allineatore!.accendi(scelto.id);
    _ricarica();
    await _allineaMostrandoEsito();
  }

  Future<void> _spegni() async {
    // null: annulla; false: spegni lasciando gli eventi; true: toglili.
    final bool? togli = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Smettere di usare il calendario?'),
        content: const Text(
          'Le attività non andranno più nel calendario. Gli eventi già '
          'creati da TiFaro si possono togliere o lasciare dove sono.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lasciali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Toglili'),
          ),
        ],
      ),
    );
    if (togli == null || !mounted) {
      return;
    }
    await _allineatore!.spegni(togliEventi: togli);
    _ricarica();
  }

  Future<void> _allineaMostrandoEsito() async {
    final AllineatoreCalendario a = _allineatore!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool riuscito = await a.allinea();
    final StatoCalendario stato = a.stato.value;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          riuscito
              ? 'Calendario allineato: ${stato.eventi} attività nel calendario.'
              : 'Calendario non allineato: ${stato.messaggio}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AllineatoreCalendario? a = _allineatore;
    final ThemeData tema = Theme.of(context);
    if (a == null) {
      return const SizedBox.shrink();
    }
    if (!a.dispositivo.disponibile) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IntestazioneGruppo(
            titolo: 'Calendario',
            icona: Icons.calendar_month_outlined,
          ),
          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('Lo gestisce il telefono'),
            subtitle: Text(
              'Le attività «nel calendario» le mette nel calendario l\'app '
              'Android, se nelle sue impostazioni ne hai scelto uno.',
            ),
          ),
        ],
      );
    }
    return FutureBuilder<({bool attivo, CalendarioTelefono? scelto})>(
      future: _stato,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<({bool attivo, CalendarioTelefono? scelto})> esito,
          ) {
            final ({bool attivo, CalendarioTelefono? scelto})? s = esito.data;
            if (s == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              );
            }
            final CalendarioTelefono? scelto = s.scelto;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const IntestazioneGruppo(
                  titolo: 'Calendario',
                  icona: Icons.calendar_month_outlined,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.event_available),
                  title: const Text('Metti nel calendario le attività segnate'),
                  subtitle: const Text(
                    'Quelle «nel calendario» con una scadenza diventano '
                    'eventi, aggiornati e tolti insieme all\'attività.',
                  ),
                  value: s.attivo,
                  onChanged: (bool v) => v ? _accendi() : _spegni(),
                ),
                if (s.attivo) ...<Widget>[
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Calendario'),
                    subtitle: Text(
                      scelto == null
                          ? 'Non trovato: sceglierne un altro'
                          : '${scelto.nome} · ${scelto.account}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: _cambia,
                  ),
                  ValueListenableBuilder<StatoCalendario>(
                    valueListenable: a.stato,
                    builder: (BuildContext context, StatoCalendario stato, _) {
                      final String? messaggio = stato.messaggio;
                      return ListTile(
                        leading: const Icon(Icons.sync),
                        title: const Text('Eventi'),
                        subtitle: Text(
                          messaggio ??
                              '${stato.eventi} attività nel calendario',
                          style: messaggio == null
                              ? null
                              : TextStyle(color: tema.colorScheme.error),
                        ),
                        trailing: FilledButton.tonal(
                          onPressed: _allineaMostrandoEsito,
                          child: const Text('Allinea'),
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
