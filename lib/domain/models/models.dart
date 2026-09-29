final class User {
  const User({required this.id, required this.name, required this.email, required this.role});
  final String id, name, email, role;
  factory User.fromJson(Map<String,Object?> j)=>User(id:j['id'] as String,name:j['name'] as String,email:j['email'] as String,role:j['role'] as String);
}
final class Kit {
  const Kit({required this.id,required this.serialNumber,required this.name,required this.status,required this.devicesCount});
  final String id,serialNumber,status; final String? name; final int devicesCount;
  factory Kit.fromJson(Map<String,Object?> j)=>Kit(id:j['id'] as String,serialNumber:j['serial_number'] as String,name:j['name'] as String?,status:j['status'] as String,devicesCount:j['devices_count'] as int);
  String get displayName => name?.trim().isNotEmpty==true ? name! : serialNumber;
}
final class Device {
  const Device({required this.id,required this.kitId,required this.deviceUid,required this.name,required this.type,required this.status,required this.state,required this.isActive,required this.room,required this.currentPower,required this.energyKwh});
  final String id,kitId,deviceUid,type,status,state; final String? name,room; final bool isActive; final num? currentPower,energyKwh;
  factory Device.fromJson(Map<String,Object?> j)=>Device(id:j['id'] as String,kitId:j['kit_id'] as String,deviceUid:j['device_uid'] as String,name:j['name'] as String?,room:j['room'] as String?,type:j['type'] as String,status:j['status'] as String,state:j['state'] as String,isActive:j['is_active'] as bool,currentPower:j['current_power'] as num?,energyKwh:j['energy_kwh'] as num?);
  String get displayName => name?.trim().isNotEmpty==true ? name! : deviceUid;
}
enum DeviceCommandPhase { idle, pending, confirmed, error }
final class DeviceCommandState {
 const DeviceCommandState(this.phase,{this.device,this.message});
 final DeviceCommandPhase phase; final Device? device; final String? message;
}