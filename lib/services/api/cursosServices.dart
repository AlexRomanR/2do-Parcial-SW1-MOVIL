import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/cursos.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';

class CursoService extends ChangeNotifier {
  List<Curso> cursos = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Curso>> loadCursos(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    // Si no hay sessionId, devolvemos un error
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Crear y enviar la solicitud
    final url = Uri.parse('${servidor.baseURL}api/cursos');
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

      // Convertir la lista de cursos en objetos Curso
      cursos = List<Curso>.from(
        responseData['result']['cursos'].map((data) => Curso.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return cursos;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load cursos');
    }
  }


  // Método para cargar cursos de un docente específico
  Future<List<Curso>> loadCursosPorDocente(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.user.id.toString();
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}api/curso_docente/$userId');
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
      cursos = List<Curso>.from(
        responseData['result']['cursos'].map((data) => Curso.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return cursos;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load cursos');
    }
  }

  // Método para cargar el curso de un estudiante específico
Future<List<Curso>> loadCursosPorEstudiante(BuildContext context) async {
  isLoading = true;
  notifyListeners();

  final authService = Provider.of<AuthService>(context, listen: false);
  final userId = authService.user.id.toString();
  final sessionId = authService.sessionId;

  if (sessionId == null) {
    throw Exception('No se encontró session_id');
  }

  final url = Uri.parse('${servidor.baseURL}api/curso_estudiante/$userId');
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

    if (responseData['result'] != null && responseData['result']['curso'] != null) {
      // Cargar el curso en la lista de cursos
      cursos = [Curso.fromJson(responseData['result']['curso'])];
    } else {
      cursos = [];
    }

    isLoading = false;
    notifyListeners();
    return cursos;
  } else {
    print('Error en la solicitud: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');
    isLoading = false;
    notifyListeners();
    throw Exception('Failed to load curso');
  }
}


}



