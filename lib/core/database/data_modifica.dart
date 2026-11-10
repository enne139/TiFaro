import 'package:drift/drift.dart';

/// La data di modifica da scrivere sulle righe di [tabella] che rispettano
/// [dove]: adesso, ma sempre almeno un secondo dopo la data che hanno già.
///
/// Serve alla sincronizzazione, dove vince la modifica più recente. Se un
/// dispositivo ha l'orologio un po' indietro, una modifica fatta dopo aver
/// ricevuto una riga risulterebbe "più vecchia" di quella riga e verrebbe
/// scartata. Così invece chi modifica dopo aver visto una versione la batte
/// sempre (DECISIONI.md, voce 021). Nel database le date stanno al secondo,
/// quindi "un secondo dopo" è il passo più piccolo.
Future<DateTime> dataDiModifica(
  DatabaseConnectionUser db,
  String tabella, {
  required String dove,
  List<Variable<Object>> variabili = const <Variable<Object>>[],
  String colonna = 'aggiornata_il',
  DateTime? adesso,
}) async {
  final DateTime ora = adesso ?? DateTime.now();
  final QueryRow riga = await db
      .customSelect(
        'SELECT MAX($colonna) AS ultima FROM $tabella WHERE $dove',
        variables: variabili,
      )
      .getSingle();
  final int? ultima = riga.read<int?>('ultima');
  if (ultima == null) {
    return ora;
  }
  final DateTime minima = DateTime.fromMillisecondsSinceEpoch(
    (ultima + 1) * 1000,
  );
  return minima.isAfter(ora) ? minima : ora;
}

/// Come [dataDiModifica], per le righe con questi [ids].
Future<DateTime> dataDiModificaPerId(
  DatabaseConnectionUser db,
  String tabella,
  Iterable<String> ids, {
  String colonna = 'aggiornata_il',
  DateTime? adesso,
}) {
  final List<String> elenco = ids.toList();
  if (elenco.isEmpty) {
    return Future<DateTime>.value(adesso ?? DateTime.now());
  }
  return dataDiModifica(
    db,
    tabella,
    dove: 'id IN (${List<String>.filled(elenco.length, '?').join(', ')})',
    variabili: <Variable<Object>>[
      for (final String id in elenco) Variable<String>(id),
    ],
    colonna: colonna,
    adesso: adesso,
  );
}
