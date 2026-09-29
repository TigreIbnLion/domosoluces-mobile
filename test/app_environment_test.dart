import 'package:flutter_test/flutter_test.dart';
import 'package:domosoluces_mobile/core/config/app_environment.dart';

void main() {
  test('API base path always targets /api', () {
    expect(AppConfig.apiBaseUri.path.endsWith('/api'), isTrue);
  });
}
