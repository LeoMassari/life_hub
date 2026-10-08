import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/app.dart';
import 'package:life_hub/data/local_store.dart';

class MemoryStore implements AppStore {
  Map<String, dynamic>? value;
  @override
  Future<Map<String, dynamic>?> load() async => value;
  @override
  Future<void> save(Map<String, dynamic> data) async => value = data;
}

void main() {
  testWidgets('mostra la navigazione principale e il menu altre aree', (
    tester,
  ) async {
    await tester.pumpWidget(LifeHubApp(store: MemoryStore()));
    await tester.pumpAndSettle();
    expect(find.text('Oggi'), findsWidgets);
    expect(find.text('Finanze'), findsOneWidget);
    expect(find.text('Progetti'), findsWidgets);
    expect(find.text('Scadenze'), findsOneWidget);
    expect(find.text('Altro'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Panoramica'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Panoramica'), findsOneWidget);
    expect(find.text('Saldo'), findsOneWidget);

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    expect(find.text('Allenamento'), findsOneWidget);
    expect(find.text('Alimentazione'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Assistente'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Check lists'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
  });

  testWidgets('mostra gli obiettivi economici in Finanze', (tester) async {
    await tester.pumpWidget(LifeHubApp(store: MemoryStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finanze'));
    await tester.pumpAndSettle();

    expect(find.text('Obiettivi economici'), findsOneWidget);
    expect(find.byTooltip('Nuovo obiettivo economico'), findsOneWidget);
  });

  testWidgets('mostra il menu delle azioni di progetto', (tester) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': [
              {'id': 'task-1', 'title': 'Comprare una lampada'},
            ],
            'folders': <Map<String, dynamic>>[],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Azioni'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Azioni'));
    await tester.pumpAndSettle();

    expect(find.text('Programma'), findsOneWidget);
    expect(find.text('Sposta in'), findsOneWidget);
  });

  testWidgets(
    'aggiunge rapidamente un’attività scegliendo dove e la priorità',
    (tester) async {
      final store = MemoryStore()
        ..value = {
          'projects': [
            {
              'id': 'project-1',
              'title': 'Casa',
              'tasks': <Map<String, dynamic>>[],
              'folders': [
                {
                  'id': 'folder-1',
                  'title': 'Soggiorno',
                  'emoji': '🛋️',
                  'tasks': <Map<String, dynamic>>[],
                },
              ],
            },
          ],
        };
      await tester.pumpWidget(LifeHubApp(store: store));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Progetti').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Aggiungi attività'));
      await tester.pumpAndSettle();

      expect(find.text('Dove'), findsOneWidget);
      expect(find.text('Priorità'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).first,
        'Montare la lampada',
      );
      await tester.tap(find.text('Senza cartella'));
      await tester.pumpAndSettle();
      expect(find.text('Soggiorno'), findsOneWidget);
      await tester.tap(find.text('Soggiorno').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(
        store.value?['projects']?[0]['folders']?[0]['tasks']?[0]['title'],
        'Montare la lampada',
      );
      expect(store.value?['projects']?[0]['folders']?[0]['emoji'], '🛋️');
    },
  );

  testWidgets('seleziona più attività di un progetto per spostarle insieme', (
    tester,
  ) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': [
              {'id': 'task-1', 'title': 'Prima attività', 'priority': 1},
              {'id': 'task-2', 'title': 'Seconda attività', 'priority': 2},
            ],
            'folders': <Map<String, dynamic>>[],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Seleziona più attività'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prima attività'));
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seconda attività'));
    await tester.pumpAndSettle();

    expect(find.text('2 selezionate'), findsOneWidget);
    expect(find.byTooltip('Sposta selezionate'), findsOneWidget);
  });

  testWidgets('apre le sottocartelle dei progetti', (tester) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': <Map<String, dynamic>>[],
            'folders': [
              {
                'id': 'folder-1',
                'title': 'Ristrutturazione',
                'tasks': <Map<String, dynamic>>[],
                'folders': [
                  {
                    'id': 'folder-2',
                    'title': 'Soggiorno',
                    'emoji': '🛋️',
                    'tasks': <Map<String, dynamic>>[],
                  },
                ],
              },
            ],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ristrutturazione'));
    await tester.pumpAndSettle();

    expect(find.text('Sottocartelle'), findsOneWidget);
    expect(find.text('Soggiorno'), findsOneWidget);
    expect(find.byTooltip('Aggiungi sottocartella'), findsOneWidget);
  });

  testWidgets('riordina le priorità con i pulsanti su e giù', (tester) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': [
              {'id': 'task-1', 'title': 'Prima attività', 'priority': 1},
              {'id': 'task-2', 'title': 'Seconda attività', 'priority': 2},
            ],
            'folders': <Map<String, dynamic>>[],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ordina priorità'));
    await tester.pumpAndSettle();

    expect(find.text('Ordina per importanza'), findsOneWidget);
    await tester.tap(find.byTooltip('Sposta in basso').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva ordine'));
    await tester.pumpAndSettle();

    final tasks = store.value?['projects']?[0]['tasks'] as List<dynamic>;
    expect(tasks.first['title'], 'Seconda attività');
    expect(tasks.first['priority'], 1);
    expect(tasks.last['priority'], 2);
  });

  testWidgets('sposta le completate in fondo e permette di nasconderle', (
    tester,
  ) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': [
              {'id': 'task-1', 'title': 'Da fare', 'done': false},
              {'id': 'task-2', 'title': 'Già fatta', 'done': true},
            ],
            'folders': <Map<String, dynamic>>[],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Attività completate'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Attività completate'), findsOneWidget);
    expect(find.text('Già fatta'), findsOneWidget);
    final completedTile = find.ancestor(
      of: find.text('Già fatta'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(
        of: completedTile,
        matching: find.byTooltip('Elimina attività completata'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: completedTile, matching: find.byTooltip('Azioni')),
      findsNothing,
    );
    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fatto'));
    await tester.pumpAndSettle();

    expect(find.text('Attività completate'), findsNothing);
    expect(find.text('Già fatta'), findsNothing);
  });

  testWidgets('smista un elemento Inbox dentro un progetto', (tester) async {
    final store = MemoryStore()
      ..value = {
        'cycleItems': [
          {'id': 'inbox-1', 'title': 'Comprare la lampada'},
        ],
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': <Map<String, dynamic>>[],
            'folders': [
              {
                'id': 'folder-1',
                'title': 'Soggiorno',
                'tasks': <Map<String, dynamic>>[],
                'folders': <Map<String, dynamic>>[],
              },
            ],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smista'));
    await tester.pumpAndSettle();

    expect(find.text('Smista in un progetto'), findsOneWidget);
    expect(find.text('Casa'), findsOneWidget);
    await tester.tap(find.text('Smista').last);
    await tester.pumpAndSettle();

    expect(find.text('Comprare la lampada'), findsNothing);
    expect(
      store.value?['projects']?[0]['tasks']?[0]['title'],
      'Comprare la lampada',
    );
  });

  testWidgets('l’Assistente crea un elemento Inbox dopo la conferma', (
    tester,
  ) async {
    final store = MemoryStore();
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();

    expect(find.text('Assistente AI'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'Aggiungi comprare il latte in Inbox',
    );
    await tester.tap(find.text('Interpreta'));
    await tester.pumpAndSettle();
    expect(find.text('Anteprima'), findsOneWidget);
    expect(find.text('Aggiungi a Inbox'), findsOneWidget);

    await tester.tap(find.text('Aggiungi a Inbox'));
    await tester.pumpAndSettle();
    expect(store.value?['cycleItems']?[0]['title'], 'comprare il latte');
  });

  testWidgets('il tasto AI di Oggi aggiunge un’attività alla giornata', (
    tester,
  ) async {
    final store = MemoryStore();
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Chiedi all’Assistente AI'), findsOneWidget);
    await tester.tap(find.text('Chiedi all’Assistente AI'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Aggiungi fare la spesa ad Oggi',
    );
    await tester.tap(find.text('Interpreta'));
    await tester.pumpAndSettle();
    expect(find.text('Aggiungi a Oggi'), findsOneWidget);

    await tester.tap(find.text('Aggiungi a Oggi'));
    await tester.pumpAndSettle();
    final savedTasks = store.value?['tasks'] as List<dynamic>;
    expect(savedTasks.any((task) => task['title'] == 'fare la spesa'), isTrue);
  });

  testWidgets('l’editor del progetto mostra nome e icona', (tester) async {
    final store = MemoryStore()
      ..value = {
        'projects': [
          {
            'id': 'project-1',
            'title': 'Casa',
            'tasks': <Map<String, dynamic>>[],
            'folders': [
              {
                'id': 'folder-1',
                'title': 'Soggiorno',
                'tasks': <Map<String, dynamic>>[],
                'folders': <Map<String, dynamic>>[],
              },
            ],
          },
        ],
      };
    await tester.pumpWidget(LifeHubApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progetti').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica nome e icona'));
    await tester.pumpAndSettle();

    expect(find.text('Icona o emoji'), findsOneWidget);
    expect(
      find.text('Lascia vuoto per usare l’icona predefinita.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Soggiorno'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica nome e icona'));
    await tester.pumpAndSettle();

    expect(find.text('Icona o emoji'), findsOneWidget);
  });

  testWidgets('aggiunge nome e orario alle attività di oggi', (tester) async {
    await tester.pumpWidget(LifeHubApp(store: MemoryStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Aggiungi attività'));
    await tester.pumpAndSettle();
    expect(find.text('L’orario è facoltativo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Allenamento breve');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Allenamento breve'), findsOneWidget);
  });

  testWidgets('apre l’editor con ordine e sfondo della pagina', (tester) async {
    await tester.pumpWidget(LifeHubApp(store: MemoryStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    expect(
      find.text('Trascina le sezioni per cambiarne l’ordine.'),
      findsOneWidget,
    );
    expect(find.text('Sfondo della pagina'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsWidgets);
    expect(find.text('Predefinito'), findsOneWidget);
    expect(find.text('Personale'), findsOneWidget);
  });

  testWidgets('crea una routine e apre il monitoraggio', (tester) async {
    await tester.pumpWidget(LifeHubApp(store: MemoryStore()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Routine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aggiungi routine'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Meditazione');
    await tester.enterText(find.byType(TextField).last, '2');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Meditazione'), findsOneWidget);
    await tester.tap(find.text('Meditazione'));
    await tester.pumpAndSettle();

    expect(find.text('Andamento'), findsOneWidget);
    expect(find.text('30 giorni'), findsOneWidget);
    expect(find.text('Segna come fatta'), findsOneWidget);
  });
}
