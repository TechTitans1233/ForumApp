// TelaPublicacoes.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaPublicacoes extends StatefulWidget {
  const TelaPublicacoes({super.key});

  @override
  State<TelaPublicacoes> createState() => _TelaPublicacoesState();
}

class _TelaPublicacoesState extends State<TelaPublicacoes> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar publicação ao Firestore
  Future<void> _adicionarPublicacao() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('publicacoes').add({
      'titulo': _tituloController.text.trim(),
      'conteudo': _conteudoController.text.trim(),
      'usuarioId': user.uid,
      'dataPublicacao': FieldValue.serverTimestamp(),
    });

    _tituloController.clear();
    _conteudoController.clear();
  }

  // Buscar publicações do usuário logado
  Stream<QuerySnapshot> _obterPublicacoes() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('publicacoes')
        .where('usuarioId', isEqualTo: user.uid)
        .orderBy('dataPublicacao', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Publicações')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _conteudoController,
                  decoration: const InputDecoration(labelText: 'Conteúdo'),
                  maxLines: 5,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _adicionarPublicacao,
                  child: const Text('Publicar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _obterPublicacoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma publicação encontrada.'));
                }
                final publicacoes = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: publicacoes.length,
                  itemBuilder: (context, index) {
                    final publicacao = publicacoes[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(publicacao['titulo']),
                        subtitle: Text(publicacao['conteudo']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
