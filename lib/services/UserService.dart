import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../network/NetworkService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static const String _tokenKey = 'oauth-token';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;
    return json.decode(userJson) as Map<String, dynamic>?;
  }

static Future<Map<String, dynamic>?> fetchUser([int? userId]) async {
  final baseUrl = dotenv.env['BUSINESS_BASE_URL'];

    final fullUrl = userId != null 
        ? '$baseUrl/users/${userId.toString()}'
        : '$baseUrl/users';

    final response = await NetworkService.get(fullUrl);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body)['data'];
      
      if (responseData is List && responseData.isNotEmpty) {
        return responseData.first as Map<String, dynamic>;
      }
      
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      
      return null;
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
    final fullUrl ='$baseUrl/users/${userId.toString()}';

    final response = await NetworkService.put(fullUrl);

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      return null;
    }
  }


  }