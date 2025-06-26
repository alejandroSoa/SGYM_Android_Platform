import 'package:flutter/material.dart';
import '../widgets/OAuthWebView.dart';
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
      const redirectUri = 'sgym://oauth-callback';
      final authUrl = Uri.https(
        'c914-2806-267-1482-1823-b83b-4950-e233-f123.ngrok-free.app',
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

      if (token == null || token.isEmpty) {
        throw AuthException("Autenticación cancelada o incompleta");
      }

      UserService.setToken(token);
      final userData = await UserService.fetchUser();
      if (userData == null) {
        UserService.clearToken();
        throw AuthException("Error al obtener informacion,. \nInicie sesion nuevamente.");
      }
      await UserService.setUser(userData);

      return true;
    } catch (e) {
      throw AuthException("Error en autenticación");
    }
  }
}