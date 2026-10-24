import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/bootstrap/bootstrap_context.dart';
import 'package:aviapos_mobile/core/bootstrap/stages/networking_bootstrap_stage.dart';
import 'package:aviapos_mobile/core/environment/environment_config.dart';
import 'package:aviapos_mobile/core/environment/runtime_environment.dart';
import 'package:aviapos_mobile/services/authentication/authentication_service.dart';
import 'package:aviapos_mobile/services/authentication/authentication_token_store.dart';
import 'package:aviapos_mobile/services/networking/api_client.dart';
import 'package:aviapos_mobile/services/networking/authenticated_api_client.dart';
import 'package:aviapos_mobile/services/networking/package_http_adapter.dart';

void main() {
  group('NetworkingBootstrapStage', () {
    test('constructs and registers networking dependencies', () async {
      final context = BootstrapContext();

      context.put<EnvironmentConfig>(
        const EnvironmentConfig(
          environment: RuntimeEnvironment.test,
          apiBaseUrl: 'http://localhost:8000',
          applicationName: 'Avia',
        ),
      );

      const stage = NetworkingBootstrapStage();

      await stage.execute(context);

      final adapter = context.get<PackageHttpAdapter>();
      final apiClient = context.get<ApiClient>();
      final authenticationService = context.get<AuthenticationService>();
      final tokenStore = context.get<AuthenticationTokenStore>();
      final authenticatedApiClient = context.get<AuthenticatedApiClient>();

      expect(adapter, isNotNull);
      expect(apiClient, isNotNull);
      expect(authenticationService, isNotNull);
      expect(tokenStore, isNotNull);
      expect(authenticatedApiClient, isNotNull);

      expect(apiClient!.baseUri, Uri.parse('http://localhost:8000'));
      expect(apiClient.adapter, same(adapter));

      expect(authenticationService!.apiClient, same(apiClient));

      expect(authenticatedApiClient!.apiClient, same(apiClient));
      expect(authenticatedApiClient.tokenStore, same(tokenStore));
    });

    test('fails when environment configuration is missing', () async {
      final context = BootstrapContext();
      const stage = NetworkingBootstrapStage();

      await expectLater(stage.execute(context), throwsA(isA<StateError>()));

      expect(context.get<ApiClient>(), isNull);
      expect(context.get<AuthenticatedApiClient>(), isNull);
    });
  });
}
