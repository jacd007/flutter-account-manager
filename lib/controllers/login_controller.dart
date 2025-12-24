import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/services.dart';
import '../services/account_manager_service.dart';
import '../routes/app_routes.dart';
import '../utils/snackbar_utils.dart';

class LoginController extends ChangeNotifier {
  final BuildContext context;
  final AccountManagerService _accountService = AccountManagerService();

  // Estado
  bool isLoading = false;
  bool isRegistering = false;
  List<String> savedAccounts = [];

  // Configuración MSAL
  static const String _clientId = "TODO_REPLACE_WITH_CLIENT_ID";
  static const String _redirectUri =
      "msauth://com.example.flutter_account_manager/TODO_REPLACE_WITH_SIGNATURE_HASH";

  LoginController(this.context) {
    _loadSavedAccounts();
  }

  void toggleRegistering(bool value) {
    isRegistering = value;
    notifyListeners();
  }

  Future<void> _loadSavedAccounts() async {
    savedAccounts = await _accountService.getAccounts();
    notifyListeners();
  }

  Future<void> handleAuthAction(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      SnackBarUtils.showError(context, 'Ingresa tus credenciales.');
      return;
    }

    if (isRegistering) {
      await loginWithMSAL(email, isNewAccount: true, passwordIfNew: password);
    } else {
      await loginWithMSAL(email);
    }
  }

  Future<void> loginWithMSAL(
    String email, {
    bool isNewAccount = false,
    String? passwordIfNew,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final pca = await SingleAccountPca.create(
        clientId: _clientId,
        androidConfig: AndroidConfig(
          configFilePath: "assets/auth_config.json",
          redirectUri: _redirectUri,
        ),
      );

      final result = await Future.any([
        pca.acquireToken(scopes: ["User.Read"], loginHint: email),
        Future.delayed(const Duration(minutes: 1)).then((_) => throw 'TIMEOUT'),
      ]);

      final msEmail = result.account.username;
      final msToken = result.accessToken;

      if (isNewAccount && passwordIfNew != null) {
        final success = await _accountService.addAccount(
          msEmail ?? email,
          passwordIfNew,
        );
        if (!success) {
          SnackBarUtils.showError(context, 'Error al registrar localmente.');
          return;
        }
      }

      SnackBarUtils.showSuccess(context, 'Autenticación Exitosa.');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: {'message': 'Bienvenido, $msEmail', 'token': msToken},
      );
    } on PlatformException catch (e) {
      SnackBarUtils.showError(
        context,
        'Error de Microsoft.',
        technicalDetails: 'Msal: ${e.message} (${e.code})',
      );
    } catch (e) {
      if (e == 'TIMEOUT') {
        SnackBarUtils.showError(
          context,
          'Tiempo agotado.',
          technicalDetails: 'MSAL Timeout 1min',
        );
      } else {
        SnackBarUtils.showError(
          context,
          'Fallo al iniciar sesión.',
          technicalDetails: '$e',
        );
      }
    } finally {
      isLoading = false;
      _loadSavedAccounts();
      notifyListeners();
    }
  }

  Future<bool> removeAccount(String username) async {
    final success = await _accountService.removeAccount(username);
    if (success) {
      _loadSavedAccounts();
    }
    return success;
  }
}
