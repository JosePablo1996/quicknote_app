import 'package:flutter/material.dart';

class SnackbarUtils {
  // Snackbar de éxito
  static void showSuccessSnackbar(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  // Snackbar de error
  static void showErrorSnackbar(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  // Snackbar de información
  static void showInfoSnackbar(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  // Snackbar de advertencia
  static void showWarningSnackbar(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  // Método privado que construye el Snackbar
  static void _showSnackbar(
    BuildContext context, 
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Ocultar cualquier Snackbar existente
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Mostrar el nuevo Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        duration: duration,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}