import 'package:flutter/foundation.dart';
import '../data/local_store.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.store);
  final AppStore store;
  bool ready = false;
  bool darkMode = false;
  List<TaskItem> tasks = [];
  List<ReminderItem> reminders = [];
  List<DeadlineItem> deadlines = [];
  List<Movement> movements = [];
  List<GoalItem> goals = [];
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> init() async {
    final j = await store.load();
    if (j == null) {
      tasks = [
        TaskItem(id: _id(), title: 'Controlla le priorità di oggi'),
        TaskItem(id: _id(), title: 'Fai una pausa di 10 minuti'),
      ];
      reminders = [ReminderItem(id: _id(), title: 'Bere acqua', time: '11:00')];
      deadlines = [
        DeadlineItem(
          id: _id(),
          title: 'Rinnovo assicurazione',
          date: DateTime.now().add(const Duration(days: 12)),
        ),
      ];
      movements = [
        Movement(
          id: _id(),
          label: 'Spesa settimanale',
          amount: -54.80,
          date: DateTime.now(),
        ),
        Movement(
          id: _id(),
          label: 'Stipendio',
          amount: 1800,
          date: DateTime.now(),
        ),
      ];
      goals = [
        GoalItem(id: _id(), title: 'Fondo emergenze', progress: .35),
        GoalItem(id: _id(), title: 'Allenamento settimanale', progress: .6),
      ];
      await _save();
    } else {
      tasks = (j['tasks'] as List)
          .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      reminders = (j['reminders'] as List)
          .map((e) => ReminderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      deadlines = (j['deadlines'] as List)
          .map((e) => DeadlineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      movements = (j['movements'] as List)
          .map((e) => Movement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      goals = (j['goals'] as List)
          .map((e) => GoalItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      darkMode = j['darkMode'] ?? false;
    }
    ready = true;
    notifyListeners();
  }

  Future<void> _save() => store.save({
    'tasks': tasks.map((e) => e.toJson()).toList(),
    'reminders': reminders.map((e) => e.toJson()).toList(),
    'deadlines': deadlines.map((e) => e.toJson()).toList(),
    'movements': movements.map((e) => e.toJson()).toList(),
    'goals': goals.map((e) => e.toJson()).toList(),
    'darkMode': darkMode,
  });
  void addTask(String v) {
    tasks.add(TaskItem(id: _id(), title: v));
    _changed();
  }

  void toggleTask(TaskItem v) {
    v.done = !v.done;
    _changed();
  }

  void removeTask(TaskItem value) {
    tasks.remove(value);
    _changed();
  }

  void addReminder(String title, String time) {
    reminders.add(ReminderItem(id: _id(), title: title, time: time));
    _changed();
  }

  void removeReminder(ReminderItem value) {
    reminders.remove(value);
    _changed();
  }

  void addDeadline(String title, DateTime date) {
    deadlines.add(DeadlineItem(id: _id(), title: title, date: date));
    _changed();
  }

  void toggleDeadline(DeadlineItem v) {
    v.done = !v.done;
    _changed();
  }

  void removeDeadline(DeadlineItem value) {
    deadlines.remove(value);
    _changed();
  }

  void addMovement(String label, double amount) {
    movements.insert(
      0,
      Movement(id: _id(), label: label, amount: amount, date: DateTime.now()),
    );
    _changed();
  }

  void removeMovement(Movement value) {
    movements.remove(value);
    _changed();
  }

  void addGoal(String title) {
    goals.add(GoalItem(id: _id(), title: title));
    _changed();
  }

  void setGoal(GoalItem goal, double value) {
    goal.progress = value;
    _changed();
  }

  void removeGoal(GoalItem value) {
    goals.remove(value);
    _changed();
  }

  void setDark(bool value) {
    darkMode = value;
    _changed();
  }

  void _changed() {
    notifyListeners();
    _save();
  }
}
