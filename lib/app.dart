import 'package:flutter/material.dart';
import 'data/local_store.dart';
import 'state/app_state.dart';

class LifeHubApp extends StatefulWidget {
  const LifeHubApp({super.key, this.store});
  final AppStore? store;
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
        ? LifeHubShell(state: state)
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
  const LifeHubShell({super.key, required this.state});
  final AppState state;
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
      SettingsPage(widget.state),
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

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class TodayPage extends StatelessWidget {
  const TodayPage(this.s, {super.key});
  final AppState s;
  @override
  Widget build(BuildContext c) {
    final done = s.tasks.where((e) => e.done).length;
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
              if (v?.isNotEmpty == true) s.addReminder(v!, 'Oggi');
            },
          ),
          child: Column(
            children: s.reminders
                .map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_none),
                    title: Text(e.title),
                    trailing: Text(e.time),
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
              final v = await _textDialog(
                c,
                'Nuovo movimento',
                hint: 'Descrizione, importo (es. Caffè, -1.50)',
              );
              if (v != null) {
                final p = v.split(',');
                if (p.length > 1) {
                  final n = double.tryParse(p.last.trim().replaceAll(',', '.'));
                  if (n != null) s.addMovement(p.first.trim(), n);
                }
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
                    trailing: Text(
                      '${e.amount >= 0 ? '+' : ''}${e.amount.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: e.amount >= 0 ? Colors.green : null,
                      ),
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
                    secondary: const Icon(Icons.calendar_month),
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
  const SettingsPage(this.s, {super.key});
  final AppState s;
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
      const Section(
        title: 'Dati e sincronizzazione',
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.cloud_off_outlined),
          title: Text('Solo locale'),
          subtitle: Text(
            'I dati restano sul dispositivo. L’architettura è pronta per collegare un servizio cloud in futuro.',
          ),
        ),
      ),
    ],
  );
}
