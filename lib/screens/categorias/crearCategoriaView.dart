import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:http/http.dart' as http;




class CrearCategoria extends StatefulWidget {
  const CrearCategoria({Key? key}) : super(key: key);

  @override
  _CrearCategoriaState createState() => _CrearCategoriaState();
}

class _CrearCategoriaState extends State<CrearCategoria> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TextEditingController nombreController = TextEditingController();

  bool isLoading = true;

  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('${servidor.baseURL}api/categoria/create');
      final sessionId = await _getSessionId();

      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId',
      };

      final body = jsonEncode({
        'nombre': nombreController.text,
      });

      try {
        final response = await http.post(uri, headers: headers, body: body);
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoria creada con éxito')),
          );
          Navigator.pop(context, true);  // Regresa con un valor "true"
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear la categoria')),
          );
          print("Error al crear la categoria: ${response.statusCode}");
          print("Error details: ${response.body}");
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
        title: Text('Crear Categoria', style: TextStyle(color: Colors.white)),
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
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo',
                        labelStyle: TextStyle(color: Colors.white), // Cambia el color de la etiqueta a blanco
                      ),
                      style: TextStyle(color: Colors.white), // Cambia el color del texto ingresado a blanco
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                   
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Crear Categoria'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
