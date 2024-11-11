class Entrega {
  final int id;
  final int estudianteId;
  final String estudianteNombre;
  final String archivoNombre;
  final double puntaje;
  final DateTime fechaEntrega;
  final String urlPublica;
  final String formatoArchivo;

  Entrega({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.archivoNombre,
    required this.puntaje,
    required this.fechaEntrega,
    required this.urlPublica,
    required this.formatoArchivo,

  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      id: json['id'],
      estudianteId: json['estudiante_id'],
      estudianteNombre: json['estudiante_nombre'],
      archivoNombre: json['archivo_nombre'],
      puntaje: (json['puntaje'] as num).toDouble(),
      fechaEntrega: DateTime.parse(json['fecha_entrega']),
      urlPublica: json['url_publica'],
      formatoArchivo: json['formatoArchivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'estudiante_nombre': estudianteNombre,
      'archivo_nombre': archivoNombre,
      'puntaje': puntaje,
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'url_publica': urlPublica,
      'formatoArchivo': formatoArchivo
    };
  }
}
