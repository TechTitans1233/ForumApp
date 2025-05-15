import 'package:flutter/material.dart';
import '../Modelos/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _email, _bio, _imageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.profile.name;
    _email = widget.profile.email;
    _bio = widget.profile.bio;
    _imageUrl = widget.profile.imageUrl;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updated = UserProfile(
        uid: widget.profile.uid,
        name: _name,
        email: _email,
        bio: _bio,
        imageUrl: _imageUrl,
      );
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: "URL da imagem"),
                onSaved: (v) => _imageUrl = v ?? '',
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) => v!.isEmpty ? 'Insira seu nome' : null,
                onSaved: (v) => _name = v!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? 'Insira seu email' : null,
                onSaved: (v) => _email = v!,
              ),
              TextFormField(
                initialValue: _bio,
                decoration: const InputDecoration(labelText: "Bio"),
                onSaved: (v) => _bio = v ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
