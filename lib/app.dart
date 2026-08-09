import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'data/local_store.dart';
import 'models/models.dart';
import 'state/app_state.dart';

class LifeHubApp extends StatefulWidget {
  const LifeHubApp({super.key, this.store, this.cloudEmail, this.onSignOut});
  final AppStore? store;
  final String? cloudEmail;
  final Future<void> Function()? onSignOut;
  @override
  State<LifeHubApp> createState() => _LifeHubAppState();
}

class _LifeHubAppState extends State<LifeHubApp> {
  late final AppState state;
  @override
  void initState() {
    super.initState();
    state = AppState(widget.store ?? LocalStore())..addListener(_refresh);
    state.init();
  }

  void _refresh() => setState(() {});
  @override
  void dispose() {
    state.removeListener(_refresh);
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Life Hub',
    locale: const Locale('it'),
    supportedLocales: const [Locale('it')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
    theme: _theme(Brightness.light, Color(state.themeSeedValue)),
    darkTheme: _theme(Brightness.dark, Color(state.themeSeedValue)),
    home: state.ready
        ? LifeHubShell(
            state: state,
            cloudEmail: widget.cloudEmail,
            onSignOut: widget.onSignOut,
          )
        : const Scaffold(body: Center(child: CircularProgressIndicator())),
  );
}

ThemeData _theme(Brightness b, Color seedColor) {
  final dark = b == Brightness.dark;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: b),
    useMaterial3: true,
    scaffoldBackgroundColor: dark
        ? const Color(0xff101114)
        : const Color(0xfff7f7fb),
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
  );
}

MemoryImage? _memoryImage(String? imageBase64) {
  if (imageBase64 == null || imageBase64.isEmpty) return null;
  try {
    return MemoryImage(base64Decode(imageBase64));
  } on FormatException {
    return null;
  }
}

Future<String?> _pickImageBase64(
  BuildContext context, {
  int maxBytes = 600000,
}) async {
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 72,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'L’immagine è troppo grande. Scegline una sotto '
              '${(maxBytes / 1000000).toStringAsFixed(1)} MB.',
            ),
          ),
        );
      }
      return null;
    }
    return base64Encode(bytes);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non è stato possibile aprire la foto.')),
      );
    }
    return null;
  }
}

class LifeHubShell extends StatefulWidget {
  const LifeHubShell({
    super.key,
    required this.state,
    this.cloudEmail,
    this.onSignOut,
  });
  final AppState state;
  final String? cloudEmail;
  final Future<void> Function()? onSignOut;
  @override
  State<LifeHubShell> createState() => _LifeHubShellState();
}

enum HubPage {
  today,
  finance,
  goals,
  deadlines,
  training,
  nutrition,
  study,
  cycles,
  calendar,
  routine,
  checklists,
  settings,
}

class _LifeHubShellState extends State<LifeHubShell> {
  HubPage selectedPage = HubPage.today;
  Timer? _dayTimer;

  @override
  void initState() {
    super.initState();
    _dayTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => widget.state.checkDayRollover(),
    );
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    super.dispose();
  }

  static const primaryDestinations = [
    ('Oggi', Icons.today_outlined),
    ('Finanze', Icons.account_balance_wallet_outlined),
    ('Obiettivi', Icons.flag_outlined),
    ('Scadenze', Icons.event_outlined),
    ('Altro', Icons.apps_outlined),
  ];

  int get primaryIndex => switch (selectedPage) {
    HubPage.today => 0,
    HubPage.finance => 1,
    HubPage.goals => 2,
    HubPage.deadlines => 3,
    _ => 4,
  };

  Widget _page() => switch (selectedPage) {
    HubPage.today => TodayPage(widget.state),
    HubPage.finance => FinancePage(widget.state),
    HubPage.goals => GoalsPage(widget.state),
    HubPage.deadlines => DeadlinesPage(widget.state),
    HubPage.training => WorkInProgressPage(
      state: widget.state,
      title: 'Allenamento',
      subtitle: 'Il tuo spazio dedicato al movimento',
      icon: Icons.fitness_center,
    ),
    HubPage.nutrition => WorkInProgressPage(
      state: widget.state,
      title: 'Alimentazione',
      subtitle: 'Il tuo spazio dedicato all’alimentazione',
      icon: Icons.restaurant_outlined,
    ),
    HubPage.study => StudyPage(widget.state),
    HubPage.cycles => CyclesPage(widget.state),
    HubPage.calendar => CalendarPage(widget.state),
    HubPage.routine => WorkInProgressPage(
      state: widget.state,
      title: 'Routine',
      subtitle: 'Costruisci e monitora le abitudini che contano',
      icon: Icons.repeat,
    ),
    HubPage.checklists => ChecklistsPage(widget.state),
    HubPage.settings => SettingsPage(
      widget.state,
      cloudEmail: widget.cloudEmail,
      onSignOut: widget.onSignOut,
    ),
  };

  void _selectPrimary(BuildContext context, int value) {
    if (value == 4) {
      _showMoreMenu(context);
      return;
    }
    setState(() {
      selectedPage = HubPage.values[value];
    });
  }

  Future<void> _showMoreMenu(BuildContext context) async {
    final page = await showModalBottomSheet<HubPage>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Altre aree',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              _MoreMenuTile(
                page: HubPage.training,
                icon: Icons.fitness_center,
                title: 'Allenamento',
              ),
              _MoreMenuTile(
                page: HubPage.nutrition,
                icon: Icons.restaurant_outlined,
                title: 'Alimentazione',
              ),
              _MoreMenuTile(
                page: HubPage.study,
                icon: Icons.menu_book_outlined,
                title: 'Studio',
              ),
              _MoreMenuTile(
                page: HubPage.cycles,
                icon: Icons.autorenew,
                title: 'Cicli',
              ),
              _MoreMenuTile(
                page: HubPage.calendar,
                icon: Icons.calendar_month_outlined,
                title: 'Calendario',
              ),
              _MoreMenuTile(
                page: HubPage.routine,
                icon: Icons.repeat,
                title: 'Routine',
              ),
              _MoreMenuTile(
                page: HubPage.checklists,
                icon: Icons.checklist_outlined,
                title: 'Check lists',
              ),
              const Divider(),
              _MoreMenuTile(
                page: HubPage.settings,
                icon: Icons.settings_outlined,
                title: 'Impostazioni',
              ),
            ],
          ),
        ),
      ),
    );
    if (page != null && mounted) setState(() => selectedPage = page);
  }

  @override
  Widget build(BuildContext c) {
    return LayoutBuilder(
      builder: (c, box) {
        final wide = box.maxWidth >= 760;
        final nav = primaryDestinations
            .map(
              (d) => NavigationRailDestination(
                icon: Icon(d.$2),
                label: Text(d.$1),
              ),
            )
            .toList();
        final pageContent = Row(
          children: [
            if (wide)
              NavigationRail(
                selectedIndex: primaryIndex,
                onDestinationSelected: (v) => _selectPrimary(c, v),
                labelType: NavigationRailLabelType.all,
                destinations: nav,
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(selectedPage),
                  child: _page(),
                ),
              ),
            ),
          ],
        );
        final background = _memoryImage(widget.state.backgroundImageBase64);
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Life Hub',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(child: Text('${DateTime.now().day}')),
              ),
            ],
          ),
          body: background == null
              ? pageContent
              : DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: background,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ColoredBox(
                    color: Theme.of(
                      c,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.82),
                    child: pageContent,
                  ),
                ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: primaryIndex,
                  onDestinationSelected: (v) => _selectPrimary(c, v),
                  destinations: primaryDestinations
                      .map(
                        (d) => NavigationDestination(
                          icon: Icon(d.$2),
                          label: d.$1,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class _MoreMenuTile extends StatelessWidget {
  const _MoreMenuTile({
    required this.page,
    required this.icon,
    required this.title,
  });

  final HubPage page;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.pop(context, page),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.state,
    this.pageId,
  });
  final String title, subtitle;
  final List<Widget> children;
  final AppState? state;
  final String? pageId;

  Future<void> _editSections(BuildContext context) async {
    final appState = state;
    if (appState == null) return;
    final sections = children.whereType<Section>().toList();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Personalizza $title'),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sections
                    .map(
                      (section) => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(section.title),
                        subtitle: const Text(
                          'I dati restano salvati e sincronizzati nel cloud.',
                        ),
                        value: appState.isSectionVisible(
                          pageId ?? title,
                          section.visibilityId,
                        ),
                        onChanged: (value) {
                          appState.setSectionVisible(
                            pageId ?? title,
                            section.visibilityId,
                            value,
                          );
                          setDialogState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fatto'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final visibleChildren = children.where((child) {
      if (state == null || child is! Section) return true;
      return state!.isSectionVisible(pageId ?? title, child.visibilityId);
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(c).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(c).textTheme.bodyLarge),
                ],
              ),
            ),
            if (state != null)
              TextButton.icon(
                onPressed: () => _editSections(c),
                icon: const Icon(Icons.tune),
                label: const Text('Modifica'),
              ),
          ],
        ),
        const SizedBox(height: 22),
        if (visibleChildren.isEmpty)
          const _EmptyState(
            icon: Icons.visibility_off_outlined,
            message:
                'Tutte le sezioni sono disattivate. Usa Modifica per riattivarle.',
          )
        else
          ...visibleChildren,
      ],
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.id,
  });
  final String title;
  final Widget child;
  final Widget? action;
  final String? id;
  String get visibilityId => id ?? title;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(c).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Dart versions before null-aware collection elements need this form.
                // ignore: use_null_aware_elements
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ),
  );
}

Future<String?> _textDialog(
  BuildContext c,
  String title, {
  String hint = '',
  String initialValue = '',
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: c,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        onTap: () => controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        ),
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, controller.text.trim()),
          child: const Text('Salva'),
        ),
      ],
    ),
  );
}

Future<({String title, String? time})?> _todayTaskDialog(
  BuildContext context, {
  TaskItem? task,
  String dialogTitle = 'Nuova attività',
}) async {
  final titleController = TextEditingController(text: task?.title ?? '');
  String? selectedTime = task?.time;
  String? error;
  final result = await showDialog<({String title, String? time})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(dialogTitle),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Attività',
                  hintText: 'Cosa vuoi fare?',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(selectedTime ?? 'Nessun orario'),
                subtitle: const Text('L’orario è facoltativo'),
                trailing: selectedTime == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        tooltip: 'Rimuovi orario',
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            setDialogState(() => selectedTime = null),
                      ),
                onTap: () async {
                  final parts = selectedTime?.split(':');
                  final initial = parts?.length == 2
                      ? TimeOfDay(
                          hour: int.tryParse(parts![0]) ?? TimeOfDay.now().hour,
                          minute:
                              int.tryParse(parts[1]) ?? TimeOfDay.now().minute,
                        )
                      : TimeOfDay.now();
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: initial,
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedTime =
                          '${picked.hour.toString().padLeft(2, '0')}:'
                          '${picked.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                setDialogState(() => error = 'Inserisci un nome');
                return;
              }
              Navigator.pop(context, (title: title, time: selectedTime));
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  return result;
}

Future<bool> _confirmDelete(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminare questo elemento?'),
        content: Text(name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    ) ??
    false;

Future<({String label, double amount})?> _movementDialog(
  BuildContext context,
) async {
  final labelController = TextEditingController();
  final amountController = TextEditingController();
  var isIncome = false;
  String? error;
  final result = await showDialog<({String label, double amount})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Nuovo movimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Uscita')),
                ButtonSegment(value: true, label: Text('Entrata')),
              ],
              selected: {isIncome},
              onSelectionChanged: (value) =>
                  setDialogState(() => isIncome = value.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                hintText: 'Es. Spesa settimanale',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Importo',
                suffixText: '€',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final label = labelController.text.trim();
              final parsed = double.tryParse(
                amountController.text.trim().replaceAll(',', '.'),
              );
              if (label.isEmpty || parsed == null || parsed <= 0) {
                setDialogState(() => error = 'Inserisci un importo valido');
                return;
              }
              Navigator.pop(context, (
                label: label,
                amount: isIncome ? parsed : -parsed,
              ));
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  labelController.dispose();
  amountController.dispose();
  return result;
}

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

int _daysUntil(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  return target.difference(today).inDays;
}

String _deadlineStatus(DateTime date) {
  final days = _daysUntil(date);
  if (days < 0) return 'Scaduta da ${-days} giorni';
  if (days == 0) return 'Scade oggi';
  if (days == 1) return 'Scade domani';
  return 'Tra $days giorni';
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PhotoWidgetCard extends StatelessWidget {
  const _PhotoWidgetCard({required this.s, required this.photo});

  final AppState s;
  final PhotoWidgetItem photo;

  @override
  Widget build(BuildContext context) {
    final image = _memoryImage(photo.imageBase64);
    return SizedBox(
      width: 250,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: image == null
                  ? const Center(child: Icon(Icons.broken_image_outlined))
                  : Image(image: image, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      photo.caption.isEmpty ? 'La tua foto' : photo.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'caption') {
                        final caption = await _textDialog(
                          context,
                          'Didascalia',
                          initialValue: photo.caption,
                          hint: 'Un ricordo, un luogo, una motivazione…',
                        );
                        if (caption != null) {
                          s.updatePhotoWidgetCaption(photo, caption);
                        }
                      } else if (value == 'delete' &&
                          await _confirmDelete(
                            context,
                            photo.caption.isEmpty
                                ? 'Questa foto'
                                : photo.caption,
                          )) {
                        s.removePhotoWidget(photo);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'caption',
                        child: Text('Modifica didascalia'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Elimina')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayPage extends StatelessWidget {
  const TodayPage(this.s, {super.key});
  final AppState s;

  Widget _timeLabel(BuildContext context, String? time) => time == null
      ? const SizedBox.shrink()
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text(time),
          ],
        );

  @override
  Widget build(BuildContext c) {
    final done = s.tasks.where((e) => e.done).length;
    final balance = s.movements.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final activeDeadlines = s.deadlines.where((item) => !item.done).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final nextDeadline = activeDeadlines.firstOrNull;
    final goalProgress = s.goals.isEmpty
        ? 0
        : s.goals.fold<double>(0, (sum, item) => sum + item.progress) /
              s.goals.length;
    final urgent = activeDeadlines
        .where((item) => _daysUntil(item.date) <= 7)
        .take(3)
        .toList();
    return PageBody(
      title: 'Oggi',
      subtitle: 'La tua giornata a colpo d’occhio',
      state: s,
      pageId: 'today',
      children: [
        Section(
          title: 'Progresso',
          child: Column(
            children: [
              LinearProgressIndicator(
                value: s.tasks.isEmpty ? 0 : done / s.tasks.length,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('$done di ${s.tasks.length} attività completate'),
              ),
            ],
          ),
        ),
        Section(
          title: 'Attività',
          id: 'tasks',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Programma domani'),
                onPressed: () => _showTomorrowPlanner(c, s),
              ),
              IconButton(
                tooltip: 'Aggiungi attività',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await _todayTaskDialog(c);
                  if (result != null) {
                    s.addTask(result.title, time: result.time);
                  }
                },
              ),
            ],
          ),
          child: s.tasks.isEmpty
              ? const Text('Nessuna attività')
              : Column(
                  children: s.tasks
                      .map(
                        (e) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Modifica',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final result = await _todayTaskDialog(
                                    c,
                                    task: e,
                                    dialogTitle: 'Modifica attività',
                                  );
                                  if (result != null) {
                                    s.updateTask(e, result.title, result.time);
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Elimina',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  if (await _confirmDelete(c, e.title)) {
                                    s.removeTask(e);
                                  }
                                },
                              ),
                            ],
                          ),
                          value: e.done,
                          onChanged: (_) => s.toggleTask(e),
                          title: Text(
                            e.title,
                            style: TextStyle(
                              decoration: e.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: e.time == null
                              ? null
                              : _timeLabel(c, e.time),
                        ),
                      )
                      .toList(),
                ),
        ),
        Section(
          title: 'Attività non completate',
          id: 'incomplete_tasks',
          child: s.incompleteTasks.isEmpty
              ? const _EmptyState(
                  icon: Icons.task_alt,
                  message: 'Non ci sono attività rimaste indietro.',
                )
              : Column(
                  children: s.incompleteTasks
                      .map(
                        (task) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history),
                          title: Text(task.title),
                          subtitle: task.time == null
                              ? null
                              : _timeLabel(c, task.time),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Riporta a oggi',
                                icon: const Icon(Icons.redo),
                                onPressed: () => s.restoreIncompleteTask(task),
                              ),
                              IconButton(
                                tooltip: 'Elimina',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  if (await _confirmDelete(c, task.title)) {
                                    s.removeIncompleteTask(task);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        Section(
          title: 'Modalità Buonanotte',
          id: 'bedtime',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.bedtimeMode
                    ? 'La modalità è attiva: prima di chiudere la giornata devi programmare almeno un’attività per domani.'
                    : 'Chiudi la giornata e carica subito le attività programmate per domani.',
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                icon: const Icon(Icons.bedtime_outlined),
                label: const Text('Buonanotte'),
                onPressed: !s.canStartNextDay
                    ? null
                    : () {
                        final advanced = s.startNextDay();
                        if (!advanced) {
                          ScaffoldMessenger.of(c).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Programma almeno un’attività per domani prima di continuare.',
                              ),
                            ),
                          );
                        }
                      },
              ),
              if (s.tomorrowTasks.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('${s.tomorrowTasks.length} attività già programmate'),
              ],
            ],
          ),
        ),
        Section(
          title: 'Promemoria',
          action: IconButton(
            icon: const Icon(Icons.add_alert_outlined),
            onPressed: () async {
              final v = await _textDialog(
                c,
                'Nuovo promemoria',
                hint: 'Es. Prendere le vitamine',
              );
              if (v?.isNotEmpty == true) {
                if (!c.mounted) return;
                final time = await showTimePicker(
                  context: c,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final formatted =
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  s.addReminder(v!, formatted);
                }
              }
            },
          ),
          child: Column(
            children: s.reminders
                .map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_none),
                    title: Text(e.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(e.time),
                        IconButton(
                          tooltip: 'Elimina',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await _confirmDelete(c, e.title)) {
                              s.removeReminder(e);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Section(
          title: 'Foto',
          action: IconButton(
            tooltip: 'Aggiungi foto',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () async {
              if (s.photoWidgets.length >= 4) {
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Puoi aggiungere fino a 4 foto per mantenere veloce il cloud.',
                    ),
                  ),
                );
                return;
              }
              final image = await _pickImageBase64(c);
              if (image == null || !c.mounted) return;
              final caption = await _textDialog(
                c,
                'Didascalia della foto',
                hint: 'Facoltativa',
              );
              if (caption != null) s.addPhotoWidget(image, caption);
            },
          ),
          child: s.photoWidgets.isEmpty
              ? const _EmptyState(
                  icon: Icons.photo_outlined,
                  message: 'Aggiungi una foto come widget della tua giornata.',
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: s.photoWidgets
                      .map((photo) => _PhotoWidgetCard(s: s, photo: photo))
                      .toList(),
                ),
        ),
        Section(
          title: 'Panoramica',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MetricCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Saldo',
                    value: '${balance.toStringAsFixed(2)} €',
                  ),
                  MetricCard(
                    icon: Icons.event_outlined,
                    label: 'Prossima scadenza',
                    value: nextDeadline?.title ?? 'Nessuna',
                  ),
                  MetricCard(
                    icon: Icons.flag_outlined,
                    label: 'Obiettivi',
                    value: '${(goalProgress * 100).round()}% completati',
                  ),
                ],
              ),
              if (urgent.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Richiede attenzione',
                  style: Theme.of(c).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ...urgent.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _daysUntil(item.date) < 0
                          ? Icons.error_outline
                          : Icons.schedule,
                      color: _daysUntil(item.date) <= 1
                          ? Theme.of(c).colorScheme.error
                          : null,
                    ),
                    title: Text(item.title),
                    subtitle: Text(_deadlineStatus(item.date)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _showTomorrowPlanner(BuildContext context, AppState state) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 620),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Programma domani',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Aggiungi attività',
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final result = await _todayTaskDialog(
                        context,
                        dialogTitle: 'Attività di domani',
                      );
                      if (result != null) {
                        state.addTomorrowTask(result.title, time: result.time);
                        setSheetState(() {});
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Queste attività verranno caricate al prossimo cambio giornata.',
              ),
              const SizedBox(height: 14),
              Flexible(
                child: state.tomorrowTasks.isEmpty
                    ? const _EmptyState(
                        icon: Icons.event_available_outlined,
                        message:
                            'La giornata di domani non è ancora programmata.',
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: state.tomorrowTasks
                            .map(
                              (task) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  child: Text(task.time ?? '—'),
                                ),
                                title: Text(task.title),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Modifica',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final result = await _todayTaskDialog(
                                          context,
                                          task: task,
                                          dialogTitle: 'Modifica attività',
                                        );
                                        if (result != null) {
                                          state.updateTomorrowTask(
                                            task,
                                            result.title,
                                            result.time,
                                          );
                                          setSheetState(() {});
                                        }
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Elimina',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () {
                                        state.removeTomorrowTask(task);
                                        setSheetState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fatto'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

double? _parseAmount(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

Future<({String person, double total, double paid})?> _debtDialog(
  BuildContext context, {
  DebtItem? debt,
}) async {
  final person = TextEditingController(text: debt?.person ?? '');
  final total = TextEditingController(
    text: debt == null ? '' : debt.totalAmount.toStringAsFixed(2),
  );
  final paid = TextEditingController(
    text: debt == null ? '' : debt.paidAmount.toStringAsFixed(2),
  );
  String? error;
  final result = await showDialog<({String person, double total, double paid})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(debt == null ? 'Nuovo debito' : 'Modifica debito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: person,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Con chi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: total,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Importo totale',
                suffixText: '€',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: paid,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Importo già dato',
                suffixText: '€',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final name = person.text.trim();
              final totalValue = _parseAmount(total.text);
              final paidValue = paid.text.trim().isEmpty
                  ? 0.0
                  : _parseAmount(paid.text);
              if (name.isEmpty ||
                  totalValue == null ||
                  totalValue <= 0 ||
                  paidValue == null ||
                  paidValue < 0 ||
                  paidValue > totalValue) {
                setDialogState(() => error = 'Controlla gli importi inseriti');
                return;
              }
              Navigator.pop(context, (
                person: name,
                total: totalValue,
                paid: paidValue,
              ));
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  person.dispose();
  total.dispose();
  paid.dispose();
  return result;
}

Future<({String title, double amount})?> _recurringExpenseDialog(
  BuildContext context, {
  RecurringExpense? expense,
}) async {
  final title = TextEditingController(text: expense?.title ?? '');
  final amount = TextEditingController(
    text: expense == null ? '' : expense.amount.toStringAsFixed(2),
  );
  String? error;
  final result = await showDialog<({String title, double amount})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          expense == null ? 'Nuova spesa ricorrente' : 'Modifica spesa',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                hintText: 'Es. Affitto',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Importo mensile',
                suffixText: '€',
                errorText: error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final label = title.text.trim();
              final value = _parseAmount(amount.text);
              if (label.isEmpty || value == null || value <= 0) {
                setDialogState(() => error = 'Inserisci un importo valido');
                return;
              }
              Navigator.pop(context, (title: label, amount: value));
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  title.dispose();
  amount.dispose();
  return result;
}

Future<double?> _salaryDialog(BuildContext context, double current) async {
  final controller = TextEditingController(
    text: current > 0 ? current.toStringAsFixed(2) : '',
  );
  String? error;
  final result = await showDialog<double>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Stipendio mensile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Importo netto',
            suffixText: '€',
            errorText: error,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final value = _parseAmount(controller.text);
              if (value == null || value <= 0) {
                setDialogState(() => error = 'Inserisci un importo valido');
                return;
              }
              Navigator.pop(context, value);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

class _RecurringDonut extends StatelessWidget {
  const _RecurringDonut({required this.expenses, required this.salary});

  final double expenses;
  final double salary;

  @override
  Widget build(BuildContext context) {
    final ratio = salary <= 0 ? 0.0 : expenses / salary;
    final color = ratio > 1
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(150),
            painter: _DonutPainter(
              ratio: ratio,
              color: color,
              trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                salary <= 0 ? '—' : '${(ratio * 100).round()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const Text('dello stipendio'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.ratio,
    required this.color,
    required this.trackColor,
  });

  final double ratio;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    final value = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * ratio.clamp(0, 1),
      false,
      value,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.ratio != ratio ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

class FinancePage extends StatelessWidget {
  const FinancePage(this.s, {super.key});
  final AppState s;

  @override
  Widget build(BuildContext c) {
    final balance = s.movements.fold<double>(0, (a, b) => a + b.amount);
    final totalRecurring = s.recurringExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final totalDebt = s.debts.fold<double>(
      0,
      (sum, debt) => sum + debt.remaining,
    );
    return PageBody(
      title: 'Finanze',
      subtitle: 'Movimenti, impegni e spese mensili',
      state: s,
      pageId: 'finance',
      children: [
        Section(
          title: 'Saldo attuale',
          child: Text(
            '${balance.toStringAsFixed(2)} €',
            style: Theme.of(
              c,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Section(
          title: 'Debiti · ${totalDebt.toStringAsFixed(2)} € rimanenti',
          id: 'debts',
          action: IconButton(
            tooltip: 'Aggiungi debito',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await _debtDialog(c);
              if (result != null) {
                s.addDebt(result.person, result.total, result.paid);
              }
            },
          ),
          child: s.debts.isEmpty
              ? const _EmptyState(
                  icon: Icons.handshake_outlined,
                  message: 'Nessun debito registrato.',
                )
              : Column(
                  children: s.debts
                      .map(
                        (debt) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person_outline),
                                ),
                                title: Text(debt.person),
                                subtitle: Text(
                                  '${debt.paidAmount.toStringAsFixed(2)} € dati su '
                                  '${debt.totalAmount.toStringAsFixed(2)} €',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${debt.remaining.toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Modifica',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final result = await _debtDialog(
                                          c,
                                          debt: debt,
                                        );
                                        if (result != null) {
                                          s.updateDebt(
                                            debt,
                                            result.person,
                                            result.total,
                                            result.paid,
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Elimina',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        if (await _confirmDelete(
                                          c,
                                          debt.person,
                                        )) {
                                          s.removeDebt(debt);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              LinearProgressIndicator(
                                value: debt.progress,
                                minHeight: 7,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        Section(
          title: 'Spese mensili ricorrenti',
          action: IconButton(
            tooltip: 'Aggiungi spesa',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await _recurringExpenseDialog(c);
              if (result != null) {
                s.addRecurringExpense(result.title, result.amount);
              }
            },
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 28,
                runSpacing: 18,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _RecurringDonut(
                    expenses: totalRecurring,
                    salary: s.monthlySalary,
                  ),
                  SizedBox(
                    width: 280,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stipendio: ${s.monthlySalary.toStringAsFixed(2)} €',
                          style: Theme.of(c).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Spese fisse: ${totalRecurring.toStringAsFixed(2)} €',
                        ),
                        Text(
                          'Disponibile: '
                          '${(s.monthlySalary - totalRecurring).toStringAsFixed(2)} €',
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifica stipendio'),
                          onPressed: () async {
                            final value = await _salaryDialog(
                              c,
                              s.monthlySalary,
                            );
                            if (value != null) s.setMonthlySalary(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (s.recurringExpenses.isEmpty)
                const _EmptyState(
                  icon: Icons.pie_chart_outline,
                  message: 'Aggiungi le spese che si ripetono ogni mese.',
                )
              else
                ...s.recurringExpenses.map(
                  (expense) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.repeat),
                    title: Text(expense.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${expense.amount.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          tooltip: 'Modifica',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final result = await _recurringExpenseDialog(
                              c,
                              expense: expense,
                            );
                            if (result != null) {
                              s.updateRecurringExpense(
                                expense,
                                result.title,
                                result.amount,
                              );
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Elimina',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await _confirmDelete(c, expense.title)) {
                              s.removeRecurringExpense(expense);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Section(
          title: 'Ultimi movimenti',
          action: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final movement = await _movementDialog(c);
              if (movement != null) {
                s.addMovement(movement.label, movement.amount);
              }
            },
          ),
          child: Column(
            children: s.movements
                .map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(
                        e.amount >= 0 ? Icons.south_west : Icons.north_east,
                      ),
                    ),
                    title: Text(e.label),
                    subtitle: Text(_date(e.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${e.amount >= 0 ? '+' : ''}${e.amount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: e.amount >= 0 ? Colors.green : null,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Elimina',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await _confirmDelete(c, e.label)) {
                              s.removeMovement(e);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

Future<({String title, double target, double saved, String description})?>
_goalDialog(BuildContext context, {GoalItem? goal}) async {
  final title = TextEditingController(text: goal?.title ?? '');
  final target = TextEditingController(
    text: goal == null ? '' : goal.targetAmount.toStringAsFixed(2),
  );
  final saved = TextEditingController(
    text: goal == null ? '' : goal.savedAmount.toStringAsFixed(2),
  );
  final description = TextEditingController(text: goal?.description ?? '');
  String? error;
  final result =
      await showDialog<
        ({String title, double target, double saved, String description})
      >(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(
              goal == null ? 'Nuovo obiettivo economico' : 'Modifica obiettivo',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: title,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: target,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Obiettivo da raggiungere',
                      suffixText: '€',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: saved,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Già accantonato',
                      suffixText: '€',
                      errorText: error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  final name = title.text.trim();
                  final targetValue = _parseAmount(target.text);
                  final savedValue = saved.text.trim().isEmpty
                      ? 0.0
                      : _parseAmount(saved.text);
                  if (name.isEmpty ||
                      targetValue == null ||
                      targetValue <= 0 ||
                      savedValue == null ||
                      savedValue < 0) {
                    setDialogState(
                      () => error = 'Controlla gli importi inseriti',
                    );
                    return;
                  }
                  Navigator.pop(context, (
                    title: name,
                    target: targetValue,
                    saved: savedValue,
                    description: description.text.trim(),
                  ));
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      );
  title.dispose();
  target.dispose();
  saved.dispose();
  description.dispose();
  return result;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.s, required this.goal});

  final AppState s;
  final GoalItem goal;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => GoalDetailPage(s: s, goal: goal),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.savings_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(goal.progress * 100).round()}%'),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await _goalDialog(context, goal: goal);
                      if (result != null) {
                        s.updateGoal(
                          goal,
                          result.title,
                          result.target,
                          result.saved,
                          result.description,
                        );
                      }
                    } else if (value == 'delete' &&
                        await _confirmDelete(context, goal.title)) {
                      s.removeGoal(goal);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Modifica')),
                    PopupMenuItem(value: 'delete', child: Text('Elimina')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 7),
            Text(
              '${goal.savedAmount.toStringAsFixed(2)} € di '
              '${goal.targetAmount.toStringAsFixed(2)} €',
            ),
          ],
        ),
      ),
    ),
  );
}

class GoalDetailPage extends StatefulWidget {
  const GoalDetailPage({super.key, required this.s, required this.goal});

  final AppState s;
  final GoalItem goal;

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.s.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.s.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _edit() async {
    final result = await _goalDialog(context, goal: widget.goal);
    if (result != null) {
      widget.s.updateGoal(
        widget.goal,
        result.title,
        result.target,
        result.saved,
        result.description,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final remaining = math.max(0, goal.targetAmount - goal.savedAmount);
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            tooltip: 'Modifica obiettivo',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Section(
            title: '${(goal.progress * 100).round()}% raggiunto',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 14,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    MetricCard(
                      icon: Icons.flag_outlined,
                      label: 'Obiettivo',
                      value: '${goal.targetAmount.toStringAsFixed(2)} €',
                    ),
                    MetricCard(
                      icon: Icons.savings_outlined,
                      label: 'Accantonato',
                      value: '${goal.savedAmount.toStringAsFixed(2)} €',
                    ),
                    MetricCard(
                      icon: Icons.trending_up,
                      label: 'Mancano',
                      value: '${remaining.toStringAsFixed(2)} €',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Section(
            title: 'Descrizione',
            child: Text(
              goal.description.isEmpty
                  ? 'Nessuna descrizione. Usa Modifica per aggiungerla.'
                  : goal.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage(this.s, {super.key});
  final AppState s;

  @override
  Widget build(BuildContext c) => PageBody(
    title: 'Obiettivi',
    subtitle: 'Risparmi e progetti, organizzati con chiarezza',
    state: s,
    pageId: 'goals',
    children: [
      Section(
        title: 'Obiettivi economici',
        action: IconButton(
          tooltip: 'Nuovo obiettivo economico',
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await _goalDialog(c);
            if (result != null) {
              s.addEconomicGoal(
                result.title,
                result.target,
                result.saved,
                result.description,
              );
            }
          },
        ),
        child: s.goals.isEmpty
            ? const _EmptyState(
                icon: Icons.savings_outlined,
                message: 'Crea il tuo primo obiettivo economico.',
              )
            : Column(
                children: s.goals
                    .map((goal) => _GoalCard(s: s, goal: goal))
                    .toList(),
              ),
      ),
      Section(
        title: 'Progetti',
        action: IconButton(
          tooltip: 'Nuovo progetto',
          icon: const Icon(Icons.create_new_folder_outlined),
          onPressed: () async {
            final title = await _textDialog(
              c,
              'Nuovo progetto',
              hint: 'Es. Ristrutturare lo studio',
            );
            if (title?.isNotEmpty == true) s.addProject(title!);
          },
        ),
        child: s.projects.isEmpty
            ? const _EmptyState(
                icon: Icons.folder_open_outlined,
                message: 'Crea un progetto e dividilo in attività più piccole.',
              )
            : Column(
                children: s.projects
                    .map((project) => _ProjectCard(s: s, project: project))
                    .toList(),
              ),
      ),
    ],
  );
}

class DeadlinesPage extends StatelessWidget {
  const DeadlinesPage(this.s, {super.key});
  final AppState s;
  @override
  Widget build(BuildContext c) {
    final list = [...s.deadlines]..sort((a, b) => a.date.compareTo(b.date));
    return PageBody(
      title: 'Scadenze',
      subtitle: 'Tutto sotto controllo, senza sorprese',
      state: s,
      pageId: 'deadlines',
      children: [
        Section(
          title: 'In programma',
          action: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final v = await _textDialog(c, 'Nuova scadenza');
              if (v?.isNotEmpty == true) {
                if (!c.mounted) return;
                final d = await showDatePicker(
                  context: c,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (d != null) s.addDeadline(v!, d);
              }
            },
          ),
          child: Column(
            children: list
                .map(
                  (e) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: e.done,
                    onChanged: (_) => s.toggleDeadline(e),
                    secondary: IconButton(
                      tooltip: 'Elimina',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (await _confirmDelete(c, e.title)) {
                          s.removeDeadline(e);
                        }
                      },
                    ),
                    title: Text(e.title),
                    subtitle: Text(_date(e.date)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 22),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    ),
  );
}

class WorkInProgressPage extends StatelessWidget {
  const WorkInProgressPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.state,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final AppState state;

  @override
  Widget build(BuildContext context) => PageBody(
    title: title,
    subtitle: subtitle,
    state: state,
    pageId: title.toLowerCase(),
    children: [
      Section(
        title: 'Work in progress',
        child: _EmptyState(
          icon: icon,
          message: 'Questa area è pronta per essere costruita insieme.',
        ),
      ),
    ],
  );
}

class StudyPage extends StatelessWidget {
  const StudyPage(this.s, {super.key});

  final AppState s;

  @override
  Widget build(BuildContext context) => PageBody(
    title: 'Studio',
    subtitle: 'Scegli con chiarezza la tua prossima lettura',
    state: s,
    pageId: 'study',
    children: [
      Section(
        title: 'Coda di lettura',
        action: IconButton(
          tooltip: 'Aggiungi libro',
          icon: const Icon(Icons.add),
          onPressed: () async {
            final title = await _textDialog(
              context,
              'Aggiungi un libro',
              hint: 'Titolo del libro',
            );
            if (title?.isNotEmpty == true) s.addBook(title!);
          },
        ),
        child: s.books.isEmpty
            ? const _EmptyState(
                icon: Icons.menu_book_outlined,
                message: 'Aggiungi i libri che vuoi leggere.',
              )
            : ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: s.books.length,
                onReorderItem: s.reorderBooks,
                itemBuilder: (context, index) {
                  final book = s.books[index];
                  return ListTile(
                    key: ValueKey(book.id),
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(book.title),
                    subtitle: Text(
                      index == 0
                          ? 'Prossima lettura'
                          : 'Posizione ${index + 1}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Modifica',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final title = await _textDialog(
                              context,
                              'Modifica libro',
                              initialValue: book.title,
                            );
                            if (title?.isNotEmpty == true) {
                              s.updateBook(book, title!);
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Elimina',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (await _confirmDelete(context, book.title)) {
                              s.removeBook(book);
                            }
                          },
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.drag_handle),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

class CyclesPage extends StatelessWidget {
  const CyclesPage(this.s, {super.key});

  final AppState s;

  @override
  Widget build(BuildContext context) => PageBody(
    title: 'Cicli',
    subtitle: 'Raccogli qui ciò che smisterai e pianificherai più avanti',
    state: s,
    pageId: 'cycles',
    children: [
      Section(
        title: 'Da smistare',
        action: IconButton(
          tooltip: 'Aggiungi elemento',
          icon: const Icon(Icons.add),
          onPressed: () async {
            final title = await _textDialog(
              context,
              'Nuovo elemento',
              hint: 'Cosa vuoi ricordare?',
            );
            if (title?.isNotEmpty == true) s.addCycleItem(title!);
          },
        ),
        child: s.cycleItems.isEmpty
            ? const _EmptyState(
                icon: Icons.inbox_outlined,
                message: 'La tua lista da smistare è vuota.',
              )
            : Column(
                children: s.cycleItems
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.radio_button_unchecked),
                        title: Text(item.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Modifica',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final title = await _textDialog(
                                  context,
                                  'Modifica elemento',
                                  initialValue: item.title,
                                );
                                if (title?.isNotEmpty == true) {
                                  s.updateCycleItem(item, title!);
                                }
                              },
                            ),
                            IconButton(
                              tooltip: 'Elimina',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                if (await _confirmDelete(context, item.title)) {
                                  s.removeCycleItem(item);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    ],
  );
}

class CalendarPage extends StatefulWidget {
  const CalendarPage(this.s, {super.key});

  final AppState s;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime visibleMonth;
  late DateTime selectedDay;

  static const monthNames = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDay = DateTime(now.year, now.month, now.day);
    visibleMonth = DateTime(now.year, now.month);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _changeMonth(int amount) {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + amount);
      selectedDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = widget.s.calendarItems
        .where((item) => _sameDay(item.date, selectedDay))
        .toList();
    return PageBody(
      title: 'Calendario',
      subtitle: 'Decidi cosa fare e quando farlo',
      state: widget.s,
      pageId: 'calendar',
      children: [
        Section(
          title: '${monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
          id: 'month',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Mese precedente',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Mese successivo',
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  Row(
                    children: const ['L', 'M', 'M', 'G', 'V', 'S', 'D']
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 42,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.08,
                        ),
                    itemBuilder: (context, index) {
                      final offset = visibleMonth.weekday - 1;
                      final day = index - offset + 1;
                      final daysInMonth = DateUtils.getDaysInMonth(
                        visibleMonth.year,
                        visibleMonth.month,
                      );
                      if (day < 1 || day > daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime(
                        visibleMonth.year,
                        visibleMonth.month,
                        day,
                      );
                      final isSelected = _sameDay(date, selectedDay);
                      final hasItems = widget.s.calendarItems.any(
                        (item) => _sameDay(item.date, date),
                      );
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => selectedDay = date),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasItems
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Section(
          title: _date(selectedDay),
          action: IconButton(
            tooltip: 'Aggiungi attività',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final title = await _textDialog(
                context,
                'Nuova attività',
                hint: 'Cosa vuoi fare?',
              );
              if (title?.isNotEmpty == true) {
                widget.s.addCalendarItem(title!, selectedDay);
              }
            },
          ),
          child: selectedItems.isEmpty
              ? const _EmptyState(
                  icon: Icons.event_available_outlined,
                  message: 'Nessuna attività prevista per questo giorno.',
                )
              : Column(
                  children: selectedItems
                      .map(
                        (item) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: item.done,
                          onChanged: (_) => widget.s.toggleCalendarItem(item),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          secondary: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Modifica',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () async {
                                  final title = await _textDialog(
                                    context,
                                    'Modifica attività',
                                    initialValue: item.title,
                                  );
                                  if (title?.isNotEmpty != true ||
                                      !context.mounted) {
                                    return;
                                  }
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 3650),
                                    ),
                                    initialDate: item.date,
                                  );
                                  if (date != null) {
                                    widget.s.updateCalendarItem(
                                      item,
                                      title!,
                                      date,
                                    );
                                    setState(() {
                                      selectedDay = date;
                                      visibleMonth = DateTime(
                                        date.year,
                                        date.month,
                                      );
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Elimina',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  if (await _confirmDelete(
                                    context,
                                    item.title,
                                  )) {
                                    widget.s.removeCalendarItem(item);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.s, required this.project});

  final AppState s;
  final ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final completed = project.allTasks.where((task) => task.done).length;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProjectDetailPage(s: s, project: project),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('${(project.progress * 100).round()}%'),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final title = await _textDialog(
                          context,
                          'Rinomina progetto',
                          initialValue: project.title,
                        );
                        if (title?.isNotEmpty == true) {
                          s.updateProject(project, title!);
                        }
                      } else if (value == 'delete' &&
                          await _confirmDelete(context, project.title)) {
                        s.removeProject(project);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Rinomina')),
                      PopupMenuItem(value: 'delete', child: Text('Elimina')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: project.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 7),
              Text(
                '$completed di ${project.allTasks.length} attività completate',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectFolderCard extends StatelessWidget {
  const _ProjectFolderCard({
    required this.s,
    required this.project,
    required this.folder,
  });

  final AppState s;
  final ProjectItem project;
  final ProjectFolder folder;

  @override
  Widget build(BuildContext context) {
    final completed = folder.tasks.where((task) => task.done).length;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(folder.title),
        subtitle: Text(
          '$completed di ${folder.tasks.length} attività · '
          '${(folder.progress * 100).round()}%',
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                ProjectFolderDetailPage(s: s, project: project, folder: folder),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final title = await _textDialog(
                context,
                'Rinomina cartella',
                initialValue: folder.title,
              );
              if (title?.isNotEmpty == true) {
                s.updateProjectFolder(folder, title!);
              }
            } else if (value == 'delete' &&
                await _confirmDelete(context, folder.title)) {
              s.removeProjectFolder(project, folder);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Rinomina')),
            PopupMenuItem(value: 'delete', child: Text('Elimina')),
          ],
        ),
      ),
    );
  }
}

Future<({String title, DateTime? deadline})?> _projectTaskDialog(
  BuildContext context, {
  ProjectTask? task,
}) async {
  final controller = TextEditingController(text: task?.title ?? '');
  DateTime? deadline = task?.deadline;
  String? error;
  final result = await showDialog<({String title, DateTime? deadline})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          task == null ? 'Nuova sotto-attività' : 'Modifica attività',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Titolo',
                errorText: error,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                deadline == null ? 'Nessuna scadenza' : _date(deadline!),
              ),
              trailing: deadline == null
                  ? null
                  : IconButton(
                      tooltip: 'Rimuovi scadenza',
                      icon: const Icon(Icons.close),
                      onPressed: () => setDialogState(() => deadline = null),
                    ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  initialDate: deadline ?? DateTime.now(),
                );
                if (date != null) setDialogState(() => deadline = date);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) {
                setDialogState(() => error = 'Inserisci un titolo');
                return;
              }
              Navigator.pop(context, (title: title, deadline: deadline));
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  return result;
}

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.s, required this.project});

  final AppState s;
  final ProjectItem project;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.s.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.s.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _addTask() async {
    final result = await _projectTaskDialog(context);
    if (result != null) {
      widget.s.addProjectTask(widget.project, result.title, result.deadline);
    }
  }

  Future<void> _addFolder() async {
    final title = await _textDialog(
      context,
      'Nuova cartella',
      hint: 'Es. Preparazione, Acquisti, Documenti…',
    );
    if (title?.isNotEmpty == true) {
      widget.s.addProjectFolder(widget.project, title!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final completed = project.allTasks.where((task) => task.done).length;
    final tasks = [...project.tasks]
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Attività'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Section(
            title: '${(project.progress * 100).round()}% completato',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 10),
                Text('$completed di ${project.allTasks.length} sotto-attività'),
              ],
            ),
          ),
          Section(
            title: 'Cartelle',
            action: IconButton(
              tooltip: 'Aggiungi cartella',
              icon: const Icon(Icons.create_new_folder_outlined),
              onPressed: _addFolder,
            ),
            child: project.folders.isEmpty
                ? const _EmptyState(
                    icon: Icons.folder_open_outlined,
                    message: 'Crea cartelle per raggruppare le attività.',
                  )
                : Column(
                    children: project.folders
                        .map(
                          (folder) => _ProjectFolderCard(
                            s: widget.s,
                            project: project,
                            folder: folder,
                          ),
                        )
                        .toList(),
                  ),
          ),
          Section(
            title: 'Attività senza cartella',
            action: IconButton(
              tooltip: 'Aggiungi',
              icon: const Icon(Icons.add),
              onPressed: _addTask,
            ),
            child: tasks.isEmpty
                ? const _EmptyState(
                    icon: Icons.checklist,
                    message: 'Le attività non assegnate appariranno qui.',
                  )
                : Column(
                    children: tasks
                        .map(
                          (task) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: task.done,
                            onChanged: (_) => widget.s.toggleProjectTask(task),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: task.deadline == null
                                ? const Text('Nessuna scadenza')
                                : Text(
                                    '${_date(task.deadline!)} · ${_deadlineStatus(task.deadline!)}',
                                  ),
                            secondary: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Modifica',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    final result = await _projectTaskDialog(
                                      context,
                                      task: task,
                                    );
                                    if (result != null) {
                                      widget.s.updateProjectTask(
                                        task,
                                        result.title,
                                        result.deadline,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Elimina',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    if (await _confirmDelete(
                                      context,
                                      task.title,
                                    )) {
                                      widget.s.removeProjectTask(project, task);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class ProjectFolderDetailPage extends StatefulWidget {
  const ProjectFolderDetailPage({
    super.key,
    required this.s,
    required this.project,
    required this.folder,
  });

  final AppState s;
  final ProjectItem project;
  final ProjectFolder folder;

  @override
  State<ProjectFolderDetailPage> createState() =>
      _ProjectFolderDetailPageState();
}

class _ProjectFolderDetailPageState extends State<ProjectFolderDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.s.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.s.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _addTask() async {
    final result = await _projectTaskDialog(context);
    if (result != null) {
      widget.s.addProjectFolderTask(
        widget.folder,
        result.title,
        result.deadline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final folder = widget.folder;
    final completed = folder.tasks.where((task) => task.done).length;
    final tasks = [...folder.tasks]
      ..sort((a, b) {
        if (a.done != b.done) return a.done ? 1 : -1;
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(folder.title),
            Text(
              widget.project.title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Attività'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Section(
            title: '${(folder.progress * 100).round()}% completato',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: folder.progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 10),
                Text('$completed di ${folder.tasks.length} attività'),
              ],
            ),
          ),
          Section(
            title: 'Attività',
            action: IconButton(
              tooltip: 'Aggiungi attività',
              icon: const Icon(Icons.add),
              onPressed: _addTask,
            ),
            child: tasks.isEmpty
                ? const _EmptyState(
                    icon: Icons.checklist,
                    message: 'Aggiungi la prima attività della cartella.',
                  )
                : Column(
                    children: tasks
                        .map(
                          (task) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: task.done,
                            onChanged: (_) => widget.s.toggleProjectTask(task),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: task.deadline == null
                                ? const Text('Nessuna scadenza')
                                : Text(
                                    '${_date(task.deadline!)} · '
                                    '${_deadlineStatus(task.deadline!)}',
                                  ),
                            secondary: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Modifica',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    final result = await _projectTaskDialog(
                                      context,
                                      task: task,
                                    );
                                    if (result != null) {
                                      widget.s.updateProjectTask(
                                        task,
                                        result.title,
                                        result.deadline,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Elimina',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    if (await _confirmDelete(
                                      context,
                                      task.title,
                                    )) {
                                      widget.s.removeProjectTask(
                                        widget.project,
                                        task,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class ChecklistsPage extends StatelessWidget {
  const ChecklistsPage(this.s, {super.key});

  final AppState s;

  @override
  Widget build(BuildContext context) => PageBody(
    title: 'Check lists',
    subtitle: 'Liste riutilizzabili, ordinate in cartelle',
    state: s,
    pageId: 'checklists',
    children: [
      Section(
        title: 'Le tue cartelle',
        id: 'folders',
        action: IconButton(
          tooltip: 'Nuova cartella',
          icon: const Icon(Icons.create_new_folder_outlined),
          onPressed: () async {
            final title = await _textDialog(
              context,
              'Nuova cartella',
              hint: 'Es. Valigia per il weekend',
            );
            if (title?.isNotEmpty == true) s.addChecklistFolder(title!);
          },
        ),
        child: s.checklistFolders.isEmpty
            ? const _EmptyState(
                icon: Icons.checklist_outlined,
                message: 'Crea una cartella per la tua prima checklist.',
              )
            : Column(
                children: s.checklistFolders
                    .map(
                      (folder) => Card.outlined(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(
                            folder.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${folder.entries.where((entry) => entry.done).length} di '
                            '${folder.entries.length} completati',
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            8,
                            12,
                          ),
                          children: [
                            LinearProgressIndicator(
                              value: folder.progress,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 8),
                            ...folder.entries.map(
                              (entry) => CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: entry.done,
                                onChanged: (_) => s.toggleChecklistEntry(entry),
                                title: Text(
                                  entry.title,
                                  style: TextStyle(
                                    decoration: entry.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                secondary: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Modifica',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () async {
                                        final title = await _textDialog(
                                          context,
                                          'Modifica elemento',
                                          initialValue: entry.title,
                                        );
                                        if (title?.isNotEmpty == true) {
                                          s.updateChecklistEntry(entry, title!);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Elimina',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () =>
                                          s.removeChecklistEntry(folder, entry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonalIcon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Aggiungi elemento'),
                                  onPressed: () async {
                                    final title = await _textDialog(
                                      context,
                                      'Nuovo elemento',
                                      hint: 'Cosa vuoi ricordare?',
                                    );
                                    if (title?.isNotEmpty == true) {
                                      s.addChecklistEntry(folder, title!);
                                    }
                                  },
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Rinomina'),
                                  onPressed: () async {
                                    final title = await _textDialog(
                                      context,
                                      'Rinomina cartella',
                                      initialValue: folder.title,
                                    );
                                    if (title?.isNotEmpty == true) {
                                      s.updateChecklistFolder(folder, title!);
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Elimina cartella'),
                                  onPressed: () async {
                                    if (await _confirmDelete(
                                      context,
                                      folder.title,
                                    )) {
                                      s.removeChecklistFolder(folder);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    ],
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage(this.s, {super.key, this.cloudEmail, this.onSignOut});

  static const themeColors = [
    Color(0xff6558d3),
    Color(0xff006c51),
    Color(0xff0061a4),
    Color(0xff8f4c38),
    Color(0xff984061),
    Color(0xff7a5900),
    Color(0xff455a64),
    Color(0xff6b5778),
  ];

  final AppState s;
  final String? cloudEmail;
  final Future<void> Function()? onSignOut;
  @override
  Widget build(BuildContext c) => PageBody(
    title: 'Impostazioni',
    subtitle: 'Personalizza la tua esperienza',
    state: s,
    pageId: 'settings',
    children: [
      Section(
        title: 'Aspetto',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tema scuro'),
              subtitle: const Text('Riduce la luminosità dell’interfaccia'),
              value: s.darkMode,
              onChanged: s.setDark,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Colore principale',
              style: Theme.of(
                c,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: themeColors
                  .map(
                    (color) => Semantics(
                      label: 'Scegli colore tema',
                      button: true,
                      selected: s.themeSeedValue == color.toARGB32(),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => s.setThemeSeed(color.toARGB32()),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: s.themeSeedValue == color.toARGB32()
                                  ? Theme.of(c).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: s.themeSeedValue == color.toARGB32()
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      Section(
        title: 'Sfondo personale',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_memoryImage(s.backgroundImageBase64) case final image?) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 6,
                  child: Image(image: image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
            ] else
              const _EmptyState(
                icon: Icons.wallpaper_outlined,
                message: 'Scegli una foto da usare dietro alle pagine.',
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    s.backgroundImageBase64 == null
                        ? 'Scegli foto'
                        : 'Cambia foto',
                  ),
                  onPressed: () async {
                    final image = await _pickImageBase64(c, maxBytes: 900000);
                    if (image != null) s.setBackgroundImage(image);
                  },
                ),
                if (s.backgroundImageBase64 != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Rimuovi sfondo'),
                    onPressed: () => s.setBackgroundImage(null),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Le immagini vengono ridotte e salvate insieme ai dati del tuo account.',
              style: Theme.of(c).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      Section(
        title: 'Organizzazione della giornata',
        id: 'day_organization',
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Modalità Buonanotte'),
              subtitle: const Text(
                'Richiede almeno un’attività programmata prima di chiudere la giornata.',
              ),
              value: s.bedtimeMode,
              onChanged: s.setBedtimeMode,
            ),
            const Divider(),
            DropdownButtonFormField<int>(
              initialValue: s.dayResetHour,
              decoration: const InputDecoration(
                labelText: 'Ora del cambio giornata automatico',
                prefixIcon: Icon(Icons.schedule),
              ),
              items: List.generate(
                24,
                (hour) => DropdownMenuItem(
                  value: hour,
                  child: Text('${hour.toString().padLeft(2, '0')}:00'),
                ),
              ),
              onChanged: (hour) {
                if (hour != null) s.setDayResetHour(hour);
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Al cambio giornata le attività completate vengono archiviate; quelle incomplete restano recuperabili in Oggi.',
              style: Theme.of(c).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      Section(
        title: 'Dati e sincronizzazione',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            cloudEmail == null ? Icons.cloud_off_outlined : Icons.cloud_done,
          ),
          title: Text(cloudEmail == null ? 'Solo locale' : 'Cloud attivo'),
          subtitle: Text(cloudEmail ?? 'I dati restano su questo dispositivo.'),
        ),
      ),
      if (onSignOut != null)
        Section(
          title: 'Account',
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(cloudEmail ?? 'Account personale'),
                subtitle: const Text(
                  'I dati di questo account sono separati dagli altri.',
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: const Text('Esci dall’account'),
                onTap: onSignOut,
              ),
            ],
          ),
        ),
    ],
  );
}
