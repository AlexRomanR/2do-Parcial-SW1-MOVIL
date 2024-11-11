
class Opcion {
  final int id;
  final String texto;
  final bool isCorrect;

  Opcion({
    required this.id,
    required this.texto,
    required this.isCorrect,
  });

  // Constructor para crear un objeto Opcion desde un JSON
  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      id: json['id'],
      texto: json['texto'],
      isCorrect: json['is_correct'],
    );
  }

  // Método para convertir el objeto Opcion a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'is_correct': isCorrect,
    };
  }
}