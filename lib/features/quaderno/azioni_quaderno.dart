/// Le azioni sul Quaderno che si fanno da più schermate: mettere
/// un'attività in una pagina, toglierla, scegliere dove metterla dal
/// dettaglio (DECISIONI.md, voce 038).
library;

import 'package:flutter/material.dart';

import 'package:tifaro/core/app_scope.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/core/errori.dart';
import 'package:tifaro/features/quaderno/logica/pagina.dart';

/// Mette l'attività [id] nella pagina di [pagina], fra le veloci se
/// [veloce], dopo aver controllato che fra le cose principali ci sia ancora
/// posto. Restituisce `true` se è andata.
Future<bool> spostaNelQuaderno(
  BuildContext context,
  String id,
  DateTime pagina, {
  required bool veloce,
}) {
  final DateTime adesso = DateTime.now();
  final PaginaQuaderno arrivo = paginaDelGiorno(
    DatiApp.leggi(context).indice,
    pagina,
    adesso,
  );
  final String quando = switch (giorniFra(adesso, pagina)) {
    0 => 'Oggi',
    1 => 'Domani',
    _ => 'Quel giorno',
  };
  final AppDatabase db = AppScope.db(context);
  return eseguiSegnalandoErrori(context, () async {
    if (!veloce && !haPosto(arrivo, id)) {
      throw Exception(
        '$quando ci sono già $cosePerGiorno cose: prima togline una.',
      );
    }
    await db.attivitaDao.mettiNelQuaderno(id, pagina, veloce: veloce);
  });
}

/// Toglie l'attività [id] dal Quaderno: resta fra le cose da fare.
Future<bool> togliDalQuaderno(BuildContext context, String id) {
  final AppDatabase db = AppScope.db(context);
  return eseguiSegnalandoErrori(
    context,
    () => db.attivitaDao.togliDalQuaderno(id),
  );
}

/// Se fra le cose principali di [pagina] c'è posto per l'attività [id]:
/// c'è se non è piena, o se lei è già una di quelle.
bool haPosto(PaginaQuaderno pagina, String id) =>
    !pagina.piena || pagina.principali.any((Attivita a) => a.id == id);

/// Fa scegliere dove mettere [attivita] nel Quaderno: oggi o domani, fra
/// le cose principali o fra le veloci; oppure toglierla, se c'è già.
Future<void> scegliQuaderno(BuildContext context, Attivita attivita) async {
  final ({DateTime? pagina, bool veloce})? scelta =
      await showModalBottomSheet<({DateTime? pagina, bool veloce})>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (BuildContext context) => _SceltaQuaderno(attivita: attivita),
      );
  if (scelta == null || !context.mounted) {
    return;
  }
  final DateTime? pagina = scelta.pagina;
  if (pagina == null) {
    await togliDalQuaderno(context, attivita.id);
  } else {
    await spostaNelQuaderno(
      context,
      attivita.id,
      pagina,
      veloce: scelta.veloce,
    );
  }
}

/// Il foglio con le pagine del Quaderno dove mettere un'attività. Si
/// chiude con la scelta: una pagina e se fra le veloci, o la pagina nulla
/// per toglierla.
class _SceltaQuaderno extends StatelessWidget {
  const _SceltaQuaderno({required this.attivita});

  final Attivita attivita;

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final DateTime adesso = DateTime.now();
    final DateTime oggi = giorno(adesso);
    final DateTime domani = DateTime(oggi.year, oggi.month, oggi.day + 1);
    final DateTime? giornoAttuale = attivita.giornoQuaderno;
    final bool eraVeloce = attivita.quadernoVeloce == true;

    // Una voce del foglio: la pagina di [pagina], fra le veloci o no.
    Widget voce(DateTime pagina, String nome, {required bool veloce}) {
      final bool attuale =
          giornoAttuale != null &&
          giorniFra(giornoAttuale, pagina) == 0 &&
          eraVeloce == veloce;
      // Fra le cose principali una pagina piena non si sceglie: meglio
      // dirlo qui che con un errore dopo.
      final bool piena =
          !veloce &&
          !haPosto(paginaDelGiorno(dati.indice, pagina, adesso), attivita.id);
      return ListTile(
        leading: Icon(veloce ? Icons.bolt : Icons.flag_outlined),
        title: Text(
          veloce ? '$nome, fra le veloci' : '$nome, fra le $cosePerGiorno cose',
        ),
        subtitle: piena
            ? Text('Ci sono già $cosePerGiorno cose: prima togline una')
            : null,
        trailing: attuale ? const Icon(Icons.check) : null,
        enabled: !piena && !attuale,
        onTap: () => Navigator.pop(context, (pagina: pagina, veloce: veloce)),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('Nel Quaderno', style: tema.textTheme.titleMedium),
        ),
        voce(oggi, 'Oggi', veloce: false),
        voce(oggi, 'Oggi', veloce: true),
        voce(domani, 'Domani', veloce: false),
        voce(domani, 'Domani', veloce: true),
        if (giornoAttuale != null)
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Togli dal Quaderno'),
            onTap: () => Navigator.pop(context, (pagina: null, veloce: false)),
          ),
      ],
    );
  }
}
