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
