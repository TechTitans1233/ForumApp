import 'package:flutter/material.dart';
import 'telas/Tela_admin.dart'; // Importando a tela corretamente após a mudança de pasta

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Alertas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TelaAdmin(), // Tela inicial apontando para TelaAdmin
    );
  }
}
