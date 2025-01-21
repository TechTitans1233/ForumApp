class ModeloLogin {
  String email;
  String senha;

  ModeloLogin({
    required this.email,
    required this.senha,
  });

  // Método para validar o login de um usuário
  bool validarLogin() {
    // Exemplo de validação, você pode adicionar lógica real
    return email == 'user@example.com' && senha == 'userpassword';
  }
}
