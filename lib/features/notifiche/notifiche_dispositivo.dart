import 'dart:async';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:tifaro/features/notifiche/logica/avvisi.dart';

/// Un avviso già programmato sul dispositivo, come lo si rilegge.
@immutable
class AvvisoProgrammato {
  const AvvisoProgrammato({required this.id, required this.firma});

  final int id;

  /// Titolo, testo e carico, come [AvvisoVoluto.firma].
  final String firma;
}

/// Le notifiche del dispositivo, viste dall'app.
///
/// È un'interfaccia perché le prove usano una versione finta, e perché
/// Android e Linux lavorano in modo diverso: Android programma gli avvisi
/// nel sistema, che li mostra anche ad app chiusa; Linux sa solo mostrarli
/// subito, e li tiene in attesa finché l'app è aperta (voce 033).
abstract class NotificheDispositivo {
  /// Le notifiche di questo dispositivo: Android, Linux, oppure nessuna.
  static NotificheDispositivo? perQuestoDispositivo() {
    if (kIsWeb) {
      return null;
    }
    if (Platform.isAndroid) {
      return NotificheAndroid();
    }
    if (Platform.isLinux) {
      return NotificheLinux();
    }
    return null;
  }

  /// Se gli avvisi arrivano anche con l'app chiusa.
  bool get ancheAppChiusa;

  /// Da chiamare una volta, all'avvio: [alTocco] riceve il carico
  /// dell'avviso toccato.
  Future<void> prepara(void Function(String? carico) alTocco);

  /// Il carico dell'avviso che ha aperto l'app, se l'ha aperta un avviso.
  Future<String?> caricoDiAvvio();

  /// Se l'app può mostrare le notifiche.
  Future<bool> haPermesso();

  /// Chiede il permesso; `true` se concesso.
  Future<bool> chiediPermesso();

  /// Se gli avvisi arrivano all'ora giusta e non qualche minuto dopo.
  Future<bool> orariPrecisi();

  /// Porta alla pagina del sistema dove permettere gli orari precisi.
  Future<void> chiediOrariPrecisi();

  /// Gli avvisi programmati e non ancora mostrati.
  Future<List<AvvisoProgrammato>> programmati();

  /// Programma [avviso], sostituendo quello con lo stesso numero.
  Future<void> programma(AvvisoVoluto avviso);

  /// Toglie l'avviso programmato [id].
  Future<void> togli(int id);

  /// Mostra subito un avviso, per provare che arrivino.
  Future<void> mostraSubito({required String titolo, required String testo});
}

/// Il colore dell'app, per l'icona degli avvisi su Android.
const Color _colore = Color(0xFF1E4F8C);

/// Il canale delle scadenze: su Android l'utente lo vede nelle impostazioni
/// delle notifiche dell'app, e può cambiarne suono e importanza.
const AndroidNotificationDetails _canale = AndroidNotificationDetails(
  'scadenze',
  'Scadenze',
  channelDescription: 'Le attività che stanno per scadere',
  importance: Importance.high,
  priority: Priority.high,
  category: AndroidNotificationCategory.reminder,
  color: _colore,
  // Un riepilogo con molti titoli si legge per intero aprendolo.
  styleInformation: BigTextStyleInformation(''),
);

/// Le notifiche su Android, programmate nel sistema con
/// `flutter_local_notifications`.
class NotificheAndroid implements NotificheDispositivo {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()!;

  /// Se gli orari precisi sono permessi, letto una volta per giro.
  bool? _precisi;

  @override
  bool get ancheAppChiusa => true;

  @override
  Future<void> prepara(void Function(String? carico) alTocco) async {
    await _plugin.initialize(
      // L'icona piccola, bianca su trasparente, in res/drawable-*.
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notifica'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse r) =>
          alTocco(r.payload),
    );
  }

  @override
  Future<String?> caricoDiAvvio() async {
    final NotificationAppLaunchDetails? dettagli = await _plugin
        .getNotificationAppLaunchDetails();
    if (dettagli == null || !dettagli.didNotificationLaunchApp) {
      return null;
    }
    return dettagli.notificationResponse?.payload;
  }

  @override
  Future<bool> haPermesso() async =>
      await _android.areNotificationsEnabled() ?? false;

  @override
  Future<bool> chiediPermesso() async =>
      await _android.requestNotificationsPermission() ?? false;

  @override
  Future<bool> orariPrecisi() async =>
      _precisi = await _android.canScheduleExactNotifications() ?? false;

  @override
  Future<void> chiediOrariPrecisi() async {
    await _android.requestExactAlarmsPermission();
    _precisi = null;
  }

  @override
  Future<List<AvvisoProgrammato>> programmati() async {
    return <AvvisoProgrammato>[
      for (final PendingNotificationRequest r
          in await _plugin.pendingNotificationRequests())
        AvvisoProgrammato(
          id: r.id,
          firma: '${r.title ?? ''}\n${r.body ?? ''}\n${r.payload ?? ''}',
        ),
    ];
  }

  @override
  Future<void> programma(AvvisoVoluto avviso) async {
    final bool precisi = _precisi ?? await orariPrecisi();
    await _plugin.zonedSchedule(
      id: avviso.id,
      title: avviso.titolo,
      body: avviso.testo,
      // In UTC: è l'istante che conta, e così non serve conoscere il nome
      // del fuso orario del telefono.
      scheduledDate: tz.TZDateTime.from(avviso.quando, tz.UTC),
      notificationDetails: NotificationDetails(
        android: _conTesto(avviso.testo),
      ),
      // Senza il permesso degli orari precisi Android può ritardare
      // l'avviso di qualche minuto, ma lo mostra lo stesso.
      androidScheduleMode: precisi
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: avviso.carico,
    );
  }

  @override
  Future<void> togli(int id) => _plugin.cancel(id: id);

  @override
  Future<void> mostraSubito({required String titolo, required String testo}) {
    return _plugin.show(
      id: 1,
      title: titolo,
      body: testo,
      notificationDetails: NotificationDetails(android: _conTesto(testo)),
    );
  }

  /// Il canale, con il testo lungo da mostrare aprendo l'avviso.
  AndroidNotificationDetails _conTesto(String testo) =>
      AndroidNotificationDetails(
        _canale.channelId,
        _canale.channelName,
        channelDescription: _canale.channelDescription,
        importance: _canale.importance,
        priority: _canale.priority,
        category: _canale.category,
        color: _canale.color,
        styleInformation: BigTextStyleInformation(testo),
      );
}

/// Le notifiche su Linux: il sistema sa solo mostrarle subito, quindi gli
/// avvisi aspettano in un timer finché l'app è aperta.
class NotificheLinux implements NotificheDispositivo {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Gli avvisi in attesa, per numero.
  final Map<int, ({AvvisoVoluto avviso, Timer timer})> _inAttesa =
      <int, ({AvvisoVoluto avviso, Timer timer})>{};

  @override
  bool get ancheAppChiusa => false;

  @override
  Future<void> prepara(void Function(String? carico) alTocco) async {
    await _plugin.initialize(
      settings: InitializationSettings(
        linux: LinuxInitializationSettings(
          defaultActionName: 'Apri',
          defaultIcon: AssetsLinuxIcon('assets/icona/tifaro.png'),
        ),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse r) =>
          alTocco(r.payload),
    );
  }

  @override
  Future<String?> caricoDiAvvio() async => null;

  @override
  Future<bool> haPermesso() async => true;

  @override
  Future<bool> chiediPermesso() async => true;

  @override
  Future<bool> orariPrecisi() async => true;

  @override
  Future<void> chiediOrariPrecisi() async {}

  @override
  Future<List<AvvisoProgrammato>> programmati() async => <AvvisoProgrammato>[
    for (final ({AvvisoVoluto avviso, Timer timer}) a in _inAttesa.values)
      AvvisoProgrammato(id: a.avviso.id, firma: a.avviso.firma),
  ];

  @override
  Future<void> programma(AvvisoVoluto avviso) async {
    _inAttesa.remove(avviso.id)?.timer.cancel();
    final Duration fra = avviso.quando.difference(DateTime.now());
    _inAttesa[avviso.id] = (
      avviso: avviso,
      timer: Timer(fra.isNegative ? Duration.zero : fra, () {
        _inAttesa.remove(avviso.id);
        _plugin.show(
          id: avviso.id,
          title: avviso.titolo,
          body: avviso.testo,
          payload: avviso.carico,
        );
      }),
    );
  }

  @override
  Future<void> togli(int id) async {
    _inAttesa.remove(id)?.timer.cancel();
  }

  @override
  Future<void> mostraSubito({required String titolo, required String testo}) {
    return _plugin.show(id: 1, title: titolo, body: testo);
  }
}
