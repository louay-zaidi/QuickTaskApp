import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'app_themes.dart';

class ThemeNotifier extends ChangeNotifier {
  late Box _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeNotifier() {
    _loadThemeMode();
  }

  // Load the theme mode from Hive
  void _loadThemeMode() async {
    _box = await Hive.openBox('settings');
    _isDarkMode = _box.get('isDarkMode', defaultValue: false);
    notifyListeners();
  }

  // Toggle the theme mode and save it to Hive
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _box.put('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
