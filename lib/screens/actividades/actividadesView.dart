import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/entregas.dart';
import 'package:gestion_asistencia_docente/screens/actividades/EntregasView.dart';
import 'package:gestion_asistencia_docente/screens/actividades/crearActividad.dart';
import 'package:gestion_asistencia_docente/screens/actividades/crearEntrega.dart';
import 'package:gestion_asistencia_docente/screens/actividades/editarActividad.dart';
import 'package:gestion_asistencia_docente/screens/actividades/editarEntrega.dart';
import 'package:gestion_asistencia_docente/screens/actividades/lecturasActividadView.dart';
import 'package:gestion_asistencia_docente/screens/actividades/verActividadView.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/actividadesService.dart';
import 'package:gestion_asistencia_docente/services/api/lectoresActividad.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

  class ActividadesView extends StatefulWidget {
    const ActividadesView({super.key});

    @override
    State<ActividadesView> createState() => _ActividadesViewState();
  }

  class _ActividadesViewState extends State<ActividadesView> {
    final FlutterSecureStorage _storage = FlutterSecureStorage();
    final Server servidor = Server();

    @override
    void initState() {
      super.initState();
      Future.delayed(Duration.zero, () {
        _loadData();
      });
    }
    
    Future<void> _loadData() async {
      final actividadService = Provider.of<ActividadService>(context, listen: false);
      await actividadService.loadActividades(context);

    }
  
    Future<String?> _getSessionId() async {
      return await _storage.read(key: 'session_id');
    }
  
    Future<void> _markActividadAsRead(actividadId) async {
      int userId = Provider.of<AuthService>(context, listen: false).user.id;
      final url = Uri.parse('${servidor.baseURL}/api/marcar-actividad-leido/$userId/$actividadId');
      final sessionId = await _getSessionId();
  
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
  
      // Envía la solicitud para marcar el actividad como leído
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': 'session_id=$sessionId',
          },
          body: jsonEncode({}), 
        );
  
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            print('Actividad marcado como leído exitosamente');
          } else {
            print('Error al marcar como leído: ${data['error']}');
          }
        } else {
          print('Error en la solicitud: ${response.statusCode}');
        }
      } catch (e) {
        print('Excepción al marcar como leído: $e');
      }
    }

    Future<void> _deleteActividad(int idActividad) async {
      final uri = Uri.parse('${servidor.baseURL}api/actividad/delete/$idActividad');
      
      // Obtén el session_id almacenado
      final sessionId = await _getSessionId(); // Asegúrate de que _getSessionId() retorna el session_id correcto
      
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
    
      print("Intentando eliminar el actividad con ID: $idActividad");
    
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'session_id=$sessionId', // Agrega session_id aquí
        },
        body: jsonEncode({}), // Envía el body vacío como se requiere
      );
    
      print("Response status code: ${response.statusCode}");
      print("Response body: ${await response.body}");
    
      if (response.statusCode == 200) {
        // Accede al servicio de actividades a través de Provider
        final actividadService = Provider.of<ActividadService>(context, listen: false);
    
        // Eliminamos el actividad de la lista local
        actividadService.actividades.removeWhere((actividad) => actividad.id == idActividad);
        actividadService.notifyListeners();  // Notifica cambios para refrescar la UI
    
        print("Actividad eliminado localmente. Mostrando SnackBar.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad eliminado exitosamente'),
          ),
        );
      } else {
        print("Error al eliminar el actividad en el servidor. Código de estado: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el actividad'),
          ),
        );
      }
    }

    Future<Map<String, dynamic>> verificarEntrega(int idActividad) async {
      final Server servidor = Server();
      int userId = Provider.of<AuthService>(context, listen: false).user.id;
      final url = Uri.parse('${servidor.baseURL}api/entregas/existe/$idActividad/$userId');
    
      print('Información de verificar entrega');
      print('ID Actividad: $idActividad');
      print('ID Usuario: $userId');
    
      final sessionId = await _getSessionId();
      if (sessionId == null) {
        print("No se encontró el session_id");
        return {'existe': false};
      }
    
      try {
        // Crear la solicitud GET manualmente y añadir un cuerpo vacío
        final request = http.Request('GET', url)
          ..headers.addAll({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'session_id=$sessionId',
          })
          ..body = jsonEncode({});
    
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
    
        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody);
    
          // Asegúrate de acceder al campo "result" en la respuesta JSON
          final result = data['result'] ?? {};
          print('Resultado de verificar entrega: $result');
          
          return {
            'existe': result['existe'] ?? false,
            'entrega_id': result['entrega_id'] ?? null,
          };
        } else {
          print('Error en la solicitud: ${response.statusCode}');
          return {'existe': false};
        }
      } catch (e) {
        print("Error en la verificación de entrega: $e");
        return {'existe': false};
      }
    }

    @override
    Widget build(BuildContext context) {
      final actividadService = Provider.of<ActividadService>(context);
      // Obtén el servicio de autenticación
      final authService = Provider.of<AuthService>(context, listen: false);
      final roles = authService.rol ?? [];
  
      // Condición para verificar si el rol permite editar y eliminar
      final canEditOrDelete = roles.any((role) =>
          role.toLowerCase() == 'docente' ||
          role.toLowerCase() == 'docentes' ||
          role.toLowerCase() == 'profesor');

      final canEntregar = roles.any((role) =>
          role.toLowerCase() == 'estudiante' ||
          role.toLowerCase() == 'estudiantes' ||
          role.toLowerCase() == 'alumnos');    
          
      return Scaffold(
        appBar: AppBar(
          title: Text('Actividades', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
             if (canEditOrDelete)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearActividad()),
                  );
                },
              ),
          ],
        ),
        backgroundColor: Colors.black,
        body: actividadService.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orange))
            : ListView.builder(
                itemCount: actividadService.actividades.length,
                itemBuilder: (context, index) {
                  final actividad = actividadService.actividades[index];
                  
                  // Formatear la fecha de publicación
                  String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(actividad.fechaCreacion);

                  // Convertir los roles a una cadena de texto separada por comas
                  String cursoMateria = actividad.cursoMateria.isNotEmpty 
                  ? actividad.cursoMateria 
                  : 'No especificado';



                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        actividad.motivo,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            'Fecha de publicación: $formattedDate',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Para: $cursoMateria',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Navegar a la vista VerActividadViews y pasar el actividad
                                await _markActividadAsRead(actividad.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerActividadViews(actividad: actividad),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 255, 255, 255), // Cambiado a backgroundColor
                              ),
                              child: Text('Ver Actividad'),
                            ),
                          ),
                          SizedBox(height: 10),
                          if (canEditOrDelete)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditarActividad(actividad: actividad),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Text('Editar'),
                              ),
                            ),
                          SizedBox(height: 10),
                          if (canEditOrDelete)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EntregasView(
                                        actividad: actividad,
                                        entregas: actividad.entregas,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Text('Entregas'),
                              ),
                            ),

                          SizedBox(height: 10),
                          if (canEditOrDelete)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Obtener el servicio de LectoresActividadesService
                                  final lectoresService = Provider.of<LectoresActividadesService>(context, listen: false);
                                  
                                  // Intentar cargar los lectores desde el servicio
                                  try {
                                    final lectores = await lectoresService.loadLectorActividades(context, actividad.id.toString());
              
                                    // Navegar a LecturasActividadView con los datos obtenidos
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LecturasActividadView(
                                          actividad: actividad,
                                          lecturas: lectores,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Manejar el error si la carga falla
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al cargar lectores: $e')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Text('Leídos'),
                              ),
                            ),
                          SizedBox(height: 10),
                          if (canEntregar)
                            FutureBuilder<Map<String, dynamic>>(
                              future: verificarEntrega(actividad.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error al verificar entrega',
                                    style: TextStyle(color: Colors.red),
                                  );
                                } else {
                                  final existeEntrega = snapshot.data?['existe'] ?? false;
                                  final entregaId = snapshot.data?['entrega_id'];
                          
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => existeEntrega
                                                ? EditarEntrega(entrega: actividad.entregas.firstWhere((entrega) => entrega.id == entregaId, orElse: () => actividad.entregas.first))
                                                : CrearEntrega(actividad: actividad),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      child: Text(existeEntrega ? 'Editar Entrega' : 'Crear Entrega'),
                                    ),
                                  );
                                }
                              },
                            ),

                          SizedBox(height: 10),
                          // Solo muestra el botón de eliminar si el usuario tiene permisos
                          if (canEditOrDelete)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteActividad(actividad.id);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    }
  }