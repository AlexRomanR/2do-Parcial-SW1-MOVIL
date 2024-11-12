import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gestion_asistencia_docente/screens/actividades/actividadesView.dart';
import 'package:gestion_asistencia_docente/screens/asistencias/asistenciasView.dart';
import 'package:gestion_asistencia_docente/screens/categorias/categoriasView.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/comunicadosView.dart';
import 'package:gestion_asistencia_docente/screens/eventos/listaEventos.dart';
import 'package:gestion_asistencia_docente/screens/configuraciones/editConfiguracion.dart';
import 'package:gestion_asistencia_docente/screens/cursos/cursosView.dart';
import 'package:gestion_asistencia_docente/screens/cursos/rankingCursoView.dart';
import 'package:gestion_asistencia_docente/screens/desafios/DesafiosView.dart';
import 'package:gestion_asistencia_docente/screens/desafios/historialDesafiosView.dart';
import 'package:gestion_asistencia_docente/screens/desafios/solicitudesView.dart';
import 'package:gestion_asistencia_docente/screens/licencias/licenciasView.dart';
import 'package:gestion_asistencia_docente/screens/login/home_screen.dart';
import 'package:gestion_asistencia_docente/screens/login/login_screen.dart';
import 'package:gestion_asistencia_docente/screens/programacion_academica/programacion_academicaView.dart';
import 'package:gestion_asistencia_docente/services/api/cursosServices.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  void _navigateToRanking(BuildContext context) async {
  // Obtener el servicio de CursoService
  final cursoService = Provider.of<CursoService>(context, listen: false);
    try {
      final cursos = await cursoService.loadCursosPorEstudiante(context);
      
      if (cursos.isNotEmpty) {

        final curso = cursos.first;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RankingCurso(curso: curso),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró un curso asociado al estudiante.')),
        );
      }
    } catch (e) {
      // Manejar el error si la carga falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar curso: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    final roles = authService.rol.join(', ');
    final permissions = authService.permisos.join(', ');
    final rolese = authService.rol ?? [];

    // Condición para verificar si el rol permite editar y eliminar
    final docente = rolese.any((role) =>
        role.toLowerCase() == 'docente' ||
        role.toLowerCase() == 'docentes' ||
        role.toLowerCase() == 'profesor');
    final estudiante = rolese.any((role) =>
        role.toLowerCase() == 'estudiante' ||
        role.toLowerCase() == 'estudiantes' ||
        role.toLowerCase() == 'alumnos');    

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
            ListTile(
              title: Text(
                'Ver Actividades',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActividadesView()));
              },
            ),
             ListTile(
              title: Text(
                'Ver Eventos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EventosScreen()));
              },
            ),
            Divider(color: Colors.white, thickness: 1),
            if(docente)
              ListTile(
                title: Text(
                  'GESTION CURSOS Y DESAFIOS',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 184, 184, 184),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if(docente)  
              ListTile(
                title: Text(
                  'Mis cursos',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CursosView(),
                    ),
                  );
                },
              ),

            if(docente)  
              ListTile(
                title: Text(
                  'Configuraciones de Desafios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditarConfiguracion(),
                    ),
                  );
                },
              ),

            if(docente)  
              ListTile(
                title: Text(
                  'Categorias de Desafios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriasView(),
                    ),
                  );
                },
              ),

            if (estudiante)  
              ListTile(
                title: Text(
                  'Rankings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _navigateToRanking(context),
              ),
            if (estudiante)  
              ListTile(
                title: Text(
                  'Mis desafios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DesafiosView(),
                    ),
                  );
                },
              ),  

            if (estudiante)  
              ListTile(
                title: Text(
                  'Historial de desafios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorialDesafiosView(),
                    ),
                  );
                },
              ),  

            if (estudiante)  
              ListTile(
                title: Text(
                  'Solicitudes de Desafios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SolicitudesView(),
                    ),
                  );
                },
              ),  

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
