final class User {
  const User(this.raw);
  final Map<String, Object?> raw;
  factory User.fromJson(Map<String, Object?> json) => User(Map.unmodifiable(json));
}
final class Kit {
  const Kit(this.raw);
  final Map<String, Object?> raw;
  factory Kit.fromJson(Map<String, Object?> json) => Kit(Map.unmodifiable(json));
}
final class Device {
  const Device(this.raw);
  final Map<String, Object?> raw;
  factory Device.fromJson(Map<String, Object?> json) => Device(Map.unmodifiable(json));
  String? get state => raw['state']?.toString();
  String? get status => raw['status']?.toString();
}
enum DeviceCommandPhase { idle, pending, confirmed, error }
final class DeviceCommandState {
  const DeviceCommandState(this.phase, {this.device, this.message});
  final DeviceCommandPhase phase;
  final Device? device;
  final String? message;
}
