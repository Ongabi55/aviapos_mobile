import '../bootstrap_context.dart';
import '../bootstrap_stage.dart';
import '../../environment/environment_config.dart';
import '../../../services/authentication/authentication_service.dart';
import '../../../services/authentication/authentication_token_store.dart';
import '../../../services/authentication/secure_authentication_token_store.dart';
import '../../../services/networking/api_client.dart';
import '../../../services/networking/authenticated_api_client.dart';
import '../../../services/networking/package_http_adapter.dart';

/// Constructs networking and authentication dependencies.
///
/// Environment configuration must already have been loaded and validated.
/// This stage does not make network requests, authenticate a user,
/// or construct merchant context.
class NetworkingBootstrapStage implements BootstrapStage {
  const NetworkingBootstrapStage();

  @override
  String get name => 'networking';

  @override
  Future<void> execute(BootstrapContext context) async {
    final environmentConfig = context.get<EnvironmentConfig>();

    if (environmentConfig == null) {
      throw StateError(
        'Validated environment configuration is required '
        'before networking bootstrap.',
      );
    }

    final adapter = PackageHttpAdapter();

    try {
      final apiClient = ApiClient(
        baseUri: Uri.parse(environmentConfig.apiBaseUrl),
        adapter: adapter,
      );

      final authenticationService = AuthenticationService(apiClient: apiClient);

      final AuthenticationTokenStore tokenStore =
          SecureAuthenticationTokenStore();

      final authenticatedApiClient = AuthenticatedApiClient(
        apiClient: apiClient,
        tokenStore: tokenStore,
      );

      context.put<PackageHttpAdapter>(adapter);
      context.put<ApiClient>(apiClient);
      context.put<AuthenticationService>(authenticationService);
      context.put<AuthenticationTokenStore>(tokenStore);
      context.put<AuthenticatedApiClient>(authenticatedApiClient);
    } catch (_) {
      adapter.close();
      rethrow;
    }
  }
}
