import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/cursoMateria.dart';
import 'package:gestion_asistencia_docente/models/entregas.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:http/http.dart' as http;


class PuntuarEntrega extends StatefulWidget {
  final Entrega entrega;

  const PuntuarEntrega({Key? key, required this.entrega}) : super(key: key);

  @override
  _PuntuarEntregaState createState() => _PuntuarEntregaState();
}

class _PuntuarEntregaState extends State<PuntuarEntrega> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TextEditingController puntajeController = TextEditingController();


  File? archivo;
  bool isLoading = true;

  List<CursoMateria> cursoMateriaDisponibles = [];
  CursoMateria? cursoMateriaSeleccionado; 
  final Server servidor = Server();
  
  @override
  void initState() {
    super.initState();
    puntajeController.text = widget.entrega.puntaje.toString();
    
    // Cambia isLoading a false después de inicializar puntajeController
    setState(() {
      isLoading = false;
    });
  }


  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('${servidor.baseURL}api/entregas/edit/${widget.entrega.id}');
      final request = http.MultipartRequest('POST', uri);

      request.fields['puntaje'] = puntajeController.text;

      // if (archivo != null) {
      //   request.files.add(await http.MultipartFile.fromPath(
      //     'archivo',
      //     archivo!.path,
      //   ));
      // }

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

        print("Response status code: ${response.statusCode}");
        print("Response body: $responseBody");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrega editado con éxito')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al editar el entrega')),
          );
          print("Error al editar el entrega: ${response.statusCode}");
          print("Error details: $responseBody");
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
        title: Text('Editar Entrega', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: puntajeController,
                      decoration: const InputDecoration(
                        labelText: 'Puntaje',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un puntaje';
                        }
                        return null;
                      },
                    ),
                    // ElevatedButton(
                    //   onPressed: _seleccionarArchivo,
                    //   child: const Text('Seleccionar archivo'),
                    // ),
                    // archivo != null
                    //     ? Text(
                    //         'Archivo seleccionado: ${archivo!.path.split('/').last}',
                    //         style: const TextStyle(color: Colors.white),
                    //       )
                    //     : const Text(
                    //         'No se ha seleccionado un archivo',
                    //         style: TextStyle(color: Colors.white),
                    //       ),
                    // const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
