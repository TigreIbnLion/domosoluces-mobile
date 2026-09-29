import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/errors/app_exception.dart';
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
    try {
      return await repo.me();
    } on UnauthorizedException {
      return null;
    } catch (_) {
      rethrow;
    }
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

final deviceCommandProvider = AsyncNotifierProviderFamily<DeviceCommandController,
    DeviceCommandState, String>(DeviceCommandController.new);

final class DeviceCommandController
    extends FamilyAsyncNotifier<DeviceCommandState, String> {
  @override
  Future<DeviceCommandState> build(String arg) async =>
      const DeviceCommandState(DeviceCommandPhase.idle);

  Future<void> execute({required bool turnOn}) async {
    final previousDevice = state.value?.device;
    state = AsyncData(DeviceCommandState(
      DeviceCommandPhase.pending,
      device: previousDevice,
    ));
    try {
      final result = await ref.read(clientRepositoryProvider)
          .commandAndConfirm(arg, turnOn: turnOn);
      state = AsyncData(result);
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final device = await ref.read(clientRepositoryProvider).status(arg);
      return DeviceCommandState(DeviceCommandPhase.idle, device: device);
    });
  }
}
