import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/user/profile_interface.dart';
import 'UserService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';

  static Future<void> setProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode({
      'user_id': profile.userId,
      'full_name': profile.fullName,
      'phone': profile.phone,
      'birth_date': profile.birthDate,
      'gender': profile.gender,
      'photo_url': profile.photoUrl,
    }));
  }

  static Future<Profile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson == null) return null;
    return Profile.fromJson(json.decode(profileJson));
  }


  static Future<Profile?> fetchProfile([int? userId]) async {
    final token = await UserService.getToken();
    final User = await UserService.getUser();

    if (token == null) return null;

    final idPath = await User?['id'];
    final url = 'https://2886-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app/users/$idPath/profile';
    //    final url = 'https://2886-2806-101e-b-bea-14c6-f2f4-c351-92f7.ngrok-free.app/users/6/profile';

    final response = await http.get(
        Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        //Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsImVtYWlsIjoidGlvLm1hbmNvLjIyMTJAZ21haWwuY29tIiwicm9sZUlkIjoxLCJpYXQiOjE3NTA4NzIyNTgsImV4cCI6MTc1MDg3NTg1OH0.73yqs-nM0M--wgJCoxM5SPXzKNaBRyRY7P8PZ1kyN0k',

        'Content-Type': 'application/json',
      },
    );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = Profile.fromJson(data['data']);
        
        return profile;
      } else {
        return null;
      }
  }
}