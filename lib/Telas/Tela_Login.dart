import 'package:flutter/material.dart';
import '../Modelos/Modelo_Login.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String adminPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Login de Usuário
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login de Usuário',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite seu email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Senha'),
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007bff),
                      foregroundColor: Colors
                          .white, // Corrigido de onPrimary para foregroundColor
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Validar email e senha
                        if (email == 'user@example.com' &&
                            password == 'userpassword') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Login realizado com sucesso')));
                          Navigator.pushReplacementNamed(context, '/admin');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Email ou senha incorretos')));
                        }
                      }
                    },
                    child: Text('Entrar'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Exemplo de navegação para tela de cadastro
                      Navigator.pushNamed(context, '/cadastro');
                    },
                    child: Text('Não tem conta? Cadastre-se'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Exemplo de login administrativo
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Login Administrativo'),
                          content: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: 'Senha Administrativa'),
                            onChanged: (value) {
                              setState(() {
                                adminPassword = value;
                              });
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (adminPassword == 'admin123') {
                                  Navigator.pushReplacementNamed(
                                      context, '/admin');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Senha administrativa incorreta')));
                                }
                              },
                              child: Text('Entrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Login Administrativo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
