import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';

class ProfileService {
  static Future<Profile?> fetchProfile([int? userId]) async {
    final token = await UserService.getToken();
    if (token == null) return null;

    final idPath = userId != null ? userId.toString() : '';
    final url = 'https://sgym-1.free.beeceptor.com/users/2/profile';

    final response = await http.get(
        Uri.parse(url),
      headers: {
        // 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

      print('DEBUG: Status de respuesta: ${response.statusCode}');
      print('DEBUG: Cuerpo de respuesta: ${response.body}');


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
              print('DEBUG: JSON parseado: $data');
        print('DEBUG: Sección data: ${data['data']}');

        final profile = Profile.fromJson(data['data']);
        
        return profile;
      } else {
        return null;
      }
  }
}