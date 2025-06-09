import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(String email, String pass) async {
    return await _supabase.auth.signInWithPassword(email: email, password: pass);
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String pass) async {
    return await _supabase.auth.signUp(email: email, password: pass);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

//To Show User Details
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }
}