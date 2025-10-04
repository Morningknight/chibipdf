// lib/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _prefs;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    // Set a default theme and load the saved preference
    _themeMode = ThemeMode.system;
    _loadFromPrefs();
  }

  // Helper method to toggle the theme
  toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveToPrefs();
    notifyListeners(); // This is the crucial part that tells listeners to rebuild
  }

  // Initialize SharedPreferences
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Load the saved theme preference
  _loadFromPrefs() async {
    await _initPrefs();
    String? themeStr = _prefs!.getString(key);

    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // Default to system if nothing is saved
    }
    notifyListeners();
  }

  // Save the current theme preference
  _saveToPrefs() async {
    await _initPrefs();
    if (_themeMode == ThemeMode.light) {
      _prefs!.setString(key, 'light');
    } else {
      _prefs!.setString(key, 'dark');
    }
  }
}