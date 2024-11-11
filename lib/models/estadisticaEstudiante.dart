class EstadisticaEstudiante {
  final int estudianteId;
  final String nombre;
  final int promedioDiasEntrega;
  final int promedioPuntaje;

  EstadisticaEstudiante({
    required this.estudianteId,
    required this.nombre,
    required this.promedioDiasEntrega,
    required this.promedioPuntaje,
  });


  factory EstadisticaEstudiante.fromJson(Map<String, dynamic> json) {
    return EstadisticaEstudiante(
      estudianteId: json['estudiante_id'],
      nombre: json['nombre'],
      promedioDiasEntrega: (json['promedio_dias_entrega'] as num).round(),
      promedioPuntaje: (json['promedio_puntaje'] as num).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estudiante_id': estudianteId,
      'nombre': nombre,
      'promedio_dias_entrega': promedioDiasEntrega,
      'promedio_puntaje': promedioPuntaje,
    };
  }
}
