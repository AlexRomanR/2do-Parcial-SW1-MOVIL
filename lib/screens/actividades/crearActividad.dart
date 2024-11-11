import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestion_asistencia_docente/models/cursos.dart';
import 'package:gestion_asistencia_docente/models/cursoMateria.dart';
import 'package:gestion_asistencia_docente/server.dart';
import 'package:gestion_asistencia_docente/services/api/cursoMateriaService.dart';
import 'package:gestion_asistencia_docente/services/api/cursosServices.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';



class CrearActividad extends StatefulWidget {
  const CrearActividad({Key? key}) : super(key: key);

  @override
  _CrearActividadState createState() => _CrearActividadState();
}

class _CrearActividadState extends State<CrearActividad> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  TextEditingController motivoController = TextEditingController();
  TextEditingController textoController = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaPresentacion;

  File? archivo;
  bool isLoading = true;

  List<CursoMateria> cursoMateriaDisponibles = [];
  CursoMateria? cursoMateriaSeleccionado; 
  final Server servidor = Server();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _loadCursoMaterias();
    });
  }

  Future<void> _loadCursoMaterias() async {
    final cursoMateriaService = Provider.of<CursoMateriaService>(context, listen: false);
    cursoMateriaDisponibles = await cursoMateriaService.loadCursoMaterias(context);
    setState(() {
      isLoading = false;
    });
  }


  Future<void> _selectDate(BuildContext context, {required bool isInicio}) async {
    DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isInicio) {
            fechaInicio = selectedDateTime;
          } else {
            fechaPresentacion = selectedDateTime;
          }
        });
      }
    }
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
      final uri = Uri.parse('${servidor.baseURL}/api/actividad/create');
      final request = http.MultipartRequest('POST', uri);
      // Formato de fecha en 'YYYY-MM-DD HH:MM:SS'
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedFechaInicio = dateFormat.format(fechaInicio!);
      final formattedFechaPresentacion = dateFormat.format(fechaPresentacion!);
  
      // Agregar campos y archivo
      request.fields['motivo'] = motivoController.text;
      request.fields['texto'] = textoController.text;
      request.fields['curso_docente_materia_id'] = cursoMateriaSeleccionado!.id.toString(); 
      request.fields['fecha_inicio'] = formattedFechaInicio;
      request.fields['fecha_presentacion'] = formattedFechaPresentacion;
  
      print(cursoMateriaSeleccionado!.id.toString());

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
            const SnackBar(content: Text('Actividad creado con éxito')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear el actividad')),
          );
          print("Error al crear el actividad: ${response.statusCode}");
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
        title: Text('Crear Actividad', style: TextStyle(color: Colors.white)),
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
                          return 'Por favor, ingresa el texto del actividad';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, isInicio: true),
                      child: Text(fechaInicio != null
                          ? 'Fecha de Inicio: ${fechaInicio!.toIso8601String().split("T")[0]}'
                          : 'Seleccionar Fecha de Inicio'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, isInicio: false),
                      child: Text(fechaPresentacion != null
                          ? 'Fecha de Presentación: ${fechaPresentacion!.toIso8601String().split("T")[0]}'
                          : 'Seleccionar Fecha de Presentación'),
                    ),
                    const SizedBox(height: 50.0),
                    DropdownButtonFormField<CursoMateria>(
                      decoration: InputDecoration(
                        labelText: 'Curso Materia',
                        border: OutlineInputBorder(),
                      ),
                      items: cursoMateriaDisponibles.map((cursoMateria) {
                        return DropdownMenuItem<CursoMateria>(
                          value: cursoMateria,
                          child: Text(cursoMateria.nombre,  style: TextStyle(color: Color.fromARGB(255, 107, 107, 107)),),
                          
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cursoMateriaSeleccionado = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Por favor, selecciona un curso y materia' : null,
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Estilo del texto del valor seleccionado
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
                        child: const Text('Crear Actividad'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
