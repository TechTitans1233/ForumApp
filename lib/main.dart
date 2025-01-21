import 'package:flutter/material.dart';
import 'Telas/Tela_Login.dart';
import 'Telas/Tela_Admin.dart'; // Importando a tela administrativa

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => TelaLogin(),
        // Agora a TelaAdmin está corretamente definida
        '/admin': (context) => TelaAdmin(),
      },
    );
  }
}
