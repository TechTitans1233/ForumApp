class Usuario {
  final String id;
  String nome;
  String email;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
  });

  // Método para converter de JSON para objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
    );
  }

  // Método para converter de objeto Usuario para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }
}

class Publicacao {
  final String id;
  String titulo;
  String conteudo;

  Publicacao({
    required this.id,
    required this.titulo,
    required this.conteudo,
  });

  // Método para converter de JSON para objeto Publicacao
  factory Publicacao.fromJson(Map<String, dynamic> json) {
    return Publicacao(
      id: json['id'],
      titulo: json['titulo'],
      conteudo: json['conteudo'],
    );
  }

  // Método para converter de objeto Publicacao para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
    };
  }
}
