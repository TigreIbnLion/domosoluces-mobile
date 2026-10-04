import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors/app_exception.dart';
import '../domain/models/models.dart';
import 'app_dependencies.dart';

final routerProvider=Provider<GoRouter>((ref)=>GoRouter(initialLocation:'/splash',routes:[
 GoRoute(path:'/splash',builder:(_,__)=>const SessionGate()),
 GoRoute(path:'/login',builder:(_,__)=>const LoginPage()),
 GoRoute(path:'/home',builder:(_,__)=>const HomePage()),
 GoRoute(path:'/kits/:kitId',builder:(_,s)=>DevicesPage(kitId:s.pathParameters['kitId']!)),
 GoRoute(path:'/devices/:deviceId',builder:(_,s)=>DevicePage(deviceId:s.pathParameters['deviceId']!)),
]));
final class DomosolucesApp extends ConsumerWidget{const DomosolucesApp({super.key});@override Widget build(BuildContext c,WidgetRef r)=>MaterialApp.router(debugShowCheckedModeBanner:false,title:'DOMOSOLUCES',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF4F7F3),colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF0F5C3F),primary:const Color(0xFF0F5C3F),secondary:const Color(0xFF8CC63F),tertiary:const Color(0xFFF26B1D)),cardTheme:const CardThemeData(elevation:0),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)))),routerConfig:r.watch(routerProvider));}
final class SessionGate extends ConsumerWidget{const SessionGate({super.key});@override Widget build(BuildContext c,WidgetRef r){final a=r.watch(authControllerProvider);r.listen(authControllerProvider,(_,n)=>n.whenData((u){if(c.mounted)c.go(u==null?'/login':'/home');}));return Scaffold(body:Center(child:a.hasError?Text(a.error is AppException?(a.error! as AppException).message:'Connexion impossible'):const CircularProgressIndicator()));}}
final class LoginPage extends ConsumerStatefulWidget{const LoginPage({super.key});@override ConsumerState<LoginPage> createState()=>_LoginPageState();}
final class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(email.text, password.text);
    if (mounted && ref.read(authControllerProvider).value != null) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width:56,height:56,decoration:BoxDecoration(color:const Color(0xFF0F5C3F),borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.power_settings_new_rounded,color:Colors.white,size:32)),
                    const SizedBox(height: 16),
                    Text('DOMOSOLUCES', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w900,color:const Color(0xFF0F5C3F))),
                    const SizedBox(height: 6),
                    const Text('Votre maison, connectée et maîtrisée.',style:TextStyle(color:Color(0xFF52685F))),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      validator: (v) => v?.isNotEmpty == true ? null : 'Mot de passe requis',
                    ),
                    if (auth.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(auth.error is AppException
                            ? (auth.error! as AppException).message
                            : 'Erreur de connexion'),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: auth.isLoading ? null : submit,
                      child: Text(auth.isLoading ? 'Connexion…' : 'Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
final class HomePage extends ConsumerStatefulWidget{const HomePage({super.key});@override ConsumerState<HomePage> createState()=>_HomePageState();}
final class _HomePageState extends ConsumerState<HomePage>{late Future<List<Kit>> future;@override void initState(){super.initState();future=ref.read(clientRepositoryProvider).kits();}Future<void> reload()async{setState(()=>future=ref.read(clientRepositoryProvider).kits());await future;}@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('DOMOSOLUCES',style:TextStyle(fontWeight:FontWeight.w900,color:Color(0xFF0F5C3F))),actions:[IconButton(onPressed:()async{await ref.read(authControllerProvider.notifier).logout();if(c.mounted)c.go('/login');},icon:const Icon(Icons.logout))]),body:FutureBuilder<List<Kit>>(future:future,builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return ErrorView(error:s.error,onRetry:reload);final xs=s.data??[];if(xs.isEmpty)return const Center(child:Text('Aucun kit disponible.'));return RefreshIndicator(onRefresh:reload,child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:xs.length+1,itemBuilder:(_,i){if(i==0)return Padding(padding:const EdgeInsets.only(bottom:20),child:Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF0F5C3F),borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.energy_savings_leaf_rounded,color:Color(0xFF8CC63F),size:32),SizedBox(height:14),Text('Pilotez votre maison en toute simplicité.',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)),SizedBox(height:6),Text('Vos installations et équipements en un coup d’œil.',style:TextStyle(color:Color(0xFFD4E2DC))) ])));final k=xs[i-1];return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xFFDCE5DC))),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:8),leading:const CircleAvatar(backgroundColor:Color(0xFFEAF3EA),foregroundColor:Color(0xFF0F5C3F),child:Icon(Icons.home_work_outlined)),title:Text(k.displayName,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${k.status} • ${k.devicesCount} équipement(s)'),trailing:const Icon(Icons.chevron_right),onTap:()=>c.push('/kits/${k.id}')))); }));}));}
final class DevicesPage extends StatelessWidget{const DevicesPage({super.key,required this.kitId});final String kitId;@override Widget build(BuildContext c)=>Consumer(builder:(c,r,_)=>Scaffold(appBar:AppBar(title:const Text('Équipements')),body:FutureBuilder<List<Device>>(future:r.read(clientRepositoryProvider).devices(kitId),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return ErrorView(error:s.error,onRetry:()=>c.pushReplacement('/kits/$kitId'));final xs=s.data??[];if(xs.isEmpty)return const Center(child:Text('Aucun équipement.'));return ListView.builder(padding:const EdgeInsets.all(16),itemCount:xs.length,itemBuilder:(_,i){final d=xs[i];return Card(child:ListTile(title:Text(d.displayName),subtitle:Text('${d.type} • ${d.status} • ${d.state}'),trailing:const Icon(Icons.chevron_right),onTap:()=>c.push('/devices/${d.id}')));});})));}
final class DevicePage extends ConsumerStatefulWidget{const DevicePage({super.key,required this.deviceId});final String deviceId;@override ConsumerState<DevicePage> createState()=>_DevicePageState();}
final class _DevicePageState extends ConsumerState<DevicePage>{@override void initState(){super.initState();Future.microtask(()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh());}@override Widget build(BuildContext c){final a=ref.watch(deviceCommandProvider(widget.deviceId));return Scaffold(appBar:AppBar(title:const Text('Détail équipement')),body:a.when(loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>ErrorView(error:e,onRetry:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh()),data:(x){final d=x.device;final pending=x.phase==DeviceCommandPhase.pending;if(d==null&&x.phase==DeviceCommandPhase.idle)return const Center(child:CircularProgressIndicator());return ListView(padding:const EdgeInsets.all(24),children:[Text(d?.displayName??'Équipement',style:Theme.of(c).textTheme.headlineSmall),const SizedBox(height:12),Text('Connectivité : ${d?.status??'—'}'),Text('État confirmé : ${d?.state??'—'}'),if(d?.room!=null)Text('Pièce : ${d!.room}'),if(d?.currentPower!=null)Text('Puissance : ${d!.currentPower} W'),if(d?.energyKwh!=null)Text('Énergie : ${d!.energyKwh} kWh'),const SizedBox(height:24),if(pending)const Row(children:[CircularProgressIndicator(),SizedBox(width:16),Expanded(child:Text('Commande envoyée — attente de confirmation physique…'))]),if(x.phase==DeviceCommandPhase.confirmed)const Text('État physique confirmé par le serveur.'),if(x.phase==DeviceCommandPhase.error)Text(x.message??'Confirmation impossible.'),const SizedBox(height:16),Row(children:[Expanded(child:FilledButton(onPressed:pending?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:true),child:const Text('ON'))),const SizedBox(width:12),Expanded(child:OutlinedButton(onPressed:pending?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:false),child:const Text('OFF')))])]);}));}}
final class ErrorView extends StatelessWidget{const ErrorView({super.key,required this.error,required this.onRetry});final Object? error;final VoidCallback onRetry;@override Widget build(BuildContext c)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error is AppException?(error! as AppException).message:'Chargement impossible.'),const SizedBox(height:12),FilledButton(onPressed:()=>onRetry(),child:const Text('Réessayer'))])));}
