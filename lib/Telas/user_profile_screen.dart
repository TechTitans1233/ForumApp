import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Modelos/user_profile.dart';
import '../services/firestore_service.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _service = FirestoreService();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _service.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  void _editProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)),
    );
    if (updated != null) {
      await _service.updateUserProfile(updated);
      await _loadUserProfile();
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final profile = _profile!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editProfile),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(radius: 60, backgroundImage: NetworkImage(profile.imageUrl)),
          const SizedBox(height: 15),
          Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(profile.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Text(profile.bio),
        ],
      ),
    );
  }
}
