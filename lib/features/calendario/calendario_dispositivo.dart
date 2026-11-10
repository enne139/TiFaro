import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:tifaro/features/calendario/logica/eventi.dart';

/// Un calendario del dispositivo, come lo mostra il sistema.
@immutable
class CalendarioTelefono {
  const CalendarioTelefono({
    required this.id,
    required this.nome,
    required this.account,
    required this.colore,
    required this.scrivibile,
  });

  final int id;
  final String nome;

  /// L'account a cui appartiene (per esempio l'indirizzo Google).
  final String account;

  /// Il colore del calendario, ARGB.
  final int colore;

  /// Se si possono aggiungere eventi.
  final bool scrivibile;
}

/// Il calendario del dispositivo, visto dall'app.
///
/// È un'interfaccia perché le prove usano una versione finta: il calendario
/// vero esiste solo su Android.
abstract class CalendarioDispositivo {
  /// Se su questo dispositivo c'è un calendario da usare.
  bool get disponibile;

  /// Se l'app ha già il permesso di leggere e scrivere il calendario.
  Future<bool> haPermesso();

  /// Chiede il permesso; `true` se concesso.
  Future<bool> chiediPermesso();

  /// I calendari del dispositivo.
  Future<List<CalendarioTelefono>> calendari();

  /// Gli eventi di TiFaro nel calendario [calendarioId], per id
  /// dell'attività: servono a ritrovarli dopo una reinstallazione.
  Future<Map<String, int>> eventiTiFaro(int calendarioId);

  /// Crea l'evento, o aggiorna [eventoId] se c'è ancora, e ne restituisce
  /// l'id.
  Future<int> salva(
    EventoVoluto evento, {
    required int calendarioId,
    int? eventoId,
  });

  /// Toglie l'evento [eventoId].
  Future<void> togli(int eventoId);
}

/// Il calendario di Android, attraverso il canale "tifaro/calendario" di
/// `MainActivity.kt`.
class CalendarioAndroid implements CalendarioDispositivo {
  const CalendarioAndroid();

  static const MethodChannel _canale = MethodChannel('tifaro/calendario');

  @override
  bool get disponibile => !kIsWeb && Platform.isAndroid;

  @override
  Future<bool> haPermesso() async =>
      await _canale.invokeMethod<bool>('haPermesso') ?? false;

  @override
  Future<bool> chiediPermesso() async =>
      await _canale.invokeMethod<bool>('chiediPermesso') ?? false;

  @override
  Future<List<CalendarioTelefono>> calendari() async {
    final List<Object?> righe =
        await _canale.invokeMethod<List<Object?>>('calendari') ??
        const <Object?>[];
    return righe.map((Object? r) {
      final Map<Object?, Object?> m = r! as Map<Object?, Object?>;
      return CalendarioTelefono(
        id: (m['id']! as num).toInt(),
        nome: m['nome'] as String? ?? '',
        account: m['account'] as String? ?? '',
        colore: (m['colore'] as num? ?? 0).toInt(),
        scrivibile: m['scrivibile'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<Map<String, int>> eventiTiFaro(int calendarioId) async {
    final List<Object?> righe =
        await _canale.invokeMethod<List<Object?>>(
          'eventiTiFaro',
          <String, Object?>{'calendario': calendarioId},
        ) ??
        const <Object?>[];
    final Map<String, int> eventi = <String, int>{};
    for (final Object? r in righe) {
      final Map<Object?, Object?> m = r! as Map<Object?, Object?>;
      final String segno = m['segno'] as String? ?? '';
      if (segno.startsWith(prefissoSegno)) {
        eventi[segno.substring(prefissoSegno.length)] = (m['evento']! as num)
            .toInt();
      }
    }
    return eventi;
  }

  @override
  Future<int> salva(
    EventoVoluto evento, {
    required int calendarioId,
    int? eventoId,
  }) async {
    final num? id = await _canale.invokeMethod<num>(
      'salvaEvento',
      <String, Object?>{
        'calendario': calendarioId,
        'evento': eventoId,
        'titolo': evento.titolo,
        'descrizione': evento.descrizione,
        'inizio': evento.inizio,
        'fine': evento.fine,
        'tuttoIlGiorno': evento.tuttoIlGiorno,
        'chiaveColore': evento.chiaveColore,
        'colore': evento.colore,
        'segno': evento.segno,
      },
    );
    if (id == null) {
      throw Exception('Il calendario non ha restituito l\'evento.');
    }
    return id.toInt();
  }

  @override
  Future<void> togli(int eventoId) => _canale.invokeMethod<bool>(
    'eliminaEvento',
    <String, Object?>{'evento': eventoId},
  );
}
