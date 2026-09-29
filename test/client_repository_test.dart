import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:domosoluces_mobile/core/network/api_client.dart';
import 'package:domosoluces_mobile/core/storage/token_store.dart';
import 'package:domosoluces_mobile/data/repositories/client_repository.dart';
import 'package:domosoluces_mobile/domain/models/models.dart';

final class TokenStoreStub implements TokenStore {
  @override Future<void> clear() async {}
  @override Future<String?> read() async => 'token';
  @override Future<void> write(String token) async {}
}

Map<String, Object?> deviceJson({String state = 'on'}) => {
  'id':'dev-1','kit_id':'kit-1','device_uid':'D1','name':'Prise salon',
  'room':'Salon','icon':null,'type':'prise','status':'online','state':state,
  'mode':'normal','is_active':true,'is_leader':false,'firmware_version':'1.0.0',
  'last_seen_at':'2026-09-29T02:00:00Z','current_power':0,'energy_kwh':0,
};

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ClientRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    adapter = DioAdapter(dio: dio);
    repository = ClientRepository(ApiClient(TokenStoreStub(), dio: dio));
  });

  test('kits consumes exact V1 kits wrapper', () async {
    adapter.onGet('client/kits', (server) => server.reply(200, {'kits': [{
      'id':'kit-1','serial_number':'KIT-001','name':'Maison','site_label':null,
      'type':null,'status':'active','installed_at':null,'activated_at':null,
      'devices_count':1,
    }]}));
    final kits = await repository.kits();
    expect(kits.single.id, 'kit-1');
    expect(kits.single.displayName, 'Maison');
  });

  test('accepted ON command waits for confirmed server state', () async {
    adapter.onPost('client/devices/dev-1/on', (server) =>
        server.reply(202, {'message': 'accepted'}));
    adapter.onGet('client/devices/dev-1/status', (server) =>
        server.reply(200, {'device': deviceJson(state: 'on')}));

    final result = await repository.commandAndConfirm(
      'dev-1', turnOn: true, interval: Duration.zero,
      timeout: const Duration(seconds: 1),
    );
    expect(result.phase, DeviceCommandPhase.confirmed);
    expect(result.device?.state, 'on');
  });

  test('command does not report confirmed when server state differs', () async {
    adapter.onPost('client/devices/dev-1/off', (server) =>
        server.reply(202, {'message': 'accepted'}));
    adapter.onGet('client/devices/dev-1/status', (server) =>
        server.reply(200, {'device': deviceJson(state: 'on')}));

    final result = await repository.commandAndConfirm(
      'dev-1', turnOn: false, interval: const Duration(milliseconds: 1),
      timeout: const Duration(milliseconds: 5),
    );
    expect(result.phase, DeviceCommandPhase.error);
    expect(result.device?.state, 'on');
    expect(result.device?.status, 'online');
  });
}
