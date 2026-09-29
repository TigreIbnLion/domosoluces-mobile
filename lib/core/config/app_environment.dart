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
        _ => AppEnvironment.dev,
      };

  static Uri get apiBaseUri {
    final origin = Uri.parse(apiOrigin);
    if (environment == AppEnvironment.production && origin.scheme != 'https') {
      throw StateError('Production API_ORIGIN must use HTTPS.');
    }
    return origin.replace(path: _join(origin.path, 'api'));
  }

  static String _join(String left, String right) {
    final a = left.endsWith('/') ? left.substring(0, left.length - 1) : left;
    return '$a/$right';
  }
}
