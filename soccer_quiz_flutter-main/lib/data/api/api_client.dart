import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// REMOVIDO: import '../../../test/auth_service_test.dart'; (Nunca importe testes aqui)

class ApiClient {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;
  final http.Client client; // Adicionado: Armazena o cliente HTTP

  ApiClient({
    required this.baseUrl,
    required this.secureStorage,
    required this.client, // Alterado: De MockClient para http.Client genérico
  });

  // -------------------------
  // TOKEN
  // -------------------------
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return secureStorage.read(key: 'auth_token');
  }

  // -------------------------
  // HEADERS
  // -------------------------
  Future<Map<String, String>> _headers({bool authenticated = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await getToken();
      if (token != null) {
        headers['x-access-token'] = token;
      }
    }

    return headers;
  }

  // -------------------------
  // POST
  // -------------------------
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    // CORREÇÃO: Usar 'client.post' (instância) em vez de 'http.post' (estático)
    return client.post( 
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // -------------------------
  // GET (PROTEGIDO)
  // -------------------------
  Future<http.Response> get(String path) async {
    // CORREÇÃO: Usar 'client.get' (instância) em vez de 'http.get' (estático)
    return client.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(authenticated: true),
    );
  }
}