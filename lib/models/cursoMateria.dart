class CursoMateria {
  final int id;
  final String curso;
  final String materia;
  final String? name;
  final String nombre;

  CursoMateria({
    required this.id,
    required this.curso,
    required this.materia,
    this.name,
    required this.nombre,
  });

  // Constructor para crear un objeto CursoMateria desde un JSON
  factory CursoMateria.fromJson(Map<String, dynamic> json) {
    return CursoMateria(
      id: json['id'],
      curso: json['curso'],
      materia: json['materia'],
      name: json['name'] ?? '',
      nombre: json['nombre'],
    );
  }

  // Método para convertir el objeto CursoMateria a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'curso': curso,
      'materia': materia,
      'name': name ?? '',
      'nombre': nombre,
    };
  }
}
