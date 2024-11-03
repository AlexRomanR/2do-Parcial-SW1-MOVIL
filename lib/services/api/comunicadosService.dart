import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/comunicados.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ComunicadoService extends ChangeNotifier {
  List<Comunicado> comunicados = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Comunicado>> loadComunicados(BuildContext context) async {
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
    final url = Uri.parse('${servidor.baseURL}api/get_comunicados/$userId');
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
      comunicados = List<Comunicado>.from(
        responseData['result']['comunicados'].map((data) => Comunicado.fromJson(data)),
      );

      isLoading = false;
      notifyListeners();
      return comunicados;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load comunicados');
    }
  }
}