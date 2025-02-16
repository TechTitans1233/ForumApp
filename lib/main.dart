import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Telas/Tela_login.dart';
import 'Telas/Tela_admin.dart';
import 'Telas/Tela_publicacoes.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/',
      routes: {
        '/': (context) => const Tela_Login(),
        '/forum': (context) => const Tela_Publicacoes(),
        '/admin': (context) => const Tela_admin(),
      },
    );
  }
}
