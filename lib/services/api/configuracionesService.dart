import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/configuraciones.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';

class ConfiguracionService extends ChangeNotifier {
  Configuracion? configuracion;
  bool isLoading = true;
  final Server servidor = Server();

  Future<Configuracion> loadConfiguracion(BuildContext context) async {
    isLoading = true;

    // Utilizar addPostFrameCallback para retrasar notifyListeners()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}api/configuracion/get');
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

      final configData = responseData['result']?['configuracion'];
      if (configData != null) {
        configuracion = Configuracion.fromJson(configData);
        isLoading = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return configuracion!;
      } else {
        isLoading = false;
        throw Exception('Formato de datos inesperado en la respuesta de configuración');
      }
    } else {
      isLoading = false;
      throw Exception('Error al cargar la configuración');
    }
  }
}
