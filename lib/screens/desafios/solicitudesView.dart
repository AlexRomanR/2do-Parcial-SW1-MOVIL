import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/services/api/solicitudesDesafioService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

  class SolicitudesView extends StatefulWidget {
    const SolicitudesView({super.key});

    @override
    State<SolicitudesView> createState() => _SolicitudesViewState();
  }

  class _SolicitudesViewState extends State<SolicitudesView> {
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
      final solicitudService = Provider.of<SolicitudesDesafiosService>(context, listen: false);
      await solicitudService.loadSolicitudDesafioes(context);

    }
  
    Future<String?> _getSessionId() async {
      return await _storage.read(key: 'session_id');
    }
  
    Future<void> _acceptDesafio(int solicitudId) async {
      final sessionId = await _getSessionId();
  
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
  
      final url = Uri.parse('${servidor.baseURL}/api/desafio/aceptar/$solicitudId');
  
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
          if (data['result'] != null && data['result']['status'] == 'success') {
            print('Desafío aceptado exitosamente');
            // Opcional: Actualizar la lista de solicitudes después de aceptar
                    // Mostrar un diálogo
        // Mostrar un diálogo con imagen personalizada
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.all(20),
              title: Row(
                children: [
                  Icon(Icons.star, color: Colors.orangeAccent),
                  SizedBox(width: 10),
                  Text("¡Desafío Aceptado!"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/utils/estudiar.png', // Ruta de tu imagen
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Prepárate para competir y mostrar tus habilidades. ¡Buena suerte!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "¡Vamos!",
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              ],
            );
          },
        );

        await _loadData();
          } else {
            print('Error al aceptar el desafío: ${data['message']}');
          }
        } else {
          print('Error en la solicitud: ${response.statusCode}');
        }
      } catch (e) {
        print('Excepción al aceptar el desafío: $e');
      }
    }

    Future<void> _deleteSolicitud(int idSolicitud) async {
      final uri = Uri.parse('${servidor.baseURL}/api/solicitud/delete/$idSolicitud');
      
      // Obtén el session_id almacenado
      final sessionId = await _getSessionId(); // Asegúrate de que _getSessionId() retorna el session_id correcto
      
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
    
      print("Intentando eliminar el actividad con ID: $idSolicitud");
    
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
        // Accede al servicio de solicitudes a través de Provider
        final actividadService = Provider.of<SolicitudesDesafiosService>(context, listen: false);
    
        // Eliminamos el actividad de la lista local
        actividadService.solicitudes.removeWhere((actividad) => actividad.id == idSolicitud);
        actividadService.notifyListeners();  // Notifica cambios para refrescar la UI
    
        print("Solicitud eliminado localmente. Mostrando SnackBar.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud eliminado exitosamente'),
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

    
    
  @override
  Widget build(BuildContext context) {
    final solicitudService = Provider.of<SolicitudesDesafiosService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de Desafío', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: solicitudService.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.builder(
              itemCount: solicitudService.solicitudes.length,
              itemBuilder: (context, index) {
                final solicitud = solicitudService.solicitudes[index];

                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      solicitud.desafianteNombre,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Fecha de solicitud: ${solicitud.fechaSolicitud}\nMensaje: ${solicitud.mensaje}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _acceptDesafio(solicitud.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _deleteSolicitud(solicitud.id);
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