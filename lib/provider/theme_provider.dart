import 'package:classroom_app/locator.dart';
import 'package:classroom_app/theme/themes.dart';
import 'package:classroom_app/utils/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPrefs prefs = locator<SharedPrefs>();
  late Themes themes = Themes();
  ThemeProvider() {
    isDarkMode = prefs.getDarkMode() ?? false;
  }

  bool isDarkMode = true;

  ThemeData getThemeData() {
    return isDarkMode ? themes.dark : themes.light;
  }

  ThemeData getThemeLightTheme() {
    return themes.light;
  }

  ThemeData getThemeDarkTheme() {
    return themes.dark;
  }

  ThemeMode getThemeMode() {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    await prefs.setDarkMode(isDarkMode);
    notifyListeners();
  }
}
