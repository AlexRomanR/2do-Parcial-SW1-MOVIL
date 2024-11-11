class LectorComunicado {
  final int usuarioId;
  final String nombre;
  final bool leido;
  final bool enviado;

  LectorComunicado({
    required this.usuarioId,
    required this.nombre,
    required this.leido,
    required this.enviado,
  });

  // Constructor para crear un objeto LectorComunicado desde un JSON
  factory LectorComunicado.fromJson(Map<String, dynamic> json) {
    return LectorComunicado(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      leido: json['leido'],
      enviado: json['enviado'],
    );
  }

  // Método para convertir el objeto LectorComunicado a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'nombre': nombre,
      'leido': leido,
      'enviado': enviado,
    };
  }
}
