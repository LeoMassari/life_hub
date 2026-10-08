# Assistente di Life Hub

## Versione attuale

L'Assistente interpreta localmente comandi semplici in italiano e prepara
un'azione in anteprima. Nessun dato viene modificato finché l'utente non preme
il pulsante di conferma.

Comandi supportati:

- aggiungere un'attività direttamente a Oggi;
- aggiungere un elemento a Inbox;
- aggiungere un'attività a un progetto o a una sua cartella;
- programmare un elemento nel calendario usando `oggi`, `domani`,
  `dopodomani` oppure una data numerica;
- aggiungere una scadenza a un'attività di progetto e riportarla anche nel
  calendario.

L'interpretazione avviene sul dispositivo e non usa chiavi o servizi esterni.
Le destinazioni accettano anche formulazioni naturali equivalenti, per esempio
`in Inbox`, `a Inbox`, `ad Inbox` e `ad Oggi`.

## Comandi vocali

È prevista una modalità microfono che trasformerà la voce in testo e passerà
la trascrizione allo stesso interprete già usato per i comandi scritti. Anche
in questo caso l'app mostrerà sempre l'anteprima e richiederà una conferma prima
di modificare i dati.

Per mantenere un comportamento affidabile su iPhone, computer e browser, il
livello vocale resterà separato dall'esecuzione delle azioni:

1. richiesta esplicita del permesso per il microfono;
2. registrazione e trascrizione del comando;
3. visualizzazione del testo riconosciuto, che l'utente potrà correggere;
4. interpretazione tramite l'Assistente;
5. conferma finale dell'azione.

La prima integrazione potrà usare il riconoscimento disponibile sul dispositivo
quando supportato, mantenendo un servizio di trascrizione protetto come opzione
per i browser che non offrono risultati affidabili. Nessuna chiave di servizio
sarà inclusa nella build web.

## Evoluzione con un modello AI

Il collegamento a un modello generativo dovrà passare da una funzione cloud
protetta, per esempio una Supabase Edge Function. La chiave del fornitore AI
rimarrà esclusivamente nel backend e non sarà mai inclusa nel codice Flutter o
nel file JavaScript pubblico.

La funzione riceverà il comando e soltanto il contesto minimo necessario,
restituendo una risposta strutturata e validabile:

```json
{
  "version": 1,
  "actions": [
    {
      "type": "project_task",
      "title": "Montare la lampada",
      "projectId": "project-id",
      "folderId": "folder-id",
      "date": "2026-10-12"
    }
  ],
  "clarification": null
}
```

L'app continuerà a mostrare l'anteprima e richiederà conferma. Il modello non
potrà scrivere direttamente nel database.

## Passi successivi

1. aggiungere la Edge Function con autenticazione dell'utente;
2. validare la risposta con uno schema rigido e riferimenti realmente presenti;
3. gestire richieste con più azioni e domande di chiarimento;
4. conservare un registro locale delle azioni confermate e permettere Annulla;
5. estendere i comandi a promemoria, routine, finanze e checklist.
6. aggiungere il microfono con trascrizione modificabile e fallback sicuro.
