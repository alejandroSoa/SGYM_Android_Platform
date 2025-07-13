import 'SharedPreferencesService.dart';
import 'dart:convert';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static Future<void> setToken(String token) async {
    await SharedPreferencesService.setToken(token);
  }

  static Future<String?> getToken() async {
    return await SharedPreferencesService.getToken();
  }

  static Future<void> clearToken() async {
    await SharedPreferencesService.clearToken();
  }

  static Future<void> setRefreshToken(String refreshToken) async {
    await SharedPreferencesService.setRefreshToken(refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return await SharedPreferencesService.getRefreshToken();
  }

  static Future<void> clearRefreshToken() async {
    await SharedPreferencesService.clearRefreshToken();
  }

  static Future<void> clearAllTokens() async {
    await SharedPreferencesService.clearToken();
    await SharedPreferencesService.clearRefreshToken();
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    await SharedPreferencesService.setUser(user);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    return await SharedPreferencesService.getUser();
  }

  static Future<Map<String, dynamic>?> fetchUser([int? userId]) async {
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];

    final fullUrl = userId != null
        ? '$baseUrl/users/${userId.toString()}'
        : '$baseUrl/users';

    final response = await NetworkService.get(fullUrl);
    print("[RESPONSE]: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body)['data'];

      if (responseData is List && responseData.isNotEmpty) {
        return responseData.first as Map<String, dynamic>;
      }

      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      return null;
    } else if (response.statusCode == 401) {
      final errorMessage = "Usuario no accesible desde esta plataforma";
      throw Exception(errorMessage);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUser({
    required int userId,
    String? email,
    int? roleId,
    bool? isActive,
  }) async {
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];

    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (roleId != null) body['role_id'] = roleId;
    if (isActive != null) body['is_active'] = isActive;
    final fullUrl = '$baseUrl/users/${userId.toString()}';

    final response = await NetworkService.put(fullUrl);

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }
}
