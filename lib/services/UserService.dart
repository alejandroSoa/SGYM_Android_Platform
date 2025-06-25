import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String _tokenKey = 'oauth-token';
  static const String _baseUrl = 'https://2886-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app';

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

  // Obtiene el usuario de SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson == null) return null;
    return json.decode(userJson) as Map<String, dynamic>;
  }

  // Servicio: Obtener datos de un usuario
  static Future<Map<String, dynamic>?> fetchUser([int? userId]) async {
    final token = await getToken();
    if (token == null) return null;
  
    final url = userId != null 
        ? '$_baseUrl/users/${userId.toString()}'
        : '$_baseUrl/users';
  
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  
    if (response.statusCode == 200) {
        final userData = json.decode(response.body)['data'];
        await setUser(userData);
        return userData;
    } else {
      return null;
    }
  }


  }