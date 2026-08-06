import 'package:flutter/foundation.dart';
import '../data/local_store.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.store);
  final AppStore store;
  bool ready = false;
  bool darkMode = false;
  int themeSeedValue = 0xff6558d3;
  String? backgroundImageBase64;
  double monthlySalary = 0;
  List<TaskItem> tasks = [];
  List<ReminderItem> reminders = [];
  List<DeadlineItem> deadlines = [];
  List<Movement> movements = [];
  List<DebtItem> debts = [];
  List<RecurringExpense> recurringExpenses = [];
  List<GoalItem> goals = [];
  List<BookItem> books = [];
  List<CycleItem> cycleItems = [];
  List<CalendarItem> calendarItems = [];
  List<ProjectItem> projects = [];
  List<PhotoWidgetItem> photoWidgets = [];
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
      monthlySalary = 1800;
      recurringExpenses = [
        RecurringExpense(id: _id(), title: 'Abbonamenti', amount: 24.99),
      ];
      goals = [
        GoalItem(
          id: _id(),
          title: 'Fondo emergenze',
          targetAmount: 5000,
          savedAmount: 1750,
          description:
              'Una riserva per affrontare gli imprevisti con serenità.',
        ),
        GoalItem(
          id: _id(),
          title: 'Viaggio',
          targetAmount: 2500,
          savedAmount: 600,
          description: 'Budget dedicato al prossimo viaggio.',
        ),
      ];
      await _save();
    } else {
      List<dynamic> items(String key) => j[key] as List<dynamic>? ?? const [];
      tasks = items(
        'tasks',
      ).map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e))).toList();
      reminders = items('reminders')
          .map((e) => ReminderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      deadlines = items('deadlines')
          .map((e) => DeadlineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      movements = items(
        'movements',
      ).map((e) => Movement.fromJson(Map<String, dynamic>.from(e))).toList();
      debts = items(
        'debts',
      ).map((e) => DebtItem.fromJson(Map<String, dynamic>.from(e))).toList();
      recurringExpenses = items('recurringExpenses')
          .map((e) => RecurringExpense.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      goals = items(
        'goals',
      ).map((e) => GoalItem.fromJson(Map<String, dynamic>.from(e))).toList();
      books = items(
        'books',
      ).map((e) => BookItem.fromJson(Map<String, dynamic>.from(e))).toList();
      cycleItems = items(
        'cycleItems',
      ).map((e) => CycleItem.fromJson(Map<String, dynamic>.from(e))).toList();
      calendarItems = items('calendarItems')
          .map((e) => CalendarItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      projects = items(
        'projects',
      ).map((e) => ProjectItem.fromJson(Map<String, dynamic>.from(e))).toList();
      photoWidgets = items('photoWidgets')
          .map((e) => PhotoWidgetItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      darkMode = j['darkMode'] ?? false;
      themeSeedValue = (j['themeSeedValue'] as num?)?.toInt() ?? 0xff6558d3;
      backgroundImageBase64 = j['backgroundImageBase64'] as String?;
      monthlySalary = (j['monthlySalary'] as num?)?.toDouble() ?? 0;
    }
    ready = true;
    notifyListeners();
  }

  Future<void> _save() => store.save({
    'tasks': tasks.map((e) => e.toJson()).toList(),
    'reminders': reminders.map((e) => e.toJson()).toList(),
    'deadlines': deadlines.map((e) => e.toJson()).toList(),
    'movements': movements.map((e) => e.toJson()).toList(),
    'debts': debts.map((e) => e.toJson()).toList(),
    'recurringExpenses': recurringExpenses.map((e) => e.toJson()).toList(),
    'goals': goals.map((e) => e.toJson()).toList(),
    'books': books.map((e) => e.toJson()).toList(),
    'cycleItems': cycleItems.map((e) => e.toJson()).toList(),
    'calendarItems': calendarItems.map((e) => e.toJson()).toList(),
    'projects': projects.map((e) => e.toJson()).toList(),
    'photoWidgets': photoWidgets.map((e) => e.toJson()).toList(),
    'darkMode': darkMode,
    'themeSeedValue': themeSeedValue,
    'backgroundImageBase64': backgroundImageBase64,
    'monthlySalary': monthlySalary,
  });
  void addTask(String v) {
    tasks.add(TaskItem(id: _id(), title: v));
    _changed();
  }

  void toggleTask(TaskItem v) {
    v.done = !v.done;
    _changed();
  }

  void updateTaskTitle(TaskItem task, String title) {
    task.title = title;
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

  void addDebt(String person, double totalAmount, double paidAmount) {
    debts.add(
      DebtItem(
        id: _id(),
        person: person,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
      ),
    );
    _changed();
  }

  void updateDebt(
    DebtItem debt,
    String person,
    double totalAmount,
    double paidAmount,
  ) {
    debt.person = person;
    debt.totalAmount = totalAmount;
    debt.paidAmount = paidAmount;
    _changed();
  }

  void removeDebt(DebtItem debt) {
    debts.remove(debt);
    _changed();
  }

  void setMonthlySalary(double amount) {
    monthlySalary = amount;
    _changed();
  }

  void addRecurringExpense(String title, double amount) {
    recurringExpenses.add(
      RecurringExpense(id: _id(), title: title, amount: amount),
    );
    _changed();
  }

  void updateRecurringExpense(
    RecurringExpense expense,
    String title,
    double amount,
  ) {
    expense.title = title;
    expense.amount = amount;
    _changed();
  }

  void removeRecurringExpense(RecurringExpense expense) {
    recurringExpenses.remove(expense);
    _changed();
  }

  void addGoal(String title) {
    goals.add(GoalItem(id: _id(), title: title));
    _changed();
  }

  void setGoal(GoalItem goal, double value) {
    goal.savedAmount = goal.targetAmount * value;
    _changed();
  }

  void addEconomicGoal(
    String title,
    double targetAmount,
    double savedAmount,
    String description,
  ) {
    goals.add(
      GoalItem(
        id: _id(),
        title: title,
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        description: description,
      ),
    );
    _changed();
  }

  void updateGoal(
    GoalItem goal,
    String title,
    double targetAmount,
    double savedAmount,
    String description,
  ) {
    goal.title = title;
    goal.targetAmount = targetAmount;
    goal.savedAmount = savedAmount;
    goal.description = description;
    _changed();
  }

  void removeGoal(GoalItem value) {
    goals.remove(value);
    _changed();
  }

  void addBook(String title) {
    books.add(BookItem(id: _id(), title: title));
    _changed();
  }

  void updateBook(BookItem book, String title) {
    book.title = title;
    _changed();
  }

  void removeBook(BookItem book) {
    books.remove(book);
    _changed();
  }

  void reorderBooks(int oldIndex, int newIndex) {
    final book = books.removeAt(oldIndex);
    books.insert(newIndex, book);
    _changed();
  }

  void addCycleItem(String title) {
    cycleItems.add(CycleItem(id: _id(), title: title));
    _changed();
  }

  void updateCycleItem(CycleItem item, String title) {
    item.title = title;
    _changed();
  }

  void removeCycleItem(CycleItem item) {
    cycleItems.remove(item);
    _changed();
  }

  void addCalendarItem(String title, DateTime date) {
    calendarItems.add(CalendarItem(id: _id(), title: title, date: date));
    _changed();
  }

  void updateCalendarItem(CalendarItem item, String title, DateTime date) {
    item.title = title;
    item.date = date;
    _changed();
  }

  void toggleCalendarItem(CalendarItem item) {
    item.done = !item.done;
    _changed();
  }

  void removeCalendarItem(CalendarItem item) {
    calendarItems.remove(item);
    _changed();
  }

  void addProject(String title) {
    projects.add(ProjectItem(id: _id(), title: title));
    _changed();
  }

  void updateProject(ProjectItem project, String title) {
    project.title = title;
    _changed();
  }

  void removeProject(ProjectItem project) {
    projects.remove(project);
    _changed();
  }

  void addProjectTask(ProjectItem project, String title, DateTime? deadline) {
    project.tasks.add(ProjectTask(id: _id(), title: title, deadline: deadline));
    _changed();
  }

  void addProjectFolder(ProjectItem project, String title) {
    project.folders.add(ProjectFolder(id: _id(), title: title));
    _changed();
  }

  void updateProjectFolder(ProjectFolder folder, String title) {
    folder.title = title;
    _changed();
  }

  void removeProjectFolder(ProjectItem project, ProjectFolder folder) {
    project.folders.remove(folder);
    _changed();
  }

  void addProjectFolderTask(
    ProjectFolder folder,
    String title,
    DateTime? deadline,
  ) {
    folder.tasks.add(ProjectTask(id: _id(), title: title, deadline: deadline));
    _changed();
  }

  void updateProjectTask(ProjectTask task, String title, DateTime? deadline) {
    task.title = title;
    task.deadline = deadline;
    _changed();
  }

  void toggleProjectTask(ProjectTask task) {
    task.done = !task.done;
    _changed();
  }

  void removeProjectTask(ProjectItem project, ProjectTask task) {
    project.tasks.remove(task);
    for (final folder in project.folders) {
      folder.tasks.remove(task);
    }
    _changed();
  }

  void setDark(bool value) {
    darkMode = value;
    _changed();
  }

  void setThemeSeed(int value) {
    themeSeedValue = value;
    _changed();
  }

  void setBackgroundImage(String? imageBase64) {
    backgroundImageBase64 = imageBase64;
    _changed();
  }

  void addPhotoWidget(String imageBase64, String caption) {
    photoWidgets.add(
      PhotoWidgetItem(id: _id(), imageBase64: imageBase64, caption: caption),
    );
    _changed();
  }

  void updatePhotoWidgetCaption(PhotoWidgetItem photo, String caption) {
    photo.caption = caption;
    _changed();
  }

  void removePhotoWidget(PhotoWidgetItem photo) {
    photoWidgets.remove(photo);
    _changed();
  }

  void _changed() {
    notifyListeners();
    _save();
  }
}
