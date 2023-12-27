import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('logo');
    var initializationSettings = InitializationSettings(android: androidInitSettings);
    await notificationsPlugin.initialize(initializationSettings);
  }

  // Shows a notification
  Future showNotification(String title, String body) async {
    const NotificationDetails androidChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max));
    return notificationsPlugin.show(0, title, body, androidChannelSpecifics);
  }
  
}