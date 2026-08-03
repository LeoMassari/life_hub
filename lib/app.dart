import 'package:flutter/material.dart';
import 'data/local_store.dart';
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

class _LifeHubShellState extends State<LifeHubShell> {
  int index = 0;
  static const destinations = [
    ('Oggi', Icons.today_outlined),
    ('Finanze', Icons.account_balance_wallet_outlined),
    ('Obiettivi', Icons.flag_outlined),
    ('Scadenze', Icons.event_outlined),
    ('Impostazioni', Icons.settings_outlined),
  ];
  @override
  Widget build(BuildContext c) {
    final pages = [
      TodayPage(widget.state),
      FinancePage(widget.state),
      GoalsPage(widget.state),
      DeadlinesPage(widget.state),
      SettingsPage(
        widget.state,
        cloudEmail: widget.cloudEmail,
        onSignOut: widget.onSignOut,
      ),
    ];
    return LayoutBuilder(
      builder: (c, box) {
        final wide = box.maxWidth >= 760;
        final nav = destinations
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
                  selectedIndex: index,
                  onDestinationSelected: (v) => setState(() => index = v),
                  labelType: NavigationRailLabelType.all,
                  destinations: nav,
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(index),
                    child: pages[index],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: (v) => setState(() => index = v),
                  destinations: destinations
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

Future<String?> _textDialog(BuildContext c, String title, {String hint = ''}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: c,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
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
          title: 'Panoramica',
          child: Wrap(
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
        ),
        if (urgent.isNotEmpty)
          Section(
            title: 'Richiede attenzione',
            child: Column(
              children: urgent
                  .map(
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
                  )
                  .toList(),
            ),
          ),
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
                          secondary: IconButton(
                            tooltip: 'Elimina',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              if (await _confirmDelete(c, e.title)) {
                                s.removeTask(e);
                              }
                            },
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
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text('Esci dall’account'),
            onTap: onSignOut,
          ),
        ),
    ],
  );
}
