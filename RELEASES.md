# Versioni scaricabili

Ogni aggiornamento completato produce due archivi nella cartella `releases/`:

- `life_hub-source-vX.Y.Z.zip`: progetto Flutter completo, senza cronologia Git o file temporanei;
- `life_hub-web-vX.Y.Z.zip`: applicazione web compilata, pronta per essere pubblicata su un servizio di hosting.

## 0.15.0

- Invio sulla tastiera attiva Salva in tutti i moduli di modifica;
- ordine di visualizzazione dei progetti modificabile trascinandoli da **Modifica**;
- priorità delle attività riordinabili trascinando la nuova maniglia a due linee;
- priorità iniziale vuota quando si crea una nuova attività di progetto;
- dettatura vocale dell'Assistente tramite il pulsante **Parla**, con richiesta del permesso per il microfono, trascrizione in italiano e anteprima da confermare;
- configurazione dei permessi vocali per web, Android e iOS;
- nuovi controlli automatici per salvataggio con Invio, ordinamento e interfaccia vocale.

## 0.14.0

- collegamento rapido all'Assistente AI in cima alla pagina Oggi;
- nuovo comando dell'Assistente per aggiungere direttamente attività a Oggi;
- riconoscimento delle preposizioni `in`, `a` e `ad` nelle destinazioni;
- editor unificato di nome e icona per progetti, cartelle e sottocartelle;
- icona o emoji personalizzata salvata anche sul progetto e sincronizzata con gli altri dati;
- progettazione della futura dettatura vocale con conferma prima di ogni azione.

## 0.13.0

- pulsante Smista in Inbox per trasferire un elemento in un progetto o in una sottocartella;
- assegnazione automatica della priorità quando un elemento viene smistato;
- cestino diretto al posto del menu a tre puntini sulle attività completate;
- ripristino del menu completo soltanto dopo aver tolto la spunta;
- nuova pagina Assistente AI con interpretazione locale, anteprima e conferma;
- comandi semplici per Inbox, progetti, sottocartelle e calendario;
- architettura documentata per collegare in futuro un modello tramite backend sicuro;
- nessuna chiave AI inserita nell'app o nella build web pubblica.

## 0.12.0

- ordinamento manuale delle attività tramite pulsanti su e giù;
- assegnazione automatica delle priorità numeriche in base all'ordine scelto;
- sottocartelle annidabili dentro qualsiasi cartella di progetto;
- destinazioni annidate disponibili nei menu Dove e Sposta in;
- attività concluse raccolte in una sezione separata in fondo alla pagina;
- preferenza Modifica per mostrare o nascondere le attività completate senza cancellarle;
- conteggi e avanzamento aggiornati includendo tutte le sottocartelle;
- piena compatibilità con i progetti cloud e locali delle versioni precedenti.

## 0.11.0

- selezione multipla delle attività di un progetto o di una cartella e spostamento in blocco;
- icona o emoji personalizzabile per ogni cartella di progetto;
- sfondo della pagina Progetti mantenuto anche entrando nei progetti e nelle cartelle;
- priorità numerica delle attività, con ordinamento automatico dal numero più basso;
- pulsante rapido sulle schede dei progetti per aggiungere un'attività;
- campi Dove, Scadenza e Priorità disponibili prima del salvataggio;
- compatibilità completa con i progetti già salvati nel cloud o in locale.

## 0.10.0

- la pagina Obiettivi diventa Progetti e mostra soltanto i progetti operativi;
- la pagina Cicli diventa Inbox, mantenendo tutti gli elementi già salvati;
- gli obiettivi economici sono ora raccolti nella pagina Finanze;
- nuovo menu a tre puntini accanto alla spunta delle azioni di progetto;
- programmazione delle azioni nel calendario senza creare duplicati;
- spostamento delle azioni tra cartelle o creazione immediata di una nuova cartella;
- piena compatibilità con i dati cloud e locali delle versioni precedenti.

## 0.9.0

- riordino delle sezioni tramite trascinamento dal pannello Modifica;
- sfondo personale diverso per ogni pagina oppure uso dello sfondo predefinito;
- trasparenza regolabile separatamente per sfondo e pannelli;
- immagini dei widget fino a 2 MB;
- routine configurabili per giorno, settimana o mese;
- registrazione delle esecuzioni, cronologia e grafici su 7, 30, 90 o 365 giorni;
- piena compatibilità con i dati e le personalizzazioni delle versioni precedenti.

## 0.8.0

- orario facoltativo per ogni attività nella pagina Oggi;
- pianificazione della giornata di domani con nome e orario;
- cambio giornata automatico a un’ora configurabile;
- recupero delle attività non completate e pulsante per riportarle a Oggi;
- Modalità Buonanotte configurabile dalle Impostazioni;
- pulsante Modifica in ogni pagina per attivare o disattivare le sezioni senza perdere i dati;
- nuova pagina Routine predisposta come work in progress;
- nuova pagina Check lists con cartelle ed elementi spuntabili;
- compatibilità automatica con tutti i dati delle versioni precedenti.

## 0.7.0

- debiti personali con importo totale, già restituito e residuo;
- spese mensili ricorrenti con stipendio, disponibilità e grafico percentuale;
- obiettivi economici apribili con cifra da raggiungere, risparmio e descrizione;
- cartelle dentro ai progetti, ciascuna con le proprie attività e scadenze;
- scelta del colore principale oltre al tema chiaro o scuro;
- sfondo personale selezionabile dal dispositivo;
- fino a quattro widget fotografici nella pagina Oggi;
- migrazione automatica degli obiettivi e piena compatibilità con i dati 0.6.0.

## 0.6.0

- nuovo menu Altro per mantenere semplice la navigazione;
- pagine Allenamento e Alimentazione predisposte come work in progress;
- coda di lettura ordinabile nella pagina Studio;
- inbox Cicli per raccogliere elementi da smistare;
- calendario mensile con attività giornaliere;
- progetti con sotto-attività, scadenze e avanzamento automatico;
- modifica del nome delle attività in Oggi;
- Panoramica spostata in fondo alla pagina Oggi;
- piena compatibilità con i dati salvati dalle versioni precedenti.

## 0.5.0

- accesso con account email e password;
- dati locali separati per utente;
- migrazione sicura dei dati preesistenti al primo account;
- sincronizzazione cloud personale tramite Supabase.

## 0.4.0

- nuova dashboard Oggi con saldo, prossima scadenza e obiettivi;
- sezione Richiede attenzione per scadenze imminenti o già scadute;
- indicazioni temporali leggibili nelle scadenze;
- layout responsive delle metriche.

## 0.3.0

- configurazione PWA installabile da Safari sulla schermata Home;
- identità web e comportamento a schermo intero;
- build offline tramite service worker Flutter;
- recupero automatico delle modifiche cloud rimaste in attesa;
- protezione contro la sovrascrittura dei dati modificati offline.

## 0.3.1

- pubblicazione automatica gratuita tramite GitHub Pages;
- compilazione e test a ogni aggiornamento del branch principale;
- configurazione Supabase tramite GitHub Secrets;
- guida per installare la web app da Safari su iPhone.

## 0.2.0

- pagine Oggi, Finanze, Obiettivi, Scadenze e Impostazioni;
- salvataggio locale;
- interfaccia responsive;
- inserimento guidato e cancellazione protetta;
- base Supabase con autenticazione, sicurezza per utente e migrazione locale-cloud;
- 4 test automatici.
