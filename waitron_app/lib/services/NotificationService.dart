import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Class for managing notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialises the notification service for Android
  Future<void> init() async {
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('logo');
    var initializationSettings = const InitializationSettings(android: androidInitSettings);
    await notificationsPlugin.initialize(initializationSettings);
  }

  // Shows a notification
  Future showNotification(String title, String body) async {
    const NotificationDetails androidChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails('channel1', 'notification', importance: Importance.max));
    return notificationsPlugin.show(0, title, body, androidChannelSpecifics);
  }
  
}