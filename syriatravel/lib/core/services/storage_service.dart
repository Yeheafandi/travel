import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUserRole(String role) async =>
      await _prefs.setString('user_role', role);

  static Future<void> saveUserName(String name) async =>
      await _prefs.setString('user_name', name);

  static String getUserRole() => _prefs.getString('user_role') ?? "";

  static String getUserName() => _prefs.getString('user_name') ?? "";

  static bool hasRole() => getUserRole().isNotEmpty;

  static Future<void> clearAll() async => await _prefs.clear();
}
