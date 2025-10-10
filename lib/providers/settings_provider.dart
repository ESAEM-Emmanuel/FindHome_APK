// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  Locale _locale = const Locale('fr', 'FR'); // Par défaut : Français
  ThemeMode _themeMode = ThemeMode.light; // Par défaut : Clair

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Charger la langue
    final langCode = prefs.getString('languageCode') ?? 'fr';
    _locale = Locale(langCode);

    // Charger le thème
    final themeString = prefs.getString('themeMode') ?? 'light';
    _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  void setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) return;
    _themeMode = newThemeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}