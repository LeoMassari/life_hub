# Pubblicare gratuitamente Life Hub Web

Il progetto contiene un flusso GitHub Actions che verifica, compila e pubblica automaticamente l'app a ogni aggiornamento del branch `main`.

## Prima pubblicazione

1. Carica il repository su GitHub.
2. In **Settings → Secrets and variables → Actions**, crea:
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
3. In **Settings → Pages → Build and deployment**, scegli **GitHub Actions**.
4. Apri **Actions → Pubblica Life Hub Web → Run workflow**.

Al termine GitHub mostrerà l'indirizzo HTTPS. Aprilo con Safari su iPhone, premi **Condividi → Aggiungi alla schermata Home** e attiva **Apri come app web**.

## Privacy

GitHub Pages è gratuito con GitHub Free per repository pubblici. Il codice non contiene dati personali né credenziali: le chiavi sono lette dai Secrets e i dati personali restano protetti in Supabase. Se vuoi mantenere privato anche il codice, servirà un piano GitHub compatibile oppure un hosting gratuito che accetti repository privati.
