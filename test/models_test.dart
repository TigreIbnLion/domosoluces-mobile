import 'package:flutter_test/flutter_test.dart';
import 'package:domosoluces_mobile/domain/models/models.dart';

void main() {
  test('Kit V1 uses contractual id, name and devices_count', () {
    final kit = Kit.fromJson({
      'id': 'kit-1',
      'serial_number': 'KIT-001',
      'name': 'Maison',
      'site_label': 'Maison Abidjan',
      'type': null,
      'status': 'active',
      'installed_at': null,
      'activated_at': null,
      'devices_count': 2,
    });
    expect(kit.id, 'kit-1');
    expect(kit.displayName, 'Maison');
    expect(kit.devicesCount, 2);
  });

  test('Device V1 exposes confirmed state and connectivity separately', () {
    final device = Device.fromJson({
      'id': 'dev-1',
      'kit_id': 'kit-1',
      'device_uid': 'PRISE-001',
      'name': 'Prise salon',
      'room': 'Salon',
      'icon': null,
      'type': 'prise',
      'status': 'online',
      'state': 'on',
      'mode': 'normal',
      'is_active': true,
      'is_leader': false,
      'firmware_version': '1.0.0',
      'last_seen_at': '2026-09-29T04:00:00Z',
      'current_power': 12.5,
      'energy_kwh': 1.2,
    });
    expect(device.id, 'dev-1');
    expect(device.status, 'online');
    expect(device.state, 'on');
    expect(device.displayName, 'Prise salon');
  });

  test('User V1 parses direct auth me schema', () {
    final user = User.fromJson({
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
      'sites': [],
    });
    expect(user.id, 'user-1');
    expect(user.role, 'client');
  });
}
