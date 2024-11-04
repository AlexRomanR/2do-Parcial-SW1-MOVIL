import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fMCToken = await _firebaseMessaging.getToken();
    print('Token: $fMCToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
