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
  final secureStorage = FlutterSecureStorage();

  // URL Mágica para o Emulador Android acessar o localhost da máquina
  // Se for rodar na Web ou iOS, use 'http://localhost:3000'
  const baseUrl = 'http://10.0.2.2:3000'; 

  final apiClient = ApiClient(baseUrl: baseUrl, secureStorage: secureStorage);
  final authRepository = AuthRepository(apiClient: apiClient);
  final authProvider = AuthProvider(authRepository: authRepository);

  return ServiceContainer(
    authRepository: authRepository, 
    authProvider: authProvider, 
    apiClient: apiClient
  );
}