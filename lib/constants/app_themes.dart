
// // lib/constants/app_themes.dart
// import 'package:flutter/material.dart';

// // Palette 2025
// const Color primaryColor1       = Color(0xFF3084F2);
// const Color accentColor1        = Color(0xFFF05524);
// const Color successColor1       = Color.fromARGB(255, 5, 242, 131);
// const Color errorColor1         = Color.fromARGB(255, 243, 20, 20);
// const Color warningColor1       = Color.fromARGB(255, 248, 139, 106);
// const Color infoColor1          = Color(0xFF3084F2); // Nouvelle couleur info

// class AppThemes {
//   static final ThemeData lightTheme = ThemeData(
//     primaryColor: primaryColor1,
//     scaffoldBackgroundColor: Colors.grey[50],
//     useMaterial3: true,
//     fontFamily: 'Roboto',
//     colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
//         .copyWith(
//           secondary: accentColor1,
//           background: Colors.grey[50],
//           brightness: Brightness.light,
//         ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryColor1,
//       elevation: 0,
//       titleTextStyle: TextStyle(
//         color: Colors.white,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: accentColor1,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       filled: true,
//       fillColor: const Color(0xFFF1F5FF),
//     ),
//   );

//   static final ThemeData darkTheme = ThemeData(
//     primaryColor: primaryColor1,
//     scaffoldBackgroundColor: const Color(0xFF0D0D0D),
//     useMaterial3: true,
//     fontFamily: 'Roboto',
//     colorScheme: ColorScheme.fromSwatch(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//       ).copyWith(
//         secondary: accentColor1,
//         background: const Color(0xFF0D0D0D),
//       ),
//     appBarTheme: AppBarTheme(
//       backgroundColor: Colors.grey[850],
//       elevation: 0,
//       titleTextStyle: const TextStyle(
//         color: Colors.white,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//       iconTheme: const IconThemeData(color: Colors.white),
//     ),
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: accentColor1,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       filled: true,
//       fillColor: Colors.grey[850],
//       labelStyle: const TextStyle(color: Colors.white70),
//     ),
//   );

//   // Méthodes utilitaires pour accéder aux couleurs depuis n'importe où
//   static Color getSuccessColor(BuildContext context) => successColor1;
//   static Color getErrorColor(BuildContext context) => errorColor1;
//   static Color getWarningColor(BuildContext context) => warningColor1;
//   static Color getCertifiedColor(BuildContext context) => successColor1;
//   static Color getInfoColor(BuildContext context) => infoColor1;
// }
// lib/constants/app_themes.dart
import 'package:flutter/material.dart';

// =============================================================================
// PALETTE DE COULEURS 2025
// =============================================================================

/// Couleur primaire principale de l'application - Bleu moderne
const Color primaryColor1 = Color(0xFF0175C2);

/// Couleur d'accent - Orange vif pour les actions et éléments importants
const Color accentColor1 = Color(0xFFFF6600);

/// Couleur de succès - Vert pour les confirmations et états positifs
const Color successColor1 = Color.fromARGB(255, 5, 242, 131);

/// Couleur d'erreur - Rouge pour les alertes et états négatifs
const Color errorColor1 = Color.fromARGB(255, 243, 51, 51);

/// Couleur d'avertissement - Orange clair pour les avertissements
const Color warningColor1 = Color.fromARGB(255, 248, 139, 106);

/// Couleur d'information - Bleu pour les informations et états neutres
const Color infoColor1 = Color(0xFF3084F2);

// =============================================================================
// THÈMES DE L'APPLICATION
// =============================================================================

/// Gestionnaire centralisé des thèmes de l'application
/// Fournit les configurations de thème clair et sombre
class AppThemes {
  // ===========================================================================
  // THÈME CLAIR
  // ===========================================================================

  /// Configuration du thème clair de l'application
  /// Design moderne avec fond clair et couleurs vives
  static final ThemeData lightTheme = ThemeData(
    // Configuration de base
    primaryColor: primaryColor1,
    scaffoldBackgroundColor: Colors.grey[50],
    useMaterial3: true,
    fontFamily: 'Roboto',

    // Schéma de couleurs étendu
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
      secondary: accentColor1,
      background: Colors.grey[50],
      brightness: Brightness.light,
    ),

    // Configuration de l'AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor1,
      elevation: 0, // Design plat moderne
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Configuration des boutons d'action flottants
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor1,
    ),

    // Configuration des champs de formulaire
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Design sans bordure visible
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5FF), // Fond bleu très clair
    ),
  );

  // ===========================================================================
  // THÈME SOMBRE
  // ===========================================================================

  /// Configuration du thème sombre de l'application
  /// Design élégant avec fond sombre pour le confort visuel
  static final ThemeData darkTheme = ThemeData(
    // Configuration de base
    primaryColor: primaryColor1,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Noir profond
    useMaterial3: true,
    fontFamily: 'Roboto',

    // Schéma de couleurs étendu
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: accentColor1,
      background: const Color(0xFF0D0D0D),
    ),

    // Configuration de l'AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850], // Gris foncé
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // Configuration des boutons d'action flottants
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor1,
    ),

    // Configuration des champs de formulaire
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[850], // Fond gris foncé
      labelStyle: const TextStyle(color: Colors.white70), // Texte gris clair
    ),
  );

  // ===========================================================================
  // MÉTHODES UTILITAIRES POUR L'ACCÈS AUX COULEURS
  // ===========================================================================

  /// Retourne la couleur de succès depuis n'importe quel contexte
  /// Utilisée pour les confirmations, validations, états positifs
  static Color getSuccessColor(BuildContext context) => successColor1;

  /// Retourne la couleur d'erreur depuis n'importe quel contexte
  /// Utilisée pour les erreurs, alertes, états négatifs
  static Color getErrorColor(BuildContext context) => errorColor1;

  /// Retourne la couleur d'avertissement depuis n'importe quel contexte
  /// Utilisée pour les avertissements, états nécessitant une attention
  static Color getWarningColor(BuildContext context) => warningColor1;

  /// Retourne la couleur de certification depuis n'importe quel contexte
  /// Utilisée pour les badges certifiés, vérifications
  static Color getCertifiedColor(BuildContext context) => successColor1;

  /// Retourne la couleur d'information depuis n'importe quel contexte
  /// Utilisée pour les informations, états neutres
  static Color getInfoColor(BuildContext context) => infoColor1;

  // ===========================================================================
  // MÉTHODES UTILITAIRES POUR LA GESTION DES THÈMES
  // ===========================================================================

  /// Retourne le thème approprié selon le mode sombre/clair
  /// [isDarkMode] : true pour le thème sombre, false pour le thème clair
  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  /// Retourne le contraste de texte approprié selon la luminosité du fond
  /// [backgroundColor] : couleur de fond pour déterminer le contraste
  static Color getTextContrastColor(Color backgroundColor) {
    // Calcule la luminance pour déterminer si le fond est clair ou sombre
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Retourne une couleur d'élévation (ombre) selon le thème
  /// [context] : contexte pour déterminer le thème actuel
  static Color getElevationColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
  }

  /// Retourne la couleur de fond de carte selon le thème
  /// [context] : contexte pour déterminer le thème actuel
  static Color getCardBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.white;
  }

  /// Retourne la couleur de texte secondaire selon le thème
  /// [context] : contexte pour déterminer le thème actuel
  static Color getSecondaryTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey[700]!;
  }
}