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

    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Panoramica'), findsOneWidget);
    expect(find.text('Saldo'), findsOneWidget);

    await tester.tap(find.text('Altro'));
    await tester.pumpAndSettle();
    expect(find.text('Allenamento'), findsOneWidget);
    expect(find.text('Alimentazione'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Cicli'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
  });
}
