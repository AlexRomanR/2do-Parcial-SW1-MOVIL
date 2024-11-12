class Curso {
  final int id;
  final String displayName;
  final int curso;
  final String paralelo;

  Curso({
    required this.id,
    required this.displayName,
    required this.curso,
    required this.paralelo,
  });

  // Constructor para crear un objeto Curso desde un JSON
  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'],
      displayName: json['display_name'],
      curso: json['curso'],
      paralelo: json['paralelo'],
    );
  }

  // Método para convertir el objeto Curso a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'curso': curso,
      'paralelo': paralelo,
    };
  }
}
