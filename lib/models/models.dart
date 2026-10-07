class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    this.time,
    this.done = false,
  });
  final String id;
  String title;
  String? time;
  bool done;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time,
    'done': done,
  };
  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
    id: j['id'],
    title: j['title'],
    time: j['time'] as String?,
    done: j['done'] ?? false,
  );
}

class ReminderItem {
  ReminderItem({required this.id, required this.title, required this.time});
  final String id;
  String title;
  String time;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'time': time};
  factory ReminderItem.fromJson(Map<String, dynamic> j) =>
      ReminderItem(id: j['id'], title: j['title'], time: j['time']);
}

class DeadlineItem {
  DeadlineItem({
    required this.id,
    required this.title,
    required this.date,
    this.done = false,
  });
  final String id;
  String title;
  DateTime date;
  bool done;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'done': done,
  };
  factory DeadlineItem.fromJson(Map<String, dynamic> j) => DeadlineItem(
    id: j['id'],
    title: j['title'],
    date: DateTime.parse(j['date']),
    done: j['done'] ?? false,
  );
}

class Movement {
  Movement({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
  });
  final String id;
  String label;
  double amount;
  DateTime date;
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'amount': amount,
    'date': date.toIso8601String(),
  };
  factory Movement.fromJson(Map<String, dynamic> j) => Movement(
    id: j['id'],
    label: j['label'],
    amount: (j['amount'] as num).toDouble(),
    date: DateTime.parse(j['date']),
  );
}

class DebtItem {
  DebtItem({
    required this.id,
    required this.person,
    required this.totalAmount,
    this.paidAmount = 0,
  });

  final String id;
  String person;
  double totalAmount;
  double paidAmount;

  double get remaining => (totalAmount - paidAmount).clamp(0, double.infinity);
  double get progress =>
      totalAmount <= 0 ? 0 : (paidAmount / totalAmount).clamp(0, 1);

  Map<String, dynamic> toJson() => {
    'id': id,
    'person': person,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
  };

  factory DebtItem.fromJson(Map<String, dynamic> json) => DebtItem(
    id: json['id'] as String,
    person: json['person'] as String,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
  );
}

class RecurringExpense {
  RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
  });

  final String id;
  String title;
  double amount;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'amount': amount};

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      RecurringExpense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

class GoalItem {
  GoalItem({
    required this.id,
    required this.title,
    this.targetAmount = 1000,
    this.savedAmount = 0,
    this.description = '',
    double? progress,
  }) {
    if (progress != null && savedAmount == 0) {
      savedAmount = targetAmount * progress;
    }
  }

  final String id;
  String title;
  double targetAmount;
  double savedAmount;
  String description;

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'description': description,
  };

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    final target = (json['targetAmount'] as num?)?.toDouble() ?? 1000;
    final saved = (json['savedAmount'] as num?)?.toDouble();
    final legacyProgress = (json['progress'] as num?)?.toDouble() ?? 0;
    return GoalItem(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: target,
      savedAmount: saved ?? target * legacyProgress,
      description: json['description'] as String? ?? '',
    );
  }
}

class BookItem {
  BookItem({required this.id, required this.title});

  final String id;
  String title;

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  factory BookItem.fromJson(Map<String, dynamic> json) =>
      BookItem(id: json['id'] as String, title: json['title'] as String);
}

class CycleItem {
  CycleItem({required this.id, required this.title});

  final String id;
  String title;

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  factory CycleItem.fromJson(Map<String, dynamic> json) =>
      CycleItem(id: json['id'] as String, title: json['title'] as String);
}

class CalendarItem {
  CalendarItem({
    required this.id,
    required this.title,
    required this.date,
    this.done = false,
    this.projectTaskId,
  });

  final String id;
  String title;
  DateTime date;
  bool done;
  final String? projectTaskId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'done': done,
    if (projectTaskId != null) 'projectTaskId': projectTaskId,
  };

  factory CalendarItem.fromJson(Map<String, dynamic> json) => CalendarItem(
    id: json['id'] as String,
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
    done: json['done'] as bool? ?? false,
    projectTaskId: json['projectTaskId'] as String?,
  );
}

class ProjectTask {
  ProjectTask({
    required this.id,
    required this.title,
    this.deadline,
    this.done = false,
    this.priority,
  });

  final String id;
  String title;
  DateTime? deadline;
  bool done;
  int? priority;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'deadline': deadline?.toIso8601String(),
    'done': done,
    'priority': priority,
  };

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
    id: json['id'] as String,
    title: json['title'] as String,
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
    done: json['done'] as bool? ?? false,
    priority: (json['priority'] as num?)?.toInt(),
  );
}

class ProjectFolder {
  ProjectFolder({
    required this.id,
    required this.title,
    this.emoji,
    List<ProjectTask>? tasks,
    List<ProjectFolder>? folders,
  }) : tasks = tasks ?? [],
       folders = folders ?? [];

  final String id;
  String title;
  String? emoji;
  final List<ProjectTask> tasks;
  final List<ProjectFolder> folders;

  Iterable<ProjectTask> get allTasks sync* {
    yield* tasks;
    for (final folder in folders) {
      yield* folder.allTasks;
    }
  }

  Iterable<ProjectFolder> get allFolders sync* {
    for (final folder in folders) {
      yield folder;
      yield* folder.allFolders;
    }
  }

  double get progress => allTasks.isEmpty
      ? 0
      : allTasks.where((task) => task.done).length / allTasks.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'emoji': emoji,
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'folders': folders.map((folder) => folder.toJson()).toList(),
  };

  factory ProjectFolder.fromJson(Map<String, dynamic> json) => ProjectFolder(
    id: json['id'] as String,
    title: json['title'] as String,
    emoji: json['emoji'] as String?,
    tasks: (json['tasks'] as List<dynamic>? ?? const [])
        .map(
          (task) =>
              ProjectTask.fromJson(Map<String, dynamic>.from(task as Map)),
        )
        .toList(),
    folders: (json['folders'] as List<dynamic>? ?? const [])
        .map(
          (folder) =>
              ProjectFolder.fromJson(Map<String, dynamic>.from(folder as Map)),
        )
        .toList(),
  );
}

class ProjectItem {
  ProjectItem({
    required this.id,
    required this.title,
    List<ProjectTask>? tasks,
    List<ProjectFolder>? folders,
  }) : tasks = tasks ?? [],
       folders = folders ?? [];

  final String id;
  String title;
  final List<ProjectTask> tasks;
  final List<ProjectFolder> folders;

  Iterable<ProjectTask> get allTasks sync* {
    yield* tasks;
    for (final folder in folders) {
      yield* folder.allTasks;
    }
  }

  Iterable<ProjectFolder> get allFolders sync* {
    for (final folder in folders) {
      yield folder;
      yield* folder.allFolders;
    }
  }

  double get progress => allTasks.isEmpty
      ? 0
      : allTasks.where((task) => task.done).length / allTasks.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tasks': tasks.map((task) => task.toJson()).toList(),
    'folders': folders.map((folder) => folder.toJson()).toList(),
  };

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
    id: json['id'] as String,
    title: json['title'] as String,
    tasks: (json['tasks'] as List<dynamic>? ?? const [])
        .map(
          (task) =>
              ProjectTask.fromJson(Map<String, dynamic>.from(task as Map)),
        )
        .toList(),
    folders: (json['folders'] as List<dynamic>? ?? const [])
        .map(
          (folder) =>
              ProjectFolder.fromJson(Map<String, dynamic>.from(folder as Map)),
        )
        .toList(),
  );
}

class PhotoWidgetItem {
  PhotoWidgetItem({
    required this.id,
    required this.imageBase64,
    this.caption = '',
  });

  final String id;
  String imageBase64;
  String caption;

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageBase64': imageBase64,
    'caption': caption,
  };

  factory PhotoWidgetItem.fromJson(Map<String, dynamic> json) =>
      PhotoWidgetItem(
        id: json['id'] as String,
        imageBase64: json['imageBase64'] as String,
        caption: json['caption'] as String? ?? '',
      );
}

class ChecklistEntry {
  ChecklistEntry({required this.id, required this.title, this.done = false});

  final String id;
  String title;
  bool done;

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};

  factory ChecklistEntry.fromJson(Map<String, dynamic> json) => ChecklistEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    done: json['done'] as bool? ?? false,
  );
}

class ChecklistFolder {
  ChecklistFolder({
    required this.id,
    required this.title,
    List<ChecklistEntry>? entries,
  }) : entries = entries ?? [];

  final String id;
  String title;
  final List<ChecklistEntry> entries;

  double get progress => entries.isEmpty
      ? 0
      : entries.where((entry) => entry.done).length / entries.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'entries': entries.map((entry) => entry.toJson()).toList(),
  };

  factory ChecklistFolder.fromJson(
    Map<String, dynamic> json,
  ) => ChecklistFolder(
    id: json['id'] as String,
    title: json['title'] as String,
    entries: (json['entries'] as List<dynamic>? ?? const [])
        .map(
          (entry) =>
              ChecklistEntry.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(),
  );
}

enum RoutinePeriod { day, week, month }

class RoutineItem {
  RoutineItem({
    required this.id,
    required this.title,
    required this.targetCount,
    required this.period,
    List<DateTime>? completions,
  }) : completions = completions ?? [];

  final String id;
  String title;
  int targetCount;
  RoutinePeriod period;
  final List<DateTime> completions;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetCount': targetCount,
    'period': period.name,
    'completions': completions
        .map((completion) => completion.toIso8601String())
        .toList(),
  };

  factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
    id: json['id'] as String,
    title: json['title'] as String,
    targetCount: (json['targetCount'] as num?)?.toInt() ?? 1,
    period: RoutinePeriod.values.firstWhere(
      (period) => period.name == json['period'],
      orElse: () => RoutinePeriod.day,
    ),
    completions: (json['completions'] as List<dynamic>? ?? const [])
        .map((completion) => DateTime.parse(completion as String))
        .toList(),
  );
}
