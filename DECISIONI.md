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

