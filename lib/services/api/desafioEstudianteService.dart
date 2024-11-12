import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/desafioEstudiante.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';

class DesafioEstudianteService extends ChangeNotifier {
  List<DesafioEstudiante> desafiosEstudiantes = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<DesafioEstudiante>> loadDesafioEstudiantes(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    final userId = authService.user.id.toString();
    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafios_estudiante/$userId');
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

      // Convertir la lista de desafiosEstudiantes en objetos DesafioEstudiante
      desafiosEstudiantes = List<DesafioEstudiante>.from(
        responseData['result']['desafios_estudiante'].map((data) => DesafioEstudiante.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return desafiosEstudiantes;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load desafiosEstudiantes');
    }
  }



  Future<List<DesafioEstudiante>> loadDesafioCompletadoEstudiantes(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    final userId = authService.user.id.toString();
    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafios_completados_estudiante/$userId');
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

      // Convertir la lista de desafiosEstudiantes en objetos DesafioEstudiante
      desafiosEstudiantes = List<DesafioEstudiante>.from(
        responseData['result']['desafios_estudiante'].map((data) => DesafioEstudiante.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return desafiosEstudiantes;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load desafiosEstudiantes');
    }
  }



}



