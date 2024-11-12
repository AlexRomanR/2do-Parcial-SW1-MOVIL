import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/preguntas.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PreguntaService extends ChangeNotifier {
  List<Pregunta> preguntas = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Pregunta>> loadPreguntasByDesafio(BuildContext context, int desafioId) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;
    final userId = authService.user.id.toString();

    // Verificar que sessionId esté disponible
    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    // Construir la URL de la solicitud
    final url = Uri.parse('${servidor.baseURL}api/desafio/$desafioId/preguntas/$userId');
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

      // Convertir la lista de preguntas en objetos Pregunta
      preguntas = List<Pregunta>.from(
        responseData['result']['preguntas'].map((data) => Pregunta.fromJson(data)),
      );

      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return preguntas;
    } else {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      throw Exception('Failed to load preguntas');
    }
  }
}
