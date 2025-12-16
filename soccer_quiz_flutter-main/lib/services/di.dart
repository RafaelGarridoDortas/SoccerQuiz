import 'package:http/http.dart' as http; // Import necessário
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/api/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/i_auth_repository.dart';
import '../providers/auth_provider.dart';

class ServiceContainer {
  final IAuthRepository authRepository;
  final AuthProvider authProvider;
  final ApiClient apiClient;

  ServiceContainer({
    required this.authRepository,
    required this.authProvider,
    required this.apiClient,
  });
}

Future<ServiceContainer> buildServiceContainer() async {
  final secureStorage = const FlutterSecureStorage();

  // Configurado para WEB (localhost funciona nativamente no browser)
  const baseUrl = 'http://localhost:3000'; 

  final apiClient = ApiClient(
    baseUrl: baseUrl, 
    secureStorage: secureStorage, 
    client: http.Client() // A correção do null permanece aqui
  );

  final authRepository = AuthRepository(apiClient: apiClient);
  final authProvider = AuthProvider(authRepository: authRepository);

  return ServiceContainer(
    authRepository: authRepository, 
    authProvider: authProvider, 
    apiClient: apiClient
  );
}