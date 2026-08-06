import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub/data/local_store.dart';
import 'package:life_hub/state/app_state.dart';

class MemoryStore implements AppStore {
  Map<String, dynamic>? value;
  @override
  Future<Map<String, dynamic>?> load() async => value;
  @override
  Future<void> save(Map<String, dynamic> data) async => value = data;
}

void main() {
  test('salva e ricarica i dati personali', () async {
    final store = MemoryStore();
    final first = AppState(store);
    await first.init();

    first.addTask('Prenota il dentista');
    first.addMovement('Cinema', -12.50);
    first.addReminder('Chiamare Marco', '18:30');
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(store);
    await restored.init();

    expect(
      restored.tasks.any((item) => item.title == 'Prenota il dentista'),
      isTrue,
    );
    expect(restored.movements.any((item) => item.label == 'Cinema'), isTrue);
    expect(restored.reminders.any((item) => item.time == '18:30'), isTrue);
  });

  test('carica una versione precedente senza i nuovi campi', () async {
    final store = MemoryStore()
      ..value = {
        'tasks': <Object>[],
        'reminders': <Object>[],
        'deadlines': <Object>[],
        'movements': <Object>[],
        'goals': <Object>[],
        'darkMode': false,
      };

    final state = AppState(store);
    await state.init();

    expect(state.books, isEmpty);
    expect(state.cycleItems, isEmpty);
    expect(state.calendarItems, isEmpty);
    expect(state.projects, isEmpty);
  });

  test('salva libri, calendario e progetti con sotto-attività', () async {
    final store = MemoryStore();
    final state = AppState(store);
    await state.init();

    state.addBook('Il nome della rosa');
    state.addBook('Dune');
    state.reorderBooks(1, 0);
    state.addCycleItem('Organizzare il viaggio');
    state.addCalendarItem('Dentista', DateTime(2026, 9, 12));
    state.addProject('Casa');
    state.addProjectTask(
      state.projects.first,
      'Chiedere un preventivo',
      DateTime(2026, 10, 1),
    );
    state.toggleProjectTask(state.projects.first.tasks.first);
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(store);
    await restored.init();

    expect(restored.books.first.title, 'Dune');
    expect(restored.cycleItems.single.title, 'Organizzare il viaggio');
    expect(restored.calendarItems.single.title, 'Dentista');
    expect(restored.projects.single.progress, 1);
    expect(restored.projects.single.tasks.single.deadline, isNotNull);
  });

  test('migra il progresso dei vecchi obiettivi economici', () async {
    final store = MemoryStore()
      ..value = {
        'tasks': <Object>[],
        'reminders': <Object>[],
        'deadlines': <Object>[],
        'movements': <Object>[],
        'goals': [
          {'id': 'goal-1', 'title': 'Fondo', 'progress': .35},
        ],
      };

    final state = AppState(store);
    await state.init();

    expect(state.goals.single.targetAmount, 1000);
    expect(state.goals.single.savedAmount, 350);
    expect(state.goals.single.progress, .35);
  });

  test('salva debiti, spese ricorrenti e personalizzazione', () async {
    final store = MemoryStore();
    final state = AppState(store);
    await state.init();

    state.addDebt('Marco', 500, 120);
    state.setMonthlySalary(2100);
    state.addRecurringExpense('Affitto', 650);
    state.setThemeSeed(0xff006c51);
    state.setBackgroundImage('aW1tYWdpbmU=');
    state.addPhotoWidget('Zm90bw==', 'Montagna');
    await Future<void>.delayed(Duration.zero);

    final restored = AppState(store);
    await restored.init();

    expect(restored.debts.single.remaining, 380);
    expect(restored.monthlySalary, 2100);
    expect(
      restored.recurringExpenses.any((item) => item.title == 'Affitto'),
      isTrue,
    );
    expect(restored.themeSeedValue, 0xff006c51);
    expect(restored.backgroundImageBase64, 'aW1tYWdpbmU=');
    expect(restored.photoWidgets.single.caption, 'Montagna');
  });

  test('calcola il progresso del progetto includendo le cartelle', () async {
    final store = MemoryStore();
    final state = AppState(store);
    await state.init();

    state.addProject('Trasloco');
    final project = state.projects.last;
    state.addProjectTask(project, 'Disdire utenze', null);
    state.addProjectFolder(project, 'Scatoloni');
    final folder = project.folders.single;
    state.addProjectFolderTask(folder, 'Comprare scatole', null);
    state.toggleProjectTask(folder.tasks.single);

    expect(project.allTasks.length, 2);
    expect(project.progress, .5);
    expect(folder.progress, 1);
  });
}
