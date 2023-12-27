import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:waitron_app/screens/HomePage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:waitron_app/services/NotificationService.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}