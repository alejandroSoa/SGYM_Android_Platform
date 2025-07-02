import 'SharedPreferencesService.dart';

class InitializationService {
  static Future<bool> isFirstTimeUser() async {
    return await SharedPreferencesService.isFirstTimeUser();
  }

  static Future<bool> markFirstTimeDone() async {
    return await SharedPreferencesService.markFirstTimeDone();
  }
}