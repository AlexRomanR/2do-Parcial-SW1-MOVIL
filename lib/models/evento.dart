import 'dart:convert';

List<Evento> eventoFromMap(String str) => List<Evento>.from(json.decode(str).map((x) => Evento.fromMap(x)));

String eventoToMap(List<Evento> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Evento {
    int id;
    int eventoId;
    String tipo;
    String descripcion;
    bool archivoDocumento;
    String resumen;
    String fecha;
    bool leido;
    bool asistencia;
    bool confirmacion;
    int estudianteId;

    Evento({
        required this.id,
        required this.eventoId,
        required this.tipo,
        required this.descripcion,
        required this.archivoDocumento,
        required this.resumen,
        required this.fecha,
        required this.leido,
        required this.asistencia,
        required this.confirmacion,
        required this.estudianteId,
    });

    factory Evento.fromMap(Map<String, dynamic> json) => Evento(
        id: json["id"],
        eventoId: json["evento_id"],
        tipo: json["tipo"],
        descripcion: json["descripcion"],
        archivoDocumento: json["archivo_documento"],
        resumen: json["resumen"] is bool ? '' : json["resumen"], // Conversión de bool a String.
        fecha: json["fecha"],
        leido: json["leido"],
        asistencia: json["asistencia"],
        confirmacion: json["confirmacion"],
        estudianteId: json["estudiante_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "evento_id": eventoId,
        "tipo": tipo,
        "descripcion": descripcion,
        "archivo_documento": archivoDocumento,
        "resumen": resumen,
        "fecha": fecha,
        "leido": leido,
        "asistencia": asistencia,
        "confirmacion": confirmacion,
        "estudiante_id": estudianteId,
    };
}
