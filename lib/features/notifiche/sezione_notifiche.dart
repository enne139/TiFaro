import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/core/widgets/vuoto_view.dart';
import 'package:tifaro/features/notifiche/pianificatore_notifiche.dart';

/// La sezione delle impostazioni per gli avvisi delle scadenze
/// (DECISIONI.md, voce 033).
class SezioneNotifiche extends StatefulWidget {
  const SezioneNotifiche({super.key});

  @override
  State<SezioneNotifiche> createState() => _SezioneNotificheState();
}

class _SezioneNotificheState extends State<SezioneNotifiche> {
  Future<({bool attive, int ora})>? _preferenze;

  PianificatoreNotifiche? get _pianificatore => AppScope.notifiche(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preferenze ??= _leggi();
  }

  Future<({bool attive, int ora})> _leggi() async {
    final PianificatoreNotifiche? p = _pianificatore;
    if (p == null) {
      return (attive: false, ora: 0);
    }
    return (attive: await p.attive(), ora: await p.oraRiepilogo());
  }

  void _ricarica() => setState(() => _preferenze = _leggi());

  Future<void> _accendi(bool accese) async {
    final PianificatoreNotifiche p = _pianificatore!;
    await eseguiSegnalandoErrori(context, () async {
      if (accese &&
          !await p.dispositivo.haPermesso() &&
          !await p.dispositivo.chiediPermesso()) {
        throw Exception(
          'Senza il permesso delle notifiche gli avvisi non si vedono: '
          'concedilo dalle impostazioni del telefono.',
        );
      }
      await p.accendi(accese);
    });
    _ricarica();
  }

  Future<void> _scegliOra(int minuti) async {
    final TimeOfDay? ora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minuti ~/ 60, minute: minuti % 60),
      helpText: 'Ora del riepilogo',
    );
    if (ora == null || !mounted) {
      return;
    }
    await eseguiSegnalandoErrori(
      context,
      () => _pianificatore!.impostaOraRiepilogo(ora.hour * 60 + ora.minute),
    );
    _ricarica();
  }

  Future<void> _prova() async {
    await eseguiSegnalandoErrori(
      context,
      () => _pianificatore!.dispositivo.mostraSubito(
        titolo: 'TiFaro',
        testo: 'Gli avvisi delle scadenze arrivano così.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PianificatoreNotifiche? p = _pianificatore;
    if (p == null) {
      return const SizedBox.shrink();
    }
    final ThemeData tema = Theme.of(context);
    return FutureBuilder<({bool attive, int ora})>(
      future: _preferenze,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<({bool attive, int ora})> esito,
          ) {
            final ({bool attive, int ora})? s = esito.data;
            if (s == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              );
            }
            final DateTime oggi = DateTime.now();
            final String ora = formatoOra(
              DateTime(oggi.year, oggi.month, oggi.day, 0, s.ora),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const IntestazioneGruppo(
                  titolo: 'Avvisi',
                  icona: Icons.notifications_outlined,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Avvisa quando scade qualcosa'),
                  subtitle: Text(
                    'Le attività con l\'ora all\'ora giusta; quelle senza, in '
                    'un riepilogo alle $ora del giorno in cui scadono.',
                  ),
                  value: s.attive,
                  onChanged: _accendi,
                ),
                if (s.attive) ...<Widget>[
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Ora del riepilogo'),
                    subtitle: Text(ora),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _scegliOra(s.ora),
                  ),
                  ValueListenableBuilder<StatoNotifiche>(
                    valueListenable: p.stato,
                    builder: (BuildContext context, StatoNotifiche stato, _) {
                      final String? messaggio = stato.messaggio;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.alarm),
                            title: Text(
                              stato.programmati == 1
                                  ? '1 avviso in arrivo'
                                  : '${stato.programmati} avvisi in arrivo',
                            ),
                            subtitle: Text(
                              messaggio ??
                                  (p.dispositivo.ancheAppChiusa
                                      ? 'Nei prossimi 30 giorni.'
                                      : 'Su Linux arrivano solo mentre '
                                            'TiFaro è aperta.'),
                              style: messaggio == null
                                  ? null
                                  : TextStyle(color: tema.colorScheme.error),
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: _prova,
                              child: const Text('Prova'),
                            ),
                          ),
                          if (!stato.precisi)
                            ListTile(
                              leading: const Icon(Icons.timer_outlined),
                              title: const Text('Orari precisi'),
                              subtitle: const Text(
                                'Ora gli avvisi possono arrivare con qualche '
                                'minuto di ritardo. Permetti a TiFaro sveglie '
                                'e promemoria per averli all\'ora giusta.',
                              ),
                              trailing: const Icon(Icons.open_in_new),
                              onTap: () async {
                                await p.dispositivo.chiediOrariPrecisi();
                                await p.allinea();
                              },
                            ),
                        ],
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
