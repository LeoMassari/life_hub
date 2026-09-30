import 'package:flutter/foundation.dart';
import '../data/local_store.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState(this.store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final AppStore store;
  final DateTime Function() _clock;
  bool ready = false;
  bool darkMode = false;
  int themeSeedValue = 0xff6558d3;
  String? backgroundImageBase64;
  double monthlySalary = 0;
  List<TaskItem> tasks = [];
  List<TaskItem> tomorrowTasks = [];
  List<TaskItem> incompleteTasks = [];
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
  List<ChecklistFolder> checklistFolders = [];
  List<RoutineItem> routines = [];
  Map<String, bool> sectionVisibility = {};
  Map<String, List<String>> sectionOrder = {};
  Map<String, String> pageBackgroundImages = {};
  Map<String, bool> pageUsesCustomBackground = {};
  double backgroundTransparency = 0.82;
  double panelTransparency = 0;
  bool bedtimeMode = false;
  int dayResetHour = 4;
  late DateTime activeDay;
  int _idCounter = 0;
  String _id() => '${_clock().microsecondsSinceEpoch}-${_idCounter++}';

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _effectiveDay(DateTime value) =>
      _dateOnly(value.subtract(Duration(hours: dayResetHour)));

  String _dayToJson(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  TaskItem _freshTask(TaskItem task) =>
      TaskItem(id: task.id, title: task.title, time: task.time);

  Future<void> init() async {
    final j = await store.load();
    if (j == null) {
      activeDay = _effectiveDay(_clock());
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
      tomorrowTasks = items(
        'tomorrowTasks',
      ).map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e))).toList();
      incompleteTasks = items(
        'incompleteTasks',
      ).map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e))).toList();
      checklistFolders = items('checklistFolders')
          .map((e) => ChecklistFolder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      routines = items(
        'routines',
      ).map((e) => RoutineItem.fromJson(Map<String, dynamic>.from(e))).toList();
      darkMode = j['darkMode'] ?? false;
      themeSeedValue = (j['themeSeedValue'] as num?)?.toInt() ?? 0xff6558d3;
      backgroundImageBase64 = j['backgroundImageBase64'] as String?;
      monthlySalary = (j['monthlySalary'] as num?)?.toDouble() ?? 0;
      bedtimeMode = j['bedtimeMode'] as bool? ?? false;
      dayResetHour = ((j['dayResetHour'] as num?)?.toInt() ?? 4).clamp(0, 23);
      sectionVisibility = Map<String, bool>.from(
        j['sectionVisibility'] as Map? ?? const {},
      );
      sectionOrder = (j['sectionOrder'] as Map? ?? const {}).map(
        (key, value) =>
            MapEntry(key.toString(), List<String>.from(value as List<dynamic>)),
      );
      pageBackgroundImages = Map<String, String>.from(
        j['pageBackgroundImages'] as Map? ?? const {},
      );
      pageUsesCustomBackground = Map<String, bool>.from(
        j['pageUsesCustomBackground'] as Map? ?? const {},
      );
      backgroundTransparency =
          (j['backgroundTransparency'] as num?)?.toDouble().clamp(0, 0.95) ??
          0.82;
      panelTransparency =
          (j['panelTransparency'] as num?)?.toDouble().clamp(0, 0.8) ?? 0;
      final savedActiveDay = j['activeDay'] as String?;
      activeDay = savedActiveDay == null
          ? _effectiveDay(_clock())
          : DateTime.parse(savedActiveDay);
      if (_rolloverIfNeeded()) await _save();
    }
    ready = true;
    notifyListeners();
  }

  Future<void> _save() => store.save({
    'tasks': tasks.map((e) => e.toJson()).toList(),
    'tomorrowTasks': tomorrowTasks.map((e) => e.toJson()).toList(),
    'incompleteTasks': incompleteTasks.map((e) => e.toJson()).toList(),
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
    'checklistFolders': checklistFolders.map((e) => e.toJson()).toList(),
    'routines': routines.map((e) => e.toJson()).toList(),
    'darkMode': darkMode,
    'themeSeedValue': themeSeedValue,
    'backgroundImageBase64': backgroundImageBase64,
    'monthlySalary': monthlySalary,
    'sectionVisibility': sectionVisibility,
    'sectionOrder': sectionOrder,
    'pageBackgroundImages': pageBackgroundImages,
    'pageUsesCustomBackground': pageUsesCustomBackground,
    'backgroundTransparency': backgroundTransparency,
    'panelTransparency': panelTransparency,
    'bedtimeMode': bedtimeMode,
    'dayResetHour': dayResetHour,
    'activeDay': _dayToJson(activeDay),
  });
  void addTask(String title, {String? time}) {
    tasks.add(TaskItem(id: _id(), title: title, time: time));
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

  void updateTask(TaskItem task, String title, String? time) {
    task.title = title;
    task.time = time;
    _changed();
  }

  void removeTask(TaskItem value) {
    tasks.remove(value);
    _changed();
  }

  void addTomorrowTask(String title, {String? time}) {
    tomorrowTasks.add(TaskItem(id: _id(), title: title, time: time));
    _changed();
  }

  void updateTomorrowTask(TaskItem task, String title, String? time) {
    task.title = title;
    task.time = time;
    _changed();
  }

  void removeTomorrowTask(TaskItem task) {
    tomorrowTasks.remove(task);
    _changed();
  }

  void restoreIncompleteTask(TaskItem task) {
    incompleteTasks.remove(task);
    tasks.add(_freshTask(task));
    _changed();
  }

  void removeIncompleteTask(TaskItem task) {
    incompleteTasks.remove(task);
    _changed();
  }

  bool _rolloverIfNeeded() {
    final target = _effectiveDay(_clock());
    var changed = false;
    while (activeDay.isBefore(target)) {
      _rollForwardOneDay();
      changed = true;
    }
    return changed;
  }

  void _rollForwardOneDay() {
    incompleteTasks.addAll(tasks.where((task) => !task.done).map(_freshTask));
    tasks = tomorrowTasks.map(_freshTask).toList();
    tomorrowTasks = [];
    activeDay = activeDay.add(const Duration(days: 1));
  }

  void checkDayRollover() {
    if (_rolloverIfNeeded()) _changed();
  }

  bool startNextDay() {
    if (!canStartNextDay) return false;
    if (bedtimeMode && tomorrowTasks.isEmpty) return false;
    _rollForwardOneDay();
    _changed();
    return true;
  }

  bool get canStartNextDay => !activeDay.isAfter(_effectiveDay(_clock()));

  bool isSectionVisible(String pageId, String sectionId) =>
      sectionVisibility['$pageId::$sectionId'] ?? true;

  void setSectionVisible(String pageId, String sectionId, bool visible) {
    sectionVisibility['$pageId::$sectionId'] = visible;
    _changed();
  }

  void setSectionOrder(String pageId, List<String> order) {
    sectionOrder[pageId] = List<String>.from(order);
    _changed();
  }

  String? backgroundForPage(String pageId) =>
      pageUsesCustomBackground[pageId] == true
      ? pageBackgroundImages[pageId]
      : backgroundImageBase64;

  bool usesCustomBackgroundForPage(String pageId) =>
      pageUsesCustomBackground[pageId] ?? false;

  void setPageUsesCustomBackground(String pageId, bool value) {
    pageUsesCustomBackground[pageId] = value;
    _changed();
  }

  void setPageBackgroundImage(String pageId, String imageBase64) {
    pageBackgroundImages[pageId] = imageBase64;
    pageUsesCustomBackground[pageId] = true;
    _changed();
  }

  void removePageBackgroundImage(String pageId) {
    pageBackgroundImages.remove(pageId);
    pageUsesCustomBackground[pageId] = false;
    _changed();
  }

  void setBackgroundTransparency(double value) {
    backgroundTransparency = value.clamp(0, 0.95);
    _changed();
  }

  void setPanelTransparency(double value) {
    panelTransparency = value.clamp(0, 0.8);
    _changed();
  }

  void setBedtimeMode(bool value) {
    bedtimeMode = value;
    _changed();
  }

  void setDayResetHour(int value) {
    dayResetHour = value.clamp(0, 23);
    _rolloverIfNeeded();
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

  void scheduleProjectTask(ProjectTask task, DateTime date) {
    task.deadline = date;
    CalendarItem? scheduledItem;
    for (final item in calendarItems) {
      if (item.projectTaskId == task.id) {
        scheduledItem = item;
        break;
      }
    }
    if (scheduledItem == null) {
      calendarItems.add(
        CalendarItem(
          id: _id(),
          title: task.title,
          date: date,
          done: task.done,
          projectTaskId: task.id,
        ),
      );
    } else {
      scheduledItem.title = task.title;
      scheduledItem.date = date;
      scheduledItem.done = task.done;
    }
    _changed();
  }

  void updateCalendarItem(CalendarItem item, String title, DateTime date) {
    item.title = title;
    item.date = date;
    final task = _projectTaskById(item.projectTaskId);
    if (task != null) {
      task.title = title;
      task.deadline = date;
    }
    _changed();
  }

  void toggleCalendarItem(CalendarItem item) {
    item.done = !item.done;
    final task = _projectTaskById(item.projectTaskId);
    if (task != null) task.done = item.done;
    _changed();
  }

  void removeCalendarItem(CalendarItem item) {
    calendarItems.remove(item);
    final task = _projectTaskById(item.projectTaskId);
    if (task != null) task.deadline = null;
    _changed();
  }

  ProjectTask? _projectTaskById(String? id) {
    if (id == null) return null;
    for (final project in projects) {
      for (final task in project.allTasks) {
        if (task.id == id) return task;
      }
    }
    return null;
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
    final taskIds = project.allTasks.map((task) => task.id).toSet();
    calendarItems.removeWhere((item) => taskIds.contains(item.projectTaskId));
    projects.remove(project);
    _changed();
  }

  void addProjectTask(ProjectItem project, String title, DateTime? deadline) {
    project.tasks.add(ProjectTask(id: _id(), title: title, deadline: deadline));
    _changed();
  }

  ProjectFolder addProjectFolder(ProjectItem project, String title) {
    final folder = ProjectFolder(id: _id(), title: title);
    project.folders.add(folder);
    _changed();
    return folder;
  }

  void updateProjectFolder(ProjectFolder folder, String title) {
    folder.title = title;
    _changed();
  }

  void removeProjectFolder(ProjectItem project, ProjectFolder folder) {
    final taskIds = folder.tasks.map((task) => task.id).toSet();
    calendarItems.removeWhere((item) => taskIds.contains(item.projectTaskId));
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
    for (final item in calendarItems) {
      if (item.projectTaskId == task.id) {
        item.title = title;
        if (deadline != null) item.date = deadline;
      }
    }
    _changed();
  }

  void toggleProjectTask(ProjectTask task) {
    task.done = !task.done;
    for (final item in calendarItems) {
      if (item.projectTaskId == task.id) item.done = task.done;
    }
    _changed();
  }

  void moveProjectTask(
    ProjectItem project,
    ProjectTask task,
    ProjectFolder? destination,
  ) {
    project.tasks.remove(task);
    for (final folder in project.folders) {
      folder.tasks.remove(task);
    }
    if (destination == null) {
      project.tasks.add(task);
    } else {
      destination.tasks.add(task);
    }
    _changed();
  }

  void removeProjectTask(ProjectItem project, ProjectTask task) {
    project.tasks.remove(task);
    for (final folder in project.folders) {
      folder.tasks.remove(task);
    }
    calendarItems.removeWhere((item) => item.projectTaskId == task.id);
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

  void addChecklistFolder(String title) {
    checklistFolders.add(ChecklistFolder(id: _id(), title: title));
    _changed();
  }

  void updateChecklistFolder(ChecklistFolder folder, String title) {
    folder.title = title;
    _changed();
  }

  void removeChecklistFolder(ChecklistFolder folder) {
    checklistFolders.remove(folder);
    _changed();
  }

  void addChecklistEntry(ChecklistFolder folder, String title) {
    folder.entries.add(ChecklistEntry(id: _id(), title: title));
    _changed();
  }

  void updateChecklistEntry(ChecklistEntry entry, String title) {
    entry.title = title;
    _changed();
  }

  void toggleChecklistEntry(ChecklistEntry entry) {
    entry.done = !entry.done;
    _changed();
  }

  void removeChecklistEntry(ChecklistFolder folder, ChecklistEntry entry) {
    folder.entries.remove(entry);
    _changed();
  }

  void addRoutine(String title, int targetCount, RoutinePeriod period) {
    routines.add(
      RoutineItem(
        id: _id(),
        title: title,
        targetCount: targetCount,
        period: period,
      ),
    );
    _changed();
  }

  void updateRoutine(
    RoutineItem routine,
    String title,
    int targetCount,
    RoutinePeriod period,
  ) {
    routine.title = title;
    routine.targetCount = targetCount;
    routine.period = period;
    _changed();
  }

  void removeRoutine(RoutineItem routine) {
    routines.remove(routine);
    _changed();
  }

  void completeRoutine(RoutineItem routine) {
    routine.completions.add(_clock());
    _changed();
  }

  void undoLastRoutineCompletion(RoutineItem routine) {
    if (routine.completions.isEmpty) return;
    routine.completions.sort();
    routine.completions.removeLast();
    _changed();
  }

  void _changed() {
    notifyListeners();
    _save();
  }
}
