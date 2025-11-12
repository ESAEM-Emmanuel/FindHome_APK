// // lib/constants/app_themes.dart
// import 'package:flutter/material.dart';

// const Color primaryBlue = Color.fromARGB(255, 6, 143, 255);
// const Color accentOrange = Color.fromARGB(255, 255, 81, 0);

// class AppThemes {
//   static final ThemeData lightTheme = ThemeData(
//     primaryColor: primaryBlue,
//     scaffoldBackgroundColor: Colors.grey[50],
//     useMaterial3: true,
//     fontFamily: 'Roboto', // Exemple de police
//     colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
//         .copyWith(
//           secondary: accentOrange,
//           background: Colors.grey[50],
//           brightness: Brightness.light,
//         ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryBlue,
//       elevation: 0,
//       titleTextStyle: TextStyle(
//         color: Colors.white,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: accentOrange,
//     ),
//     inputDecorationTheme: InputDecorationTheme( // Style des champs de texte
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       filled: true,
//       fillColor: Colors.grey[100],
//     ),
//   );

//   static final ThemeData darkTheme = ThemeData(
//     primaryColor: primaryBlue,
//     scaffoldBackgroundColor: Colors.grey[900],
//     useMaterial3: true,
//     fontFamily: 'Roboto',
//     colorScheme: ColorScheme.fromSwatch(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//       ).copyWith(
//         secondary: accentOrange,
//         background: Colors.grey[900],
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
//       backgroundColor: accentOrange,
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//       filled: true,
//       fillColor: Colors.grey[800],
//       labelStyle: const TextStyle(color: Colors.white70),
//     ),
//   );
// }
// lib/constants/app_themes.dart
import 'package:flutter/material.dart';

const Color primaryBlue = Color.fromARGB(255, 6, 143, 255);
const Color accentOrange = Color.fromARGB(255, 255, 81, 0);
const Color successGreen = Color.fromARGB(255, 76, 175, 80); // Vert pour succès/certification
const Color errorRed = Color.fromARGB(255, 244, 67, 54);    // Rouge pour erreurs
const Color warningOrange = Color.fromARGB(255, 255, 152, 0); // Orange pour avertissements

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.grey[50],
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(
          secondary: accentOrange,
          background: Colors.grey[50],
          brightness: Brightness.light,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentOrange,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.grey[900],
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: accentOrange,
        background: Colors.grey[900],
      ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentOrange,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );

  // Méthodes utilitaires pour accéder aux couleurs depuis n'importe où
  static Color getSuccessColor(BuildContext context) {
    return successGreen;
  }

  static Color getErrorColor(BuildContext context) {
    return errorRed;
  }

  static Color getWarningColor(BuildContext context) {
    return warningOrange;
  }

  static Color getCertifiedColor(BuildContext context) {
    return successGreen; // Même couleur que le succès pour la certification
  }
}