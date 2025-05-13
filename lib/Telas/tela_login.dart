import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_admin.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showAdminLogin = false;
  bool _showRegister = false;
  String _errorMessage = '';

  Future<void> _handleUserLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists && userDoc.data()!['isAdmin'] == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TelaAdmin()));
      } else {
        Navigator.pushReplacementNamed(context, '/forum');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _getErrorMessage(e.code));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final query = await _firestore
          .collection('admin_settings')
          .where('secret_key', isEqualTo: _adminPasswordController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw FirebaseAuthException(code: 'invalid-admin-key');
      }

      final userCredential = await _auth.signInAnonymously();
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const TelaAdmin()));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _getErrorMessage(e.code));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/forum');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _getErrorMessage(e.code));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-admin-key':
        return 'Chave administrativa inválida';
      case 'user-not-found':
      case 'wrong-password':
        return 'Credenciais inválidas';
      case 'email-already-in-use':
        return 'Email já cadastrado';
      default:
        return 'Erro na autenticação';
    }
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_showAdminLogin)
            _buildAdminForm()
          else if (_showRegister)
            _buildRegisterForm()
          else
            _buildLoginForm(),
          const SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          const SizedBox(height: 20),
          _buildToggleButtons(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty ? 'Digite seu email' : null,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Senha',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) => value!.isEmpty ? 'Digite sua senha' : null,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleUserLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFF007BFF),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Entrar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Column(
      children: [
        TextFormField(
          controller: _adminPasswordController,
          decoration: const InputDecoration(
            labelText: 'Chave Administrativa',
            prefixIcon: Icon(Icons.security),
          ),
          obscureText: true,
          validator: (value) => value!.isEmpty ? 'Digite a chave' : null,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleAdminLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.red,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Acessar Painel Admin',
                    style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => value!.isEmpty ? 'Digite seu nome' : null,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value!.isEmpty ? 'Digite seu email' : null,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Senha',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
          validator: (value) => value!.isEmpty ? 'Digite sua senha' : null,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegistration,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color(0xFF00B312),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Column(
      children: [
        if (!_showAdminLogin && !_showRegister)
          TextButton(
            onPressed: () => setState(() => _showAdminLogin = true),
            child: const Text(
              'Login Administrativo',
              style: TextStyle(color: Color(0xFF007BFF)),
            ),
          ),
        if (!_showAdminLogin)
          TextButton(
            onPressed: () => setState(() {
              _showRegister = !_showRegister;
              _errorMessage = '';
            }),
            child: Text(
              _showRegister ? 'Já tem uma conta? Entrar' : 'Criar nova conta',
              style: const TextStyle(color: Color(0xFF007BFF)),
            ),
          ),
        if (_showAdminLogin)
          TextButton(
            onPressed: () => setState(() => _showAdminLogin = false),
            child: const Text(
              'Voltar ao login comum',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: const Text('Login', style: TextStyle(color: Colors.white)),
              centerTitle: true,
            ),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(25),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(
                        _showAdminLogin
                            ? 'Acesso Administrativo'
                            : _showRegister
                                ? 'Criar Conta'
                                : 'Bem-vindo',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildAuthForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }
}
