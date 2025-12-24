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
          _controller.useFakeAuth
              ? _buildFakeAuthWidgets()
              : _buildRealAuthWidgets(),
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

  Widget _buildRealAuthWidgets() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("Registrar como nueva cuenta"),
          value: _controller.isRegistering,
          onChanged: (val) => _controller.toggleRegistering(val ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        _buildSubmitButton(
          label: _controller.isRegistering
              ? 'Registrar y Verificar'
              : 'Iniciar Sesión Real',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildFakeAuthWidgets() {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              "⚠️ MODO DE PRUEBA ACTIVO ⚠️\n(AppConfigMainApp.useFakeAuth = true)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        _buildSubmitButton(
          label: 'Simular Inicio (PROBAR FLUJO)',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({required String label, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _controller.handleAuthAction(
          emailController.text.trim(),
          passwordController.text.trim(),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}
