import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'oauth-token';
  static const String _refreshTokenKey = 'oauth-refresh-token';
  
  static Future<bool> authenticateWithOAuth() async {
    try {
      final result = await FlutterWebAuth.authenticate(
        url: "https://tu-oauth-provider.com/auth",
        callbackUrlScheme: "sgym"
      );

      final token = Uri.parse(result).queryParameters['token'];
      final refreshToken = Uri.parse(result).queryParameters['refresh_token'];

      if (token != null && refreshToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_refreshTokenKey, refreshToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }
}