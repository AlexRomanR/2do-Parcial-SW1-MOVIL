import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/lectoresActividades.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LectoresActividadesService extends ChangeNotifier {
  List<LectorActividad> lectores = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<LectorActividad>> loadLectorActividades(BuildContext context, String actividadId) async {
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
    final url = Uri.parse('${servidor.baseURL}api/actividad/lectores/$actividadId');
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

      // Convertir la lista de lectores en objetos LectorActividad
      lectores = List<LectorActividad>.from(
        responseData['result']['lectores'].map((data) => LectorActividad.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return lectores;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load lectores');
    }
  }
}