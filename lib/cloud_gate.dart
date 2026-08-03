import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'data/local_store.dart';
import 'data/supabase_store.dart';
import 'data/synced_store.dart';

class CloudGate extends StatelessWidget {
  const CloudGate({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? client.auth.currentSession;
        if (session == null) return LoginApp(client: client);
        return LifeHubApp(
          store: SyncedStore(
            local: LocalStore(),
            remote: SupabaseStore(client),
          ),
          cloudEmail: session.user.email,
          onSignOut: client.auth.signOut,
        );
      },
    );
  }
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key, required this.client});
  final SupabaseClient client;
  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool createAccount = false;
  bool loading = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      message = null;
    });
    try {
      if (createAccount) {
        final result = await widget.client.auth.signUp(
          email: email.text.trim(),
          password: password.text,
        );
        if (result.session == null) {
          message = 'Controlla la tua email per confermare l’account.';
        }
      } else {
        await widget.client.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on AuthException catch (error) {
      message = error.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6558d3)),
      useMaterial3: true,
    ),
    home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.hub_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      createAccount ? 'Crea il tuo account' : 'Bentornato',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      onSubmitted: (_) => loading ? null : submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'Almeno 6 caratteri',
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(message!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: loading ? null : submit,
                      child: Text(createAccount ? 'Registrati' : 'Accedi'),
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () =>
                                setState(() => createAccount = !createAccount),
                      child: Text(
                        createAccount
                            ? 'Hai già un account? Accedi'
                            : 'Non hai un account? Registrati',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
