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
    expect(find.text('Obiettivi'), findsWidgets);
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
    expect(find.text('Cicli'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Check lists'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
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
}
