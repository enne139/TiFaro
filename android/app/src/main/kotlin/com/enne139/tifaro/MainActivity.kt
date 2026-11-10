package com.enne139.tifaro

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

/**
 * L'attività di TiFaro. Oltre a quello che fa la standard di Flutter, offre
 * all'app il calendario del telefono sul canale "tifaro/calendario": elenco
 * dei calendari, eventi creati, aggiornati e tolti (DECISIONI.md, voce 027).
 *
 * Gli eventi si scrivono nel calendario scelto; se è quello di un account
 * Google, è Android a portarli su Google Calendar.
 */
class MainActivity : FlutterActivity() {
    /** La risposta in attesa della finestra dei permessi. */
    private var permessoInAttesa: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tifaro/calendario")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "haPermesso" -> result.success(haPermesso())
                        "chiediPermesso" -> chiediPermesso(result)
                        "calendari" -> result.success(calendari())
                        "eventiTiFaro" -> result.success(eventiTiFaro(numero(call, "calendario")))
                        "salvaEvento" -> result.success(salvaEvento(call))
                        "eliminaEvento" -> result.success(eliminaEvento(numero(call, "evento")))
                        else -> result.notImplemented()
                    }
                } catch (e: SecurityException) {
                    result.error("permesso", "Manca il permesso del calendario.", null)
                } catch (e: Exception) {
                    result.error("calendario", e.message ?: e.toString(), null)
                }
            }
    }

    /** Un numero obbligatorio fra gli argomenti; da Dart arriva Int o Long. */
    private fun numero(call: MethodCall, nome: String): Long =
        call.argument<Number>(nome)?.toLong()
            ?: throw IllegalArgumentException("Manca $nome")

    private fun haPermesso(): Boolean =
        checkSelfPermission(Manifest.permission.READ_CALENDAR) == PackageManager.PERMISSION_GRANTED &&
            checkSelfPermission(Manifest.permission.WRITE_CALENDAR) == PackageManager.PERMISSION_GRANTED

    /** Chiede i permessi e risponde quando l'utente ha scelto. */
    private fun chiediPermesso(result: MethodChannel.Result) {
        if (haPermesso()) {
            result.success(true)
            return
        }
        // Una richiesta già in corso si chiude come negata: ne vale una.
        permessoInAttesa?.success(false)
        permessoInAttesa = result
        requestPermissions(
            arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR),
            CODICE_PERMESSO,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CODICE_PERMESSO) {
            permessoInAttesa?.success(haPermesso())
            permessoInAttesa = null
        }
    }

    /** I calendari del telefono, con quello che serve per sceglierne uno. */
    private fun calendari(): List<Map<String, Any?>> {
        val colonne = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.CALENDAR_COLOR,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
        )
        val elenco = mutableListOf<Map<String, Any?>>()
        contentResolver.query(CalendarContract.Calendars.CONTENT_URI, colonne, null, null, null)
            ?.use { c ->
                while (c.moveToNext()) {
                    elenco.add(
                        mapOf(
                            "id" to c.getLong(0),
                            "nome" to c.getString(1),
                            "account" to c.getString(2),
                            "colore" to c.getInt(3),
                            "scrivibile" to
                                (c.getInt(4) >= CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR),
                        ),
                    )
                }
            }
        return elenco
    }

    /**
     * Gli eventi di TiFaro nel calendario: id dell'evento e segno
     * (tifaro://attivita/<id>). Servono a ritrovarli dopo una
     * reinstallazione, invece di crearne dei doppioni.
     */
    private fun eventiTiFaro(calendario: Long): List<Map<String, Any?>> {
        val colonne = arrayOf(CalendarContract.Events._ID, CalendarContract.Events.CUSTOM_APP_URI)
        val dove = "${CalendarContract.Events.CALENDAR_ID} = ? AND " +
            "${CalendarContract.Events.DELETED} = 0 AND " +
            "${CalendarContract.Events.CUSTOM_APP_URI} LIKE ?"
        val elenco = mutableListOf<Map<String, Any?>>()
        contentResolver.query(
            CalendarContract.Events.CONTENT_URI,
            colonne,
            dove,
            arrayOf(calendario.toString(), "$PREFISSO_SEGNO%"),
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                elenco.add(mapOf("evento" to c.getLong(0), "segno" to c.getString(1)))
            }
        }
        return elenco
    }

    /** Se l'evento c'è ancora in quel calendario e non è stato tolto. */
    private fun eventoEsiste(evento: Long, calendario: Long): Boolean {
        val dove = "${CalendarContract.Events._ID} = ? AND " +
            "${CalendarContract.Events.CALENDAR_ID} = ? AND " +
            "${CalendarContract.Events.DELETED} = 0"
        contentResolver.query(
            CalendarContract.Events.CONTENT_URI,
            arrayOf(CalendarContract.Events._ID),
            dove,
            arrayOf(evento.toString(), calendario.toString()),
            null,
        )?.use { c -> return c.count > 0 }
        return false
    }

    /**
     * Crea o aggiorna un evento e ne restituisce l'id.
     *
     * Se l'evento da aggiornare non c'è più (tolto a mano dal calendario) se
     * ne crea uno nuovo: l'attività è ancora "nel calendario".
     */
    private fun salvaEvento(call: MethodCall): Long {
        val calendario = numero(call, "calendario")
        val evento = call.argument<Number>("evento")?.toLong()
        val tuttoIlGiorno = call.argument<Boolean>("tuttoIlGiorno") ?: false
        val valori = ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, calendario)
            put(CalendarContract.Events.TITLE, call.argument<String>("titolo"))
            put(CalendarContract.Events.DESCRIPTION, call.argument<String>("descrizione"))
            put(CalendarContract.Events.DTSTART, numero(call, "inizio"))
            put(CalendarContract.Events.DTEND, numero(call, "fine"))
            put(CalendarContract.Events.ALL_DAY, if (tuttoIlGiorno) 1 else 0)
            // Android vuole gli eventi di tutto il giorno in UTC, a mezzanotte.
            put(
                CalendarContract.Events.EVENT_TIMEZONE,
                if (tuttoIlGiorno) "UTC" else TimeZone.getDefault().id,
            )
            put(CalendarContract.Events.CUSTOM_APP_PACKAGE, packageName)
            put(CalendarContract.Events.CUSTOM_APP_URI, call.argument<String>("segno"))
        }
        coloreEvento(
            valori,
            calendario,
            call.argument<String>("chiaveColore"),
            call.argument<Number>("colore")?.toInt(),
        )

        if (evento != null && eventoEsiste(evento, calendario)) {
            contentResolver.update(
                ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, evento),
                valori,
                null,
                null,
            )
            return evento
        }
        val nuovo = contentResolver.insert(CalendarContract.Events.CONTENT_URI, valori)
            ?: throw IllegalStateException("Il calendario non ha accettato l'evento.")
        return ContentUris.parseId(nuovo)
    }

    /**
     * Il colore dell'evento: la chiave dei colori di Google (gli stessi degli
     * argomenti, DECISIONI.md voce 008) se l'account del calendario la
     * conosce, altrimenti il colore così com'è.
     */
    private fun coloreEvento(valori: ContentValues, calendario: Long, chiave: String?, colore: Int?) {
        if (chiave != null) {
            var nomeAccount: String? = null
            var tipoAccount: String? = null
            contentResolver.query(
                ContentUris.withAppendedId(CalendarContract.Calendars.CONTENT_URI, calendario),
                arrayOf(CalendarContract.Calendars.ACCOUNT_NAME, CalendarContract.Calendars.ACCOUNT_TYPE),
                null,
                null,
                null,
            )?.use { c ->
                if (c.moveToFirst()) {
                    nomeAccount = c.getString(0)
                    tipoAccount = c.getString(1)
                }
            }
            val account = nomeAccount
            val tipo = tipoAccount
            if (account != null && tipo != null) {
                val dove = "${CalendarContract.Colors.ACCOUNT_NAME} = ? AND " +
                    "${CalendarContract.Colors.ACCOUNT_TYPE} = ? AND " +
                    "${CalendarContract.Colors.COLOR_TYPE} = ? AND " +
                    "${CalendarContract.Colors.COLOR_KEY} = ?"
                val conosciuta = contentResolver.query(
                    CalendarContract.Colors.CONTENT_URI,
                    arrayOf(CalendarContract.Colors.COLOR_KEY),
                    dove,
                    arrayOf(account, tipo, CalendarContract.Colors.TYPE_EVENT.toString(), chiave),
                    null,
                )?.use { c -> c.count > 0 } ?: false
                if (conosciuta) {
                    valori.put(CalendarContract.Events.EVENT_COLOR_KEY, chiave)
                    return
                }
            }
        }
        if (colore != null) {
            valori.put(CalendarContract.Events.EVENT_COLOR, colore)
        }
    }

    /** Toglie un evento. Restituisce false se non c'era già più. */
    private fun eliminaEvento(evento: Long): Boolean =
        contentResolver.delete(
            ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, evento),
            null,
            null,
        ) > 0

    private companion object {
        const val CODICE_PERMESSO = 4807

        /** Il segno sugli eventi di TiFaro, seguito dall'id dell'attività. */
        const val PREFISSO_SEGNO = "tifaro://attivita/"
    }
}
