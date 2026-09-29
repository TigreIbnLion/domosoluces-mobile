import 'package:flutter_test/flutter_test.dart';
import 'package:domosoluces_mobile/core/config/app_environment.dart';

void main() {
  test('default environment is development', () {
    expect(AppConfig.environment, AppEnvironment.dev);
  });

  test('API base path targets exactly one /api suffix', () {
    expect(AppConfig.apiBaseUri.path.endsWith('/api'), isTrue);
    expect(AppConfig.apiBaseUri.path.endsWith('/api/api'), isFalse);
  });

  test('API base URI never carries query or fragment from origin', () {
    expect(AppConfig.apiBaseUri.query, isEmpty);
    expect(AppConfig.apiBaseUri.fragment, isEmpty);
  });
}
