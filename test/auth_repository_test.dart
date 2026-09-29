import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:domosoluces_mobile/core/network/api_client.dart';
import 'package:domosoluces_mobile/core/storage/token_store.dart';
import 'package:domosoluces_mobile/data/repositories/auth_repository.dart';

final class TestTokenStore implements TokenStore {
  String? token = 'token';
  @override Future<void> clear() async => token = null;
  @override Future<String?> read() async => token;
  @override Future<void> write(String value) async => token = value;
}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TestTokenStore tokens;
  late AuthRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    adapter = DioAdapter(dio: dio);
    tokens = TestTokenStore();
    repository = AuthRepository(ApiClient(tokens, dio: dio), tokens);
  });

  test('login accepts contractual UserResource before sites relation is loaded', () async {
    adapter.onPost('auth/login', (server) => server.reply(200, {
      'message': 'Connexion réussie.',
      'token': 'new-token',
      'user': {
        'id': 'user-1',
        'name': 'Client',
        'email': 'client@example.test',
        'phone': null,
        'role': 'client',
        'zone': null,
        'is_active': true,
        'has_2fa': false,
        'created_at': '2026-09-29',
        'unread_alerts': 0,
      },
    }), data: {
      'email': 'client@example.test',
      'password': 'password',
      'device_name': 'DOMOSOLUCES Mobile',
    });
    final user = await repository.login(
      email: 'client@example.test',
      password: 'password',
      deviceName: 'DOMOSOLUCES Mobile',
    );
    expect(user.id, 'user-1');
    expect(user.sites, isEmpty);
    expect(tokens.token, 'new-token');
  });

  test('logout-all clears secure token', () async {
    adapter.onPost('auth/logout-all', (server) => server.reply(200, {'message': 'ok'}));
    await repository.logoutAll();
    expect(tokens.token, isNull);
  });

  test('sessions uses contractual endpoint', () async {
    adapter.onGet('auth/sessions', (server) => server.reply(200, {'data': []}));
    expect(await repository.sessions(), {'data': []});
  });

  test('revoke session URL-encodes token id', () async {
    adapter.onDelete('auth/sessions/a%2Fb', (server) => server.reply(200, {'message': 'ok'}));
    await repository.revokeSession('a/b');
  });
}
