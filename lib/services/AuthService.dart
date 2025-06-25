import 'package:flutter/material.dart';
import '../widgets/OAuthWebView.dart';
import '../widgets/MessageDialog.dart';
import '../services/UserService.dart';

class AuthException implements Exception {
  final String message;
  final String? details;
  
  AuthException(this.message, {this.details});
  
  @override
  String toString() {
    if (details != null) {
      return '$message\n$details';
    }
    return message;
  }
}

class AuthService {
  static Future<bool> authenticateWithOAuth(BuildContext context) async {
    try {
      final redirectUri = 'sgym://oauth-callback';
      final authUrl = Uri.https(
        '50f2-2806-267-148b-201d-a092-6159-54c-2788.ngrok-free.app',
        '/oauth/login',
        {
          'redirect_uri': redirectUri,
          'response_type': 'token',
        },
      );

      final token = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => OAuthWebView(
            authUrl: authUrl.toString(),
            redirectUri: redirectUri,
          ),
        ),
      );

      if (token == null) {
        throw AuthException("Autenticación cancelada o fallida", 
          details: "No se recibió un token de autenticación.");
      }

      UserService.setToken(token);

      return true;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException("Error de autenticación", details: e.toString());
    }
  }
  
  static Future<bool> showAuthResult(BuildContext context, bool success, {String? message, dynamic error}) async {
    String dialogMessage;
    
    if (success) {
      dialogMessage = message ?? "Autenticación completada exitosamente.";
    } else {
      if (error is AuthException) {
        dialogMessage = error.toString();
      } else if (error != null) {
        dialogMessage = "Error: $error";
      } else {
        dialogMessage = message ?? "Error desconocido durante la autenticación.";
      }
    }
    
    await MessageDialog.show(
      context: context, 
      title: success ? 'Autenticación exitosa' : 'Error de autenticación',
      message: dialogMessage,
      type: success ? MessageType.success : MessageType.error,
    );
    
    return success;
  }
}