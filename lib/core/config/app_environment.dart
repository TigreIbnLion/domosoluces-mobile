enum AppEnvironment { dev, staging, production }

final class AppConfig {
  const AppConfig._();

  static const environmentName =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const apiOrigin =
      String.fromEnvironment('API_ORIGIN', defaultValue: 'http://10.0.2.2:8000');

  static AppEnvironment get environment => switch (environmentName) {
        'production' => AppEnvironment.production,
        'staging' => AppEnvironment.staging,
        'dev' => AppEnvironment.dev,
        _ => throw StateError('Unsupported APP_ENV: $environmentName'),
      };

  static Uri get apiBaseUri {
    if (apiOrigin.trim().isEmpty) {
      throw StateError('API_ORIGIN must not be empty.');
    }
    final origin = Uri.tryParse(apiOrigin);
    if (origin == null || !origin.hasScheme || origin.host.isEmpty) {
      throw StateError('API_ORIGIN must be an absolute HTTP(S) URL.');
    }
    if (origin.scheme != 'http' && origin.scheme != 'https') {
      throw StateError('API_ORIGIN must use HTTP or HTTPS.');
    }
    if (environment == AppEnvironment.production && origin.scheme != 'https') {
      throw StateError('Production API_ORIGIN must use HTTPS.');
    }
    return origin.replace(path: _join(origin.path, 'api'), query: null, fragment: null);
  }

  static String _join(String left, String right) {
    final normalized = left.endsWith('/')
        ? left.substring(0, left.length - 1)
        : left;
    if (normalized.endsWith('/api')) return normalized;
    return '$normalized/$right';
  }
}
