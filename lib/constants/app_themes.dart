
// // lib/constants/app_themes.dart
// import 'package:flutter/material.dart';

// // Palette 2025
// // const Color primaryColor1       = Color(0xFF0511F2); // #0511F2
// const Color primaryColor1       = Color(0xFF3084F2); // #0511F2
// // const Color accentColor1      = Color(0xFF05F2DB); // #05F2DB 0xF05524(remplace l’orange)
// const Color accentColor1      = Color(0xFFF05524); // #05F2DB 0xF05524(remplace l’orange)
// // const Color successColor1      = Color(0xFF3084F2); // #3084F2 (vert → bleu accent)
// const Color successColor1      = Color(0xFF05F2DB); // #3084F2 (vert → bleu accent)
// const Color errorColor1          = Color.fromARGB(255, 243, 20, 20); // inchangé, pas dans la palette
// const Color warningColor1     = Color.fromARGB(255, 248, 139, 106); // #44C1F2 (orange → bleu clair)

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
//       fillColor: const Color(0xFFF1F5FF), // légère teinte bleue
//     ),
//   );

//   static final ThemeData darkTheme = ThemeData(
//     primaryColor: primaryColor1,
//     scaffoldBackgroundColor: const Color(0xFF0D0D0D), // #0D0D0D
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
// }
// lib/constants/app_themes.dart
import 'package:flutter/material.dart';

// Palette 2025
const Color primaryColor1       = Color(0xFF3084F2);
const Color accentColor1        = Color(0xFFF05524);
const Color successColor1       = Color(0xFF05F2DB);
const Color errorColor1         = Color.fromARGB(255, 243, 20, 20);
const Color warningColor1       = Color.fromARGB(255, 248, 139, 106);
const Color infoColor1          = Color(0xFF3084F2); // Nouvelle couleur info

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor1,
    scaffoldBackgroundColor: Colors.grey[50],
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(
          secondary: accentColor1,
          background: Colors.grey[50],
          brightness: Brightness.light,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor1,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5FF),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor1,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        secondary: accentColor1,
        background: const Color(0xFF0D0D0D),
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
      backgroundColor: accentColor1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[850],
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );

  // Méthodes utilitaires pour accéder aux couleurs depuis n'importe où
  static Color getSuccessColor(BuildContext context) => successColor1;
  static Color getErrorColor(BuildContext context) => errorColor1;
  static Color getWarningColor(BuildContext context) => warningColor1;
  static Color getCertifiedColor(BuildContext context) => successColor1;
  static Color getInfoColor(BuildContext context) => infoColor1;
}