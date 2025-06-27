import 'package:flutter/material.dart';
import '../widgets/OAuthWebView.dart';
import '../services/UserService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      final redirectUri = dotenv.env['OAUTH_REDIRECT_URI'] ?? 'sgym://oauth-callback';
      final responseType = dotenv.env['OAUTH_RESPONSE_TYPE'] ?? 'token';
      final authBaseUrl = dotenv.env['AUTH_BASE_URL'];

      final authUrl = Uri.https(
        Uri.parse(authBaseUrl!).host,
        '/oauth/login',
        {
          'redirect_uri': redirectUri,
          'response_type': responseType,
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