import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/api/firebase_api.dart';
import 'package:gestion_asistencia_docente/components/utils/splash_screen.dart';
import 'package:gestion_asistencia_docente/screens/login/home_screen.dart';
import 'package:gestion_asistencia_docente/screens/login/login_screen.dart';
import 'package:gestion_asistencia_docente/services/api/asistenciasService.dart';
import 'package:gestion_asistencia_docente/services/api/comunicadosService.dart';
import 'package:gestion_asistencia_docente/services/api/eventosService.dart';
import 'package:gestion_asistencia_docente/services/api/licenciasService.dart';
import 'package:gestion_asistencia_docente/services/api/notificaciones.dart';
import 'package:gestion_asistencia_docente/services/api/programacion_academicaService.dart';
import 'package:gestion_asistencia_docente/services/api/rolesServices.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const AppState());
}

class AppState extends StatefulWidget {
  const AppState({super.key});

  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProgramacionAcademicaService()),
        ChangeNotifierProvider(create: (_) => AsistenciasService()),
        ChangeNotifierProvider(create: (_) => LicenciasService()),
        ChangeNotifierProvider(create: (_) => ComunicadoService()),
        ChangeNotifierProvider(create: (_) => RoleService()),
        ChangeNotifierProvider(create: (_) => NotificacionesService()),
        ChangeNotifierProvider(create: (_) => EventosService()),

        //   ChangeNotifierProvider(create: ( _ ) => VehicleService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto SI2',
      initialRoute: 'splash',
      routes: {
        '/': (_) => HomeScreen(),
        'login': (_) => LoginScreen(),
        'splash': (_) => SplashScreen()
      },
      theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 14, 13, 12),
          appBarTheme: const AppBarTheme(
              elevation: 0, color: Color.fromARGB(255, 0, 0, 0))),
    );
  }
}
