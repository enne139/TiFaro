# Registro delle decisioni

Ogni scelta di progettazione, con la motivazione. Le voci si aggiungono in
fondo e non si riscrivono: se una decisione cambia, si aggiunge una voce nuova
che dichiara quale supera.

Formato: numero, data, contesto, decisione, motivazione, alternative scartate.

---

## 001 — App Flutter con un server Go, in cinque fasi

**Data:** 2026-11-10

**Contesto:** serve un programma per le cose da fare con sotto-attività
annidate, modelli, argomenti, tipologie, scadenze, foto e Google Calendar, da
usare sia dal telefono sia dal PC.

**Decisione:** app Flutter (Android e Linux) che funziona da sola; più avanti
un server Go sul NAS per sincronizzare i dispositivi e parlare con Google. Si
procede per fasi: 1) app da sola, 2) modelli, 3) server e sincronizzazione,
4) Google Calendar, 5) notifiche e release.

**Motivazione:** scelta fra tre proposte (web app con bot
Telegram, app Flutter con server, PWA senza server). Flutter è lo strumento
già usato per Spesone e AmbuTurni; il server serve comunque per avere gli
stessi dati su telefono e PC. Con le fasi, l'app è usabile già dalla prima.

**Alternative scartate:** web app sul NAS con bot Telegram (meno rifinita sul
telefono); PWA senza server (niente sincronizzazione né calendario).

---

## 002 — Cattura veloce senza AI

**Data:** 2026-11-10

**Contesto:** si vuole creare un'attività al volo da un testo o da una foto.

**Decisione:** nessuna AI. Il testo segue una sintassi veloce (voce 010); le
foto vengono allegate così come sono. Il tasto Condividi di Android porta
nell'app foto e testi delle altre app.

**Motivazione:** scelta presa all'avvio del progetto. Funziona offline, subito e senza costi; la
lettura delle foto con Ollama resta un'idea per dopo.

**Alternative scartate:** Ollama sul G14 con una coda (funziona solo a PC
acceso); Claude API (a pagamento, le foto escono di casa).

---

## 003 — Righe mai cancellate e data di modifica su tutto

**Data:** 2026-11-10

**Contesto:** con la fase 3 i dati andranno sincronizzati fra dispositivi.

**Decisione:** ogni tabella ha `aggiornataIl` (aggiornata a ogni scrittura) e
`cancellataIl`. Togliere vuol dire scrivere la data in `cancellataIl`; la
riga resta.

**Motivazione:** la sincronizzazione dovrà sapere cosa è cambiato dall'ultima
volta, cancellazioni comprese: una riga sparita non si può comunicare agli
altri dispositivi. Le stesse colonne fanno anche da cestino. Metterle subito
evita una migrazione di tutte le tabelle più avanti.

**Alternative scartate:** cancellare davvero e tenere un registro a parte
delle cancellazioni (due posti da tenere allineati).

---

## 004 — UUID, ma id fissi per argomenti e tipologie del primo avvio

**Data:** 2026-11-10

**Contesto:** gli id devono essere unici anche fra dispositivi diversi.

**Decisione:** ogni riga nuova ha un UUID. Gli argomenti (Lavoro, Personale,
Ambulanza) e le tipologie (Telefonata, Acquisto, Burocrazia) creati al primo
avvio hanno id fissi (`argomento-lavoro`, `tipologia-telefonata`…).

**Motivazione:** con id numerici progressivi due dispositivi darebbero lo
stesso numero a cose diverse. Con UUID anche per le righe di partenza,
telefono e PC avrebbero due "Lavoro" diversi da fondere alla prima
sincronizzazione; con id fissi sono già la stessa riga.

**Alternative scartate:** id numerici; UUID anche per le righe di partenza.

---

## 005 — Albero con il rimando al genitore; argomento ripetuto su ogni riga

**Data:** 2026-11-10

**Contesto:** le attività hanno sotto-attività a qualunque profondità, e
appartengono a un argomento.

**Decisione:** ogni attività ha `genitoreId` (nullo per le principali). Le
sotto-attività hanno sempre l'argomento della principale, scritto anche sulla
loro riga; cambiarlo dalla principale lo cambia a tutto il sottoalbero
(`cambiaArgomento`). La tipologia invece è di ogni riga.

**Motivazione:** il rimando al genitore è la forma più semplice, e SQLite sa
scorrere un sottoalbero con `WITH RECURSIVE` quando serve. Ripetere
l'argomento permette di filtrare per argomento senza risalire l'albero. La
tipologia resta libera perché è proprio il suo scopo: la "Telefonata" dentro
"Organizzare la cena" deve comparire con le altre telefonate.

**Alternative scartate:** percorsi materializzati o insiemi annidati (più
complicati da spostare e sincronizzare); argomento solo sulla principale
(ogni filtro dovrebbe risalire l'albero).

---

## 006 — Cestino a gruppi: stesso istante sul sottoalbero

**Data:** 2026-11-10

**Contesto:** cestinare un'attività deve portarsi dietro le sotto-attività, e
il ripristino deve riportare indietro esattamente quelle.

**Decisione:** `spostaNelCestino` scrive lo stesso istante (al secondo) su
tutte le righe del sottoalbero non ancora cestinate. `ripristina` riporta
indietro le righe del sottoalbero con quell'istante, più gli antenati
cestinati (solo loro), perché l'attività ripristinata abbia dove stare. Il
cestino mostra solo chi ha iniziato un gruppo.

**Motivazione:** così una sotto-attività cestinata prima, da sola, resta nel
cestino quando si ripristina il genitore, come ci si aspetta. Non serve una
colonna in più: basta l'istante.

**Alternative scartate:** un id di "gruppo di cancellazione" (una colonna in
più per la stessa informazione); ripristinare sempre tutto il sottoalbero
(farebbe tornare cose tolte apposta).

---

## 007 — Foto come file nella cartella dell'app

**Data:** 2026-11-10

**Contesto:** le attività possono avere foto, anche più d'una.

**Decisione:** la foto viene copiata (non spostata) in `foto/` nella cartella
dei dati dell'app, con un nome UUID; nel database c'è solo il nome del file.
Le foto si riducono a 2000 pixel di lato e qualità 85 già quando si
scattano o si scelgono. Togliendo una foto il file resta.

**Motivazione:** un database con dentro le immagini diventa enorme e lento da
copiare; da file, nella fase 3 si potranno mandare al server una per una. Si
copia perché le foto condivise o scelte stanno in cartelle temporanee che il
sistema svuota quando vuole. Il file resta perché la sincronizzazione dovrà
ancora sapere della foto tolta; la pulizia verrà con la fase 3.

**Alternative scartate:** foto nel database come BLOB; tenere il percorso
originale.

---

## 008 — I colori degli argomenti sono quelli di Google Calendar

**Data:** 2026-11-10

**Contesto:** ogni argomento ha un colore, e gli eventi su Google Calendar
(fase 4) dovranno averne uno.

**Decisione:** la tavolozza (`paletteArgomenti`) è fatta degli undici colori
degli eventi di Google Calendar, ognuno con il suo `colorId`. Nel database si
salva l'indice nella tavolozza.

**Motivazione:** così un'attività ha lo stesso colore nell'app e nel
calendario senza conversioni approssimate. Salvando l'indice e non il colore,
la tavolozza si può ritoccare senza toccare i dati.

**Alternative scartate:** colori liberi (in Google Calendar andrebbero
arrotondati al più vicino degli undici).

---

## 009 — "Nel calendario" si segna già, gli eventi arrivano con il server

**Data:** 2026-11-10

**Contesto:** gli eventi su Google Calendar li creerà il server (fase 4), ma
si vuole poter decidere già ora quali attività ci vanno.

**Decisione:** c'è già la colonna `nelCalendario`, che si imposta con `!cal`
o dal dettaglio; il dettaglio avvisa che l'evento arriverà con il server.

**Motivazione:** le attività segnate adesso finiranno nel calendario appena
il server ci sarà, senza doverle ripassare. Gli eventi li crea il server, e
non l'app, perché così funziona da qualunque dispositivo e un solo posto sa
quale evento corrisponde a quale attività; l'accesso sarà con un account di
servizio Google, che non scade come i login OAuth in modalità di prova.

**Alternative scartate:** scrivere nel calendario del telefono con un plugin
(funzionerebbe solo da Android, non dal PC).

---

## 010 — Sintassi della cattura veloce

**Data:** 2026-11-10

**Contesto:** senza AI, la riga della cattura veloce deve bastare a compilare
i campi principali, scritta di corsa sul telefono.

**Decisione:** `#etichetta` è l'argomento, `@etichetta` la tipologia, `!cal`
il calendario; date (`oggi`, `domani`, `dopodomani`, i giorni della settimana
per intero, `15/11`, `15/11/27`, `tra N giorni/settimane/mesi`) e ore
(`18:00`, `alle 18`) la scadenza. Le parole di collegamento subito prima di
una data ("entro il", "per", "alle") si tolgono dal titolo. Le etichette si
abbinano ignorando maiuscole e accenti, poi a meno dell'ultima vocale
(`@acquisti` → "Acquisto"), poi per inizio del nome se è uno solo e lungo
almeno tre lettere (`#amb` → "Ambulanza"). Un'etichetta che non corrisponde a
niente crea un argomento o una tipologia nuovi. L'anteprima sotto la riga
mostra cosa è stato capito prima di salvare.

Regole sulle date: un giorno della settimana è sempre il prossimo, mai oggi
(per oggi c'è "oggi"); una data senza anno già passata è dell'anno prossimo;
un'ora senza giorno è oggi, o domani se è già passata.

**Motivazione:** sono le cose che si scrivono davvero in fretta. I giorni
abbreviati sono esclusi perché darebbero falsi allarmi ("chiamare Gio"). Le
ore vogliono i due punti perché "18.30" si confonderebbe con una data.
L'abbinamento tollerante evita doppioni come "Acquisto" e "Acquisti";
l'anteprima rende visibile ogni errore.

**Alternative scartate:** campi separati da compilare (lenti sul telefono);
un'etichetta sconosciuta lasciata nel titolo (si perderebbe l'intenzione).

---

## 011 — Un argomento usato non si toglie, una tipologia sì

**Data:** 2026-11-10

**Contesto:** togliere un argomento o una tipologia che qualcuno usa.

**Decisione:** un argomento si toglie solo se nessuna attività lo usa
(cestino compreso) e se non è il predefinito. Una tipologia si toglie sempre:
le attività che l'avevano restano senza.

**Motivazione:** l'argomento è obbligatorio, quindi toglierlo lascerebbe
attività senza posto; la tipologia è facoltativa.

**Alternative scartate:** spostare d'ufficio le attività nel predefinito
(sorpresa sgradita).

---

## 012 — Tutte le attività in memoria, viste calcolate in Dart

**Data:** 2026-11-10

**Contesto:** ogni schermata guarda le stesse attività da un'angolazione
diversa (per scadenza, per argomento ad albero, per tipologia, ricerca).

**Decisione:** una sola lettura per tutta l'app (`FonteDati`, sopra il
`Navigator`) tiene attività, argomenti, tipologie e foto; a ogni cambiamento
si ricostruisce l'`IndiceAttivita` e le schermate filtrano in Dart con
funzioni pure (`logica/viste.dart`).

**Motivazione:** per un uso personale, qualche migliaio di attività in
memoria non pesa e si ricalcola in un istante. Tutta la logica delle viste è
Dart puro, facile da provare senza database. Una lettura unica evita stream
che aspettano altri stream, che in Spesone avevano causato attese infinite.

**Alternative scartate:** una query SQL per ogni schermata (logica sparsa fra
SQL e Dart, più difficile da provare).

**Da rivedere quando:** le attività diventano decine di migliaia.

---

## 013 — Principali in ordine di scadenza, sotto-attività in ordine scelto

**Data:** 2026-11-10

**Contesto:** in che ordine mostrare le attività dell'albero.

**Decisione:** le attività principali di un argomento sono ordinate per
scadenza (prima le più vicine, poi quelle senza, nell'ordine di creazione).
Le sotto-attività seguono l'ordine scelto a mano, con "Sposta su/giù".

**Motivazione:** le principali sono tante e scollegate: conta cosa scade
prima. Le sotto-attività sono spesso passaggi in sequenza, e lì l'ordine lo
decide chi le scrive. Spostare a mano le principali avrebbe poco senso:
condividono la posizione con quelle degli altri argomenti.

**Alternative scartate:** ordine a mano anche per le principali.

---

## 014 — Ogni gesto ha un pulsante

**Data:** 2026-11-10

**Contesto:** l'app gira sul telefono e sul computer.

**Decisione:** nessuna azione esiste solo come gesto (trascinare, tenere
premuto, scorrere di lato): riordinare le sotto-attività, cestinare,
togliere una foto hanno sempre una voce di menu o un pulsante.

**Motivazione:** sul computer i gesti del telefono non ci sono o non si
scoprono. Stessa regola di Spesone.

**Alternative scartate:** trascinamento per riordinare (comodo sul telefono,
ma da solo non basta).

---

## 015 — Migrazioni verificate con le fotografie dello schema

**Data:** 2026-11-10

**Contesto:** con i modelli il database passa alla versione 2, la prima
migrazione vera. Una migrazione sbagliata rende l'app installata
impossibile da aprire.

**Decisione:** si usa `drift_dev make-migrations` (configurato in
`build.yaml`): ogni versione dello schema è fotografata in `drift_schemas/`,
la migrazione si scrive a passi con `stepByStep` e `test/drift/` verifica che
da ogni versione vecchia si arrivi esattamente allo schema nuovo, dati
compresi.

**Motivazione:** è il modo che drift stesso consiglia, e trasforma un errore
che si scoprirebbe sul telefono in una prova che fallisce sul PC. I passi
generati usano lo schema di quella versione, non quello di oggi, quindi non
si rompono quando le tabelle cambiano ancora.

**Alternative scartate:** migrazioni scritte a mano e provate installando
la versione vecchia (lento, e facile da saltare).

---

## 016 — Il modello fa da attività principale; le voci sono le sotto-attività

**Data:** 2026-11-10

**Contesto:** come tenere un modello, che è un'attività con il suo albero di
sotto-attività.

**Decisione:** due tabelle nuove. `modelli` tiene i campi dell'attività
principale (il nome è anche il titolo, più descrizione, argomento,
tipologia, scadenza relativa, calendario); `voci_modello` tiene le
sotto-attività ad albero, con il rimando al genitore come le attività.
L'argomento del modello è facoltativo: senza, vale quello della cattura.
L'attività creata ricorda il modello da cui è nata (`modelloId`), solo sulla
principale.

**Motivazione:** tenere i modelli nella tabella delle attività con un
segnalino avrebbe costretto ogni lettura a escluderli, e una dimenticanza li
farebbe comparire fra le cose da fare. Un nome che fa anche da titolo evita
due campi quasi uguali. Le stesse colonne `aggiornataIl` e `cancellataIl`
delle altre tabelle li preparano alla sincronizzazione (voce 003).

**Alternative scartate:** modelli come attività con un segnalino; una riga
"radice" fra le voci, doppione della riga del modello.

---

## 017 — Scadenze relative: la principale dalla creazione, le altre dalla principale

**Data:** 2026-11-10

**Contesto:** un modello non può avere date vere: le scadenze devono
spostarsi con il giorno in cui lo si usa.

**Decisione:** ogni scadenza è un numero di giorni più un'ora facoltativa
(minuti dalla mezzanotte). Per la principale i giorni si contano dal giorno
della creazione (da 0 in su). Per le sotto-attività si contano dalla
scadenza finale della principale, anche negativi ("1 giorno prima"); se la
principale non ha scadenza, dal giorno della creazione. Se nella cattura si
sceglie un'altra scadenza per la principale, le sotto-attività si spostano
con lei. «Salva come modello» fa il contrario: le date diventano giorni
rispetto alla creazione della principale e alla sua scadenza; lo stato
fatto/da fare e le attività nel cestino non si copiano. Nell'editor si
scrivono con `+2` e `-1`, solo lì: nella cattura veloce un numero di
telefono come `+39` diventerebbe una data.

**Motivazione:** il caso tipico è un evento con dei preparativi prima (il
turno sabato, la divisa da controllare il giorno prima): contare dalla
scadenza della principale è quello che si ha in testa, e scegliendo un altro
sabato tutto si sposta da solo.

**Alternative scartate:** tutte le scadenze dalla creazione (spostando il
turno, i preparativi resterebbero dove sono); date fisse.

---

## 018 — Menu delle scelte nella cattura: il menu vince sul testo, il testo sul modello

**Data:** 2026-11-10

**Contesto:** oltre alla riga con la sintassi veloce si vuole poter
scegliere i dati da un menu, senza scriverli.

**Decisione:** una freccia accanto alla riga apre un menu con modello,
argomento, tipologia, scadenza (con scorciatoie: oggi, domani, dopodomani,
fra una settimana, una data, nessuna), ora e calendario. Le scelte del menu
stanno a parte dal testo: il testo non viene riscritto. Per ogni campo vince
il primo che c'è fra menu, testo, modello e valore predefinito; "nessuna"
scelta dal menu toglie anche quello scritto. Accanto a ogni scelta fatta dal
menu c'è la crocetta per tornare a quello scritto. Le regole stanno in una
funzione pura (`componiCattura`), e le etichette sotto la riga mostrano
sempre il risultato finale. Le finestre di scelta sono le stesse del
dettaglio e dell'editor dei modelli (`selettori.dart`).

**Motivazione:** il menu è un gesto deliberato, fatto dopo aver scritto:
deve valere di più. Non riscrivere il testo evita che la riga si riempia di
`#` e `@` mai scritti. Con una funzione pura le regole si provano una per
una.

**Alternative scartate:** scrivere nella riga le etichette scelte dal menu
(una sola fonte di verità, ma la riga diventa illeggibile e i nomi con gli
spazi vanno trasformati); il testo che vince sul menu (la scelta appena fatta
sembrerebbe ignorata).

---

## 019 — Server generico: righe in JSON, revisioni, vince la più recente

**Data:** 2026-11-10

**Contesto:** telefono e PC devono vedere le stesse attività; il server sta
sul NAS.

**Decisione:** il server Go tiene una sola tabella di righe: tabella, id,
dati (il JSON di `toJson()` dell'app, mai riscritto), data di modifica,
revisione, dispositivo. Ogni riga salvata prende una revisione più alta di
tutte; l'app chiede "tutto dopo la revisione N" a pagine. Una riga entra se
è nuova o se la sua data di modifica non è più vecchia di quella che c'è (a
parità entra); altrimenti è rifiutata e il server restituisce la sua
versione. Se l'app conosce una revisione più alta della massima del server
(server ripristinato da un backup), il server non prende niente e risponde
"ripartire": l'app dimentica cosa risultava mandato e rimanda tutto da zero.
Accesso con un token (Bearer), confrontato a tempo costante.

**Motivazione:** un server che non conosce le tabelle non va cambiato
quando l'app aggiunge una colonna o una tabella. Le revisioni del server, e
non le date dei dispositivi, decidono cosa è nuovo: gli orologi dei
dispositivi possono sbagliare, il contatore no. Il controllo del ritorno
indietro va fatto prima di salvare, perché le modifiche appena arrivate
alzerebbero la revisione massima e lo nasconderebbero.

**Limite noto:** vince la riga intera. Se sulla stessa attività si cambia il
titolo sul telefono e la descrizione sul PC prima di sincronizzare, resta
solo la modifica più recente.

**Alternative scartate:** tabelle del server uguali a quelle dell'app (ogni
cambio di schema da fare due volte); unione campo per campo (più giusta, ma
molto più complicata per un uso personale); CRDT.

---

## 020 — Backup fatti dal server, a rotazione

**Data:** 2026-11-10

**Contesto:** il server deve fare anche i backup.

**Decisione:** una volta al giorno (`TIFARO_BACKUP_OGNI`) il server scrive
un'istantanea del database con `VACUUM INTO` (coerente anche mentre lavora),
prima con un nome provvisorio e poi rinominata, e tiene le ultime 30
(`TIFARO_BACKUP_TIENI`). Le foto nuove si copiano nella cartella dei backup;
non si cancellano mai, perché non cambiano. Controlla ogni dieci minuti se è
ora, così dopo uno spegnimento il backup arriva appena il NAS riparte. La
cartella dei backup è un volume a parte (`TIFARO_BACKUP_LOCATION`), da
mettere su un altro disco se si può. L'app mostra l'ultimo backup e ne può
chiedere uno.

**Motivazione:** i backup stanno dove stanno i dati, senza strumenti in più
sul NAS. Il nome provvisorio evita che una copia interrotta sembri buona.

**Alternative scartate:** copia del file del database (in WAL può essere
incoerente); backup fatto dall'app (il telefono non è sempre acceso).

---

## 021 — Sincronizzazione nell'app: impronte, un giro solo, date che avanzano

**Data:** 2026-11-10

**Contesto:** l'app deve capire cosa mandare, applicare cosa arriva e non
perdere modifiche.

**Decisione:**

- **Cosa mandare:** per ogni riga si annota (tabella locale `sync_note`)
  l'impronta del contenuto che il server ha di sicuro. Va mandata ogni riga
  la cui impronta attuale è diversa. L'impronta è FNV-1a del JSON con le
  chiavi in ordine.
- **Un giro:** si caricano prima le foto nuove, poi si mandano le righe e si
  ricevono tutte le pagine; si applica tutto in una sola transazione, con i
  vincoli fra tabelle controllati alla fine (`defer_foreign_keys`), perché
  una sotto-attività può arrivare prima della sua principale. Poi si
  scaricano le foto che mancano.
- **Cosa arriva:** una riga ricevuta sostituisce quella locale, tranne se
  quella locale è cambiata dopo l'ultima sincronizzazione ed è più recente:
  allora resta e partirà alla prossima.
- **Date che avanzano:** ogni modifica a una riga esistente prende come data
  il massimo fra adesso e la data che la riga ha già più un secondo
  (`dataDiModifica`). Così una modifica fatta dopo aver visto una versione
  la batte sempre, anche se l'orologio di quel dispositivo è un po' indietro.
- **Righe di partenza:** argomenti e tipologie del primo avvio hanno una data
  fissa (1 gennaio 2026), così un dispositivo installato dopo non sovrascrive
  quello che si è già rinominato altrove.
- **Quando:** all'apertura, al ritorno in primo piano, ogni cinque minuti e
  cinque secondi dopo una modifica (solo se c'è qualcosa da mandare). Si può
  spegnere; l'icona in alto sincronizza a richiesta.

**Motivazione:** le date nel database sono al secondo: due modifiche nello
stesso secondo sembrerebbero una, l'impronta no. Applicare tutto insieme
evita stati a metà. Le date che avanzano sono il modo più semplice per non
dipendere dagli orologi, ed è servito: la prova completa con due dispositivi
l'ha trovato.

**Alternative scartate:** segnalino "da mandare" su ogni tabella (una colonna
in più ovunque, da tenere giusta a mano); confronto per data (cieco alle
modifiche nello stesso secondo); trigger SQLite (fuori dallo schema che
drift verifica).

---

## 022 — Server sul NAS, in rete locale, immagine costruita da Gitea

**Data:** 2026-11-10

**Contesto:** dove far girare il server e come portarci l'immagine.

**Decisione:** il server sta sul NAS, come stack di Dockge con lo stile degli
altri (`docker-compose.yml`, `.env`, `user: PUID:PGID`, volumi `:z`), sulla
porta 8645. L'immagine si costruisce sul NAS dal codice su Gitea (contesto
git con `#main:server`), su un'immagine distroless senza shell; il programma
fa da sé il controllo di salute. Parla HTTP, solo in rete locale: su Android
serve `usesCleartextTraffic`, e il permesso INTERNET va dichiarato nel
manifest principale (Flutter lo mette solo in quelli di debug). Fuori casa
l'app lavora da sola e si allinea al rientro.

**Motivazione:** i dati restano in casa, come gli altri servizi del NAS. Non
c'è un registry per le immagini, e Gitea c'è già. HTTPS in rete locale
richiederebbe certificati per un indirizzo IP, senza un vero guadagno finché
il server non esce di casa.

**Da rivedere quando:** si vorrà sincronizzare fuori casa (VPN verso il NAS,
o HTTPS davanti al server).

**Alternative scartate:** server sul VPS (raggiungibile ovunque, ma dati e
foto fuori casa); immagine costruita sul PC e copiata (un passaggio a mano a
ogni aggiornamento).

---

## 023 — Versione Linux installata per l'utente

**Data:** 2026-11-10

**Contesto:** oltre all'app Android serve la versione per il PC.

**Decisione:** `strumenti/installa_linux.sh` compila la versione definitiva
e la copia in `~/.local/opt/tifaro`, con l'icona e la voce nel menu delle
applicazioni e il comando `tifaro`. I dati stanno in
`~/.local/share/com.enne139.tifaro` e sopravvivono agli aggiornamenti.

**Motivazione:** nessun permesso di amministratore, si aggiorna rilanciando
lo script, e si toglie con `--togli`.

**Alternative scartate:** pacchetto Arch o Flatpak (da mantenere, per un
solo utente); lanciarla con `flutter run` (lenta e in modalità debug).

---

## 024 — «Tutte»: le attività di ogni argomento insieme

**Data:** 2026-11-10

**Contesto:** si vogliono vedere tutte le attività, anche di argomenti
diversi, non uno per volta.

**Decisione:** nella schermata Argomenti la prima scelta è «Tutte», ed è
quella di partenza: l'albero mostra le attività principali di ogni
argomento, ordinate per scadenza come le altre (voce 013), con l'argomento
scritto sulle principali. Le sotto-attività non lo ripetono, perché hanno
sempre quello della principale.

**Motivazione:** è la stessa vista con un filtro in meno: niente schermata
nuova da imparare, e la barra in basso resta con tre voci.

**Alternative scartate:** una quarta sezione nella barra in basso (un
doppione degli Argomenti); un elenco piatto (si perderebbe l'albero).

---

## 025 — Build e rilasci su GitHub, immagine del server su ghcr.io

**Data:** 2026-11-10

**Contesto:** il repository sta su GitHub (oltre che sul Gitea di casa), e
le build si fanno lì. Supera la parte della voce 022 sull'immagine del
server costruita sul NAS da Gitea.

**Decisione:** tre flussi di GitHub Actions. «Prove» a ogni push: analisi e
prove dell'app e del server, e la prova completa con un server vero acceso
nella macchina di GitHub. «Rilascio» a ogni tag `vX.Y.Z`: APK firmato con la
chiave presa dai segreti (senza chiave una release vera si ferma) e versione
Linux in un archivio con lo script di installazione, allegati alla release.
«Container» a ogni tag: immagine del server per amd64 e arm64 su
`ghcr.io/enne139/tifaro-server`, che il NAS scarica; quando cambia il
server si costruisce senza pubblicare. Flutter è fissato alla versione usata
per sviluppare. Lo schema è quello di Spesone.

**Motivazione:** il NAS non deve compilare niente e non deve leggere Gitea;
un aggiornamento è un «pull» come per gli altri servizi (e Diun lo segnala).
Le release di GitHub sono quello che Obtainium sa seguire. Fermare un
rilascio senza chiave evita APK che poi non si aggiornano.

**Alternative scartate:** immagine costruita sul NAS (voce 022: un passaggio
a mano e il NAS che deve raggiungere Gitea); build su Gitea Actions (serve
un runner in casa).

---

## 026 — Repository pubblico: niente dati personali

**Data:** 2026-11-10

**Contesto:** il codice va su GitHub.

**Decisione:** nel repository non entrano dati personali o di casa:
indirizzi e nomi della rete di casa, percorsi della propria home, nomi di
persone o associazioni, token, password, chiavi. Gli esempi usano valori
neutri; l'indirizzo del server non ha un valore preimpostato. Prima della
prima pubblicazione la cronologia è stata ripulita (indirizzo del NAS, un
percorso della home e un'associazione usati negli esempi), riscrivendo i
commit che non erano mai stati pubblicati.

**Motivazione:** quello che finisce in un repository pubblico non si
cancella più davvero.

**Alternative scartate:** repository privato (le release servono a
Obtainium, e il codice non ha niente da nascondere se non contiene dati
personali).

---

## 027 — Il calendario lo scrive il telefono, non il server

**Data:** 2026-11-10

**Contesto:** le attività «nel calendario» devono diventare eventi. Supera
la voce 009, che li faceva creare al server con un account di servizio
Google.

**Decisione:** gli eventi li scrive l'app Android nel calendario del
telefono (`CalendarContract`), attraverso un piccolo canale nativo scritto a
mano in `MainActivity.kt` (`tifaro/calendario`). Nelle impostazioni si
sceglie il calendario; se è quello di un account Google, è Android a portare
gli eventi su Google Calendar. Ogni attività da fare, «nel calendario» e con
una scadenza è un evento: tutto il giorno se la scadenza non ha l'ora
(mezzanotti UTC, come vuole Android), di un'ora se ce l'ha; per le
sotto-attività la descrizione dice di cosa fanno parte; il colore è la
chiave di Google dell'argomento (voce 008), se l'account la conosce. Il
telefono ricorda quale evento ha creato per quale attività (tabella locale
`eventi_calendario`, con l'impronta di quello che ha scritto) e a ogni giro
fa solo le differenze: crea, aggiorna, toglie. Ogni evento porta il segno
`tifaro://attivita/<id>` (`CUSTOM_APP_URI`): dopo una reinstallazione gli
eventi si ritrovano invece di duplicarsi; un evento tolto a mano torna alla
prossima modifica dell'attività. Il giro parte all'apertura, al ritorno in
primo piano e due secondi dopo ogni modifica, comprese quelle arrivate con la
sincronizzazione. Su Linux le impostazioni dicono che lo fa il telefono.

**Motivazione:** niente progetto Google Cloud, niente chiavi sul NAS, niente
dati che il server manda a Google; funziona anche senza rete. Con la
sincronizzazione il vantaggio del server (funzionare da qualunque
dispositivo) è quasi sparito: basta che il telefono riceva le attività. Il
canale scritto a mano evita un plugin esterno e permette il segno e i
colori.

**Limite noto:** un'attività segnata dal PC arriva nel calendario quando il
telefono si sincronizza, cioè quando si apre l'app. Una sincronizzazione in
background toglierebbe il ritardo.

**Alternative scartate:** il server con le API di Google (voce 009: più
pezzi e una configurazione Google da fare); un plugin per il calendario
(niente segno né colori, e il rischio che non compili con le versioni
nuove); un file .ics da abbonare (Google lo aggiorna ogni molte ore).

---

## 028 — In Oggi, in fondo, le attività senza scadenza

**Data:** 2026-11-10

**Contesto:** in Oggi si vogliono vedere anche le attività senza una data.

**Decisione:** sotto Scadute, Oggi e Prossimi 7 giorni c'è il gruppo «Senza
scadenza»: le attività principali da fare che non hanno una scadenza, in
ordine di creazione, dalla più vecchia. Le sotto-attività senza scadenza non
ci sono.

**Motivazione:** così Oggi è l'elenco completo delle cose da fare, con le
urgenti in cima. Le sotto-attività senza data sono spesso i passaggi di
un'attività più grande o di un modello: elencate una per una affollerebbero
il gruppo, mentre la loro principale compare già, con l'avanzamento. Dalla
più vecchia, perché quelle in attesa da più tempo non scivolino in fondo.

**Alternative scartate:** anche le sotto-attività (troppe righe); dalla più
recente (le vecchie sparirebbero sotto).

