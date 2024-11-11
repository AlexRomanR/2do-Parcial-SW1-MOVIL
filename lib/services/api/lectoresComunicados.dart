import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/lectoresComunicados.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LectoresComunicadosService extends ChangeNotifier {
  List<LectorComunicado> lectores = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<LectorComunicado>> loadLectorComunicadoes(BuildContext context, String comunicadoId) async {
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
    final url = Uri.parse('${servidor.baseURL}api/comunicado/lectores/$comunicadoId');
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

      // Convertir la lista de lectores en objetos LectorComunicado
      lectores = List<LectorComunicado>.from(
        responseData['result']['lectores'].map((data) => LectorComunicado.fromJson(data)),
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