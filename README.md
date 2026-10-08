# Life Hub

App personale Flutter per organizzare giornata, finanze, debiti, risparmi,
progetti, letture, appunti da smistare e calendario.

## Avvio

```sh
flutter pub get
flutter run
```

Scegli Chrome per il web, Windows per il desktop oppure un emulatore Android. Il progetto contiene anche la configurazione iOS, compilabile su macOS con Xcode.

## Struttura

- `lib/models`: modelli indipendenti dall'interfaccia
- `lib/data`: contratto `AppStore` e persistenza locale
- `lib/state`: stato e operazioni dell'app
- `lib/app.dart`: navigazione responsive e pagine

Le aree principali sono Oggi, Finanze, Progetti e Scadenze. Il menu **Altro**
raccoglie Allenamento, Alimentazione, Studio, Inbox, Assistente, Calendario e
Impostazioni.

Gli obiettivi economici si trovano in Finanze. Nei Progetti ogni azione può
essere programmata nel calendario, ordinata con una priorità numerica oppure
spostata singolarmente o in gruppo. Le cartelle possono avere un'icona o emoji
personale e mantengono lo sfondo scelto per la pagina Progetti. Il pulsante
rapido sulle schede permette di scegliere cartella, scadenza e priorità prima
di salvare una nuova attività. Le priorità possono anche essere riordinate con
le frecce su e giù, le cartelle possono contenere sottocartelle senza limiti di
livello e le attività concluse vengono raccolte in fondo alla pagina. Il tasto
**Modifica** nelle schede dei progetti permette di mostrare o nascondere la
sezione delle completate senza eliminare i dati.

Da Inbox il pulsante **Smista** trasferisce un elemento in un progetto o in una
sottocartella. L'Assistente, raggiungibile anche dal tasto in cima a **Oggi**,
trasforma comandi semplici in anteprime confermabili per Oggi, Inbox, Progetti e
Calendario; la progettazione del collegamento AI sicuro e dei comandi vocali è
descritta in [docs/ai_assistant.md](docs/ai_assistant.md).

Per cambiare l'icona di un progetto, di una cartella o di una sottocartella,
apri il relativo menu con i tre puntini e scegli **Modifica nome e icona**.
Seleziona una delle emoji proposte oppure scrivine una nel campo **Icona o
emoji**. Lasciando il campo vuoto viene usata l'icona predefinita.

La personalizzazione comprende tema chiaro/scuro, colore principale, sfondo
scelto dal dispositivo e fino a quattro widget fotografici nella pagina Oggi.
Le immagini vengono ridotte e salvate insieme ai dati dell'account.

Per una futura sincronizzazione è sufficiente creare una nuova implementazione di `AppStore` (per esempio Supabase o Firebase) senza riscrivere l'interfaccia.

La base Supabase è già inclusa. Consulta [docs/cloud_setup.md](docs/cloud_setup.md) per collegare un progetto personale in sicurezza.

Per pubblicare la web app automaticamente consulta [docs/publish_web.md](docs/publish_web.md).
