import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/configuraciones.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/configuracionesService.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditarConfiguracion extends StatefulWidget {
  const EditarConfiguracion({Key? key}) : super(key: key);

  @override
  _EditarConfiguracionState createState() => _EditarConfiguracionState();
}

class _EditarConfiguracionState extends State<EditarConfiguracion> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  late TextEditingController puntosController;
  late TextEditingController frecuenciaController;

  bool isLoading = true;
  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    puntosController = TextEditingController();
    frecuenciaController = TextEditingController();
    _loadConfiguracion(); // Cargar configuración al inicializar el estado
  }

  Future<void> _loadConfiguracion() async {
    final configuracionService = Provider.of<ConfiguracionService>(context, listen: false);
    
    try {
      // Cargar la configuración
      final configuracion = await configuracionService.loadConfiguracion(context);

      // Asignar valores a los controladores
      setState(() {
        puntosController.text = configuracion.puntos.toString();
        frecuenciaController.text = configuracion.frecuencia.toString();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading configuration: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('${servidor.baseURL}api/configuracion/edit');
      final request = http.MultipartRequest('POST', uri);

      // Agregar campos como enteros
      request.fields['puntos'] = int.parse(puntosController.text).toString();
      request.fields['frecuencia'] = int.parse(frecuenciaController.text).toString();

      // Obtener el session_id de manera segura
      final sessionId = await _getSessionId();

      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }

      // Agregar encabezados con la cookie de autenticación
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      });

      // Enviar la solicitud y verificar la respuesta
      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        print(responseBody);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuración editada con éxito')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al editar la configuración')),
          );
        }
      } catch (e) {
        print("Exception during request: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception: $e')),
        );
      }
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Editar Configuración', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    resizeToAvoidBottomInset: false, // Evita el desplazamiento al abrir el teclado
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: puntosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad de puntos por desafio',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa los puntos';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número entero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: frecuenciaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia de desafio',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa la frecuencia';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número entero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
  );
}

}
