import 'package:flutter/material.dart';
import '../Modelos/Modelo_Admin.dart';

class TelaAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administração"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserManagementSection(context),
            _buildPostManagementSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementSection(BuildContext context) {
    return SectionWidget(
      title: 'Gerenciar Usuários',
      tableHeaders: ['ID', 'Nome', 'Email'],
      fetchData: fetchUsers, // Função para buscar dados de usuários
    );
  }

  Widget _buildPostManagementSection(BuildContext context) {
    return SectionWidget(
      title: 'Gerenciar Publicações',
      tableHeaders: ['ID', 'Título', 'Conteúdo'],
      fetchData: fetchPosts, // Função para buscar dados de publicações
    );
  }

  Future<List<Usuario>> fetchUsers() async {
    // Simulação de dados, substitua por chamada ao Firebase ou API
    return [
      Usuario(id: '1', nome: 'João', email: 'joao@exemplo.com'),
      Usuario(id: '2', nome: 'Maria', email: 'maria@exemplo.com'),
    ];
  }

  Future<List<Publicacao>> fetchPosts() async {
    // Simulação de dados, substitua por chamada ao Firebase ou API
    return [
      Publicacao(
          id: '1',
          titulo: 'Publicação 1',
          conteudo: 'Conteúdo da publicação 1'),
      Publicacao(
          id: '2',
          titulo: 'Publicação 2',
          conteudo: 'Conteúdo da publicação 2'),
    ];
  }
}

// Widget para criar a estrutura da seção com tabelas
class SectionWidget extends StatelessWidget {
  final String title;
  final List<String> tableHeaders;
  final Future<List<dynamic>> Function() fetchData;

  SectionWidget({
    required this.title,
    required this.tableHeaders,
    required this.fetchData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        FutureBuilder<List<dynamic>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text("Nenhum dado encontrado.");
            }

            final data = snapshot.data!;
            return DataTable(
              columns: tableHeaders
                  .map((header) => DataColumn(label: Text(header)))
                  .toList(),
              rows: data.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.id)),
                  // Verifique se o item é do tipo Usuario ou Publicacao
                  DataCell(Text(item is Usuario ? item.nome : item.titulo)),
                  DataCell(Text(item is Usuario ? item.email : item.conteudo)),
                ]);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
