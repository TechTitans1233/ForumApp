import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Telas/Tela_Login.dart';
import 'Telas/Tela_admin.dart';
import 'Telas/TelaPublicacoes.dart'; 
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
        '/': (context) => const TelaLogin(),
        '/forum': (context) => const TelaPublicacoes(),
        '/admin': (context) => const TelaAdmin(),
      },
    );
  }
}
