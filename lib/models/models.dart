class TaskItem {
  TaskItem({required this.id, required this.title, this.done = false});
  final String id;
  String title;
  bool done;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
  factory TaskItem.fromJson(Map<String, dynamic> j) =>
      TaskItem(id: j['id'], title: j['title'], done: j['done'] ?? false);
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

class GoalItem {
  GoalItem({required this.id, required this.title, this.progress = 0});
  final String id;
  String title;
  double progress;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'progress': progress,
  };
  factory GoalItem.fromJson(Map<String, dynamic> j) => GoalItem(
    id: j['id'],
    title: j['title'],
    progress: (j['progress'] as num?)?.toDouble() ?? 0,
  );
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

  factory CalendarItem.fromJson(Map<String, dynamic> json) => CalendarItem(
    id: json['id'] as String,
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
    done: json['done'] as bool? ?? false,
  );
}

class ProjectTask {
  ProjectTask({
    required this.id,
    required this.title,
    this.deadline,
    this.done = false,
  });

  final String id;
  String title;
  DateTime? deadline;
  bool done;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'deadline': deadline?.toIso8601String(),
    'done': done,
  };

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
    id: json['id'] as String,
    title: json['title'] as String,
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
    done: json['done'] as bool? ?? false,
  );
}

class ProjectItem {
  ProjectItem({required this.id, required this.title, List<ProjectTask>? tasks})
    : tasks = tasks ?? [];

  final String id;
  String title;
  final List<ProjectTask> tasks;

  double get progress => tasks.isEmpty
      ? 0
      : tasks.where((task) => task.done).length / tasks.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'tasks': tasks.map((task) => task.toJson()).toList(),
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
  );
}
