import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import '../errors/app_exception.dart';
import '../storage/token_store.dart';

final class ApiClient {
  ApiClient(this._tokens, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${AppConfig.apiBaseUri.toString()}/',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await _tokens.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
  }

  final Dio _dio;
  final TokenStore _tokens;

  Future<Object?> get(String path) => _request('GET', path);
  Future<Object?> post(String path, {Object? data}) => _request('POST', path, data: data);
  Future<Object?> put(String path, {Object? data}) => _request('PUT', path, data: data);
  Future<Object?> delete(String path) => _request('DELETE', path);

  Future<Object?> _request(String method, String path, {Object? data}) async {
    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    try {
      final response = await _dio.request<Object?>(
        relativePath, data: data, options: Options(method: method));
      return response.data;
    } on DioException catch (error) {
      final response = error.response;
      if (response == null) {
        throw NetworkException('Connexion au serveur impossible.', details: error.type);
      }
      final code = response.statusCode;
      final body = response.data;
      final message = _message(body);
      switch (code) {
        case 401:
          await _tokens.clear();
          throw UnauthorizedException(message, details: body);
        case 403:
          throw ForbiddenException(message, details: body);
        case 404:
          throw NotFoundException(message, details: body);
        case 422:
          throw ValidationException(message, details: body);
        case 429:
          throw RateLimitException(message, details: body);
        default:
          if (code != null && code >= 500) {
            throw ServerException(message, statusCode: code, details: body);
          }
          throw UnexpectedResponseException(message, statusCode: code, details: body);
      }
    }
  }

  String _message(Object? body) {
    if (body is Map && body['message'] is String) return body['message'] as String;
    return 'La requête n’a pas pu être traitée.';
  }
}
