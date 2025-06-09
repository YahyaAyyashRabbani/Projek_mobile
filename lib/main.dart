import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projek_prak_mobile/login.dart';
import 'package:projek_prak_mobile/model/notifikasi.dart';
import 'package:projek_prak_mobile/root_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_prak_mobile/model/user.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter()); // Register the User adapter
  Hive.registerAdapter(NotifikasiAdapter());
  await Hive.openBox('userBox'); // Open userBox to store user data

  // Inisialisasi timezone
  tz.initializeTimeZones();

  // Inisialisasi notifikasi lokal
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );

  // Request permission for iOS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Reminder',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        // Ensure that RootPage receives the username parameter
        '/root': (context) => const RootPage(username: ''),
      },
    );
  }
}
