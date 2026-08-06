# Versioni scaricabili

Ogni aggiornamento completato produce due archivi nella cartella `releases/`:

- `life_hub-source-vX.Y.Z.zip`: progetto Flutter completo, senza cronologia Git o file temporanei;
- `life_hub-web-vX.Y.Z.zip`: applicazione web compilata, pronta per essere pubblicata su un servizio di hosting.

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
