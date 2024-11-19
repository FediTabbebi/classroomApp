import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late final SharedPreferences prefs;

  Future<SharedPreferences> init() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  bool? getBool(
    String key,
  ) =>
      prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  Future<bool> setDarkMode(bool value) async {
    bool isDarkMode = await prefs.setBool('darkMode', value);
    return isDarkMode;
  }

  bool? getDarkMode() {
    bool? isDarkMode = prefs.getBool("darkMode");
    return isDarkMode;
  }

  String? getUserId() {
    String? token = prefs.getString("userId");
    return token;
  }

  Future<void> saveUserId(String token) async {
    await prefs.setString('userId', token);
  }

  Future<void> removeUserId() async {
    await prefs.remove('userId');
  }
}
