import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_asistencia_docente/models/evento.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EventosService extends ChangeNotifier {
  List<Evento> eventos = [];
  bool isLoading = true;
  final Server servidor = Server();

  Future<List<Evento>> loadEventos(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}api/eventos');
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

      eventos = List<Evento>.from(
        responseData['eventos'].map((data) => Evento.fromMap(data)),
      );

      isLoading = false;
      notifyListeners();
      return eventos;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load notificaciones');
    }
  }

  Future<Evento> loadEvento(BuildContext context, String eventoId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }

    final url = Uri.parse('${servidor.baseURL}api/evento/ver/$eventoId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final evento = Evento.fromMap(responseData['evento']);
      return evento;
    } else {
      throw Exception('Failed to load evento: ${response.body}');
    }
  }

  Future<String> confirmarAsistencia(BuildContext context, String eventoId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final sessionId = authService.sessionId;

    if (sessionId == null) {
      throw Exception('No se encontró session_id');
    }
    final url = Uri.parse('${servidor.baseURL}api/evento/confirmar/$eventoId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      print("Notificación marcada como leída");
      return 'hecho';
    } else {
      print("Error al marcar notificación como leída: ${response.body}");
      return 'error';
    }
  }
}
