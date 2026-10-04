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

  Future<void> updateProfile({required String name,String? phone}) async {
    final current=state.value;
    try {
      final updated=await ref.read(authRepositoryProvider).updateProfile({'name':name.trim(),'phone':phone?.trim().isEmpty==true?null:phone?.trim()});
      state=AsyncData(updated);
    } catch (error,stack) {
      if(current!=null) state=AsyncData(current);
      Error.throwWithStackTrace(error,stack);
    }
  }

  Future<void> updatePassword({required String currentPassword,required String password,required String confirmation}) async {
    await ref.read(authRepositoryProvider).updatePassword({'current_password':currentPassword,'password':password,'password_confirmation':confirmation});
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


final capabilityControllerProvider=AsyncNotifierProvider.family<CapabilityController,CapabilityUiState,String>(CapabilityController.new);
final class CapabilityController extends FamilyAsyncNotifier<CapabilityUiState,String>{
 @override Future<CapabilityUiState> build(String deviceId) async=>CapabilityUiState(snapshot:await ref.read(clientRepositoryProvider).capabilities(deviceId));
 Future<void> refresh() async {final current=state.value;try{final snapshot=await ref.read(clientRepositoryProvider).capabilities(arg);state=AsyncData(CapabilityUiState(snapshot:snapshot));}catch(e,st){if(current==null)state=AsyncError(e,st);else rethrow;}}
 Future<void> execute({required String capabilityId,required String command,required Object? value}) async {
  final current=state.value;if(current==null)return;
  state=AsyncData(current.copyWith(phase:CapabilityCommandPhase.pending,pendingCapabilityId:capabilityId,clearMessage:true));
  try{final confirmed=await ref.read(clientRepositoryProvider).capabilityCommandAndConfirm(arg,capabilityId:capabilityId,command:command,value:value);state=AsyncData(CapabilityUiState(snapshot:confirmed,phase:CapabilityCommandPhase.confirmed));}
  catch(e){state=AsyncData(current.copyWith(phase:CapabilityCommandPhase.error,message:e is AppException?e.message:'Confirmation impossible.',clearPending:true));}
 }
}
