import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_store.dart';
import '../../domain/models/models.dart';

final class AuthRepository {
  const AuthRepository(this._api, this._tokens);
  final ApiClient _api;
  final TokenStore _tokens;

  Future<User> login({required String email, required String password, required String deviceName}) async {
    final data = await _api.post('/auth/login', data: {
      'email': email.trim(), 'password': password, 'device_name': deviceName,
    });
    final json = _map(data);
    final token = json['token'];
    final user = json['user'];
    if (token is! String || token.isEmpty || user is! Map) {
      throw UnexpectedResponseException('Réponse de connexion invalide.', details: data);
    }
    await _tokens.write(token);
    return User.fromJson(Map<String, Object?>.from(user));
  }

  Future<User> me() async {
    final data = await _api.get('/auth/me');
    final json = _map(data);
    return User.fromJson(json);
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout'); } finally { await _tokens.clear(); }
  }

  Future<void> logoutAll() async {
    try { await _api.post('/auth/logout-all'); } finally { await _tokens.clear(); }
  }

  Future<User> updateProfile(Map<String, Object?> payload) async {
    final data = await _api.put('/auth/profile', data: payload);
    final json = _map(data);
    final candidate = json['user'] is Map ? json['user'] : json;
    if (candidate is! Map) {
      throw UnexpectedResponseException('Profil API invalide.', details: data);
    }
    return User.fromJson(Map<String, Object?>.from(candidate));
  }

  Future<void> updatePassword(Map<String, Object?> payload) async {
    await _api.put('/auth/password', data: payload);
  }

  Future<List<AuthSession>> sessions() async {
    final data=_map(await _api.get('/auth/sessions'));
    final raw=data['sessions'];
    if(raw is! List) throw UnexpectedResponseException('Sessions API invalides.',details:data);
    return raw.map((e)=>AuthSession.fromJson(Map<String,Object?>.from(e as Map))).toList(growable:false);
  }

  Future<void> revokeSession(String tokenId) async {
    await _api.delete('/auth/sessions/${Uri.encodeComponent(tokenId)}');
  }

  Future<bool> hasSession() async => (await _tokens.read())?.isNotEmpty == true;

  Map<String, Object?> _map(Object? data) {
    if (data is Map) return Map<String, Object?>.from(data);
    throw UnexpectedResponseException('Réponse API invalide.', details: data);
  }
}
