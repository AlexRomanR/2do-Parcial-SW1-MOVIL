import 'package:gestion_asistencia_docente/models/entregas.dart';

class Actividad {
  final int id;
  final String motivo;
  final String texto;
  final String archivoUrl;
  final DateTime fechaCreacion;
  final DateTime fechaInicio;
  final DateTime fechaPresentacion;
  final List<Entrega> entregas;
  final String formatoArchivo;
  final String publicURL;
  final String cursoMateria;

  Actividad({
    required this.id,
    required this.motivo,
    required this.texto,
    required this.archivoUrl,
    required this.fechaCreacion,
    required this.fechaInicio,
    required this.fechaPresentacion,
    required this.entregas,
    required this.formatoArchivo,
    required this.publicURL,
    required this.cursoMateria,
  });

  // Factory constructor para crear un objeto Actividad a partir de un JSON
  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'],
      motivo: json['motivo'],
      texto: json['texto'],
      archivoUrl: json['archivo_url'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaPresentacion: DateTime.parse(json['fecha_presentacion']),
      entregas: json['entregas'] != null
          ? List<Entrega>.from(json['entregas'].map((e) => Entrega.fromJson(e)))
          : [],
      formatoArchivo: json['formatoarchivo'],
      publicURL: json['publicURL'] ?? '',
      cursoMateria: json['curso_materia'],
    );
  }

  // Método para convertir el objeto Actividad a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivo': motivo,
      'texto': texto,
      'archivo_url': archivoUrl,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_presentacion': fechaPresentacion.toIso8601String(),
      'entregas': entregas.map((e) => e.toJson()).toList(),
      'formatoarchivo': formatoArchivo,
      'publicURL': publicURL,
      'cursoMateria': cursoMateria,
    };
  }
}
