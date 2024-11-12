import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/solicitudes.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SolicitudesDesafiosService extends ChangeNotifier {
  List<SolicitudDesafio> solicitudes = [];
  bool isLoading = true;
  final Server servidor = Server();
  List<int> estudiantesDesafiadosIds = [];

  Future<List<SolicitudDesafio>> loadSolicitudDesafioes(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.user.id.toString();
    final sessionId = authService.sessionId;

    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafio/solicitudes_recibidas/$userId');
    final request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      })
      ..body = jsonEncode({});

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      // Convertir la lista de solicitudes en objetos SolicitudDesafio
      solicitudes = List<SolicitudDesafio>.from(
        responseData['result']['solicitudes'].map((data) => SolicitudDesafio.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return solicitudes;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load solicitudes');
    }
  }


  Future<List<SolicitudDesafio>> loadSolicitudDesafioEnviado(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.user.id.toString();
    final sessionId = authService.sessionId;

    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafio/solicitudes_enviadas/$userId');
    final request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      })
      ..body = jsonEncode({});

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));

      // Convertir la lista de solicitudes en objetos SolicitudDesafio
      estudiantesDesafiadosIds = List<int>.from(responseData['result']['solicitudes'].map((data) => data['desafiado_id']));
      isLoading = false;
      notifyListeners();
      return solicitudes;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load solicitudes');
    }
  }  

  Future<void> createSolicitud(BuildContext context, int desafianteId, int desafiadoId, String mensaje) async {
    isLoading = true;
    notifyListeners();
  
    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;
  
    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }
  
    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafio/crear_solicitud');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': 'session_id=$sessionId',
        },
        body: jsonEncode({
          'desafiante_id': desafianteId,
          'desafiado_id': desafiadoId,
          'mensaje': mensaje,
        }),
      );
  
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
  
        // Si la solicitud fue exitosa, agregar la nueva solicitud de desafío a la lista
        if (responseData['result'] != null && responseData['result']['status'] == 'success') {
          print('entrooo xdd');
       
        } else {
          print(response.body);
          print('Error al crear solicitud: ${responseData['error']}');
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al crear solicitud: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}