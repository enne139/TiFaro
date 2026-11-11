import 'package:flutter/foundation.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/notifiche/logica/avvisi.dart';
import 'package:tifaro/features/notifiche/notifiche_dispositivo.dart';

/// Le chiavi delle preferenze delle notifiche, che restano su ogni
/// dispositivo.
abstract final class ChiaviNotifiche {
  /// "no" se gli avvisi sono spenti; senza valore sono accesi.
  static const String attive = 'notifiche.attive';

  /// L'ora del riepilogo delle attività senza ora, in minuti.
  static const String ora = 'notifiche.ora';

  /// "si" quando il permesso è già stato chiesto una volta all'avvio.
  static const String chiesto = 'notifiche.chiesto';
}

/// Lo stato degli avvisi, da mostrare nelle impostazioni.
@immutable
class StatoNotifiche {
  const StatoNotifiche({
    this.programmati = 0,
    this.permesso = true,
    this.precisi = true,
    this.messaggio,
  });

  /// Quanti avvisi sono in attesa.
  final int programmati;

  /// Se l'app può mostrare le notifiche.
  final bool permesso;

  /// Se gli avvisi arrivano all'ora giusta.
  final bool precisi;

  /// Cosa è andato storto l'ultima volta, se qualcosa è andato storto.
  final String? messaggio;
}

/// Una richiesta di aprire l'app da un avviso toccato: l'attività, oppure
/// Oggi se l'avviso era un riepilogo.
@immutable
class AperturaDaAvviso {
  const AperturaDaAvviso(this.attivitaId);

  final String? attivitaId;
}

/// Tiene gli avvisi delle scadenze allineati con le attività (DECISIONI.md,
/// voce 033).
///
/// Ogni giro calcola gli avvisi che dovrebbero esserci, li confronta con
/// quelli programmati e fa solo le differenze, come il calendario.
class PianificatoreNotifiche {
  PianificatoreNotifiche({required this.db, required this.dispositivo});

  final AppDatabase db;
  final NotificheDispositivo dispositivo;

  /// Lo stato dopo l'ultimo giro.
  final ValueNotifier<StatoNotifiche> stato = ValueNotifier<StatoNotifiche>(
    const StatoNotifiche(),
  );

  /// L'ultimo avviso toccato, che l'app deve ancora aprire; chi lo apre lo
  /// rimette a `null`.
  final ValueNotifier<AperturaDaAvviso?> daAprire =
      ValueNotifier<AperturaDaAvviso?>(null);

  bool _pronto = false;
  bool _inCorso = false;

  /// Se durante un giro ne è stato chiesto un altro: i dati potrebbero
  /// essere cambiati dopo che il giro li ha letti.
  bool _ancora = false;

  /// Prepara le notifiche e guarda se l'app è stata aperta da un avviso.
  /// Da chiamare una volta, all'avvio.
  Future<void> avvia() async {
    try {
      await dispositivo.prepara(_toccato);
      _pronto = true;
      final String? carico = await dispositivo.caricoDiAvvio();
      if (carico != null) {
        _toccato(carico);
      }
    } catch (errore) {
      stato.value = StatoNotifiche(messaggio: messaggioErrore(errore));
    }
  }

  void _toccato(String? carico) {
    daAprire.value = AperturaDaAvviso(attivitaDelCarico(carico));
  }

  /// Se gli avvisi sono accesi.
  Future<bool> attive() async =>
      await db.syncDao.preferenza(ChiaviNotifiche.attive) != 'no';

  /// Accende o spegne gli avvisi e riallinea.
  Future<void> accendi(bool accese) async {
    await db.syncDao.impostaPreferenza(
      ChiaviNotifiche.attive,
      accese ? null : 'no',
    );
    await allinea();
  }

  /// L'ora del riepilogo delle attività senza ora, in minuti.
  Future<int> oraRiepilogo() async {
    final int? minuti = int.tryParse(
      await db.syncDao.preferenza(ChiaviNotifiche.ora) ?? '',
    );
    return minuti != null && minuti >= 0 && minuti < 24 * 60
        ? minuti
        : oraRiepilogoPredefinita;
  }

  /// Cambia l'ora del riepilogo e riallinea.
  Future<void> impostaOraRiepilogo(int minuti) async {
    await db.syncDao.impostaPreferenza(ChiaviNotifiche.ora, '$minuti');
    await allinea();
  }

  /// La prima volta che l'app parte con gli avvisi, chiede il permesso di
  /// mostrarli (Android 13 e oltre lo vuole). Una volta sola: se lo si
  /// nega, si riattiva dalle impostazioni.
  Future<void> chiediPermessoLaPrimaVolta() async {
    if (!_pronto ||
        await db.syncDao.preferenza(ChiaviNotifiche.chiesto) == 'si' ||
        !await attive()) {
      return;
    }
    await db.syncDao.impostaPreferenza(ChiaviNotifiche.chiesto, 'si');
    if (!await dispositivo.haPermesso()) {
      await dispositivo.chiediPermesso();
    }
  }

  /// Fa un giro di allineamento. Restituisce `true` se è andato bene.
  Future<bool> allinea({DateTime? adesso}) async {
    if (!_pronto) {
      return true;
    }
    if (_inCorso) {
      _ancora = true;
      return true;
    }
    _inCorso = true;
    try {
      final Map<int, String> programmati = <int, String>{
        for (final AvvisoProgrammato p in await dispositivo.programmati())
          p.id: p.firma,
      };
      if (!await attive()) {
        for (final int id in programmati.keys) {
          await dispositivo.togli(id);
        }
        stato.value = const StatoNotifiche();
        return true;
      }

      final List<Attivita> attivita = await (db.select(
        db.elencoAttivita,
      )..where((t) => t.cancellataIl.isNull())).get();
      // Un margine di qualche secondo: un avviso che scade mentre lo si
      // programma verrebbe rifiutato perché già passato.
      final DateTime da = (adesso ?? DateTime.now()).add(
        const Duration(seconds: 10),
      );
      final List<AvvisoVoluto> voluti = avvisiVoluti(
        IndiceAttivita(attivita),
        adesso: da,
        oraRiepilogo: await oraRiepilogo(),
      );
      final Set<int> idVoluti = <int>{
        for (final AvvisoVoluto v in voluti) v.id,
      };

      for (final int id in programmati.keys) {
        if (!idVoluti.contains(id)) {
          await dispositivo.togli(id);
        }
      }
      for (final AvvisoVoluto v in voluti) {
        if (programmati[v.id] != v.firma) {
          await dispositivo.programma(v);
        }
      }

      final bool permesso = await dispositivo.haPermesso();
      stato.value = StatoNotifiche(
        programmati: voluti.length,
        permesso: permesso,
        precisi: await dispositivo.orariPrecisi(),
        messaggio: permesso
            ? null
            : 'Le notifiche di TiFaro sono spente nelle impostazioni del '
                  'telefono: gli avvisi non si vedranno.',
      );
      return true;
    } catch (errore) {
      stato.value = StatoNotifiche(
        programmati: stato.value.programmati,
        messaggio: messaggioErrore(errore),
      );
      return false;
    } finally {
      _inCorso = false;
      if (_ancora) {
        _ancora = false;
        allinea();
      }
    }
  }
}
