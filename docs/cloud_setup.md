# Configurazione cloud Supabase

1. Crea un progetto Supabase chiamato `life-hub`.
2. In **Authentication > Providers** lascia attivo il provider Email.
3. Apri **SQL Editor**, incolla `supabase/migrations/001_life_hub_data.sql` ed eseguilo.
4. Recupera **Project URL** e **Publishable key** dal pannello **Connect**.
5. Avvia l'app passando i valori senza salvarli nel repository:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://TUO-PROGETTO.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=LA_TUA_CHIAVE_PUBBLICABILE
```

Non usare mai una `secret key` o la password del database dentro l'app.

Per la versione pubblicata su GitHub Pages, salva gli stessi valori nei GitHub
Actions Secrets `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`, quindi rilancia il
workflow **Pubblica Life Hub Web**.

La tabella usa Row Level Security: un utente autenticato può leggere e
modificare esclusivamente la propria riga. Anche la cache del browser è separata
per ID utente; i dati locali preesistenti vengono assegnati soltanto al primo
account utilizzato su quel dispositivo.

Con la conferma email attiva, ogni persona deve aprire il collegamento ricevuto
da Supabase prima del primo accesso. Per una prima prova privata puoi disattivare
temporaneamente **Confirm email** nelle impostazioni del provider Email.

## Immagini personali

Sfondo e widget fotografici vengono convertiti in dati compatti e sincronizzati
nella stessa riga dell'account. L'app limita ogni immagine e consente al massimo
quattro widget, così il salvataggio cloud resta ragionevolmente leggero. Questa
sezione è pensata per poche immagini decorative o motivazionali, non come
archivio fotografico.
