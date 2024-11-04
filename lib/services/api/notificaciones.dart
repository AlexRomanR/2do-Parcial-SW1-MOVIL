import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/comunicados.dart';
import 'package:gestion_asistencia_docente/models/notification.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NotificacionesService extends ChangeNotifier {
  List<Notificaciones> notificaciones = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Notificaciones>> loadNotificaciones(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/notificaciones');
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

      // Convertir la lista de comunicados en objetos Comunicado
      notificaciones = List<Notificaciones>.from(
        responseData['notifications'].map((data) => Notificaciones.fromMap(data)),
      );

      isLoading = false;
      notifyListeners();
      return notificaciones;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load notificaciones');
    }
  }

  Future<String> marcarTodasComoLeidas(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    // Verificar si hay un sessionId válido
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}/api/notificaciones/marcartodas');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      print("Todas las notificaciones fueron marcadas como leídas");
      return 'hecho';
    } else {
      print("Error al marcar todas como leídas");
      return 'error';
    }
  }

  Future<String> marcarComoLeida(BuildContext context, String notificacionId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }
    final url = Uri.parse('${servidor.baseURL}/api/notificacion/marcar/$notificacionId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      print("Notificación marcada como leída");
      return 'hecho';
    } else {
      print("Error al marcar notificación como leída: ${response.body}");
      return 'error';
    }
  }

}