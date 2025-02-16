class Publicacao {
  final String id;
  String titulo;
  String conteudo;
  String usuarioId; // ID do usuário que criou a publicação

  Publicacao({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.usuarioId,
  });

  // Função para converter de Map (Firestore) para o modelo
  factory Publicacao.fromMap(Map<String, dynamic> map) {
    return Publicacao(
      id: map['id'],
      titulo: map['titulo'],
      conteudo: map['conteudo'],
      usuarioId: map['usuarioId'],
    );
  }

  // Função para converter de modelo para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'usuarioId': usuarioId,
    };
  }
}
