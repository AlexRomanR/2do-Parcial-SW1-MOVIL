import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/user.dart';
import 'package:gestion_asistencia_docente/services/server.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  bool _isloggedIn = false;
  User? _user;
  String? _sessionId;
  String? _rol;
  List<String> _permisos = [];

  bool get authentificate => _isloggedIn;
  User? get userOrNull => _user;
  
  User get user {
    if (_user == null) {
      throw StateError('Usuario no inicializado');
    }
    return _user!;
  }
  
  String? get rol => _rol;
  List<String> get permisos => _permisos;

  String? get sessionId => _sessionId; // Getter para la sesión

  Servidor servidor = Servidor();
  final _storage = const FlutterSecureStorage();

  /// Inicia sesión y guarda el `session_id` si es exitoso.
  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${servidor.baseURL}/web/session/authenticate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "jsonrpc": "2.0",
          "params": {
            "db": "AgendaElectronica2",
            "login": email,
            "password": password,
          }
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final sessionCookie = response.headers['set-cookie'];
        if (sessionCookie != null) {
          _sessionId = extractSessionId(sessionCookie);
          print('Session ID: $_sessionId');
          await storageSessionId(_sessionId!);
          await trySession();
          await obtenerRolYPermisos();
          return 'correcto';
        } else {
          return 'No se pudo obtener session_id';
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        return 'Credenciales incorrectas';
      }
    } catch (e) {
      print('Error en login: $e');
      return 'Error en login';
    }
  }

  /// Extrae el `session_id` de la cookie recibida.
  String? extractSessionId(String cookie) {
    final sessionParts = cookie.split(';');
    for (var part in sessionParts) {
      if (part.trim().startsWith('session_id=')) {
        return part.split('=')[1];
      }
    }
    return null;
  }

  /// Almacena el `session_id` en almacenamiento seguro.
  Future<void> storageSessionId(String sessionId) async {
    await _storage.write(key: 'session_id', value: sessionId);
  }

  /// Verifica el `session_id` guardado y recupera los datos del usuario.
  Future<void> trySession() async {
    final storedSessionId = await _storage.read(key: 'session_id');
  
    if (storedSessionId == null) {
      print('No hay session_id almacenado');
      return;
    }
  
    try {
      final response = await http.post(
        Uri.parse('${servidor.baseURL}/web/session/get_session_info'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cookie': 'session_id=$storedSessionId',
        },
        body: jsonEncode({}), // Body JSON vacío
      );
  
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
  
      if (response.statusCode == 200) {
        var decodedBody = jsonDecode(response.body)['result'];
        _isloggedIn = true;
        _user = User.fromJson(decodedBody);
        notifyListeners();
      } else if (response.statusCode == 401) {
        print('Unauthorized: ${response.body}');
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error en trySession: $e');
    }
  }

Future<void> obtenerRolYPermisos() async {
  try {
    final url = Uri.parse('${servidor.baseURL}/api/rol-permisos/${_user!.id}');

    print('Llamando a: $url');

    final request = http.Request('GET', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$_sessionId',
      })
      ..body = jsonEncode({}); // Agregar cuerpo vacío

    final response = await http.Response.fromStream(await request.send());

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

     if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Navegar correctamente hasta los roles
      final roles = data['result']['roles'];
      if (roles.isNotEmpty) {
        final rol = roles.first;
        _rol = rol['role_name'] ?? 'Rol desconocido';
        _permisos = List<String>.from(rol['permissions'] ?? []);

        print('Rol: $_rol');
        print('Permisos: $_permisos');
        notifyListeners();
      } else {
        print('No se encontró ningún rol en la respuesta.');
      }
    } else {
      print('Error obteniendo rol y permisos: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error en obtenerRolYPermisos: $e');
  }
}



  /// Cierra sesión y limpia los datos.
  void logout() async {
    try {
      final storedSessionId = await _storage.read(key: 'session_id');
      await http.get(
        Uri.parse('${servidor.baseURL}/web/session/destroy'),
        headers: {
          'Cookie': 'session_id=$storedSessionId',
        },
      );
      cleanUp();
      notifyListeners();
    } catch (e) {
      print('Error en logout: $e');
    }
  }

  /// Limpia los datos de sesión y usuario.
  void cleanUp() async {
    _user = null;
    _isloggedIn = false;
    await _storage.delete(key: 'session_id');
  }
}
