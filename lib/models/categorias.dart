class Categoria {
  final int id;
  final String nombre;

  Categoria({
    required this.id,
    required this.nombre,
  });

  // Constructor para crear un objeto Categoria desde un JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  // Método para convertir el objeto Categoria a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
