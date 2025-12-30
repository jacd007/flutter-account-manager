import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

import '../widgets/sheets/account_selection_sheet.dart';
import '../utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LoginController(context);
    _controller.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  void _showAccountSelectionSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AccountSelectionSheet(controller: _controller),
    );

    if (result == true && _controller.savedAccounts.isEmpty && mounted) {
      AppToast.error(context, 'No quedan cuentas registradas.');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Account Manager')),
      body: _controller.isLoading ? _buildLoading() : _buildSelectionUI(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Autenticando..."),
          Text(
            "(Por favor espere)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionUI() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_balance, size: 80, color: Colors.blue),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Iniciar sesión con CUENTA NUEVA"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _showNewAccountDialog,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text("Iniciar sesión con CUENTA REGISTRADA"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
              onPressed: _showAccountSelectionSheet,
            ),
            if (_controller.useFakeAuth) ...[
              const SizedBox(height: 40),
              const Text(
                "⚠️ MODO DE PRUEBA ACTIVO ⚠️",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showNewAccountDialog() async {
    emailController.clear();
    passwordController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Cuenta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ingrese las credenciales para registrar la cuenta en el dispositivo.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                // Trigger flow for new account
                if (_controller.useFakeAuth) {
                  // Fake flow
                  _controller.handleAuthAction(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                } else {
                  // Real flow: true indicates new account flow
                  _controller.loginWithMSAL(
                    loginHint: emailController.text.trim(),
                    isNewAccount: true,
                    passwordIfNew: passwordController.text.trim(),
                  );
                }
              } else {
                AppToast.error(context, "Por favor complete los campos");
              }
            },
            child: const Text("Iniciar Sesión"),
          ),
        ],
      ),
    );
  }
}
