import 'package:flutter/material.dart';
import 'Telas/Tela_Login.dart';
import 'Telas/Tela_admin.dart'; // Importando a tela administrativa


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF007bff),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: UserProfile(),  // Página inicial agora é o perfil do usuário
    );
  }
}

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
  String _imageUrl = "https://www.w3schools.com/w3images/avatar2.png"; // Imagem fictícia

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TelaLogin()),
                );
              },
              child: Text("Sim"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
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
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blue, // Caixa azul
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Perfil do Usuário",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,  // Botão de sair
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
                child: _imageUrl == "https://www.w3schools.com/w3images/avatar2.png"
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white) 
                    : null,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          SizedBox(height: 10),
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

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String bio;
  final String imageUrl;

  EditProfilePage({
    required this.name,
    required this.email,
    required this.bio,
    required this.imageUrl,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _bio;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _bio = widget.bio;
    _imageUrl = widget.imageUrl;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        "name": _name,
        "email": _email,
        "bio": _bio,
        "imageUrl": _imageUrl,
      });
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Foto de Perfil"),
              TextFormField(
                initialValue: _imageUrl,
                decoration: InputDecoration(hintText: "URL da imagem de perfil"),
                onSaved: (value) => _imageUrl = value!,
                validator: (value) {
                  if (value == null  value.isEmpty) {
                    return 'Por favor, insira a URL da foto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              Text("Nome"),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(hintText: "Digite seu nome"),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null  value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              Text("Email"),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(hintText: "Digite seu email"),
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              Text("Bio"),
              TextFormField(
                initialValue: _bio,
                decoration: InputDecoration(hintText: "Escreva algo sobre você"),
                onSaved: (value) => _bio = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TelaLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(child: Text("Tela de Login (simulada)")),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;  // Exemplo: Controle do modo escuro
  bool _notificationsEnabled = true;  // Controle de notificações

  // Função para salvar as configurações
  void _saveSettings() {
    // FUTURO:
    // salvar as configurações localmente ou em algum banco de dados
    Navigator.pop(context); // Volta para a tela anterior
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Alternar entre modo escuro e claro
            SwitchListTile(
              title: Text("Modo Escuro"),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            // Alternar notificações
            SwitchListTile(
              title: Text("Notificações"),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text("Salvar Configurações"),
            ),
          ],
        ),
      ),
    );
  }
}
