import 'dart:async';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/models/models.dart';
final class ClientRepository {
 const ClientRepository(this._api); final ApiClient _api;
 Future<List<Kit>> kits() async { final m=_map(await _api.get('/client/kits')); return _list(m,'kits').map(Kit.fromJson).toList(); }
 Future<Kit> kit(String id) async { final m=_map(await _api.get('/client/kits/$id')); return Kit.fromJson(_object(m,'kit')); }
 Future<List<Device>> devices(String kitId) async { final m=_map(await _api.get('/client/kits/$kitId/devices')); return _list(m,'devices').map(Device.fromJson).toList(); }
 Future<Device> updateDeviceConfig(String id,{String? name,String? displayName,String? room,String? icon,int? position}) async {
  final payload=<String,Object?>{};
  if(name!=null)payload['name']=name;
  if(displayName!=null)payload['display_name']=displayName;
  if(room!=null)payload['room']=room;
  if(icon!=null)payload['icon']=icon;
  if(position!=null)payload['position']=position;
  final m=_map(await _api.put('/client/devices/$id/config',data:payload));
  return Device.fromJson(_object(m,'device'));
 }
 Future<ConsumptionSummary> consumption({String period='month'}) async { final m=_map(await _api.get('/client/consumption',)); return ConsumptionSummary.fromJson(m); }
 Future<DeviceCapabilities> capabilities(String id) async { final m=_map(await _api.get('/client/devices/$id/capabilities')); return DeviceCapabilities.fromJson(m); }
 Future<CapabilityCommandReceipt> sendCapabilityCommand(String id,{required String capabilityId,required String command,required Object? value}) async { final m=_map(await _api.post('/client/devices/$id/capability-commands',data:{'capability_id':capabilityId,'command':command,'value':value})); return CapabilityCommandReceipt.fromJson(m); }
 Future<DeviceCapabilities> capabilityCommandAndConfirm(String id,{required String capabilityId,required String command,required Object? value,Duration timeout=const Duration(seconds:15),Duration interval=const Duration(seconds:1)}) async {
  final before=await capabilities(id); final previous=before.values[capabilityId]?.value;
  await sendCapabilityCommand(id,capabilityId:capabilityId,command:command,value:value);
  final deadline=DateTime.now().add(timeout);
  while(DateTime.now().isBefore(deadline)){await Future<void>.delayed(interval);try{final current=await capabilities(id);final confirmed=current.values[capabilityId]?.value;if(confirmed!=previous&&_sameCapabilityValue(confirmed,value))return current;}on NetworkException{}on ServerException{}}
  throw UnexpectedResponseException('Commande envoyée, mais valeur non confirmée avant expiration.');
 }
 Future<PairingClaimResult> claimPairing({required String pairingId,required String kitSerial,required String deviceUid,required String pairingToken}) async { final m=_map(await _api.post('/client/pairing/claim',data:{'pairing_id':pairingId,'kit_serial':kitSerial,'device_uid':deviceUid,'pairing_token':pairingToken})); return PairingClaimResult.fromJson(m); }
 bool _sameCapabilityValue(Object? a,Object? b)=>a.toString()==b.toString();
 Future<Device> status(String id) async { final m=_map(await _api.get('/client/devices/$id/status')); return Device.fromJson(_object(m,'device')); }
 Future<void> sendCommand(String id,{required bool turnOn})=>_api.post('/client/devices/$id/${turnOn?'on':'off'}');
 Future<DeviceCommandState> commandAndConfirm(String id,{required bool turnOn,Duration timeout=const Duration(seconds:15),Duration interval=const Duration(seconds:1)}) async {
  await sendCommand(id,turnOn:turnOn); final deadline=DateTime.now().add(timeout); final expected=turnOn?'on':'off';
  Device? lastObserved;
  while(DateTime.now().isBefore(deadline)){ await Future<void>.delayed(interval); try { final d=await status(id); lastObserved=d; if(d.state==expected)return DeviceCommandState(DeviceCommandPhase.confirmed,device:d); } on NetworkException { /* Retry transient connectivity until deadline. */ } on ServerException { /* Retry transient server failure until deadline. */ } }
  return DeviceCommandState(DeviceCommandPhase.error,device:lastObserved,message:'Commande acceptée, mais état physique non confirmé avant expiration.');
 }
 Map<String,Object?> _map(Object? x){if(x is! Map)throw UnexpectedResponseException('Réponse API invalide.',details:x);return Map<String,Object?>.from(x);}
 Map<String,Object?> _object(Map<String,Object?> m,String k){final x=m[k];if(x is! Map)throw UnexpectedResponseException('Objet $k invalide.',details:m);return Map<String,Object?>.from(x);}
 List<Map<String,Object?>> _list(Map<String,Object?> m,String k){final x=m[k];if(x is! List)throw UnexpectedResponseException('Liste $k invalide.',details:m);return x.map((e){if(e is! Map)throw UnexpectedResponseException('Élément $k invalide.',details:e);return Map<String,Object?>.from(e);}).toList();}
}