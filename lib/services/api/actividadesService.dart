import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/actividades.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ActividadService extends ChangeNotifier {
  List<Actividad> actividades = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Actividad>> loadActividades(BuildContext context) async {
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
    final url = Uri.parse('${servidor.baseURL}api/get_actividades/$userId');
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

      // Convertir la lista de actividades en objetos Actividad
      actividades = List<Actividad>.from(
        responseData['result']['actividades'].map((data) => Actividad.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return actividades;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load actividades');
    }
  }

  Future<List<Actividad>> loadActividadesPorCurso(BuildContext context, cursoId) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/get_actividades_curso/$cursoId');
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

      // Convertir la lista de actividades en objetos Actividad
      actividades = List<Actividad>.from(
        responseData['result']['actividades'].map((data) => Actividad.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return actividades;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load actividades');
    }
  }
}