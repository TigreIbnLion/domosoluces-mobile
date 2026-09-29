import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:domosoluces_mobile/core/errors/app_exception.dart';
import 'package:domosoluces_mobile/core/network/api_client.dart';
import 'package:domosoluces_mobile/core/storage/token_store.dart';

final class MemoryTokenStore implements TokenStore {
  String? token;
  @override Future<void> clear() async => token = null;
  @override Future<String?> read() async => token;
  @override Future<void> write(String value) async => token = value;
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late MemoryTokenStore tokens;
  late ApiClient api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    adapter = DioAdapter(dio: dio);
    tokens = MemoryTokenStore()..token = 'secret';
    api = ApiClient(tokens, dio: dio);
  });

  test('request keeps the /api prefix and sends Sanctum Bearer token', () async {
    adapter.onGet('auth/me', (server) => server.reply(200, {'ok': true}));
    expect(await api.get('/auth/me'), {'ok': true});
    expect(tokens.token, 'secret');
  });

  test('401 clears local session token', () async {
    adapter.onGet('auth/me', (server) => server.reply(401, {'message': 'Expired'}));
    await expectLater(api.get('/auth/me'), throwsA(isA<UnauthorizedException>()));
    expect(tokens.token, isNull);
  });

  test('422 maps to ValidationException', () async {
    adapter.onPost('auth/login', (server) => server.reply(422, {'message': 'Invalid'}));
    await expectLater(api.post('/auth/login'), throwsA(isA<ValidationException>()));
  });

  test('5xx never becomes success', () async {
    adapter.onGet('client/kits', (server) => server.reply(503, {'message': 'Unavailable'}));
    await expectLater(api.get('/client/kits'), throwsA(isA<ServerException>()));
  });
}
