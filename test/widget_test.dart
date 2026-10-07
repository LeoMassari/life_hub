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
