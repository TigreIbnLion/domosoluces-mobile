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

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ClientRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    adapter = DioAdapter(dio: dio);
    repository = ClientRepository(ApiClient(TokenStoreStub(), dio: dio));
  });

  test('accepted ON command waits for confirmed server state', () async {
    adapter.onPost('client/devices/42/on', (server) =>
        server.reply(202, {'message': 'accepted'}));
    adapter.onGet('client/devices/42/status', (server) =>
        server.reply(200, {'state': 'on', 'status': 'online'}));

    final result = await repository.commandAndConfirm(
      '42',
      turnOn: true,
      interval: Duration.zero,
      timeout: const Duration(seconds: 1),
    );

    expect(result.phase, DeviceCommandPhase.confirmed);
    expect(result.device?.state, 'on');
  });

  test('command does not report confirmed when server state differs', () async {
    adapter.onPost('client/devices/42/off', (server) =>
        server.reply(202, {'message': 'accepted'}));
    adapter.onGet('client/devices/42/status', (server) =>
        server.reply(200, {'state': 'on', 'status': 'online'}));

    final result = await repository.commandAndConfirm(
      '42',
      turnOn: false,
      interval: const Duration(milliseconds: 1),
      timeout: const Duration(milliseconds: 5),
    );

    expect(result.phase, DeviceCommandPhase.error);
  });
}
