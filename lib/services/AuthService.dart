import 'package:flutter/material.dart';
import '../widgets/OAuthWebView.dart';
import '../services/UserService.dart';
import '../services/NotificationService.dart';
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
    final redirectUri =
        dotenv.env['OAUTH_REDIRECT_URI'] ?? 'sgym://oauth-callback';
    final responseType = dotenv.env['OAUTH_RESPONSE_TYPE'] ?? 'token';
    final authBaseUrl = dotenv.env['AUTH_BASE_URL'];

    final authUrl = Uri.http(Uri.parse(authBaseUrl!).host, '/oauth/login', {
      'redirect_uri': redirectUri,
      'response_type': responseType,
    });

    final tokens = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) =>
            OAuthWebView(authUrl: authUrl.toString(), redirectUri: redirectUri),
      ),
    );

    if (tokens == null ||
        tokens['access_token'] == null ||
        tokens['access_token'].isEmpty) {
      throw AuthException("Autenticación cancelada o incompleta");
    }

    final accessToken = tokens['access_token'];
    final refreshToken = tokens['refresh_token'];

    print("[TOKEN_SET] Access token guardado correctamente. $accessToken");
    if (refreshToken != null) {
      print(
        "[REFRESH_TOKEN_SET] Refresh token guardado correctamente. $refreshToken",
      );
      UserService.setRefreshToken(refreshToken);
    }

    UserService.setToken(accessToken);

    try {
      final userData = await UserService.fetchUser();
      if (userData == null) {
        UserService.clearToken();
        throw AuthException("No se pudo obtener información del usuario.");
      }
      await UserService.setUser(userData);

      // Enviar FCM token al servidor después del login exitoso
      final userId = userData['id'];
      print('[AUTH_SERVICE] Usuario autenticado: $userId');
      if (userId != null) {
        print('[AUTH_SERVICE] Enviando FCM token para usuario ID: $userId');
        try {
          await NotificationService.sendTokenToServer(userId);
        } catch (e) {
          print('[AUTH_SERVICE] Error enviando FCM token: $e');
          // No fallar el login por error de FCM token
        }
      }

      return true;
    } catch (e) {
      print("[AUTH ERROR]: $e");
      UserService.clearAllTokens();

      if (e.toString().contains('Exception:')) {
        throw AuthException(e.toString().replaceFirst('Exception: ', ''));
      } else {
        throw AuthException("Error de autenticación. Inténtalo más tarde.");
      }
    }
  }

  static Future<void> updateToken() async {
    final refreshToken = await UserService.getRefreshToken();

    if (refreshToken == null) {
      throw AuthException("No hay refresh token disponible");
    }

    final baseUrl = dotenv.env['AUTH_BASE_URL'];
    final fullUrl = '$baseUrl/access/refresh';

    // Enviamos el refresh token en el cuerpo de la petición
    final body = {'refresh_token': refreshToken};
    final response = await NetworkService.post(fullUrl, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access_token'];
      final newRefreshToken = data['refresh_token'];

      if (newAccessToken != null) {
        await UserService.setToken(newAccessToken);
        print("[TOKEN_REFRESH] Access token actualizado correctamente");
      }

      if (newRefreshToken != null) {
        await UserService.setRefreshToken(newRefreshToken);
        print("[TOKEN_REFRESH] Refresh token actualizado correctamente");
      }
    } else {
      throw Exception("Error al actualizar token: ${response.body}");
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
        print(
          "No está permitido el acceso a la aplicación desde este dispositivo.",
        );
        throw AuthException(
          "Acceso denegado: Tu rol no tiene acceso a la aplicación desde este dispositivo.",
        );
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
      return userRoleId is int
          ? userRoleId
          : int.tryParse(userRoleId.toString());
    } catch (e) {
      print("[GET_CURRENT_ROLE] Error: $e");
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await UserService.getRefreshToken();
    } catch (e) {
      print("[GET_REFRESH_TOKEN] Error: $e");
      return null;
    }
  }
}
