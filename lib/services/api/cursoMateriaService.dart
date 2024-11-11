import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/cursoMateria.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CursoMateriaService extends ChangeNotifier {
  List<CursoMateria> cursoMaterias = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<CursoMateria>> loadCursoMaterias(BuildContext context) async {
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
    final url = Uri.parse('${servidor.baseURL}api/curso_materia_docente/$userId');
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

      // Convertir la lista de cursoMaterias en objetos CursoMateria
      cursoMaterias = List<CursoMateria>.from(
        responseData['result']['cursos_materias'].map((data) => CursoMateria.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return cursoMaterias;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load cursoMaterias');
    }
  }
}