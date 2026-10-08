enum AssistantActionType { inbox, todayTask, projectTask, calendar }

class AssistantProjectReference {
  const AssistantProjectReference({
    required this.projectName,
    this.folderPaths = const [],
  });

  final String projectName;
  final List<String> folderPaths;
}

class AssistantActionDraft {
  const AssistantActionDraft({
    required this.type,
    required this.title,
    this.projectName,
    this.folderPath,
    this.date,
  });

  final AssistantActionType type;
  final String title;
  final String? projectName;
  final String? folderPath;
  final DateTime? date;
}

class LocalAssistantService {
  const LocalAssistantService();

  AssistantActionDraft? interpret(
    String input, {
    required List<AssistantProjectReference> projects,
    DateTime? today,
  }) {
    final original = input.trim();
    if (original.isEmpty) return null;
    final normalized = _normalize(original);
    final referenceDate = _dateOnly(today ?? DateTime.now());
    final date = _extractDate(normalized, referenceDate);
    final project = _findProject(normalized, projects);
    final folderPath = project == null
        ? null
        : _findFolder(normalized, project.folderPaths);
    final mentionsInbox = RegExp(
      r"\b(?:inbox|posta in arrivo)\b",
    ).hasMatch(normalized);
    final mentionsToday = RegExp(
      r"\b(?:in|a|ad|alle|nelle)\s+(?:attivit[aà]\s+(?:di\s+)?)?oggi\b",
    ).hasMatch(normalized);
    final mentionsCalendar =
        normalized.contains('calendario') ||
        normalized.startsWith('programma ') ||
        normalized.startsWith('pianifica ');

    final type = project != null
        ? AssistantActionType.projectTask
        : mentionsInbox
        ? AssistantActionType.inbox
        : mentionsCalendar && date != null
        ? AssistantActionType.calendar
        : mentionsToday
        ? AssistantActionType.todayTask
        : null;
    if (type == null) return null;

    final title = _extractTitle(original, normalized);
    if (title.isEmpty) return null;
    return AssistantActionDraft(
      type: type,
      title: title,
      projectName: project?.projectName,
      folderPath: folderPath,
      date: date,
    );
  }

  AssistantProjectReference? _findProject(
    String normalized,
    List<AssistantProjectReference> projects,
  ) {
    final sorted = [...projects]
      ..sort((a, b) => b.projectName.length.compareTo(a.projectName.length));
    for (final project in sorted) {
      final name = _normalize(project.projectName);
      if (normalized.contains('progetto $name')) return project;
    }
    return null;
  }

  String? _findFolder(String normalized, List<String> folderPaths) {
    final sorted = [...folderPaths]
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final path in sorted) {
      final folderName = path.split('/').last.trim();
      if (normalized.contains('cartella ${_normalize(folderName)}')) {
        return path;
      }
    }
    return null;
  }

  DateTime? _extractDate(String normalized, DateTime today) {
    if (normalized.contains('dopodomani')) {
      return today.add(const Duration(days: 2));
    }
    if (normalized.contains('domani')) {
      return today.add(const Duration(days: 1));
    }
    if (RegExp(r'\boggi\b').hasMatch(normalized)) return today;

    final match = RegExp(
      r'\b(\d{1,2})[\/.\-](\d{1,2})(?:[\/.\-](\d{2,4}))?\b',
    ).firstMatch(normalized);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    var year = match.group(3) == null
        ? today.year
        : int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    final result = DateTime(year, month, day);
    if (result.year != year || result.month != month || result.day != day) {
      return null;
    }
    if (match.group(3) == null && result.isBefore(today)) {
      return DateTime(year + 1, month, day);
    }
    return result;
  }

  String _extractTitle(String original, String normalized) {
    var title = original.trim();
    title = title.replaceFirst(
      RegExp(
        r'^(?:aggiungi|metti|crea|programma|pianifica|ricordami(?:\s+di)?)\s+',
        caseSensitive: false,
      ),
      '',
    );

    final normalizedTitle = _normalize(title);
    final markers = [
      ' in inbox',
      ' a inbox',
      ' ad inbox',
      ' in posta in arrivo',
      ' a posta in arrivo',
      ' ad posta in arrivo',
      " nell'inbox",
      ' nell’inbox',
      " all'inbox",
      ' all’inbox',
      ' in oggi',
      ' a oggi',
      ' ad oggi',
      ' nelle attivita di oggi',
      ' nelle attività di oggi',
      ' alle attivita di oggi',
      ' alle attività di oggi',
      ' nel progetto ',
      ' al progetto ',
      ' in progetto ',
      ' a progetto ',
      ' ad progetto ',
      ' sul calendario',
      ' nel calendario',
      ' in calendario',
      ' a calendario',
      ' ad calendario',
      ' nella cartella ',
      ' in cartella ',
      ' a cartella ',
      ' ad cartella ',
    ];
    var end = title.length;
    for (final marker in markers) {
      final index = normalizedTitle.indexOf(marker);
      if (index >= 0 && index < end) end = index;
    }
    title = title.substring(0, end);
    title = title.replaceAll(
      RegExp(r'\b(?:oggi|domani|dopodomani)\b', caseSensitive: false),
      '',
    );
    title = title.replaceAll(
      RegExp(r'\b(?:il\s+)?\d{1,2}[\/.\-]\d{1,2}(?:[\/.\-]\d{2,4})?\b'),
      '',
    );
    return title.replaceAll(RegExp(r'^[\s:;,\.\-]+|[\s:;,\.\-]+$'), '').trim();
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
