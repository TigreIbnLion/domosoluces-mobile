import 'package:flutter_test/flutter_test.dart';
import 'package:domosoluces_mobile/domain/models/models.dart';

void main() {
  test('Device exposes only contractual state and status fields', () {
    final device = Device.fromJson({
      'state': 'on',
      'status': 'online',
      'future_field': 42,
    });

    expect(device.state, 'on');
    expect(device.status, 'online');
    expect(device.raw['future_field'], 42);
  });

  test('User and Kit preserve unknown payload fields without inventing schema', () {
    final user = User.fromJson({'server_defined': true});
    final kit = Kit.fromJson({'server_defined': 7});

    expect(user.raw['server_defined'], true);
    expect(kit.raw['server_defined'], 7);
  });
}
