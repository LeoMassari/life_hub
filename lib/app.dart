import 'package:flutter/material.dart';
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
    themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: state.ready
        ? LifeHubShell(
            state: state,
            cloudEmail: widget.cloudEmail,
            onSignOut: widget.onSignOut,
          )
        : const Scaffold(body: Center(child: CircularProgressIndicator())),
  );
}

ThemeData _theme(Brightness b) {
  final dark = b == Brightness.dark;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff6558d3),
      brightness: b,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: dark
        ? const Color(0xff101114)
        : const Color(0xfff7f7fb),
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
  );
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
  settings,
}

class _LifeHubShellState extends State<LifeHubShell> {
  HubPage selectedPage = HubPage.today;

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
    HubPage.training => const WorkInProgressPage(
      title: 'Allenamento',
      subtitle: 'Il tuo spazio dedicato al movimento',
      icon: Icons.fitness_center,
    ),
    HubPage.nutrition => const WorkInProgressPage(
      title: 'Alimentazione',
      subtitle: 'Il tuo spazio dedicato all’alimentazione',
      icon: Icons.restaurant_outlined,
    ),
    HubPage.study => StudyPage(widget.state),
    HubPage.cycles => CyclesPage(widget.state),
    HubPage.calendar => CalendarPage(widget.state),
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
          body: Row(
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
  });
  final String title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext c) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        title,
        style: Theme.of(
          c,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: Theme.of(c).textTheme.bodyLarge),
      const SizedBox(height: 22),
      ...children,
    ],
  );
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
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

class TodayPage extends StatelessWidget {
  const TodayPage(this.s, {super.key});
  final AppState s;
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
          action: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final v = await _textDialog(
                c,
                'Nuova attività',
                hint: 'Cosa vuoi fare?',
              );
              if (v?.isNotEmpty == true) s.addTask(v!);
            },
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
                                  final title = await _textDialog(
                                    c,
                                    'Modifica attività',
                                    initialValue: e.title,
                                  );
                                  if (title?.isNotEmpty == true) {
                                    s.updateTaskTitle(e, title!);
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
                        ),
                      )
                      .toList(),
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

class FinancePage extends StatelessWidget {
  const FinancePage(this.s, {super.key});
  final AppState s;
  @override
  Widget build(BuildContext c) {
    final balance = s.movements.fold<double>(0, (a, b) => a + b.amount);
    return PageBody(
      title: 'Finanze',
      subtitle: 'Movimenti e saldo personale',
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
                    subtitle: Text(
                      '${_date(e.date)} · ${_deadlineStatus(e.date)}',
                    ),
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

class GoalsPage extends StatelessWidget {
  const GoalsPage(this.s, {super.key});
  final AppState s;
  @override
  Widget build(BuildContext c) => PageBody(
    title: 'Obiettivi',
    subtitle: 'Piccoli progressi, ogni giorno',
    children: [
      Section(
        title: 'I tuoi obiettivi',
        action: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final v = await _textDialog(c, 'Nuovo obiettivo');
            if (v?.isNotEmpty == true) s.addGoal(v!);
          },
        ),
        child: Column(
          children: s.goals
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text('${(e.progress * 100).round()}%'),
                          IconButton(
                            tooltip: 'Elimina',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              if (await _confirmDelete(c, e.title)) {
                                s.removeGoal(e);
                              }
                            },
                          ),
                        ],
                      ),
                      Slider(
                        value: e.progress,
                        onChanged: (v) => s.setGoal(e, v),
                      ),
                    ],
                  ),
                ),
              )
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
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => PageBody(
    title: title,
    subtitle: subtitle,
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
      children: [
        Section(
          title: '${monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
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
    final completed = project.tasks.where((task) => task.done).length;
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
              Text('$completed di ${project.tasks.length} attività completate'),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final completed = project.tasks.where((task) => task.done).length;
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
                Text('$completed di ${project.tasks.length} sotto-attività'),
              ],
            ),
          ),
          Section(
            title: 'Sotto-attività',
            action: IconButton(
              tooltip: 'Aggiungi',
              icon: const Icon(Icons.add),
              onPressed: _addTask,
            ),
            child: tasks.isEmpty
                ? const _EmptyState(
                    icon: Icons.checklist,
                    message: 'Dividi il progetto in attività concrete.',
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

class SettingsPage extends StatelessWidget {
  const SettingsPage(this.s, {super.key, this.cloudEmail, this.onSignOut});
  final AppState s;
  final String? cloudEmail;
  final Future<void> Function()? onSignOut;
  @override
  Widget build(BuildContext c) => PageBody(
    title: 'Impostazioni',
    subtitle: 'Personalizza la tua esperienza',
    children: [
      Section(
        title: 'Aspetto',
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tema scuro'),
          subtitle: const Text('Salvato su questo dispositivo'),
          value: s.darkMode,
          onChanged: s.setDark,
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
