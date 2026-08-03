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
        final userId = session.user.id;
        return LifeHubApp(
          key: ValueKey(userId),
          store: SyncedStore(
            local: LocalStore.forUser(userId),
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
  final confirmPassword = TextEditingController();
  bool createAccount = false;
  bool loading = false;
  bool hidePassword = true;
  bool messageIsError = true;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final normalizedEmail = email.text.trim();
    if (!normalizedEmail.contains('@')) {
      setState(() {
        message = 'Inserisci un indirizzo email valido.';
        messageIsError = true;
      });
      return;
    }
    if (password.text.length < 8) {
      setState(() {
        message = 'La password deve avere almeno 8 caratteri.';
        messageIsError = true;
      });
      return;
    }
    if (createAccount && password.text != confirmPassword.text) {
      setState(() {
        message = 'Le password non coincidono.';
        messageIsError = true;
      });
      return;
    }
    setState(() {
      loading = true;
      message = null;
      messageIsError = true;
    });
    try {
      if (createAccount) {
        final result = await widget.client.auth.signUp(
          email: normalizedEmail,
          password: password.text,
        );
        if (result.session == null) {
          message = 'Controlla la tua email per confermare l’account.';
          messageIsError = false;
        }
      } else {
        await widget.client.auth.signInWithPassword(
          email: normalizedEmail,
          password: password.text,
        );
      }
    } on AuthException catch (error) {
      message = error.message;
    } catch (_) {
      message = 'Accesso non riuscito. Controlla la connessione e riprova.';
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
                    const Text(
                      'LIFE HUB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      createAccount ? 'Crea il tuo account' : 'Bentornato',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: hidePassword,
                      autofillHints: createAccount
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      textInputAction: createAccount
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: (_) {
                        if (!loading && !createAccount) submit();
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: 'Almeno 8 caratteri',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: hidePassword
                              ? 'Mostra password'
                              : 'Nascondi password',
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (createAccount) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmPassword,
                        obscureText: hidePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!loading) submit();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Conferma password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                    ],
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: messageIsError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: loading ? null : submit,
                      child: Text(createAccount ? 'Registrati' : 'Accedi'),
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () => setState(() {
                              createAccount = !createAccount;
                              confirmPassword.clear();
                              message = null;
                              messageIsError = true;
                            }),
                      child: Text(
                        createAccount
                            ? 'Hai già un account? Accedi'
                            : 'Non hai un account? Registrati',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ogni account vede esclusivamente le proprie '
                            'attività, finanze, scadenze e obiettivi.',
                          ),
                        ),
                      ],
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
