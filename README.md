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

Le aree principali sono Oggi, Finanze, Obiettivi e Scadenze. Il menu **Altro**
raccoglie Allenamento, Alimentazione, Studio, Cicli, Calendario e Impostazioni.

La personalizzazione comprende tema chiaro/scuro, colore principale, sfondo
scelto dal dispositivo e fino a quattro widget fotografici nella pagina Oggi.
Le immagini vengono ridotte e salvate insieme ai dati dell'account.

Per una futura sincronizzazione è sufficiente creare una nuova implementazione di `AppStore` (per esempio Supabase o Firebase) senza riscrivere l'interfaccia.

La base Supabase è già inclusa. Consulta [docs/cloud_setup.md](docs/cloud_setup.md) per collegare un progetto personale in sicurezza.

Per pubblicare la web app automaticamente consulta [docs/publish_web.md](docs/publish_web.md).
