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
final class _HomePageState extends ConsumerState<HomePage>{
 late Future<List<Kit>> future;
 @override void initState(){super.initState();future=ref.read(clientRepositoryProvider).kits();}
 Future<void> reload()async{setState(()=>future=ref.read(clientRepositoryProvider).kits());await future;}
 @override Widget build(BuildContext c){final u=ref.watch(authControllerProvider).value;return Scaffold(appBar:AppBar(title:const BrandLockup(compact:true),actions:[Stack(children:[IconButton(tooltip:'Mon compte',onPressed:()=>c.push('/profile'),icon:const Icon(Icons.account_circle_outlined)),if((u?.unreadAlerts??0)>0)Positioned(right:6,top:6,child:Container(padding:const EdgeInsets.all(4),decoration:const BoxDecoration(color:Brand.orange,shape:BoxShape.circle),child:Text('${u!.unreadAlerts}',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w800))))])]),body:FutureBuilder<List<Kit>>(future:future,builder:(c,s){if(s.connectionState!=ConnectionState.done)return const _HomeLoading();if(s.hasError)return ErrorView(error:s.error,onRetry:reload);final xs=s.data??[];final devices=xs.fold<int>(0,(n,k)=>n+k.devicesCount),active=xs.where((k)=>k.status.toLowerCase()=='active'||k.status.toLowerCase()=='online').length;return RefreshIndicator(onRefresh:reload,child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(16,4,16,30),children:[
  Text('Bonjour${u?.name.isNotEmpty==true?', ${u!.name.split(' ').first}':''}',style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900,fontStyle:FontStyle.italic,color:Brand.ink)),const SizedBox(height:4),const Text('Voici l’état de votre maison connectée.',style:TextStyle(color:Brand.muted)),const SizedBox(height:18),
  Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Brand.forest,Color(0xFF174B39)],begin:Alignment.topLeft,end:Alignment.bottomRight),borderRadius:BorderRadius.circular(22)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const BrandMark(size:42,inverted:true),const SizedBox(height:16),const Text('Pilotez votre maison\nen toute simplicité.',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900,fontStyle:FontStyle.italic,height:1.15)),const SizedBox(height:7),const Text('Installations, équipements et énergie en un coup d’œil.',style:TextStyle(color:Color(0xFFD4E2DC),height:1.4)),const SizedBox(height:18),Row(children:[_HeroValue(value:'${xs.length}',label:'Installation${xs.length>1?'s':''}'),const SizedBox(width:28),_HeroValue(value:'$devices',label:'Équipement${devices>1?'s':''}')]) ])),const SizedBox(height:18),
  Row(children:[Expanded(child:_DashboardStat(value:'$active',label:'Actives',icon:Icons.wifi_rounded,color:Brand.forest)),const SizedBox(width:9),Expanded(child:_DashboardStat(value:'${xs.length-active}',label:'À vérifier',icon:Icons.warning_amber_rounded,color:Brand.orange)),const SizedBox(width:9),Expanded(child:_DashboardStat(value:'${u?.unreadAlerts??0}',label:'Alertes',icon:Icons.notifications_none_rounded,color:Brand.red))]),const SizedBox(height:24),
  Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Mes installations',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900,color:Brand.ink)),IconButton(onPressed:reload,tooltip:'Actualiser',icon:const Icon(Icons.refresh_rounded,color:Brand.forest))]),const SizedBox(height:8),
  if(xs.isEmpty)const _EmptyInstallations() else ...xs.map((k)=>_InstallationCard(kit:k,onTap:()=>c.push('/kits/${k.id}'))),
  const SizedBox(height:16),Text('Accès rapide',style:Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800,color:Brand.ink)),const SizedBox(height:10),Row(children:[Expanded(child:_QuickAction(icon:Icons.person_outline_rounded,label:'Mon compte',onTap:()=>c.push('/profile'))),const SizedBox(width:10),Expanded(child:_QuickAction(icon:Icons.refresh_rounded,label:'Actualiser',onTap:reload))])
 ]));}));}
}
final class _HeroValue extends StatelessWidget{const _HeroValue({required this.value,required this.label});final String value,label;@override Widget build(BuildContext c)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)),Text(label,style:const TextStyle(color:Color(0xFFC7D9D1),fontSize:12))]);}
final class _DashboardStat extends StatelessWidget{const _DashboardStat({required this.value,required this.label,required this.icon,required this.color});final String value,label;final IconData icon;final Color color;@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(vertical:14,horizontal:8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:Brand.border)),child:Column(children:[Icon(icon,color:color,size:21),const SizedBox(height:6),Text(value,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:19,color:Brand.ink)),Text(label,maxLines:1,style:const TextStyle(fontSize:10,color:Brand.muted))]));}
final class _InstallationCard extends StatelessWidget{const _InstallationCard({required this.kit,required this.onTap});final Kit kit;final VoidCallback onTap;@override Widget build(BuildContext c){final active=kit.status.toLowerCase()=='active'||kit.status.toLowerCase()=='online';return Padding(padding:const EdgeInsets.only(bottom:10),child:Card(child:InkWell(borderRadius:BorderRadius.circular(18),onTap:onTap,child:Padding(padding:const EdgeInsets.all(15),child:Row(children:[CircleAvatar(radius:25,backgroundColor:active?const Color(0xFFE8F3E4):Brand.pale,child:Icon(Icons.home_work_outlined,color:active?Brand.forest:Brand.muted)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(kit.displayName,style:const TextStyle(fontWeight:FontWeight.w800,color:Brand.ink)),const SizedBox(height:3),Text(kit.siteLabel??kit.serialNumber,style:const TextStyle(color:Brand.muted,fontSize:12)),const SizedBox(height:7),Row(children:[_MiniBadge(text:kit.status,color:active?Brand.forest:Brand.orange),const SizedBox(width:6),Text('${kit.devicesCount} équipement(s)',style:const TextStyle(color:Brand.muted,fontSize:11))])])),const Icon(Icons.chevron_right_rounded,color:Brand.muted)])))));}
final class _QuickAction extends StatelessWidget{const _QuickAction({required this.icon,required this.label,required this.onTap});final IconData icon;final String label;final VoidCallback onTap;@override Widget build(BuildContext c)=>InkWell(borderRadius:BorderRadius.circular(16),onTap:onTap,child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),border:Border.all(color:Brand.border)),child:Row(children:[Icon(icon,color:Brand.forest),const SizedBox(width:9),Expanded(child:Text(label,style:const TextStyle(fontWeight:FontWeight.w700,color:Brand.ink))) ])));}
final class _HomeLoading extends StatelessWidget{const _HomeLoading();@override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:[Container(height:210,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22))),const SizedBox(height:18),Row(children:List.generate(3,(i)=>Expanded(child:Container(height:86,margin:EdgeInsets.only(right:i<2?8:0),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16))))))]);}
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
final class DevicesPage extends ConsumerStatefulWidget{const DevicesPage({super.key,required this.kitId});final String kitId;@override ConsumerState<DevicesPage> createState()=>_DevicesPageState();}
final class _DevicesPageState extends ConsumerState<DevicesPage>{
 late Future<List<Device>> future;String query='';String filter='all';
 @override void initState(){super.initState();future=ref.read(clientRepositoryProvider).devices(widget.kitId);}
 Future<void> reload()async{setState(()=>future=ref.read(clientRepositoryProvider).devices(widget.kitId));await future;}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Équipements',style:TextStyle(fontWeight:FontWeight.w800))),body:FutureBuilder<List<Device>>(future:future,builder:(c,s){if(s.connectionState!=ConnectionState.done)return const _LoadingDevices();if(s.hasError)return ErrorView(error:s.error,onRetry:reload);final all=s.data??[];final q=query.trim().toLowerCase();final xs=all.where((d){final matches=q.isEmpty||d.displayName.toLowerCase().contains(q)||(d.room??'').toLowerCase().contains(q)||d.type.toLowerCase().contains(q);final status=filter=='all'||(filter=='online'&&d.status=='online')||(filter=='offline'&&d.status!='online')||(filter=='on'&&d.state=='on');return matches&&status;}).toList();final online=all.where((d)=>d.status=='online').length,on=all.where((d)=>d.state=='on').length;
 return RefreshIndicator(onRefresh:reload,child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.fromLTRB(16,4,16,28),children:[
  Row(children:[Expanded(child:_DeviceStat(value:'${all.length}',label:'Total',icon:Icons.devices_other_outlined)),const SizedBox(width:8),Expanded(child:_DeviceStat(value:'$online',label:'En ligne',icon:Icons.wifi_rounded)),const SizedBox(width:8),Expanded(child:_DeviceStat(value:'$on',label:'Allumés',icon:Icons.bolt_rounded))]),const SizedBox(height:16),
  TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(hintText:'Rechercher un équipement ou une pièce',prefixIcon:Icon(Icons.search_rounded))),const SizedBox(height:12),
  SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[_FilterChip(label:'Tous',selected:filter=='all',onTap:()=>setState(()=>filter='all')),_FilterChip(label:'En ligne',selected:filter=='online',onTap:()=>setState(()=>filter='online')),_FilterChip(label:'Hors ligne',selected:filter=='offline',onTap:()=>setState(()=>filter='offline')),_FilterChip(label:'Allumés',selected:filter=='on',onTap:()=>setState(()=>filter='on'))])),const SizedBox(height:14),
  if(all.isEmpty)const _EmptyDevices() else if(xs.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:42),child:Center(child:Text('Aucun équipement ne correspond aux filtres.',style:TextStyle(color:Brand.muted)))) else ...xs.map((d)=>_DeviceListCard(device:d,onTap:()=>c.push('/devices/${d.id}')))
 ]));}));}
}
final class _DeviceStat extends StatelessWidget{const _DeviceStat({required this.value,required this.label,required this.icon});final String value,label;final IconData icon;@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:13),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15),border:Border.all(color:Brand.border)),child:Column(children:[Icon(icon,size:20,color:Brand.forest),const SizedBox(height:5),Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:Brand.ink)),Text(label,maxLines:1,style:const TextStyle(fontSize:10,color:Brand.muted))]));}
final class _FilterChip extends StatelessWidget{const _FilterChip({required this.label,required this.selected,required this.onTap});final String label;final bool selected;final VoidCallback onTap;@override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(label),selected:selected,onSelected:(_)=>onTap(),selectedColor:Brand.forest,labelStyle:TextStyle(color:selected?Colors.white:Brand.ink,fontWeight:FontWeight.w600),side:const BorderSide(color:Brand.border)));}
final class _DeviceListCard extends StatelessWidget{const _DeviceListCard({required this.device,required this.onTap});final Device device;final VoidCallback onTap;@override Widget build(BuildContext c){final online=device.status=='online',on=device.state=='on';return Padding(padding:const EdgeInsets.only(bottom:10),child:Card(child:InkWell(borderRadius:BorderRadius.circular(18),onTap:onTap,child:Padding(padding:const EdgeInsets.all(15),child:Row(children:[CircleAvatar(radius:25,backgroundColor:on?const Color(0xFFE8F3E4):Brand.pale,child:Icon(_deviceIcon(device.type),color:on?Brand.forest:Brand.muted)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(device.displayName,style:const TextStyle(fontWeight:FontWeight.w800,color:Brand.ink)),const SizedBox(height:4),Text(device.room??_typeLabel(device.type),style:const TextStyle(color:Brand.muted,fontSize:12)),const SizedBox(height:7),Wrap(spacing:6,children:[_MiniBadge(text:online?'En ligne':'Hors ligne',color:online?Brand.forest:Brand.red),_MiniBadge(text:on?'ON':'OFF',color:on?Brand.lime:Brand.muted)])])),const Icon(Icons.chevron_right_rounded,color:Brand.muted)])))));}
 static IconData _deviceIcon(String t)=>switch(t){'prise'=>Icons.power_outlined,'interrupteur'=>Icons.toggle_on_outlined,'dismatique'=>Icons.electrical_services_outlined,'relais'=>Icons.settings_input_component_outlined,_=>Icons.devices_other_outlined};
 static String _typeLabel(String t)=>switch(t){'prise'=>'Prise','interrupteur'=>'Interrupteur','dismatique'=>'Disjoncteur','relais'=>'Relais',_=>t};
}
final class _MiniBadge extends StatelessWidget{const _MiniBadge({required this.text,required this.color});final String text;final Color color;@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:color.withValues(alpha:.10),borderRadius:BorderRadius.circular(12)),child:Text(text,style:TextStyle(color:color,fontSize:10,fontWeight:FontWeight.w700)));}
final class _EmptyDevices extends StatelessWidget{const _EmptyDevices();@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:Brand.border)),child:const Column(children:[Icon(Icons.devices_other_outlined,size:40,color:Brand.forest),SizedBox(height:12),Text('Aucun équipement',style:TextStyle(fontWeight:FontWeight.w800,fontSize:16)),SizedBox(height:6),Text('Les équipements associés à cette installation apparaîtront ici.',textAlign:TextAlign.center,style:TextStyle(color:Brand.muted))]));}
final class _LoadingDevices extends StatelessWidget{const _LoadingDevices();@override Widget build(BuildContext c)=>ListView(padding:const EdgeInsets.all(16),children:List.generate(5,(i)=>Container(height:i==0?82:78,margin:const EdgeInsets.only(bottom:12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:Brand.border)),child:const Center(child:CircularProgressIndicator(strokeWidth:2)))));}
final class DevicePage extends ConsumerStatefulWidget{const DevicePage({super.key,required this.deviceId});final String deviceId;@override ConsumerState<DevicePage> createState()=>_DevicePageState();}
final class _DevicePageState extends ConsumerState<DevicePage>{@override void initState(){super.initState();Future.microtask(()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh());}@override Widget build(BuildContext c){final a=ref.watch(deviceCommandProvider(widget.deviceId));return Scaffold(appBar:AppBar(title:const Text('Détail équipement')),body:a.when(loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>ErrorView(error:e,onRetry:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh()),data:(x){final d=x.device;final pending=x.phase==DeviceCommandPhase.pending;if(d==null&&x.phase==DeviceCommandPhase.idle)return const Center(child:CircularProgressIndicator());final online=d?.status=='online',on=d?.state=='on';return RefreshIndicator(onRefresh:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).refresh(),child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.all(18),children:[Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),border:Border.all(color:Brand.border)),child:Column(children:[CircleAvatar(radius:34,backgroundColor:on?const Color(0xFFE8F3E4):Brand.pale,child:Icon(Icons.power_settings_new_rounded,size:34,color:on?Brand.forest:Brand.muted)),const SizedBox(height:14),Text(d?.displayName??'Équipement',style:Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900,fontStyle:FontStyle.italic,color:Brand.ink)),const SizedBox(height:10),Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:[_StatusChip(label:online?'En ligne':'Hors ligne',color:online?Brand.forest:Brand.red),_StatusChip(label:'État ${d?.state.toUpperCase()??'—'}',color:on?Brand.lime:Brand.muted),_StatusChip(label:d?.mode??'—',color:Brand.orange)])])),const SizedBox(height:14),if(d?.room!=null)_Metric(icon:Icons.meeting_room_outlined,label:'Pièce',value:d!.room!),if(d?.currentPower!=null)_Metric(icon:Icons.bolt_rounded,label:'Puissance instantanée',value:'${d!.currentPower} W'),if(d?.energyKwh!=null)_Metric(icon:Icons.energy_savings_leaf_outlined,label:'Énergie',value:'${d!.energyKwh} kWh'),if(d?.firmwareVersion!=null)_Metric(icon:Icons.memory_outlined,label:'Firmware',value:d!.firmwareVersion!),const SizedBox(height:10),if(pending)const _CommandNotice(icon:Icons.sync_rounded,text:'Commande envoyée — attente de confirmation physique…',color:Brand.orange),if(x.phase==DeviceCommandPhase.confirmed)const _CommandNotice(icon:Icons.check_circle_outline,text:'État physique confirmé par le serveur.',color:Brand.forest),if(x.phase==DeviceCommandPhase.error)_CommandNotice(icon:Icons.error_outline,text:x.message??'Confirmation impossible.',color:Brand.red),const SizedBox(height:18),Row(children:[Expanded(child:FilledButton.icon(onPressed:pending||online!=true?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:true),icon:const Icon(Icons.power_settings_new),label:const Text('Allumer'))),const SizedBox(width:12),Expanded(child:OutlinedButton.icon(onPressed:pending||online!=true?null:()=>ref.read(deviceCommandProvider(widget.deviceId).notifier).execute(turnOn:false),icon:const Icon(Icons.power_off_outlined),label:const Text('Éteindre')))]),if(online!=true)const Padding(padding:EdgeInsets.only(top:10),child:Text('Commandes indisponibles tant que l’équipement est hors ligne.',textAlign:TextAlign.center,style:TextStyle(color:Brand.muted,fontSize:12))) ]));}));}}
final class _StatusChip extends StatelessWidget{const _StatusChip({required this.label,required this.color});final String label;final Color color;@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:color.withValues(alpha:.10),borderRadius:BorderRadius.circular(20)),child:Row(mainAxisSize:MainAxisSize.min,children:[Container(width:6,height:6,decoration:BoxDecoration(color:color,shape:BoxShape.circle)),const SizedBox(width:6),Text(label,style:TextStyle(color:color,fontSize:12,fontWeight:FontWeight.w700))]));}
final class _Metric extends StatelessWidget{const _Metric({required this.icon,required this.label,required this.value});final IconData icon;final String label,value;@override Widget build(BuildContext c)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:Brand.border)),child:Row(children:[Icon(icon,color:Brand.forest),const SizedBox(width:12),Expanded(child:Text(label,style:const TextStyle(color:Brand.muted))),Text(value,style:const TextStyle(fontWeight:FontWeight.w800,color:Brand.ink))]));}
final class _CommandNotice extends StatelessWidget{const _CommandNotice({required this.icon,required this.text,required this.color});final IconData icon;final String text;final Color color;@override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:color.withValues(alpha:.08),borderRadius:BorderRadius.circular(14),border:Border.all(color:color.withValues(alpha:.18))),child:Row(children:[Icon(icon,color:color),const SizedBox(width:10),Expanded(child:Text(text,style:TextStyle(color:color,fontWeight:FontWeight.w600))) ]));}
final class ErrorView extends StatelessWidget{const ErrorView({super.key,required this.error,required this.onRetry});final Object? error;final VoidCallback onRetry;@override Widget build(BuildContext c)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error is AppException?(error! as AppException).message:'Chargement impossible.'),const SizedBox(height:12),FilledButton(onPressed:()=>onRetry(),child:const Text('Réessayer'))])));}
