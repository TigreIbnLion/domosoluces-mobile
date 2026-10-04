final class Site {
  const Site({required this.id, required this.name, required this.city});
  final String id;
  final String name;
  final String? city;
  factory Site.fromJson(Map<String, Object?> j) => Site(
    id: j['id'] as String,
    name: j['name'] as String,
    city: j['city'] as String?,
  );
}

final class User {
  const User({
    required this.id, required this.name, required this.email, required this.phone,
    required this.role, required this.zone, required this.isActive, required this.has2fa,
    required this.createdAt, required this.unreadAlerts, required this.sites,
  });
  final String id, name, email, role, createdAt;
  final String? phone, zone;
  final bool isActive, has2fa;
  final int unreadAlerts;
  final List<Site> sites;
  factory User.fromJson(Map<String, Object?> j) => User(
    id: j['id'] as String, name: j['name'] as String, email: j['email'] as String,
    phone: j['phone'] as String?, role: j['role'] as String, zone: j['zone'] as String?,
    isActive: j['is_active'] as bool, has2fa: j['has_2fa'] as bool,
    createdAt: j['created_at'] as String, unreadAlerts: j['unread_alerts'] as int,
    sites: (j['sites'] is List ? j['sites'] as List : const <Object?>[])
        .map((e) => Site.fromJson(Map<String, Object?>.from(e as Map)))
        .toList(growable: false),
  );
}

final class Kit {
  const Kit({
    required this.id, required this.serialNumber, required this.name, required this.siteLabel,
    required this.type, required this.status, required this.installedAt, required this.activatedAt,
    required this.devicesCount,
  });
  final String id, serialNumber, status;
  final String? name, siteLabel, type, installedAt, activatedAt;
  final int devicesCount;
  factory Kit.fromJson(Map<String, Object?> j) => Kit(
    id: j['id'] as String, serialNumber: j['serial_number'] as String,
    name: j['name'] as String?, siteLabel: j['site_label'] as String?, type: j['type'] as String?,
    status: j['status'] as String, installedAt: j['installed_at'] as String?,
    activatedAt: j['activated_at'] as String?, devicesCount: j['devices_count'] as int,
  );
  String get displayName => name?.trim().isNotEmpty == true ? name! : serialNumber;
}

final class Device {
  const Device({
    required this.id, required this.kitId, required this.deviceUid, required this.name,
    required this.room, required this.icon, required this.type, required this.status,
    required this.state, required this.mode, required this.isActive, required this.isLeader,
    required this.firmwareVersion, required this.lastSeenAt, required this.currentPower,
    required this.energyKwh,
  });
  final String id, kitId, deviceUid, type, status, state, mode;
  final String? name, room, icon, firmwareVersion, lastSeenAt;
  final bool isActive, isLeader;
  final num? currentPower, energyKwh;
  factory Device.fromJson(Map<String, Object?> j) => Device(
    id: j['id'] as String, kitId: j['kit_id'] as String, deviceUid: j['device_uid'] as String,
    name: j['name'] as String?, room: j['room'] as String?, icon: j['icon'] as String?,
    type: j['type'] as String, status: j['status'] as String, state: j['state'] as String,
    mode: j['mode'] as String, isActive: j['is_active'] as bool, isLeader: j['is_leader'] as bool,
    firmwareVersion: j['firmware_version'] as String?, lastSeenAt: j['last_seen_at'] as String?,
    currentPower: j['current_power'] as num?, energyKwh: j['energy_kwh'] as num?,
  );
  String get displayName => name?.trim().isNotEmpty == true ? name! : deviceUid;
}

enum DeviceCommandPhase { idle, pending, confirmed, error }

final class DeviceCommandState {
  const DeviceCommandState(this.phase, {this.device, this.message});
  final DeviceCommandPhase phase;
  final Device? device;
  final String? message;
}


final class AuthSession {
  const AuthSession({required this.id,required this.name,required this.lastUsedAt,required this.createdAt,required this.expiresAt});
  final int id;
  final String name;
  final String? lastUsedAt,createdAt,expiresAt;
  factory AuthSession.fromJson(Map<String,Object?> j)=>AuthSession(
    id:j['id'] as int,name:j['name'] as String,
    lastUsedAt:j['last_used_at'] as String?,createdAt:j['created_at'] as String?,expiresAt:j['expires_at'] as String?,
  );
}


final class ConsumptionSummary {
 const ConsumptionSummary({required this.from,required this.to,required this.totalKwh,required this.estimatedCostXof,required this.averagePowerW,required this.peakPowerW,required this.records,required this.timeline,required this.byDevice});
 final String from,to; final num totalKwh,estimatedCostXof,averagePowerW,peakPowerW; final int records;
 final List<ConsumptionPoint> timeline; final List<DeviceConsumptionShare> byDevice;
 factory ConsumptionSummary.fromJson(Map<String,Object?> j){
  final f=Map<String,Object?>.from(j['filters'] as Map),s=Map<String,Object?>.from(j['summary'] as Map);
  return ConsumptionSummary(from:f['from'] as String,to:f['to'] as String,totalKwh:s['total_kwh'] as num,estimatedCostXof:s['estimated_cost_xof'] as num,averagePowerW:s['average_power_w'] as num,peakPowerW:s['peak_power_w'] as num,records:s['records'] as int,timeline:(j['timeline'] as List).map((e)=>ConsumptionPoint.fromJson(Map<String,Object?>.from(e as Map))).toList(growable:false),byDevice:(j['by_device'] as List).map((e)=>DeviceConsumptionShare.fromJson(Map<String,Object?>.from(e as Map))).toList(growable:false));
 }
}
final class ConsumptionPoint {const ConsumptionPoint({required this.label,required this.energyKwh,required this.averagePowerW});final String label;final num energyKwh,averagePowerW;factory ConsumptionPoint.fromJson(Map<String,Object?> j)=>ConsumptionPoint(label:j['label'] as String,energyKwh:j['energy_kwh'] as num,averagePowerW:j['average_power_w'] as num);}
final class DeviceConsumptionShare {const DeviceConsumptionShare({required this.deviceId,required this.name,required this.type,required this.kitName,required this.energyKwh,required this.sharePercent,required this.averagePowerW,required this.peakPowerW});final String deviceId,name;final String? type,kitName;final num energyKwh,sharePercent,averagePowerW,peakPowerW;factory DeviceConsumptionShare.fromJson(Map<String,Object?> j)=>DeviceConsumptionShare(deviceId:j['device_id'] as String,name:j['name'] as String,type:j['type'] as String?,kitName:j['kit_name'] as String?,energyKwh:j['energy_kwh'] as num,sharePercent:j['share_percent'] as num,averagePowerW:j['average_power_w'] as num,peakPowerW:j['peak_power_w'] as num);}
