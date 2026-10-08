import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/services/assistant_service.dart';

void main() {
  const service = LocalAssistantService();
  const projects = [
    AssistantProjectReference(
      projectName: 'Casa',
      folderPaths: ['Ristrutturazione', 'Ristrutturazione / Soggiorno'],
    ),
  ];
  final today = DateTime(2026, 10, 8);

  test('interpreta un elemento da aggiungere in Inbox', () {
    final draft = service.interpret(
      'Aggiungi comprare il latte in Inbox',
      projects: projects,
      today: today,
    );

    expect(draft?.type, AssistantActionType.inbox);
    expect(draft?.title, 'comprare il latte');
  });

  test('accetta in, a e ad come preposizioni per Inbox', () {
    for (final preposition in ['in', 'a', 'ad']) {
      final draft = service.interpret(
        'Aggiungi fare la spesa $preposition Inbox',
        projects: projects,
        today: today,
      );

      expect(draft?.type, AssistantActionType.inbox);
      expect(draft?.title, 'fare la spesa');
    }
  });

  test('interpreta ad Oggi come attività della giornata', () {
    final draft = service.interpret(
      'Aggiungi fare la spesa ad Oggi',
      projects: projects,
      today: today,
    );

    expect(draft?.type, AssistantActionType.todayTask);
    expect(draft?.title, 'fare la spesa');
    expect(draft?.date, today);
  });

  test('interpreta un’attività in una sottocartella di progetto', () {
    final draft = service.interpret(
      'Aggiungi montare la lampada al progetto Casa nella cartella Soggiorno',
      projects: projects,
      today: today,
    );

    expect(draft?.type, AssistantActionType.projectTask);
    expect(draft?.title, 'montare la lampada');
    expect(draft?.projectName, 'Casa');
    expect(draft?.folderPath, 'Ristrutturazione / Soggiorno');
  });

  test('interpreta un appuntamento di domani nel calendario', () {
    final draft = service.interpret(
      'Programma dentista domani nel calendario',
      projects: projects,
      today: today,
    );

    expect(draft?.type, AssistantActionType.calendar);
    expect(draft?.title, 'dentista');
    expect(draft?.date, DateTime(2026, 10, 9));
  });
}
