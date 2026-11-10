import 'package:flutter/material.dart';

import 'package:tifaro/core/aspetto.dart';
import 'package:tifaro/core/dati_app.dart';
import 'package:tifaro/core/database/app_database.dart';
import 'package:tifaro/core/date.dart';
import 'package:tifaro/features/attivita/azioni.dart';
import 'package:tifaro/features/attivita/logica/viste.dart';

/// Una riga di un elenco di attività: casella per segnarla fatta, titolo e,
/// sotto, le informazioni utili (percorso, scadenza, tipologia, avanzamento).
///
/// Toccandola si apre il dettaglio.
class RigaAttivita extends StatelessWidget {
  const RigaAttivita({
    required this.attivita,
    this.rientro = 0,
    this.mostraPercorso = true,
    this.mostraArgomento = false,
    this.espansa,
    this.onEspandi,
    this.azioni,
    super.key,
  });

  final Attivita attivita;

  /// Livello nell'albero: sposta la riga a destra.
  final int rientro;

  /// Se mostrare le attività sopra di lei ("Cena › Ristorante"): serve negli
  /// elenchi piatti, non negli alberi.
  final bool mostraPercorso;

  /// Se mostrare l'argomento: serve negli elenchi che li mescolano.
  final bool mostraArgomento;

  /// Se le sotto-attività sono aperte; conta solo con [onEspandi].
  final bool? espansa;

  /// Se c'è, compare il pulsante per aprire o chiudere le sotto-attività.
  final VoidCallback? onEspandi;

  /// Pulsanti in più in fondo alla riga, per esempio un menu.
  final Widget? azioni;

  @override
  Widget build(BuildContext context) {
    final DatiApp dati = DatiApp.of(context);
    final ThemeData tema = Theme.of(context);
    final DateTime adesso = DateTime.now();
    final bool fatta = attivita.fattaIl != null;
    final List<Widget> info = <Widget>[];

    if (mostraPercorso) {
      final List<Attivita> percorso = dati.indice.percorso(attivita);
      if (percorso.isNotEmpty) {
        info.add(
          _Info(
            icona: Icons.subdirectory_arrow_right,
            testo: percorso.map((Attivita a) => a.titolo).join(' › '),
          ),
        );
      }
    }
    final Argomento? argomento = dati.argomentiPerId[attivita.argomentoId];
    if (mostraArgomento && argomento != null) {
      info.add(
        _Info(
          icona: icona(argomento.icona),
          testo: argomento.nome,
          colore: coloreArgomento(argomento.colore).colore,
        ),
      );
    }
    final DateTime? scadenza = attivita.scadenza;
    if (scadenza != null) {
      info.add(
        _Info(
          icona: Icons.event,
          testo: formatoScadenza(scadenza, attivita.scadenzaConOra, adesso),
          colore: scaduta(attivita, adesso) ? tema.colorScheme.error : null,
        ),
      );
    }
    final Tipologia? tipologia = dati.tipologiePerId[attivita.tipologiaId];
    if (tipologia != null) {
      info.add(_Info(icona: icona(tipologia.icona), testo: tipologia.nome));
    }
    final ({int fatte, int totali}) avanzamento = dati.indice.avanzamento(
      attivita.id,
    );
    if (avanzamento.totali > 0) {
      info.add(
        _Info(
          icona: Icons.checklist,
          testo: '${avanzamento.fatte}/${avanzamento.totali}',
        ),
      );
    }
    final int foto = dati.fotoPerAttivita[attivita.id]?.length ?? 0;
    if (foto > 0) {
      info.add(_Info(icona: Icons.photo_outlined, testo: '$foto'));
    }
    if (attivita.nelCalendario) {
      info.add(const _Info(icona: Icons.calendar_month_outlined));
    }
    if (attivita.descrizione.isNotEmpty) {
      info.add(const _Info(icona: Icons.notes));
    }

    return ListTile(
      contentPadding: EdgeInsetsDirectional.only(
        start: 4.0 + rientro * 24,
        end: 4,
      ),
      leading: Checkbox(
        value: fatta,
        onChanged: (bool? valore) =>
            cambiaFatta(context, attivita, valore ?? false),
      ),
      title: Text(
        attivita.titolo,
        style: fatta
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: tema.colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      subtitle: info.isEmpty
          ? null
          : Wrap(spacing: 12, runSpacing: 2, children: info),
      trailing: onEspandi == null && azioni == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (onEspandi != null)
                  IconButton(
                    icon: Icon(
                      espansa == true ? Icons.expand_less : Icons.expand_more,
                    ),
                    tooltip: espansa == true
                        ? 'Nascondi le sotto-attività'
                        : 'Mostra le sotto-attività',
                    onPressed: onEspandi,
                  ),
                ?azioni,
              ],
            ),
      onTap: () => apriDettaglio(context, attivita.id),
    );
  }
}

/// Un'informazione piccola sotto il titolo: icona ed eventuale testo.
class _Info extends StatelessWidget {
  const _Info({required this.icona, this.testo, this.colore});

  final IconData icona;
  final String? testo;
  final Color? colore;

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = Theme.of(context);
    final Color c = colore ?? tema.colorScheme.onSurfaceVariant;
    final String? t = testo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icona, size: 14, color: c),
        if (t != null) ...<Widget>[
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              t,
              overflow: TextOverflow.ellipsis,
              style: tema.textTheme.bodySmall?.copyWith(color: c),
            ),
          ),
        ],
      ],
    );
  }
}
