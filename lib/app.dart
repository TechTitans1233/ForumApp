import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forumwebapp/Services/firebase_notification_service.dart';
import 'package:forumwebapp/Services/notification_service.dart';
import 'routes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    checkNotifications();
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false).initialize();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false).checkForNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Warning System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          secondary: const Color(0xFF0056B3),
        ),
        useMaterial3: true,
      ),
      routes: Routes.list,
      initialRoute: Routes.initial,
      navigatorKey: Routes.navigatorKey,
    );
  }
}