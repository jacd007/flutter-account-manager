import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../widgets/mark_text.dart';
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
      SnackBarUtils.showError(context, 'No quedan cuentas registradas.');
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
      appBar: AppBar(title: const Text('Galaxy One Auth')),
      body: _controller.isLoading ? _buildLoading() : _buildLoginForm(),
    );
  }

  Widget _buildLoading() {
    return const Center(
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
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.account_balance, size: 60, color: Colors.blue),
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
            value: _controller.isRegistering,
            onChanged: (val) => _controller.toggleRegistering(val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _controller.handleAuthAction(
                emailController.text.trim(),
                passwordController.text.trim(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _controller.isRegistering
                    ? 'Registrar y Verificar'
                    : 'Iniciar Sesión',
              ),
            ),
          ),
          const SizedBox(height: 30),
          MarkTextWidget.simple(
            text: 'Ya estoy registrado, iniciar con una *cuenta registrada*',
            textAlign: TextAlign.center,
            onPressed: (_) {
              if (!_controller.isLoading) _showAccountSelectionSheet();
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
    );
  }
}
