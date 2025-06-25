import 'package:shared_preferences/shared_preferences.dart';

class InitializationService {
  static const String _firstInitKey = 'first-init-app';
  
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstInitKey) ?? false);
  }

  static Future<bool> markFirstTimeDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstInitKey, true);
      return true; 
    } catch (e) {
      return false;
    }
  }
}