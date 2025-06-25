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
      const redirectUri = 'sgym://oauth-callback';
      final authUrl = Uri.https(
        'c9ad-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app',
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
      return true;
    } catch (e) {
      debugPrint("Error en autenticación: $e");
      rethrow;
    }
  }
}