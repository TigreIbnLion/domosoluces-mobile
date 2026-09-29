import 'dart:async';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/models/models.dart';
final class ClientRepository {
 const ClientRepository(this._api); final ApiClient _api;
 Future<List<Kit>> kits() async { final m=_map(await _api.get('/client/kits')); return _list(m,'kits').map(Kit.fromJson).toList(); }
 Future<Kit> kit(String id) async { final m=_map(await _api.get('/client/kits/$id')); return Kit.fromJson(_object(m,'kit')); }
 Future<List<Device>> devices(String kitId) async { final m=_map(await _api.get('/client/kits/$kitId/devices')); return _list(m,'devices').map(Device.fromJson).toList(); }
 Future<Device> status(String id) async { final m=_map(await _api.get('/client/devices/$id/status')); return Device.fromJson(_object(m,'device')); }
 Future<void> sendCommand(String id,{required bool turnOn})=>_api.post('/client/devices/$id/${turnOn?'on':'off'}');
 Future<DeviceCommandState> commandAndConfirm(String id,{required bool turnOn,Duration timeout=const Duration(seconds:15),Duration interval=const Duration(seconds:1)}) async {
  await sendCommand(id,turnOn:turnOn); final deadline=DateTime.now().add(timeout); final expected=turnOn?'on':'off';
  while(DateTime.now().isBefore(deadline)){ await Future<void>.delayed(interval); try { final d=await status(id); if(d.state==expected)return DeviceCommandState(DeviceCommandPhase.confirmed,device:d); } on NetworkException {} on ServerException {} }
  return const DeviceCommandState(DeviceCommandPhase.error,message:'Commande acceptée, mais état physique non confirmé avant expiration.');
 }
 Map<String,Object?> _map(Object? x){if(x is! Map)throw UnexpectedResponseException('Réponse API invalide.',details:x);return Map<String,Object?>.from(x);}
 Map<String,Object?> _object(Map<String,Object?> m,String k){final x=m[k];if(x is! Map)throw UnexpectedResponseException('Objet $k invalide.',details:m);return Map<String,Object?>.from(x);}
 List<Map<String,Object?>> _list(Map<String,Object?> m,String k){final x=m[k];if(x is! List)throw UnexpectedResponseException('Liste $k invalide.',details:m);return x.map((e){if(e is! Map)throw UnexpectedResponseException('Élément $k invalide.',details:e);return Map<String,Object?>.from(e);}).toList();}
}