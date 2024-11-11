class Resultado {
  final int puntosGanados;
  final int puntosPerdidos;

  Resultado({
    required this.puntosGanados,
    required this.puntosPerdidos,
  });

  // Constructor para crear un objeto Resultado desde un JSON
  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      puntosGanados: json['puntos_ganados'],
      puntosPerdidos: json['puntos_perdidos'],
    );
  }

  // Método para convertir el objeto Resultado a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'puntos_ganados': puntosGanados,
      'puntos_perdidos': puntosPerdidos,
    };
  }
}
