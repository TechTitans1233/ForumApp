import 'package:flutter/material.dart';
import '../Modelos/Modelo_Admin.dart'; // Atualizando o caminho para importar o modelo

// Serviço para gerenciar os usuários e publicações
class BancoDeDados {
  List<Usuario> usuarios = [];
  List<Publicacao> publicacoes = [];

  // Função para adicionar usuário
  void adicionarUsuario(String nome, String email) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    usuarios.add(Usuario(id: id, nome: nome, email: email));
  }

  // Função para editar usuário
  void editarUsuario(String id, String nome, String email) {
    final usuario = usuarios.firstWhere((u) => u.id == id);
    usuario.nome = nome;
    usuario.email = email;
  }

  // Função para excluir usuário
  void excluirUsuario(String id) {
    usuarios.removeWhere((u) => u.id == id);
  }

  // Função para adicionar publicação
  void adicionarPublicacao(String titulo, String conteudo) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    publicacoes.add(Publicacao(id: id, titulo: titulo, conteudo: conteudo));
  }

  // Função para editar publicação
  void editarPublicacao(String id, String titulo, String conteudo) {
    final publicacao = publicacoes.firstWhere((p) => p.id == id);
    publicacao.titulo = titulo;
    publicacao.conteudo = conteudo;
  }

  // Função para excluir publicação
  void excluirPublicacao(String id) {
    publicacoes.removeWhere((p) => p.id == id);
  }

  // Funções para buscar todos os usuários e publicações
  List<Usuario> buscarUsuarios() {
    return usuarios;
  }

  List<Publicacao> buscarPublicacoes() {
    return publicacoes;
  }
}

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  _TelaAdminState createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final BancoDeDados bancoDeDados = BancoDeDados();

  // Função para listar usuários e publicações
  void listarUsuarios() {
    setState(() {
      bancoDeDados.adicionarUsuario("João", "joao@teste.com");
      bancoDeDados.adicionarUsuario("Maria", "maria@teste.com");
    });
  }

  void listarPublicacoes() {
    setState(() {
      bancoDeDados.adicionarPublicacao(
          "Alerta de Tsunami", "Tsunami iminente em X região");
      bancoDeDados.adicionarPublicacao(
          "Alerta de Terremoto", "Terremoto de magnitude 7.0 em Y região");
    });
  }

  @override
  void initState() {
    super.initState();
    listarUsuarios();
    listarPublicacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seção de Usuários
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Gerenciar Usuários", style: TextStyle(fontSize: 20)),
            ),
            // Exibindo a lista de usuários
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bancoDeDados.buscarUsuarios().length,
              itemBuilder: (context, index) {
                final usuario = bancoDeDados.buscarUsuarios()[index];
                return ListTile(
                  title: Text(usuario.nome),
                  subtitle: Text(usuario.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Função de editar usuário
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            bancoDeDados.excluirUsuario(usuario.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Seção de Publicações
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text("Gerenciar Publicações", style: TextStyle(fontSize: 20)),
            ),
            // Exibindo a lista de publicações
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bancoDeDados.buscarPublicacoes().length,
              itemBuilder: (context, index) {
                final publicacao = bancoDeDados.buscarPublicacoes()[index];
                return ListTile(
                  title: Text(publicacao.titulo),
                  subtitle: Text(publicacao.conteudo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Função de editar publicação
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            bancoDeDados.excluirPublicacao(publicacao.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
