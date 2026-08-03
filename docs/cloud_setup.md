# Configurazione cloud Supabase

1. Crea un progetto Supabase chiamato `life-hub`.
2. Apri **SQL Editor**, incolla `supabase/migrations/001_life_hub_data.sql` ed eseguilo.
3. Recupera **Project URL** e **Publishable key** dal pannello **Connect**.
4. Avvia l'app passando i valori senza salvarli nel repository:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://TUO-PROGETTO.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=LA_TUA_CHIAVE_PUBBLICABILE
```

Non usare mai una `secret key` o la password del database dentro l'app.

La tabella usa Row Level Security: un utente autenticato può leggere e modificare esclusivamente la propria riga. Il prossimo passaggio collegherà accesso via email, migrazione iniziale dei dati locali e aggiornamenti in tempo reale.
