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
