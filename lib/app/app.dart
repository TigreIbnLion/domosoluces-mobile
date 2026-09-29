import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors/app_exception.dart';
import 'app_dependencies.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
  ],
));

final class DomosolucesApp extends ConsumerWidget {
  const DomosolucesApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'DOMOSOLUCES',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFFF57C00)),
    routerConfig: ref.watch(routerProvider),
  );
}

final class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

final class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(email.text, password.text);
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasValue && state.value != null) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = auth.error;
    return Scaffold(
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(padding: const EdgeInsets.all(24), child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('DOMOSOLUCES', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null),
            const SizedBox(height: 12),
            TextFormField(controller: password, obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              validator: (v) => v == null || v.isEmpty ? 'Mot de passe requis' : null),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error is AppException ? error.message : 'Une erreur est survenue.')),
            const SizedBox(height: 20),
            FilledButton(onPressed: auth.isLoading ? null : submit,
              child: auth.isLoading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator()) : const Text('Se connecter')),
          ]),
        )),
      ))),
    );
  }
}

final class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Mes kits'), actions: [
      IconButton(onPressed: () async {
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) context.go('/login');
      }, icon: const Icon(Icons.logout)),
    ]),
    body: FutureBuilder(
      future: ref.read(clientRepositoryProvider).kits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(snapshot.error is AppException ? (snapshot.error! as AppException).message : 'Chargement impossible.')));
        final kits = snapshot.data ?? const [];
        if (kits.isEmpty) return const Center(child: Text('Aucun kit disponible.'));
        return RefreshIndicator(
          onRefresh: () async => context.go('/home'),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: kits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) => Card(child: ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: Text('Kit ${index + 1}'),
              subtitle: Text(kits[index].raw.toString(), maxLines: 3, overflow: TextOverflow.ellipsis),
            )),
          ),
        );
      },
    ),
  );
}
