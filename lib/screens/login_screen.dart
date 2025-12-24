import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../routes/app_routes.dart';
import '../widgets/mark_text.dart';
import '../services/account_manager_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isRegistering = false;
  List<String> savedAccounts = [];
  final AccountManagerService accountManagerService = AccountManagerService();

  // Configuración de MSAL (Debe coincidir con Azure Portal)
  static const String _clientId = "TODO_REPLACE_WITH_CLIENT_ID";
  static const String _redirectUri =
      "msauth://com.example.flutter_account_manager/TODO_REPLACE_WITH_SIGNATURE_HASH";

  @override
  void initState() {
    super.initState();
    _loadSavedAccounts();
  }

  Future<void> _loadSavedAccounts() async {
    final accounts = await accountManagerService.getAccounts();
    setState(() {
      savedAccounts = accounts;
    });
  }

  Future<void> _handleAuthAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Ingresa tus credenciales.');
      return;
    }

    if (isRegistering) {
      await _loginWithMSAL(email, isNewAccount: true, passwordIfNew: password);
    } else {
      await _loginWithMSAL(email);
    }
  }

  Future<void> _loginWithMSAL(
    String email, {
    bool isNewAccount = false,
    String? passwordIfNew,
  }) async {
    setState(() => isLoading = true);

    try {
      // 1. Inicializar MSAL
      final pca = await SingleAccountPca.create(
        clientId: _clientId,
        androidConfig: AndroidConfig(
          configFilePath:
              "assets/auth_config.json", // Intenta leer del asset primero
          redirectUri: _redirectUri,
        ),
      );

      // 2. Intentar autenticación (Dispara flujo interactivo o MFA si es necesario)
      var result = await Future.any([
        pca.acquireToken(scopes: ["User.Read"], loginHint: email),
        Future.delayed(const Duration(minutes: 1)).then((_) => throw 'TIMEOUT'),
      ]);

      // 3. Si llega aquí, es exitoso (incluyendo MFA resuelto)
      final msEmail = result.account.username;
      final msToken = result.accessToken;

      if (isNewAccount && passwordIfNew != null) {
        final success = await accountManagerService.addAccount(
          msEmail ?? email,
          passwordIfNew,
        );
        if (!success) {
          _showError('Error al registrar en el sistema local.');
          return;
        }
      }

      if (!mounted) return;

      _showMsg('Autenticación con Microsoft Exitosa.');
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: {'message': 'Bienvenido, $msEmail', 'token': msToken},
      );
    } on PlatformException catch (e) {
      _showError(
        'Error de autenticación con Microsoft.',
        technicalDetails:
            'Msal Error: ${e.message} (${e.code}) Details: ${e.details}',
      );
    } catch (e) {
      if (e == 'TIMEOUT') {
        _showError(
          'Tiempo de espera agotado.',
          technicalDetails: 'Microsoft Auth TIMEOUT after 1 minute.',
        );
      } else {
        _showError(
          'Fallo al iniciar sesión.',
          technicalDetails: 'General Error: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
        _loadSavedAccounts();
      }
    }
  }

  void _showAccountSelectionSheet() async {
    final accounts = await accountManagerService.getAccounts();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cuentas Registradas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: accounts.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No hay cuentas registradas.'),
                            ),
                          ]
                        : accounts.map((account) {
                            return ListTile(
                              leading: const Icon(
                                Icons.account_circle,
                                color: Colors.blue,
                              ),
                              title: Text(account),
                              onTap: () {
                                Navigator.pop(context); // Close sheet
                                _loginWithMSAL(account);
                              },
                            );
                          }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showError(String simpleMsg, {String? technicalDetails}) {
    if (technicalDetails != null) {
      // \x1B[31m = Red, \x1B[0m = Reset
      developer.log(
        '\x1B[31m[AUTH ERROR] $simpleMsg | Details: $technicalDetails\x1B[0m',
        name: 'com.galaxy.auth',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(simpleMsg), backgroundColor: Colors.redAccent),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galaxy One Auth')),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Autenticando con Microsoft..."),
                  Text(
                    "(Máximo 1 minuto de espera)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.account_balance,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ingresar Credenciales:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Microsoft',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text("Registrar como nueva cuenta"),
                    value: isRegistering,
                    onChanged: (val) =>
                        setState(() => isRegistering = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleAuthAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isRegistering
                            ? 'Registrar y Verificar'
                            : 'Iniciar Sesión',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  MarkTextWidget.simple(
                    text:
                        'Ya estoy registrado, iniciar con una *cuenta registrada*',
                    textAlign: TextAlign.center,
                    onPressed: (_) {
                      if (!isLoading) _showAccountSelectionSheet();
                    },
                    styleHighlight: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    styleNormal: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
    );
  }
}
