import 'dart:convert';
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';

class ProfileService {

  static Future<Profile?> fetchProfile([int? userId]) async {
    final User = await UserService.getUser();

    final idPath = await User?['id'];
    final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
    final fullUrl = '$baseUrl/users/$idPath/profile';
    
    final response = await NetworkService.get(fullUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = Profile.fromJson(data['data']);
        
        return profile;
      } else {
        return null;
      }
  }

    //Probar funcionalidad
    static Future<Profile?> createProfile({
      required int userId,
      required String fullName,
      required String phone,
      required String birthDate,
      required String gender,
      String? photoUrl,
    }) async {

      final baseUrl = dotenv.env['BUSINESS_BASE_URL'];
      final fullUrl = '$baseUrl/users/profile';

      final body = {
        'user_id': userId,
        'full_name': fullName,
        'phone': phone,
        'birth_date': birthDate,
        'gender': gender,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

      final response = await NetworkService.post(fullUrl, body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Profile.fromJson(data['data']);
      } else {
        return null;
      }
  }
}