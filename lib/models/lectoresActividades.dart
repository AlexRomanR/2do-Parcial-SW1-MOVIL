class LectorActividad {
  final int usuarioId;
  final String nombre;
  final bool leido;
  final bool enviado;

  LectorActividad({
    required this.usuarioId,
    required this.nombre,
    required this.leido,
    required this.enviado,
  });

  // Constructor para crear un objeto LectorActividad desde un JSON
  factory LectorActividad.fromJson(Map<String, dynamic> json) {
    return LectorActividad(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      leido: json['leido'],
      enviado: json['enviado'],
    );
  }

  // Método para convertir el objeto LectorActividad a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'leido': leido,
      'enviado': enviado,
    };
  }
}
