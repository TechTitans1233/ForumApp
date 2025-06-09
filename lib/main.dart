import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Services/supabase_service.dart';
import 'app.dart';
import 'package:forumwebapp/Services/notification_service.dart';
import 'package:forumwebapp/Services/firebase_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
          create: (context) => NotificationService(),
        ),
        Provider<SupabaseService>(
          create: (context) => SupabaseService(),
        ),
        Provider<FirebaseMessagingService>(
          create: (context) => FirebaseMessagingService(context.read<NotificationService>()),
        ),
      ],
      child: const App(),
    ),
  );
}