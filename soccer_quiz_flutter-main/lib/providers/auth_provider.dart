import 'package:flutter/material.dart';
import '../domain/i_auth_repository.dart';

enum AuthState { idle, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final IAuthRepository authRepository;
  AuthProvider({required this.authRepository});

  AuthState state = AuthState.idle;
  String? error;
  Map<String, dynamic>? user;

  // ----------------------------------
  // CHECK AUTH (APP START)
  // ----------------------------------
  Future<void> checkAuth() async {
    state = AuthState.loading;
    error = null;
    notifyListeners();

    try {
      final logged = await authRepository.isLoggedIn();

      if (logged) {
        // 🔥 fetchProfile SÓ é chamado se houver token salvo
        user = await authRepository.fetchProfile();
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      state = AuthState.error;
      error = e.toString();
    }

    notifyListeners();
  }

  // ----------------------------------
  // LOGIN (CORRIGIDO)
  // ----------------------------------
  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    error = null;
    notifyListeners();

    try {
      // 1️⃣ Faz login (backend retorna token)
      await authRepository.login(email, password);

      // 2️⃣ Garante que o token existe antes de chamar rota protegida
      final logged = await authRepository.isLoggedIn();
      if (!logged) {
        throw Exception('Token não encontrado após login');
      }

      // 3️⃣ Agora sim chama rota protegida (/user/me)
      user = await authRepository.fetchProfile();

      state = AuthState.authenticated;
    } catch (e) {
      state = AuthState.error;
      error = e.toString();
    }

    notifyListeners();
  }

  // ----------------------------------
  // LOGOUT
  // ----------------------------------
  Future<void> logout() async {
    await authRepository.logout();
    user = null;
    state = AuthState.unauthenticated;
    notifyListeners();
  }
}
