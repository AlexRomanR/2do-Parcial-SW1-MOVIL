import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gestion_asistencia_docente/screens/asistencias/asistenciasView.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/comunicadosView.dart';
import 'package:gestion_asistencia_docente/screens/licencias/licenciasView.dart';
import 'package:gestion_asistencia_docente/screens/login/home_screen.dart';
import 'package:gestion_asistencia_docente/screens/login/login_screen.dart';
import 'package:gestion_asistencia_docente/screens/programacion_academica/programacion_academicaView.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    final roles = authService.rol.join(', ');
    final permissions = authService.permisos.join(', ');

    return Drawer(
      child: Container(
        color: Colors.black, // Fondo negro para el drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push( 
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Center(
                  child: Text(
                    'BIENVENIDO A\nUNI-SYS\n${user.name} Hola, $roles, tus permisos son: $permissions'
                    ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Texto blanco
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'COMUNICADOS Y ACTIVIDADES',
                style: TextStyle(
                  color: const Color.fromARGB(255, 184, 184, 184),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Ver Comunicados',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ComunicadosView()));
              },
            ),
            Divider(color: Colors.white, thickness: 1),
            // ListTile(
            //   title: Text(
            //     'GESTIÓN DE ASISTENCIAS',
            //     style: TextStyle(
            //       color: const Color.fromARGB(255, 184, 184, 184),
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // ListTile(
            //   title: Text(
            //     'Mis Asistencias',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const AsistenciasView(),
            //       ),
            //     );
            //   },
            // ),
            // ListTile(
            //   title: Text(
            //     'Mis Licencias',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const LicenciasView(),
            //       ),
            //     );
            //   },
            // ),
            Divider(color: Colors.white, thickness: 1),
            ListTile(
              title: Text(
                'LOGOUT',
                style: TextStyle(
                 color: const Color.fromARGB(255, 184, 184, 184),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Provider.of<AuthService>(context, listen: false).logout();
                print('Presionado cerrar sesión');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
