import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/roles.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/rolesServices.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class CrearComunicado extends StatefulWidget {
  const CrearComunicado({Key? key}) : super(key: key);

  @override
  _CrearComunicadoState createState() => _CrearComunicadoState();
}

class _CrearComunicadoState extends State<CrearComunicado> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TextEditingController motivoController = TextEditingController();
  TextEditingController textoController = TextEditingController();

  File? archivo;
  bool isLoading = true;

  List<Role> rolesDisponibles = [];
  List<Role> rolesSeleccionados = [];
  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _loadRoles();
    });
  }

  Future<void> _loadRoles() async {
    final roleService = Provider.of<RoleService>(context, listen: false);
    rolesDisponibles = await roleService.loadRoles(context);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles();
  
    if (result != null) {
      setState(() {
        archivo = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _getSessionId() async {
    return await _storage.read(key: 'session_id');
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse('${servidor.baseURL}/api/comunicado/create');
      final request = http.MultipartRequest('POST', uri);
  
      // Agregar campos y archivo
      request.fields['motivo'] = motivoController.text;
      request.fields['texto'] = textoController.text;
      request.fields['rol_ids'] = '[${rolesSeleccionados.map((role) => role.id).join(",")}]';

      print('[${rolesSeleccionados.map((role) => role.id).join(",")}]');
  
      if (archivo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'archivo',
          archivo!.path,
        ));
      }
  
      // Obtener el session_id de manera segura
      final sessionId = await _getSessionId();  // Asegúrate de que _getSessionId() retorna el session_id correcto
  
      if (sessionId == null) {
        print("No se encontró el session_id");
        return;
      }
  
      // Agregar encabezados con la cookie de autenticación
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Cookie': 'session_id=$sessionId', // Agregar session_id aquí
      });
  
      // Enviar la solicitud y verificar la respuesta
      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
  
        print("Response status code: ${response.statusCode}");
        print("Response body: $responseBody");
  
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comunicado creado con éxito')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear el comunicado')),
          );
          print("Error al crear el comunicado: ${response.statusCode}");
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
        title: Text('Crear Comunicado', style: TextStyle(color: Colors.white)),
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
                      controller: motivoController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo',
                        labelStyle: TextStyle(color: Colors.white), // Cambia el color de la etiqueta a blanco
                      ),
                      style: TextStyle(color: Colors.white), // Cambia el color del texto ingresado a blanco
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un motivo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: textoController,
                      decoration: const InputDecoration(
                        labelText: 'Texto',
                        labelStyle: TextStyle(color: Colors.white), // Cambia el color de la etiqueta a blanco
                      ),
                      style: TextStyle(color: Colors.white), // Cambia el color del texto ingresado a blanco
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el texto del comunicado';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 50.0),
                    MultiSelectDialogField<Role>(
                      items: rolesDisponibles
                          .map((role) => MultiSelectItem<Role>(role, role.name))
                          .toList(),
                      title: const Text(
                        'Roles',
                        style: TextStyle(color: Colors.white), // Cambia el color del título a blanco
                      ),
                      selectedItemsTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Texto seleccionado en blanco
                      itemsTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Texto de elementos en blanco
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      buttonText: const Text(
                        'Seleccionar roles',
                        style: TextStyle(color: Colors.white), // Cambia el color del botón a blanco
                      ),
                      onConfirm: (List<Role> selectedRoles) {
                        setState(() {
                          rolesSeleccionados = selectedRoles;
                        });
                      },
                      initialValue: rolesSeleccionados,
                    ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: _seleccionarArchivo,
                      child: const Text('Seleccionar archivo'),
                    ),
                    archivo != null
                        ? Text(
                            'Archivo seleccionado: ${archivo!.path.split('/').last}',
                            style: const TextStyle(color: Colors.white), // Cambia el color del texto a blanco
                          )
                        : const Text(
                            'No se ha seleccionado un archivo',
                            style: TextStyle(color: Colors.white), // Cambia el color del texto a blanco
                          ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Crear Comunicado'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
