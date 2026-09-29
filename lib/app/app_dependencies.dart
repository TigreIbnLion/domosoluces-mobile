import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_store.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/client_repository.dart';
import '../domain/models/models.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(tokenStoreProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStoreProvider)));
final clientRepositoryProvider =
    Provider<ClientRepository>((ref) => ClientRepository(ref.watch(apiClientProvider)));

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);

final class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final repo = ref.read(authRepositoryProvider);
    if (!await repo.hasSession()) return null;
    try { return await repo.me(); } catch (_) { return null; }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).login(
      email: email, password: password, deviceName: 'DOMOSOLUCES Mobile'));
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
