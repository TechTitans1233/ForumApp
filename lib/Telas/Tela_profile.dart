import 'package:flutter/material.dart';
import 'Telas/Tela_Login.dart'; 
import 'Telas/Tela_admin.dart'; 


class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _name = "João da Silva";
  String _email = "joao.silva@email.com";
  String _bio = "Entusiasta de Flutter e desenvolvedor mobile.";
  List<String> _posts = [
    "Explorando o Flutter para construção de apps incríveis!",
    "Dicas sobre o gerenciamento de estado no Flutter.",
    "Como melhorar o desempenho em apps móveis."
  ];
  List<String> _friends = ["Maria Oliveira", "Carlos Mendes", "Fernanda Souza"];
  String _imageUrl = "https://www.w3schools.com/w3images/avatar2.png";

  // Função para editar o perfil
  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: _name,
          email: _email,
          bio: _bio,
          imageUrl: _imageUrl,
        ),
      ),
    ).then((updatedUser) {
      if (updatedUser != null) {
        setState(() {
          _name = updatedUser["name"];
          _email = updatedUser["email"];
          _bio = updatedUser["bio"];
          _imageUrl = updatedUser["imageUrl"];
        });
      }
    });
  }

  // Função para alterar a foto de perfil
  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _urlController = TextEditingController(text: _imageUrl);

        return AlertDialog(
          title: Text("Alterar Foto de Perfil"),
          content: TextField(
            controller: _urlController,
            decoration: InputDecoration(hintText: "Cole a URL da nova imagem"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _imageUrl = _urlController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Salvar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  // Função de logout
  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sair"),
          content: Text("Você tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () {
                // Redireciona para a tela de login após confirmar o logout
                Navigator.pop(context); // Fecha o diálogo
                Navigator.pop(context); // Fecha o perfil e volta para o login
              },
              child: Text("Sim"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Não"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil do Usuário"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_imageUrl),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            _name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _email,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            _bio,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            "Posts feitos por você",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          for (var post in _posts)
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(post),
              ),
            ),
          SizedBox(height: 20),
          Text(
            "Amigos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (var friend in _friends)
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_imageUrl),
              ),
              title: Text(friend),
            ),
        ],
      ),
    );
  }
}

