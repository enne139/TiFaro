import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/attivita/logica/indice_attivita.dart';
import 'package:tifaro/features/calendario/calendario_dispositivo.dart';
import 'package:tifaro/features/calendario/data/calendario_dao.dart';
import 'package:tifaro/features/calendario/logica/eventi.dart';

/// Lo stato del calendario, da mostrare nelle impostazioni.
@immutable
class StatoCalendario {
  const StatoCalendario({this.eventi = 0, this.messaggio});

  /// Quanti eventi di TiFaro ci sono nel calendario.
  final int eventi;

  /// Cosa è andato storto l'ultima volta, se qualcosa è andato storto.
  final String? messaggio;
}

/// Tiene il calendario del telefono allineato con le attività "nel
/// calendario" (DECISIONI.md, voce 027).
///
/// Ogni giro confronta gli eventi che dovrebbero esserci con quelli creati
/// e fa solo le differenze. Lo fa solo il dispositivo che ha un calendario
/// (Android), con il calendario scelto nelle impostazioni.
class AllineatoreCalendario {
  AllineatoreCalendario({required this.db, required this.dispositivo});

  final AppDatabase db;
  final CalendarioDispositivo dispositivo;

  /// Lo stato dopo l'ultimo giro.
  final ValueNotifier<StatoCalendario> stato = ValueNotifier<StatoCalendario>(
    const StatoCalendario(),
  );

  bool _inCorso = false;

  /// Se l'allineamento è acceso su questo dispositivo.
  Future<bool> attivo() async =>
      dispositivo.disponibile &&
      await db.syncDao.preferenza(ChiaviCalendario.attivo) == 'si';

  /// Il calendario scelto, se c'è.
  Future<int?> calendarioScelto() async =>
      int.tryParse(await db.syncDao.preferenza(ChiaviCalendario.id) ?? '');

  /// Accende l'allineamento con il calendario [calendarioId].
  Future<void> accendi(int calendarioId) async {
    await db.syncDao.impostaPreferenza(ChiaviCalendario.id, '$calendarioId');
    await db.syncDao.impostaPreferenza(ChiaviCalendario.attivo, 'si');
  }

  /// Spegne l'allineamento; con [togliEventi] toglie anche gli eventi già
  /// creati.
  Future<void> spegni({required bool togliEventi}) async {
    await db.syncDao.impostaPreferenza(ChiaviCalendario.attivo, null);
    if (togliEventi) {
      for (final EventoCalendario e
          in (await db.calendarioDao.eventi()).values) {
        try {
          await dispositivo.togli(e.eventoId);
        } on PlatformException {
          // Già tolto, o calendario sparito: non c'è più comunque.
        }
        await db.calendarioDao.dimentica(e.attivitaId);
      }
    }
    stato.value = const StatoCalendario();
  }

  /// Fa un giro di allineamento. Restituisce `true` se è andato bene o se
  /// non c'era niente da fare.
  Future<bool> allinea() async {
    if (_inCorso || !await attivo()) {
      return true;
    }
    final int? calendarioId = await calendarioScelto();
    if (calendarioId == null) {
      return true;
    }
    _inCorso = true;
    try {
      if (!await dispositivo.haPermesso()) {
        stato.value = const StatoCalendario(
          messaggio:
              'Manca il permesso del calendario: riattivalo dalle '
              'impostazioni.',
        );
        return false;
      }

      final List<Attivita> attivita = await (db.select(
        db.elencoAttivita,
      )..where((t) => t.cancellataIl.isNull())).get();
      final List<Argomento> argomenti = await db.categorieDao.leggiArgomenti();
      final List<EventoVoluto> voluti = eventiVoluti(
        IndiceAttivita(attivita),
        <String, Argomento>{for (final Argomento a in argomenti) a.id: a},
      );

      final Map<String, EventoEsistente> esistenti = <String, EventoEsistente>{
        for (final EventoCalendario e
            in (await db.calendarioDao.eventi()).values)
          e.attivitaId: EventoEsistente(
            eventoId: e.eventoId,
            calendarioId: e.calendarioId,
            impronta: e.impronta,
          ),
      };
      if (esistenti.isEmpty) {
        // Niente di ricordato: magari l'app è stata reinstallata e gli
        // eventi ci sono già. Si ritrovano dal segno, e si riscrivono
        // (impronta vuota) invece di crearne dei doppioni.
        for (final MapEntry<String, int> e in (await dispositivo.eventiTiFaro(
          calendarioId,
        )).entries) {
          esistenti[e.key] = EventoEsistente(
            eventoId: e.value,
            calendarioId: calendarioId,
            impronta: '',
          );
        }
      }

      final PianoCalendario piano = pianifica(
        voluti: voluti,
        esistenti: esistenti,
        calendarioId: calendarioId,
      );
      // Prima si toglie: un evento che passa a un altro calendario va tolto
      // dal vecchio prima di essere ricordato nel nuovo.
      for (final ({String attivitaId, int eventoId}) t in piano.daTogliere) {
        try {
          await dispositivo.togli(t.eventoId);
        } on PlatformException catch (e) {
          if (e.code == 'permesso') {
            rethrow;
          }
          // Già tolto a mano, o il suo calendario non c'è più.
        }
        await db.calendarioDao.dimentica(t.attivitaId);
      }
      for (final ({EventoVoluto evento, int eventoId}) a
          in piano.daAggiornare) {
        await _scrivi(a.evento, calendarioId, a.eventoId);
      }
      for (final EventoVoluto c in piano.daCreare) {
        await _scrivi(c, calendarioId, null);
      }

      stato.value = StatoCalendario(eventi: voluti.length);
      return true;
    } catch (errore) {
      stato.value = StatoCalendario(
        eventi: stato.value.eventi,
        messaggio: messaggioErrore(
          errore is PlatformException
              ? (errore.message ?? errore.code)
              : errore,
        ),
      );
      return false;
    } finally {
      _inCorso = false;
    }
  }

  Future<void> _scrivi(
    EventoVoluto evento,
    int calendarioId,
    int? eventoId,
  ) async {
    final int id = await dispositivo.salva(
      evento,
      calendarioId: calendarioId,
      eventoId: eventoId,
    );
    await db.calendarioDao.ricorda(
      attivitaId: evento.attivitaId,
      eventoId: id,
      calendarioId: calendarioId,
      impronta: evento.impronta,
    );
  }
}
