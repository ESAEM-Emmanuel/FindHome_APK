// // lib/providers/settings_provider.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SettingsProvider with ChangeNotifier {
//   Locale _locale = const Locale('fr', 'FR'); // Par défaut : Français
//   ThemeMode _themeMode = ThemeMode.light; // Par défaut : Clair

//   Locale get locale => _locale;
//   ThemeMode get themeMode => _themeMode;

//   SettingsProvider() {
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Charger la langue
//     final langCode = prefs.getString('languageCode') ?? 'fr';
//     _locale = Locale(langCode);

//     // Charger le thème
//     final themeString = prefs.getString('themeMode') ?? 'light';
//     _themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

//     notifyListeners();
//   }

//   void setLocale(Locale newLocale) async {
//     if (_locale == newLocale) return;
//     _locale = newLocale;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('languageCode', newLocale.languageCode);
//     notifyListeners();
//   }

//   void setThemeMode(ThemeMode newThemeMode) async {
//     if (_themeMode == newThemeMode) return;
//     _themeMode = newThemeMode;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('themeMode', newThemeMode == ThemeMode.dark ? 'dark' : 'light');
//     notifyListeners();
//   }
// }

// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider de gestion des paramètres de l'application
/// 
/// Gère les préférences utilisateur comme la langue et le thème
/// Persiste les paramètres localement et notifie les changements
class SettingsProvider with ChangeNotifier {
  // ===========================================================================
  // CONSTANTES ET CONFIGURATION
  // ===========================================================================

  /// Langue par défaut de l'application
  static const Locale _defaultLocale = Locale('fr', 'FR');
  
  /// Thème par défaut de l'application
  static const ThemeMode _defaultThemeMode = ThemeMode.light;
  
  /// Clés pour le stockage des préférences
  static const String _languageKey = 'languageCode';
  static const String _themeKey = 'themeMode';
  
  /// Valeurs possibles pour le thème
  static const String _themeLight = 'light';
  static const String _themeDark = 'dark';

  // ===========================================================================
  // ÉTATS INTERNES
  // ===========================================================================

  /// Locale actuelle de l'application
  Locale _locale = _defaultLocale;
  
  /// Mode de thème actuel (clair/sombre/auto)
  ThemeMode _themeMode = _defaultThemeMode;

  // ===========================================================================
  // GETTERS PUBLICS
  // ===========================================================================

  /// Retourne la locale actuelle de l'application
  Locale get locale => _locale;

  /// Retourne le mode de thème actuel
  ThemeMode get themeMode => _themeMode;

  /// Retourne true si le thème sombre est activé
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Retourne le code de langue actuel (ex: 'fr', 'en')
  String get languageCode => _locale.languageCode;

  // ===========================================================================
  // INITIALISATION
  // ===========================================================================

  /// Constructeur initialisant le chargement des paramètres
  SettingsProvider() {
    _loadSettings();
  }

  // ===========================================================================
  // MÉTHODES PUBLIQUES - GESTION DE LA LANGUE
  // ===========================================================================

  /// Change la langue de l'application
  /// [newLocale] : Nouvelle locale à appliquer (ex: Locale('en', 'US'))
  Future<void> setLocale(Locale newLocale) async {
    // Éviter les mises à jour inutiles
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    
    // Persister le changement
    await _saveLanguagePreference(newLocale.languageCode);
    
    // Notifier les listeners du changement
    notifyListeners();
  }

  /// Change la langue avec seulement le code de langue
  /// [languageCode] : Code de la langue (ex: 'fr', 'en', 'es')
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Bascule entre les langues disponibles
  /// Retourne la nouvelle locale appliquée
  Future<Locale> toggleLanguage() async {
    final newLanguageCode = _locale.languageCode == 'fr' ? 'en' : 'fr';
    final newLocale = Locale(newLanguageCode);
    
    await setLocale(newLocale);
    return newLocale;
  }

  // ===========================================================================
  // MÉTHODES PUBLIQUES - GESTION DU THÈME
  // ===========================================================================

  /// Change le mode de thème de l'application
  /// [newThemeMode] : Nouveau mode de thème à appliquer
  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    // Éviter les mises à jour inutiles
    if (_themeMode == newThemeMode) return;
    
    _themeMode = newThemeMode;
    
    // Persister le changement
    await _saveThemePreference(newThemeMode);
    
    // Notifier les listeners du changement
    notifyListeners();
  }

  /// Bascule entre les modes clair et sombre
  /// Retourne le nouveau mode de thème appliqué
  Future<ThemeMode> toggleTheme() async {
    final newThemeMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    
    await setThemeMode(newThemeMode);
    return newThemeMode;
  }

  /// Définit le thème clair explicitement
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Définit le thème sombre explicitement
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Définit le thème automatique (basé sur les préférences système)
  Future<void> setAutoTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - CHARGEMENT DES PARAMÈTRES
  // ===========================================================================

  /// Charge les paramètres depuis le stockage local
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await _loadLanguage(prefs);
    await _loadTheme(prefs);
    
    // Notifier que le chargement est terminé
    notifyListeners();
  }

  /// Charge les préférences de langue
  Future<void> _loadLanguage(SharedPreferences prefs) async {
    final langCode = prefs.getString(_languageKey) ?? _defaultLocale.languageCode;
    _locale = Locale(langCode);
  }

  /// Charge les préférences de thème
  Future<void> _loadTheme(SharedPreferences prefs) async {
    final themeString = prefs.getString(_themeKey) ?? _themeLight;
    _themeMode = _parseThemeMode(themeString);
  }

  /// Parse une chaîne de caractères en ThemeMode
  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case _themeDark:
        return ThemeMode.dark;
      case _themeLight:
        return ThemeMode.light;
      default:
        return _defaultThemeMode;
    }
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - SAUVEGARDE DES PARAMÈTRES
  // ===========================================================================

  /// Sauvegarde la préférence de langue
  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Sauvegarde la préférence de thème
  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = _serializeThemeMode(themeMode);
    await prefs.setString(_themeKey, themeString);
  }

  /// Convertit un ThemeMode en chaîne de caractères pour le stockage
  String _serializeThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return _themeDark;
      case ThemeMode.light:
        return _themeLight;
      case ThemeMode.system:
        // Pour le mode système, on stocke la préférence actuelle
        return _themeLight; // ou on pourrait stocker 'system'
      default:
        return _themeLight;
    }
  }

  // ===========================================================================
  // MÉTHODES UTILITAIRES
  // ===========================================================================

  /// Réinitialise tous les paramètres aux valeurs par défaut
  Future<void> resetToDefaults() async {
    await setLocale(_defaultLocale);
    await setThemeMode(_defaultThemeMode);
  }

  /// Retourne les paramètres actuels sous forme de Map pour le débogage
  Map<String, dynamic> get debugSettings {
    return {
      'language': _locale.languageCode,
      'themeMode': _themeMode.toString(),
      'isDarkMode': isDarkMode,
    };
  }

  /// Vérifie si une locale spécifique est active
  bool isLocaleActive(Locale locale) {
    return _locale.languageCode == locale.languageCode;
  }

  /// Vérifie si un mode de thème spécifique est actif
  bool isThemeModeActive(ThemeMode themeMode) {
    return _themeMode == themeMode;
  }
}