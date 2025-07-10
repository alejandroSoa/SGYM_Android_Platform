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

  static Future<bool> accessByRole() async {
    final allowedRoles = [3, 5, 6];
    // final allowedRoles = ["trainer", "user", "nutritionist"];
    try {
      final userData = await UserService.getUser();
      
      if (userData == null) {
        throw AuthException("Usuario no autenticado");
      }
      
      final userRoleId = userData['role_id'];
      print("[ROLE_ID]: $userRoleId");
      // final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
      // final fullUrl = '$baseUrl/roles/$userRoleId';
      // print("[ACCESS_BY_ROLE] Verificando acceso por rol: $fullUrl");
      
      // final response = await NetworkService.get(fullUrl);
      // final responseData = json.decode(response.body);
      // final roleName = responseData['name'].toString();
      // print("Response body: ${response.body}");

      if (!allowedRoles.contains(userRoleId)) {
        print("No está permitido el acceso a la aplicación desde este dispositivo.");
        throw AuthException("Acceso denegado: Tu rol no tiene acceso a la aplicación desde este dispositivo.");
      }
      
      return true;
    } catch (e) {
      print("[ACCESS_BY_ROLE] Error: $e");
      return false;
    }
  }

  static Future<int?> getCurrentUserRole() async {
    try {
      final userData = await UserService.getUser();
      if (userData == null) return null;
      
      final userRoleId = userData['role_id'];
      print("[GET_CURRENT_ROLE] Role ID: $userRoleId");
      return userRoleId is int ? userRoleId : int.tryParse(userRoleId.toString());
    } catch (e) {
      print("[GET_CURRENT_ROLE] Error: $e");
      return null;
    }
  }


}