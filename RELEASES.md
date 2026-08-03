# Versioni scaricabili

Ogni aggiornamento completato produce due archivi nella cartella `releases/`:

- `life_hub-source-vX.Y.Z.zip`: progetto Flutter completo, senza cronologia Git o file temporanei;
- `life_hub-web-vX.Y.Z.zip`: applicazione web compilata, pronta per essere pubblicata su un servizio di hosting.

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
