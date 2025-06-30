import 'package:flutter/material.dart';
import '../widgets/OAuthWebView.dart';
import '../services/UserService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import 'dart:convert';

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
      final redirectUri = dotenv.env['OAUTH_REDIRECT_URI'] ?? 'sgym://oauth-callback';
      final responseType = dotenv.env['OAUTH_RESPONSE_TYPE'] ?? 'token';
      final authBaseUrl = dotenv.env['AUTH_BASE_URL'];

      final authUrl = Uri.http(
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

      print("[TOKEN_SET] Token guardado correctamente. $token");

      UserService.setToken(token);
      final userData = await UserService.fetchUser();
      if (userData == null) {
        UserService.clearToken();
        throw AuthException("Inicie sesion mas tarde.");
      }
      await UserService.setUser(userData);

      return true;
  }

  static Future<void> updateToken() async {

    final baseUrl = dotenv.env['AUTH_BASE_URL'];
    final fullUrl = '$baseUrl/access/refresh';
    
    final response = await NetworkService.post(fullUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
      } else {
        throw Exception(response.body);
      }
  }
}