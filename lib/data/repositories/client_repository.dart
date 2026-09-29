import 'dart:async';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/models/models.dart';

final class ClientRepository {
  const ClientRepository(this._api);
  final ApiClient _api;

  Future<List<Kit>> kits() async =>
      _list(await _api.get('/client/kits')).map(Kit.fromJson).toList(growable: false);

  Future<Kit> kit(String kit) async =>
      Kit.fromJson(_object(await _api.get('/client/kits/$kit')));

  Future<List<Device>> devices(String kit) async =>
      _list(await _api.get('/client/kits/$kit/devices')).map(Device.fromJson).toList(growable: false);

  Future<Device> status(String device) async =>
      Device.fromJson(_object(await _api.get('/client/devices/$device/status')));

  Future<void> sendCommand(String device, {required bool turnOn}) async {
    await _api.post('/client/devices/$device/${turnOn ? 'on' : 'off'}');
  }

  Future<DeviceCommandState> commandAndConfirm(
    String device, {
    required bool turnOn,
    Duration timeout = const Duration(seconds: 15),
    Duration interval = const Duration(seconds: 1),
  }) async {
    await sendCommand(device, turnOn: turnOn);
    final deadline = DateTime.now().add(timeout);
    final expected = turnOn ? 'on' : 'off';
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(interval);
      final current = await status(device);
      if (current.state?.toLowerCase() == expected) {
        return DeviceCommandState(DeviceCommandPhase.confirmed, device: current);
      }
    }
    return const DeviceCommandState(DeviceCommandPhase.error,
      message: 'Commande acceptée, mais état physique non confirmé avant expiration.');
  }

  List<Map<String, Object?>> _list(Object? data) {
    Object? candidate = data;
    if (data is Map) {
      for (final key in const ['data', 'kits', 'devices']) {
        if (data[key] is List) { candidate = data[key]; break; }
      }
    }
    if (candidate is! List) throw UnexpectedResponseException('Liste API invalide.', details: data);
    return candidate.map((e) {
      if (e is! Map) throw UnexpectedResponseException('Élément API invalide.', details: e);
      return Map<String, Object?>.from(e);
    }).toList(growable: false);
  }

  Map<String, Object?> _object(Object? data) {
    Object? candidate = data;
    if (data is Map && data['data'] is Map) candidate = data['data'];
    if (candidate is! Map) throw UnexpectedResponseException('Objet API invalide.', details: data);
    return Map<String, Object?>.from(candidate);
  }
}
