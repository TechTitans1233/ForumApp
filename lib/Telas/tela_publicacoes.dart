import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forumwebapp/Services/supabase_auth_service.dart';
import 'package:forumwebapp/Services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:forumwebapp/Services/firebase_notification_service.dart';
import 'package:forumwebapp/Services/notification_service.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  //final SupabaseAuthService supabaseAuthService = SupabaseAuthService();
  final ImagePicker _picker = ImagePicker();

  File? _imagemSelecionada;
  bool _carregandoImagem = false;

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    initializeSupabase();
    checkNotifications();
    login();
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false).initialize();
  }

  initializeSupabase() async {
    await Provider.of<SupabaseService>(context, listen: false).initialize();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false).checkForNotifications();
  }

  showNotification() {
    setState(() {
      Provider.of<NotificationService>(context, listen: false).showLocalNotification(
        CustomNotification(
          id: 1,
          title: '+1',
          body: 'Adicionado',
          payload: '/forum',
        ),
      );
    });
  }

  login() async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: dotenv.env['EMAIL']!, password: dotenv.env['PASSW']!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR: $e")));
      }
      print("Login Error --> $e");
    }
  }

  // Selecionar imagem da galeria ou câmera
  Future<void> _selecionarImagem() async {
    final opcao = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, 'galeria'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    if (opcao != null) {
      final XFile? image = await _picker.pickImage(
        source: opcao == 'camera' ? ImageSource.camera : ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imagemSelecionada = File(image.path);
        });
      }
    }
  }

  // Upload da imagem para Supabase Storage
  Future<String?> _uploadImagemSupabase() async {
    if (_imagemSelecionada == null) return null;

    setState(() {
      _carregandoImagem = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return null;


      final bytes = await _imagemSelecionada!.readAsBytes();
      final fileName = 'publicacoes/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await Supabase.instance.client.storage
          .from('media') // nome do bucket no Supabase
          .uploadBinary(fileName, bytes);

      if (response.isEmpty) {
        throw Exception('Erro no upload');
      }

      // Obter URL pública da imagem
      /*final urlPublica = Supabase.instance.client.storage
          .from('media')
          .getPublicUrl(fileName);*/
      // Gerar URL assinada (válida por 1 ano)
      final urlPublica = await Supabase.instance.client.storage
          .from('media')
          .createSignedUrl(fileName, 31536000); // 1 ano em segundos

      return urlPublica;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
      );
      return null;
    } finally {
      setState(() {
        _carregandoImagem = false;
      });
    }
  }

  // Adicionar publicação ao Firestore com imagem
  Future<void> _adicionarPublicacao() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione um título')),
      );
      return;
    }

    String? urlImagem;
    if (_imagemSelecionada != null) {
      urlImagem = await _uploadImagemSupabase();
      if (urlImagem == null) return; // Erro no upload
    }

    await _firestore.collection('publicacoes').add({
      'titulo': _tituloController.text.trim(),
      'conteudo': _conteudoController.text.trim(),
      'usuarioId': user.uid,
      'dataPublicacao': FieldValue.serverTimestamp(),
      'imagemUrl': urlImagem,
    });

    _tituloController.clear();
    _conteudoController.clear();
    setState(() {
      _imagemSelecionada = null;
    });

    showNotification();
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

  Future<void> _removerPublicacao(String publicacaoId) async {
    await _firestore.collection('publicacoes').doc(publicacaoId).delete();
  }

  Future<void> _editarPublicacao(String id, String tituloAtual, String conteudoAtual) async {
    final tituloController = TextEditingController(text: tituloAtual);
    final conteudoController = TextEditingController(text: conteudoAtual);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Publicação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: conteudoController,
                decoration: const InputDecoration(labelText: 'Conteúdo'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestore.collection('publicacoes').doc(id).update({
        'titulo': tituloController.text.trim(),
        'conteudo': conteudoController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação atualizada com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Publicações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
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

                // Seção para adicionar imagem
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _selecionarImagem,
                      icon: const Icon(Icons.image),
                      label: const Text('Adicionar Imagem'),
                    ),
                    if (_imagemSelecionada != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _imagemSelecionada = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Remover imagem',
                      ),
                    ],
                  ],
                ),

                // Preview da imagem selecionada
                if (_imagemSelecionada != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imagemSelecionada!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _carregandoImagem ? null : _adicionarPublicacao,
                  child: _carregandoImagem
                      ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Publicando...'),
                    ],
                  )
                      : const Text('Publicar'),
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
                    final data = publicacao.data() as Map<String, dynamic>;
                    final imagemUrl = data['imagemUrl'] as String?;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(publicacao['titulo']),
                            subtitle: Text(publicacao['conteudo']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _editarPublicacao(
                                      publicacao.id,
                                      publicacao['titulo'],
                                      publicacao['conteudo'],
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar exclusão'),
                                        content: const Text('Tem certeza que deseja excluir esta publicação?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () => Navigator.of(context).pop(false),
                                          ),
                                          TextButton(
                                            child: const Text('Excluir'),
                                            onPressed: () => Navigator.of(context).pop(true),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      final Map<String, dynamic>? dadosPublicacao =
                                      publicacao.data() as Map<String, dynamic>?;

                                      if (dadosPublicacao != null) {
                                        await _removerPublicacao(publicacao.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Publicação removida.'),
                                            duration: const Duration(seconds: 5),
                                            action: SnackBarAction(
                                              label: 'Desfazer',
                                              onPressed: () async {
                                                await _firestore.collection('publicacoes').add({
                                                  ...dadosPublicacao,
                                                  'dataPublicacao': FieldValue.serverTimestamp(),
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Exibir imagem se existir
                          if (imagemUrl != null && imagemUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imagemUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.error, color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
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