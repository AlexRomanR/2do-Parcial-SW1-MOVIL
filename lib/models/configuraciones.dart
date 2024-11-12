class Configuracion {
  final int puntos;
  final int frecuencia;

  Configuracion({
    required this.puntos,
    required this.frecuencia,
  });

  // Constructor para crear un objeto Configuracion desde un JSON
  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      puntos: json['puntos'],
      frecuencia: json['frecuencia'],
    );
  }

  // Método para convertir el objeto Configuracion a JSON (opcional)
  Map<String, dynamic> toJson() {
    return {
      'puntos': puntos,
      'frecuencia': frecuencia,
    };
  }
}
