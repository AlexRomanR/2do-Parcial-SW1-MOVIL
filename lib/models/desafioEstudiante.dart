class DesafioEstudiante {
  final int desafioId;
  final int estudianteCompaneroId;
  final int companeroUserId;
  final String estudianteCompaneroNombre;
  final double puntajeCompanero;
  final double puntajeEstudiante;  

  DesafioEstudiante({
    required this.desafioId,
    required this.estudianteCompaneroId,
    required this.companeroUserId,
    required this.estudianteCompaneroNombre,
    required this.puntajeCompanero,
    required this.puntajeEstudiante,
  });

  factory DesafioEstudiante.fromJson(Map<String, dynamic> json) {
    return DesafioEstudiante(
      desafioId: json['desafio_id'],
      estudianteCompaneroId: json['estudiante_companero_id'],
      companeroUserId: json['companero_user_id'],
      estudianteCompaneroNombre: json['estudiante_companero_nombre'],
      puntajeCompanero: (json['puntaje_companero'] as num).toDouble(),
      puntajeEstudiante: (json['puntaje_estudiante'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desafio_id': desafioId,
      'estudiante_companero_id': estudianteCompaneroId,
      'companero_user_id': companeroUserId,
      'estudiante_companero_nombre': estudianteCompaneroNombre,
      'puntaje_companero': puntajeCompanero,
      'puntaje_estudiante': puntajeEstudiante,
    };
  }
}
