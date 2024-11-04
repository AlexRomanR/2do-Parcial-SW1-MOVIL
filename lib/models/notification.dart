import 'dart:convert';

List<Notificaciones> notificacionesFromMap(String str) => List<Notificaciones>.from(json.decode(str).map((x) => Notificaciones.fromMap(x)));

String notificacionesToMap(List<Notificaciones> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Notificaciones {
    int id;
    String type;
    String data;
    dynamic readAt;
    int userId;

    Notificaciones({
        required this.id,
        required this.type,
        required this.data,
        required this.readAt,
        required this.userId,
    });

    factory Notificaciones.fromMap(Map<String, dynamic> json) => Notificaciones(
        id: json["id"],
        type: json["type"],
        data: json["data"],
        readAt: json["read_at"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "type": type,
        "data": data,
        "read_at": readAt,
        "user_id": userId,
    };
}
