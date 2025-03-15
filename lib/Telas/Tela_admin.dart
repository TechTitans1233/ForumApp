import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedUserId;
  String? _selectedPostId;
  final Map<String, String> _searchQueries = {'users': '', 'posts': ''};

  Future<void> _deleteDocument(String collection, String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  void _showEditDialog(
      String collection, String id, Map<String, dynamic> data) {
    final controllers = data.map((key, value) =>
        MapEntry(key, TextEditingController(text: value.toString())));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${collection == 'users' ? 'Usuário' : 'Post'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: e.value,
                      decoration:
                          InputDecoration(labelText: _capitalize(e.key)),
                    ),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newData = collection == 'users'
                  ? {
                      'name': controllers['name']!.text,
                      'email': controllers['email']!.text
                    }
                  : {
                      'titulo': controllers['titulo']!.text,
                      'conteudo': controllers['conteudo']!.text
                    };

              await _firestore.collection(collection).doc(id).update(newData);
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // Removida a verificação mounted
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildManagementSection(
                  title: 'Gerenciar Usuários',
                  collection: 'users',
                  selectedId: _selectedUserId,
                  columns: const ['ID', 'Nome', 'Email'],
                ),
                const SizedBox(height: 20),
                _buildManagementSection(
                  title: 'Gerenciar Publicações',
                  collection: 'posts',
                  selectedId: _selectedPostId,
                  columns: const ['ID', 'Título', 'Conteúdo'],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection({
    required String title,
    required String collection,
    required String? selectedId,
    required List<String> columns,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar $title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              onChanged: (value) {
                if (mounted) {
                  // Adicionar verificação aqui
                  setState(
                      () => _searchQueries[collection] = value.toLowerCase());
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection(collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data.values.any((value) => value
                        .toString()
                        .toLowerCase()
                        .contains(_searchQueries[collection]!));
                  }).toList();

                  return _buildDataTable(
                    filteredDocs,
                    collection,
                    selectedId,
                    columns: columns,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: selectedId == null
                      ? null
                      : () async {
                          final doc = await _firestore
                              .collection(collection)
                              .doc(selectedId)
                              .get();

                          if (!mounted) return; // Verificação correta aqui

                          if (doc.exists) {
                            _showEditDialog(
                                collection, selectedId, doc.data()!);
                          }
                        },
                  child: const Text('Editar Selecionado'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: selectedId == null
                      ? null
                      : () => _deleteDocument(collection, selectedId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Excluir Selecionado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(
      List<QueryDocumentSnapshot> docs, String collection, String? selectedId,
      {required List<String> columns}) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowColor:
            WidgetStateColor.resolveWith((states) => const Color(0xFFE0F7FA)),
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DataRow(
            selected: doc.id == selectedId,
            onSelectChanged: (_) {
              if (mounted) {
                // Verificação adicionada aqui
                setState(() {
                  if (collection == 'users') {
                    _selectedUserId = doc.id;
                    _selectedPostId = null;
                  } else {
                    _selectedPostId = doc.id;
                    _selectedUserId = null;
                  }
                });
              }
            },
            cells: columns.map((col) {
              final value = col == 'ID' ? doc.id : data[col.toLowerCase()];
              return DataCell(Text(value?.toString() ?? ''));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
