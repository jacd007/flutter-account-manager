import 'package:flutter/material.dart';
import 'dart:async';

class DeleteAccountDialog extends StatefulWidget {
  final String account;
  final Future<bool> Function(String) onConfirm;

  const DeleteAccountDialog({
    super.key,
    required this.account,
    required this.onConfirm,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();

  /// Método estático para mostrar el flujo de eliminación completo
  static Future<void> show(
    BuildContext context,
    String account,
    Future<bool> Function(String) onConfirm,
  ) async {
    // 1. Primera Verificación
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la cuenta "$account"? '
          'Se borrará permanentemente de este dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'SÍ, ELIMINAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm == true && context.mounted) {
      // 2. Segunda Verificación con Contador
      final deleted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            DeleteAccountDialog(account: account, onConfirm: onConfirm),
      );

      if (deleted == true && context.mounted) {
        Navigator.pop(context, true); // Cerramos el modal (BottomSheet)
      }
    }
  }
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  int secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¡ACCIÓN IRREVERSIBLE!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Esta acción borrará la cuenta de forma definitiva.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('El botón se activará en:'),
          Text(
            secondsRemaining > 0 ? '$secondsRemaining' : 'LISTO',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: secondsRemaining > 0
              ? null
              : () async {
                  final success = await widget.onConfirm(widget.account);
                  if (mounted) {
                    Navigator.pop(
                      context,
                      success,
                    ); // Devolvemos éxito al cerrar
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'ELIMINAR PERMANENTEMENTE',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
