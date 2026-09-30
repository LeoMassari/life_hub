# Versioni scaricabili

Ogni aggiornamento completato produce due archivi nella cartella `releases/`:

- `life_hub-source-vX.Y.Z.zip`: progetto Flutter completo, senza cronologia Git o file temporanei;
- `life_hub-web-vX.Y.Z.zip`: applicazione web compilata, pronta per essere pubblicata su un servizio di hosting.

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
