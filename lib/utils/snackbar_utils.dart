import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class SnackBarUtils {
  /// Muestra un error simple en la UI y el detalle técnico en consola (Rojo)
  static void showError(
    BuildContext context,
    String simpleMsg, {
    String? technicalDetails,
  }) {
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

  /// Muestra un mensaje informativo de éxito (Verde)
  static void showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
}
