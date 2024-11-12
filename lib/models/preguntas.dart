import 'package:gestion_asistencia_docente/models/opciones.dart';

class Pregunta {
  final int id;
  final String texto;
  final int categoriaId;
  final String categoriaNombre;
  final List<Opcion> opciones;

  Pregunta({
    required this.id,
    required this.texto,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.opciones,
  });

  // Constructor para crear un objeto Pregunta desde un JSON
  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'],
      texto: json['texto'],
      categoriaId: json['categoria_id'],
      categoriaNombre: json['categoria_nombre'],
      opciones: List<Opcion>.from(
        json['opciones'].map((opcion) => Opcion.fromJson(opcion)),
      ),
    );
  }

  // Método para convertir el objeto Pregunta a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'categoria_id': categoriaId,
      'categoria_nombre': categoriaNombre,
      'opciones': opciones.map((opcion) => opcion.toJson()).toList(),
    };
  }
}