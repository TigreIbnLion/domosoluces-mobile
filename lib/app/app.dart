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
 GoRoute(path:'/profile',builder:(_,__)=>const ProfilePage()),
 GoRoute(path:'/kits/:kitId',builder:(_,s)=>DevicesPage(kitId:s.pathParameters['kitId']!)),
 GoRoute(path:'/devices/:deviceId',builder:(_,s)=>DevicePage(deviceId:s.pathParameters['deviceId']!)),
]));
abstract final class Brand {
 static const forest=Color(0xFF0F5C3F), lime=Color(0xFF8CC63F), orange=Color(0xFFF26B1D), pale=Color(0xFFEEF1EC);
 static const ink=Color(0xFF153229), muted=Color(0xFF52685F), border=Color(0xFFDCE5DC), red=Color(0xFFD64545);
}
final class BrandMark extends StatelessWidget{
 const BrandMark({super.key,this.size=48,this.inverted=false}); final double size; final bool inverted;
 @override Widget build(BuildContext c)=>CustomPaint(size:Size.square(size),painter:_BrandPainter(inverted));
}
final class _BrandPainter extends CustomPainter{
 const _BrandPainter(this.inverted); final bool inverted;
 @override void paint(Canvas c,Size s){final k=s.width/42;
  final stroke=Paint()..color=inverted?Colors.white:Brand.forest..style=PaintingStyle.stroke..strokeWidth=5*k..strokeCap=StrokeCap.round;
  final d=Path()..moveTo(14*k,5*k)..lineTo(22*k,5*k)..cubicTo(31*k,5*k,37*k,11*k,37*k,21*k)..cubicTo(37*k,31*k,31*k,37*k,22*k,37*k)..lineTo(14*k,37*k);c.drawPath(d,stroke);
  final lime=Paint()..color=Brand.lime..strokeWidth=4*k..strokeCap=StrokeCap.round;
  for(final y in [8.0,17.0,26.0,35.0])c.drawLine(Offset(6*k,y*k),Offset(11*k,y*k),lime);
  final bolt=Path()..moveTo(23*k,10*k)..lineTo(15*k,23*k)..lineTo(22*k,23*k)..lineTo(19*k,33*k)..lineTo(29*k,18*k)..lineTo(22*k,18*k)..close();
  c.drawPath(bolt,Paint()..color=Brand.orange);
 }
 @override bool shouldRepaint(covariant _BrandPainter o)=>o.inverted!=inverted;
}
final class BrandLockup extends StatelessWidget{
 const BrandLockup({super.key,this.compact=false,this.inverted=false});final bool compact,inverted;
 @override Widget build(BuildContext c)=>Row(mainAxisSize:MainAxisSize.min,children:[BrandMark(size:compact?38:52,inverted:inverted),SizedBox(width:compact?9:12),Text('DOMOSOLUCES',style:TextStyle(color:inverted?Colors.white:Brand.forest,fontSize:compact?18:26,fontWeight:FontWeight.w900,fontStyle:FontStyle.italic,letterSpacing:-.7))]);
}
final class DomosolucesApp extends ConsumerWidget{const DomosolucesApp({super.key});@override Widget build(BuildContext c,WidgetRef r)=>MaterialApp.router(debugShowCheckedModeBanner:false,title:'DOMOSOLUCES',theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF4F7F3),colorScheme:ColorScheme.fromSeed(seedColor:Brand.forest,primary:Brand.forest,secondary:Brand.lime,tertiary:Brand.orange,surface:Colors.white),appBarTheme:const AppBarTheme(backgroundColor:Colors.transparent,foregroundColor:Brand.ink,elevation:0,centerTitle:false),cardTheme:CardThemeData(elevation:0,color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Brand.border))),filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size(0,50),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)))),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,labelStyle:const TextStyle(color:Brand.muted),border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:Brand.border)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:Brand.border)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:Brand.forest,width:1.5)))),routerConfig:r.watch(routerProvider));}
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
                    const BrandLockup(),
                    const SizedBox(height: 12),
                    const Text('La gestion automatique de la maison et l’énergie, notre affaire.',style:TextStyle(color:Brand.muted,height:1.45)),
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
final class _HomePageState extends ConsumerState<HomePage>{late Future<List<Kit>> future;@override void initState(){super.initState();future=ref.read(clientRepositoryProvider).kits();}Future<void> reload()async{setState(()=>future=ref.read(clientRepositoryProvider).kits());await future;}@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const BrandLockup(compact:true),actions:[IconButton(tooltip:'Mon compte',onPressed:()=>c.push('/profile'),icon:const Icon(Icons.account_circle_outlined))]),body:FutureBuilder<List<Kit>>(future:future,builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return ErrorView(error:s.error,onRetry:reload);final xs=s.data??[];return RefreshIndicator(onRefresh:reload,child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:xs.length+1,itemBuilder:(_,i){if(i==0)return Padding(padding:const EdgeInsets.only(bottom:20),child:Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF0F5C3F),borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.energy_savings_leaf_rounded,color:Color(0xFF8CC63F),size:32),SizedBox(height:14),Text('Pilotez votre maison en toute simplicité.',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)),SizedBox(height:6),Text('Vos installations et équipements en un coup d’œil.',style:TextStyle(color:Color(0xFFD4E2DC))) ])));if(xs.isEmpty)return const _EmptyInstallations();final k=xs[i-1];return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xFFDCE5DC))),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:8),leading:const CircleAvatar(backgroundColor:Color(0xFFEAF3EA),foregroundColor:Color(0xFF0F5C3F),child:Icon(Icons.home_work_outlined)),title:Text(k.displayName,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${k.status} • ${k.devicesCount} équipement(s)'),trailing:const Icon(Icons.chevron_right),onTap:()=>c.push('/kits/${k.id}')))); }));}));}
final class _EmptyInstallations extends StatelessWidget{
 const _EmptyInstallations();
 @override Widget build(BuildContext c)=>Container(margin:const EdgeInsets.only(top:4),padding:const EdgeInsets.all(26),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:Brand.border)),child:const Column(children:[Icon(Icons.home_work_outlined,size:38,color:Brand.forest),SizedBox(height:12),Text('Aucune installation',style:TextStyle(fontWeight:FontWeight.w800,fontSize:16)),SizedBox(height:6),Text('Votre installation apparaîtra ici dès son activation.',textAlign:TextAlign.center,style:TextStyle(color:Brand.muted))]));
}
final class ProfilePage extends ConsumerWidget{
 const ProfilePage({super.key});
 @override Widget build(BuildContext c,WidgetRef r){final u=r.watch(authControllerProvider).value;return Scaffold(appBar:AppBar(title:const Text('Mon compte')),body:ListView(padding:const EdgeInsets.all(18),children:[
  Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Column(children:[CircleAvatar(radius:34,backgroundColor:const Color(0xFFEAF3EA),foregroundColor:const Color(0xFF0F5C3F),child:Text((u?.name.isNotEmpty??false)?u!.name[0].toUpperCase():'D',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900))),const SizedBox(height:12),Text(u?.name??'Utilisateur',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(u?.email??'',style:const TextStyle(color:Color(0xFF52685F)))])),
  const SizedBox(height:14),Card(child:Column(children:[ListTile(leading:const Icon(Icons.phone_outlined),title:const Text('Téléphone'),subtitle:Text(u?.phone??'Non renseigné')),const Divider(height:1),ListTile(leading:const Icon(Icons.location_on_outlined),title:const Text('Zone'),subtitle:Text(u?.zone??'Non renseignée')),const Divider(height:1),ListTile(leading:const Icon(Icons.home_work_outlined),title:const Text('Sites'),subtitle:Text('${u?.sites.length??0} site(s)')),const Divider(height:1),ListTile(leading:const Icon(Icons.notifications_none),title:const Text('Alertes non lues'),trailing:Text('${u?.unreadAlerts??0}',style:const TextStyle(fontWeight:FontWeight.w800))) ])),
  const SizedBox(height:18),OutlinedButton.icon(onPressed:()async{await r.read(authControllerProvider.notifier).logout();if(c.mounted)c.go('/login');},icon:const Icon(Icons.logout),label:const Text('Se déconnecter'))
 ]));}
}
final class DevicesPage extends StatelessWidget{const DevicesPage({super.key,required this.kitId});final String kitId;@override Widget build(BuildContext c)=>Consumer(builder:(c,r,_)=>Scaffold(appBar:AppBar(title:const Text('Équipements')),body:FutureBuilder<List<Device>>(future:r.read(clientRepositoryProvider).devices(kitId),builder:(c,s){if(s.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());if(s.hasError)return ErrorView(error:s.error,onRetry:()=>c.pushReplacement('/kits/$kitId'));final xs=s.data??[];if(xs.isEmpty)return const Center(child:Text('Aucun équipement.'));return ListView.builder(padding:const EdgeInsets.all(16),itemCount:xs.length,itemBuilder:(_,i){final d=xs[i];final online=d.status=='online';return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(color:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xFFDCE5DC))),child:ListTile(contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:8),leading:CircleAvatar(backgroundColor:online?const Color(0xFFEAF3EA):const Color(0xFFF4F4F4),child:Icon(Icons.power_outlined,color:online?const Color(0xFF0F5C3F):Colors.grey)),title:Text(d.displayName,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${d.room??d.type} • ${online?'En ligne':'Hors ligne'} • ${d.state.toUpperCase()}'),trailing:const Icon(Icons.chevron_right),onTap:()=>c.push('/devices/${d.id}'))));});})));}
final class DevicePage extends ConsumerStatefulWidget{const DevicePage({super.key,required this.deviceId});final String deviceId;@override ConsumerState<DevicePage> createState()=>_DevicePageState();}
final class _DevicePageState extends ConsumerState<DevicePage>{@override void initState(){super.initState();Future.microtask(()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh());}@override Widget build(BuildContext c){final a=ref.watch(deviceCommandProvider(widget.deviceId));return Scaffold(appBar:AppBar(title:const Text('Détail équipement')),body:a.when(loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>ErrorView(error:e,onRetry:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh()),data:(x){final d=x.device;final pending=x.phase==DeviceCommandPhase.pending;if(d==null&&x.phase==DeviceCommandPhase.idle)return const Center(child:CircularProgressIndicator());return ListView(padding:const EdgeInsets.all(24),children:[Text(d?.displayName??'Équipement',style:Theme.of(c).textTheme.headlineSmall),const SizedBox(height:12),Text('Connectivité : ${d?.status??'—'}'),Text('État confirmé : ${d?.state??'—'}'),if(d?.room!=null)Text('Pièce : ${d!.room}'),if(d?.currentPower!=null)Text('Puissance : ${d!.currentPower} W'),if(d?.energyKwh!=null)Text('Énergie : ${d!.energyKwh} kWh'),const SizedBox(height:24),if(pending)const Row(children:[CircularProgressIndicator(),SizedBox(width:16),Expanded(child:Text('Commande envoyée — attente de confirmation physique…'))]),if(x.phase==DeviceCommandPhase.confirmed)const Text('État physique confirmé par le serveur.'),if(x.phase==DeviceCommandPhase.error)Text(x.message??'Confirmation impossible.'),const SizedBox(height:16),Row(children:[Expanded(child:FilledButton(onPressed:pending?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:true),child:const Text('ON'))),const SizedBox(width:12),Expanded(child:OutlinedButton(onPressed:pending?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:false),child:const Text('OFF')))])]);}));}}
final class ErrorView extends StatelessWidget{const ErrorView({super.key,required this.error,required this.onRetry});final Object? error;final VoidCallback onRetry;@override Widget build(BuildContext c)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error is AppException?(error! as AppException).message:'Chargement impossible.'),const SizedBox(height:12),FilledButton(onPressed:()=>onRetry(),child:const Text('Réessayer'))])));}
