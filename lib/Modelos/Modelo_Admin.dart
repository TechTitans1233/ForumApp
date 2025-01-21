// Modelo_Admin.dart

class Usuario {
  final String id;
  String nome;
  String email;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
  });
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
}
