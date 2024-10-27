import 'dart:convert';

// Funciones para decodificar y codificar JSON
User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User data) => json.encode(data.toJson());

class User {
  int id;
  String name;
  String username;
  bool isAdmin;
  String lang;
  String tz;
  String db;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.isAdmin,
    required this.lang,
    required this.tz,
    required this.db,
  });

  // Constructor a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["uid"],
      name: json["name"],
      username: json["username"],
      isAdmin: json["is_admin"],
      lang: json["user_context"]["lang"],
      tz: json["user_context"]["tz"],
      db: json["db"],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "is_admin": isAdmin,
        "lang": lang,
        "tz": tz,
        "db": db,
      };
}
