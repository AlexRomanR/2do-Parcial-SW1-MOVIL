import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/crearComunicado.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/editarComunicado.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/lecturasComunicadoView.dart';
import 'package:gestion_asistencia_docente/screens/comunicados/verComunicadosView.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/comunicadosService.dart';
import 'package:gestion_asistencia_docente/services/api/lectoresComunicados.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

  class ComunicadosView extends StatefulWidget {
    const ComunicadosView({super.key});

    @override
    State<ComunicadosView> createState() => _ComunicadosViewState();
  }

  class _ComunicadosViewState extends State<ComunicadosView> {
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
      final comunicadoService = Provider.of<ComunicadoService>(context, listen: false);
      await comunicadoService.loadComunicados(context);

    }
  


    Future<String?> _getSessionId() async {
      return await _storage.read(key: 'session_id');
    }
  
    Future<void> _markComunicadoAsRead(comunicadoId) async {
      int userId = Provider.of<AuthService>(context, listen: false).user.id;
      final url = Uri.parse('${servidor.baseURL}/api/marcar-comunicado-leido/$userId/$comunicadoId');
      final sessionId = await _getSessionId();
  
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
  
      // Envía la solicitud para marcar el comunicado como leído
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
            print('Comunicado marcado como leído exitosamente');
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

    Future<void> _deleteComunicado(int idComunicado) async {
      final uri = Uri.parse('${servidor.baseURL}api/comunicado/delete/$idComunicado');
      
      // Obtén el session_id almacenado
      final sessionId = await _getSessionId(); // Asegúrate de que _getSessionId() retorna el session_id correcto
      
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
    
      print("Intentando eliminar el comunicado con ID: $idComunicado");
    
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
        // Accede al servicio de comunicados a través de Provider
        final comunicadoService = Provider.of<ComunicadoService>(context, listen: false);
    
        // Eliminamos el comunicado de la lista local
        comunicadoService.comunicados.removeWhere((comunicado) => comunicado.id == idComunicado);
        comunicadoService.notifyListeners();  // Notifica cambios para refrescar la UI
    
        print("Comunicado eliminado localmente. Mostrando SnackBar.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comunicado eliminado exitosamente'),
          ),
        );
      } else {
        print("Error al eliminar el comunicado en el servidor. Código de estado: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el comunicado'),
          ),
        );
      }
    }


    @override
    Widget build(BuildContext context) {
      final comunicadoService = Provider.of<ComunicadoService>(context);
      // Obtén el servicio de autenticación
      final authService = Provider.of<AuthService>(context, listen: false);
      final roles = authService.rol ?? [];
  
      // Condición para verificar si el rol permite editar y eliminar
      final canEditOrDelete = roles.any((role) =>
          role.toLowerCase() == 'admin' ||
          role.toLowerCase() == 'administrador' ||
          role.toLowerCase() == 'administradores');
          
      return Scaffold(
        appBar: AppBar(
          title: Text('Comunicados', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
             if (canEditOrDelete)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearComunicado()),
                  );
                },
              ),
          ],
        ),
        backgroundColor: Colors.black,
        body: comunicadoService.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.orange))
            : ListView.builder(
                itemCount: comunicadoService.comunicados.length,
                itemBuilder: (context, index) {
                  final comunicado = comunicadoService.comunicados[index];
                  
                  // Formatear la fecha de publicación
                  String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(comunicado.fechaCreacion);

                  // Convertir los roles a una cadena de texto separada por comas
                  String roles = comunicado.roles.isNotEmpty 
                      ? comunicado.roles.join(', ') 
                      : 'Todos';


                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(
                        comunicado.motivo,
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
                            'Publicado por: ${comunicado.administrativo ?? "Desconocido"}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
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
                            'Para: $roles',
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
                                // Navegar a la vista VerComunicadoViews y pasar el comunicado
                                await _markComunicadoAsRead(comunicado.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerComunicadoViews(comunicado: comunicado),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 255, 255, 255), // Cambiado a backgroundColor
                              ),
                              child: Text('Ver Comunicado'),
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
                                      builder: (context) => EditarComunicado(comunicado: comunicado),
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
                                onPressed: () async {
                                  // Obtener el servicio de LectoresActividadesService
                                  final lectoresService = Provider.of<LectoresComunicadosService>(context, listen: false);
                                  
                                  // Intentar cargar los lectores desde el servicio
                                  try {
                                    final lectores = await lectoresService.loadLectorComunicadoes(context, comunicado.id.toString());
              
                                    // Navegar a LecturasActividadView con los datos obtenidos
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LecturasComunicadoView(
                                          comunicado: comunicado,
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
                          // Solo muestra el botón de eliminar si el usuario tiene permisos
                          if (canEditOrDelete)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteComunicado(comunicado.id);
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