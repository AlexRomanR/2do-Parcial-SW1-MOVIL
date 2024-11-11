class SolicitudDesafio {
  final int id;
  final int desafianteId;
  final String desafianteNombre;
  final String fechaSolicitud;
  final String mensaje;

  SolicitudDesafio({
    required this.id,
    required this.desafianteId,
    required this.desafianteNombre,
    required this.fechaSolicitud,
    required this.mensaje,
  });

  // Constructor para crear un objeto SolicitudDesafio desde un JSON
  factory SolicitudDesafio.fromJson(Map<String, dynamic> json) {
    return SolicitudDesafio(
      id: json['id'],
      desafianteId: json['desafiante_id'],
      desafianteNombre: json['desafiante_nombre'],
      fechaSolicitud: json['fecha_solicitud'],
      mensaje: json['mensaje'],
    );
  }

  // Método para convertir el objeto SolicitudDesafio a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desafiante_id': desafianteId,
      'desafiante_nombre': desafianteNombre,
      'fecha_solicitud': fechaSolicitud,
      'mensaje': mensaje,
    };
  }
}
