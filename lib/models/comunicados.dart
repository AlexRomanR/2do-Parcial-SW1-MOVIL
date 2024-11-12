class Comunicado {
  final int id;
  final String motivo;
  final String texto;
  final String archivoUrl;
  final String? administrativo;
  final DateTime fechaCreacion;
  final List<String> roles; 
  final List<String> cursos; 
  final String formatoarchivo;
  final String publicURL;


  Comunicado({
    required this.id,
    required this.motivo,
    required this.texto,
    required this.archivoUrl,
    this.administrativo,
    required this.fechaCreacion,
    required this.roles,
    required this.cursos,
    required this.formatoarchivo,
    required this.publicURL,
  });

  // Factory constructor para crear un objeto Comunicado a partir de un JSON
  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      id: json['id'],
      motivo: json['motivo'],
      texto: json['texto'],
      archivoUrl: json['archivo_url'],
      administrativo: json['administrativo'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [], // Manejo de null en roles
      cursos: json['cursos'] != null ? List<String>.from(json['cursos']) : [], // Manejo de null en roles
      formatoarchivo: json['formatoarchivo'],
      publicURL: json['publicURL'] is String ? json['publicURL'] : '',

    );
  }

  // Método para convertir el objeto Comunicado a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivo': motivo,
      'texto': texto,
      'archivo_url': archivoUrl,
      'administrativo': administrativo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'roles': roles, 
      'cursos': cursos, 
      'formatoarchivo': formatoarchivo,
      'publicURL': publicURL,
    };
  }
}
