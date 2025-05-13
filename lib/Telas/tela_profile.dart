import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007bff),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: const UserProfile(),
    );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _name = "João da Silva";
  String _email = "joao.silva@email.com";
  String _bio = "Entusiasta de Flutter e desenvolvedor mobile.";
  final List<String> _posts = [
    "Explorando o Flutter para construção de apps incríveis!",
    "Dicas sobre o gerenciamento de estado no Flutter.",
    "Como melhorar o desempenho em apps móveis."
  ];
  final List<String> _friends = [
    "Maria Oliveira",
    "Carlos Mendes",
    "Fernanda Souza"
  ];
  String _imageUrl = "https://www.w3schools.com/w3images/avatar2.png";

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          key: const Key('edit_profile'),
          name: _name,
          email: _email,
          bio: _bio,
          imageUrl: _imageUrl,
        ),
      ),
    ).then((updatedUser) {
      if (updatedUser != null && mounted) {
        setState(() {
          _name = updatedUser["name"];
          _email = updatedUser["email"];
          _bio = updatedUser["bio"];
          _imageUrl = updatedUser["imageUrl"];
        });
      }
    });
  }

  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final urlController = TextEditingController(text: _imageUrl);
        return AlertDialog(
          title: const Text("Alterar Foto de Perfil"),
          content: TextField(
            controller: urlController,
            decoration:
                const InputDecoration(hintText: "Cole a URL da nova imagem"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _imageUrl = urlController.text;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sair"),
          content: const Text("Você tem certeza que deseja sair?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await FirebaseAuth.instance.signOut();

                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: const Text("Sim"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Não"),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Perfil do Usuário",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const Key('edit_button'),
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
          IconButton(
            key: const Key('logout_button'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_imageUrl),
                child: _imageUrl ==
                        "https://www.w3schools.com/w3images/avatar2.png"
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            _bio,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            "Posts feitos por você",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (var post in _posts)
            Card(
              key: Key('post_${_posts.indexOf(post)}'),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(post),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            "Amigos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (var friend in _friends)
            ListTile(
              key: Key('friend_${_friends.indexOf(friend)}'),
              leading: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                    "https://www.w3schools.com/w3images/avatar2.png"),
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

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.bio,
    required this.imageUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
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
      if (mounted) {
        Navigator.pop(context, {
          "name": _name,
          "email": _email,
          "bio": _bio,
          "imageUrl": _imageUrl,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Foto de Perfil"),
              TextFormField(
                initialValue: _imageUrl,
                decoration:
                    const InputDecoration(hintText: "URL da imagem de perfil"),
                onSaved: (value) => _imageUrl = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a URL da foto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Nome"),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(hintText: "Digite seu nome"),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Email"),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(hintText: "Digite seu email"),
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Bio"),
              TextFormField(
                initialValue: _bio,
                decoration:
                    const InputDecoration(hintText: "Escreva algo sobre você"),
                onSaved: (value) => _bio = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  void _saveSettings() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Modo Escuro"),
              value: _isDarkMode,
              onChanged: (bool value) => setState(() => _isDarkMode = value),
            ),
            SwitchListTile(
              title: const Text("Notificações"),
              value: _notificationsEnabled,
              onChanged: (bool value) =>
                  setState(() => _notificationsEnabled = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Salvar Configurações"),
            ),
          ],
        ),
      ),
    );
  }
}
