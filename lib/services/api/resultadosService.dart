import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/resultados.dart';
import 'package:gestion_asistencia_docente/models/resultados.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';

class ResultadoService extends ChangeNotifier {
  Resultado? resultado;
  bool isLoading = true;
  final Server servidor = Server();

  Future<void> loadResultado(BuildContext context, int estudianteId) async {
  

    isLoading = true;

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}api/desafios_estudiante/resultados/$estudianteId');
    final request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      })
      ..body = jsonEncode({});

    final response = await http.Response.fromStream(await request.send());
    print(response.body);

    if (response.statusCode == 200) {
      print("etro al 200 xd");
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      resultado = Resultado.fromJson(responseData['result']['resultados']);
      print(resultado?.puntosGanados);
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      throw Exception('Failed to load resultado');
    }
  }
}



