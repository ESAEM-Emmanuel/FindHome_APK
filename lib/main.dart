// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// // Imports de vos fichiers
// import 'pages/home_page.dart';
// import 'pages/login_page.dart'; 
// import 'pages/profile_page.dart';
// import 'pages/register_page.dart'; 
// import 'pages/forgot_password_page.dart';
// import 'pages/property_detail_page.dart';
// import 'pages/property_map_page.dart';
// import 'pages/properties_page.dart'; 

// // Services et Providers
// import 'providers/auth_provider.dart';
// import 'providers/settings_provider.dart';
// import 'constants/app_themes.dart';
// import 'constants/app_translations.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   List<CameraDescription> cameras = [];
//   try {
//     cameras = await availableCameras();
//   } on CameraException catch (e) {
//     debugPrint('Erreur lors de l\'initialisation des caméras: $e');
//   }

//   final authProvider = AuthProvider();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => authProvider),
//         ChangeNotifierProvider(create: (_) => SettingsProvider()),
//       ],
//       child: MyApp(cameras: cameras),
//     )
//   );
// }

// class MyApp extends StatelessWidget {
//   final List<CameraDescription> cameras;
//   const MyApp({super.key, required this.cameras});

//   @override
//   Widget build(BuildContext context) {
//     final settingsProvider = Provider.of<SettingsProvider>(context);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FindHomeApp',
      
//       theme: AppThemes.lightTheme,
//       darkTheme: AppThemes.darkTheme,
//       themeMode: settingsProvider.themeMode,

//       locale: settingsProvider.locale,
//       supportedLocales: const [
//         Locale('en', 'US'),
//         Locale('fr', 'FR'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
      
//       initialRoute: '/',
//       routes: {
//         '/': (context) => MainScreen(cameras: cameras),
//         '/login': (context) => const LoginPage(),
//         '/register': (context) => const RegisterPage(),
//         '/forgot-password': (context) => const ForgotPasswordPage(),
//         '/profile': (context) => const ProfilePage(),
        
//         '/property-detail': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
//           final propertyId = args?['id'];

//           if (propertyId == null) {
//             return const Scaffold(
//               body: Center(child: Text('Erreur de navigation: ID de propriété manquant')),
//             );
//           }
          
//           return PropertyDetailPage(propertyId: propertyId);
//         },
//       },
//     );
//   }
// }

// // ----------------------------------------------------------------------
// // MAIN APPLICATION SCREEN
// // ----------------------------------------------------------------------

// class MainScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const MainScreen({super.key, required this.cameras});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   // ✅ MÉTHODE POUR GÉRER LA DÉCONNEXION
//   Future<void> _handleLogout(BuildContext context, Locale locale) async {
//     // Ferme le dialogue de confirmation si ouvert
//     if (Navigator.of(context).canPop()) {
//       Navigator.of(context).pop();
//     }
    
//     try {
//       // Déconnexion via le provider
//       await Provider.of<AuthProvider>(context, listen: false).logout();
      
//       // ✅ FORCE LE RETOUR À LA HOMEPAGE
//       if (mounted) {
//         setState(() {
//           _currentIndex = 0; // Retour à l'onglet Home
//         });
//       }
      
//       // Feedback utilisateur
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get('logout_success', locale, 'Déconnexion réussie')),
//             backgroundColor: AppThemes.getSuccessColor(context),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       // Gestion des erreurs de déconnexion
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${AppTranslations.get('logout_error', locale, 'Erreur lors de la déconnexion')}: $e'),
//             backgroundColor: AppThemes.getErrorColor(context),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // ✅ WIDGET FUSIONNÉ POUR L'ÉTAT UTILISATEUR
//   Widget _buildUserAndLanguageStatus(BuildContext context, Locale locale) {
//     final authProvider = Provider.of<AuthProvider>(context);
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Photo de profil ou icône
//           authProvider.isLoggedIn && authProvider.currentUser?.image != null && authProvider.currentUser!.image!.isNotEmpty
//               ? CircleAvatar(
//                   radius: 14,
//                   backgroundImage: NetworkImage(authProvider.currentUser!.image!),
//                 )
//               : Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     authProvider.isLoggedIn ? Icons.person : Icons.person_outline,
//                     size: 16,
//                     color: Theme.of(context).colorScheme.secondary,
//                   ),
//                 ),
          
//           const SizedBox(width: 8),
          
//           // Nom d'utilisateur ou statut invité
//           Text(
//             authProvider.isLoggedIn 
//               ? authProvider.currentUser?.username ?? 'Utilisateur'
//               : AppTranslations.get('guest', locale, 'Invité'),
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Theme.of(context).colorScheme.secondary,
//             ),
//           ),
          
//           const SizedBox(width: 8),
          
//           // Menu déroulant ou bouton de connexion
//           if (authProvider.isLoggedIn) ...[
//             PopupMenuButton<String>(
//               icon: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.more_vert,
//                   size: 16,
//                   color: Theme.of(context).colorScheme.secondary,
//                 ),
//               ),
//               offset: const Offset(0, 45),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: BorderSide(
//                   color: Theme.of(context).dividerColor,
//                   width: 1,
//                 ),
//               ),
//               onSelected: (value) {
//                 if (value == 'logout') {
//                   _showLogoutConfirmation(context, locale);
//                 } else if (value == 'profile') {
//                   Navigator.pushNamed(context, '/profile');
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 PopupMenuItem(
//                   value: 'profile',
//                   child: Row(
//                     children: [
//                       Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.secondary),
//                       const SizedBox(width: 12),
//                       Text(
//                         AppTranslations.get('profile', locale, 'Profil'),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Theme.of(context).colorScheme.secondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: 'logout',
//                   child: Row(
//                     children: [
//                       Icon(Icons.logout, size: 20, color: Theme.of(context).colorScheme.error),
//                       const SizedBox(width: 12),
//                       Text(
//                         AppTranslations.get('logout', locale, 'Déconnexion'),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Theme.of(context).colorScheme.error,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ] else ...[
//             // Bouton de connexion si non connecté - intégré dans le conteneur
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pushNamed('/login');
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.login,
//                       size: 14,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       AppTranslations.get('login', locale, 'Connexion'),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // Dialogue de confirmation pour la déconnexion
//   void _showLogoutConfirmation(BuildContext context, Locale locale) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(AppTranslations.get('logout_confirmation', locale, 'Déconnexion')),
//           content: Text(AppTranslations.get('logout_confirmation_message', locale, 'Êtes-vous sûr de vouloir vous déconnecter ?')),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.error,
//               ),
//               onPressed: () => _handleLogout(context, locale),
//               child: Text(
//                 AppTranslations.get('logout', locale, 'Déconnexion'),
//                 style: TextStyle(color: Theme.of(context).colorScheme.onError),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     final Color accentColor = Theme.of(context).colorScheme.secondary;

//     final List<String> titles = [
//       AppTranslations.get('home', locale),
//       AppTranslations.get('map', locale, 'Carte'),
//       AppTranslations.get('properties', locale, 'Propriétés'),
//     ];

//     final List<Widget> pages = [
//       const HomePage(),
//       const PropertyMapPage(), // Nouvelle page de carte
//       const PropertiesPage(), // Nouvelle page de gestion des propriétés
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             // ✅ ÉLÉMENT FUSIONNÉ : Statut utilisateur
//             _buildUserAndLanguageStatus(context, locale),
//             Expanded(
//               child: Text(titles[_currentIndex]),
//             ),
//           ],
//         ),
//         actions: [
//           // ✅ BOUTON DE CHANGEMENT DE LANGUE AVEC INDICATEUR DIRECT
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 4),
//             child: ElevatedButton(
//               onPressed: () {
//                 final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//                 final newLocale = settingsProvider.locale.languageCode == 'fr' 
//                     ? const Locale('en', 'US') 
//                     : const Locale('fr', 'FR');
//                 settingsProvider.setLocale(newLocale);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                 foregroundColor: Theme.of(context).colorScheme.primary,
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 0,
//                 shadowColor: Colors.transparent,
//               ),
//               child: Text(
//                 locale.languageCode.toUpperCase(),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//             ),
//           ),
          
//           // Bouton de changement de thème
//           IconButton(
//             icon: Provider.of<SettingsProvider>(context).themeMode == ThemeMode.light 
//                   ? Icon(Icons.light_mode, color: Theme.of(context).colorScheme.secondary)
//                   : Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.secondary),
//             onPressed: () {
//               final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
//               final newTheme = settingsProvider.themeMode == ThemeMode.light 
//                   ? ThemeMode.dark 
//                   : ThemeMode.light;
//               settingsProvider.setThemeMode(newTheme);
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         selectedItemColor: accentColor, 
//         unselectedItemColor: Theme.of(context).hintColor, 
//         backgroundColor: Theme.of(context).cardColor, 
//         elevation: 10,
//         type: BottomNavigationBarType.fixed,
//         items: [
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.home),
//             label: AppTranslations.get('home', locale),
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.map),
//             label: AppTranslations.get('map', locale, 'Carte'),
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.add_home_work), 
//             label: AppTranslations.get('properties', locale, 'Propriétés'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Imports de vos fichiers
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/property_detail_page.dart';
import 'pages/property_map_page.dart';
import 'pages/properties_page.dart';

// Services et Providers
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'constants/app_themes.dart';
import 'constants/app_translations.dart';
import 'dart:io' show Platform; // ⬅️ NOUVEAU: Importez Platform pour vérifier l'OS
import 'package:flutter/foundation.dart' show kIsWeb; // ⬅️ NOUVEAU: Importez kIsWeb pour le web

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = [];

  bool isMobileOrWeb = Platform.isAndroid || Platform.isIOS || kIsWeb;

  if (isMobileOrWeb) {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      // Si une erreur survient (caméra non trouvée, permissions refusées), 
      // la liste 'cameras' restera vide.
      debugPrint('Erreur lors de l\'initialisation des caméras: $e');
    } catch (e) {
      // Gérer l'exception générale MissingPluginException sur les plateformes desktop
      // (même si on essaie de l'éviter, c'est une sécurité)
      debugPrint('Erreur inattendue de plugin (probablement desktop non supporté) : $e');
    }
  }

  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(cameras: cameras),
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindHomeApp',

      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: settingsProvider.themeMode,

      locale: settingsProvider.locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(cameras: cameras),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/property-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          final propertyId = args?['id'];

          if (propertyId == null) {
            return const Scaffold(
              body: Center(child: Text('Erreur de navigation: ID de propriété manquant')),
            );
          }

          return PropertyDetailPage(propertyId: propertyId);
        },
      },
    );
  }
}

// ------------------------------------------------------------------
// MAIN APPLICATION SCREEN
// ------------------------------------------------------------------

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainScreen({super.key, required this.cameras});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> _handleLogout(BuildContext context, Locale locale) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();

      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('logout_success', locale, 'Déconnexion réussie')),
            backgroundColor: AppThemes.getSuccessColor(context),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('logout_error', locale, 'Erreur lors de la déconnexion')}: $e'),
            backgroundColor: AppThemes.getErrorColor(context),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildUserAndLanguageStatus(BuildContext context, Locale locale) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          authProvider.isLoggedIn && authProvider.currentUser?.image != null && authProvider.currentUser!.image!.isNotEmpty
              ? CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(authProvider.currentUser!.image!),
                )
              : Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    authProvider.isLoggedIn ? Icons.person : Icons.person_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
          const SizedBox(width: 8),
          Text(
            authProvider.isLoggedIn
                ? authProvider.currentUser?.username ?? 'Utilisateur'
                : AppTranslations.get('guest', locale, 'Invité'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          if (authProvider.isLoggedIn) ...[
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutConfirmation(context, locale);
                } else if (value == 'profile') {
                  Navigator.pushNamed(context, '/profile');
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text(
                        AppTranslations.get('profile', locale, 'Profil'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        AppTranslations.get('logout', locale, 'Déconnexion'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.login,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppTranslations.get('login', locale, 'Connexion'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

    Future<void> loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      try {
        await authProvider.fetchUserProfile();
      } catch (e) {
        print("Erreur lors du chargement des données utilisateur: $e");
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context, Locale locale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.get('logout_confirmation', locale, 'Déconnexion')),
          content: Text(AppTranslations.get('logout_confirmation_message', locale, 'Êtes-vous sûr de vouloir vous déconnecter ?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppTranslations.get('cancel', locale, 'Annuler')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _handleLogout(context, locale),
              child: Text(
                AppTranslations.get('logout', locale, 'Déconnexion'),
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final accentColor = Theme.of(context).colorScheme.secondary;

    final List<String> titles = [
      AppTranslations.get('home', locale),
      AppTranslations.get('map', locale, 'Carte'),
      AppTranslations.get('properties', locale, 'Propriétés'),
    ];

    final List<Widget> pages = [
      const HomePage(),
      const PropertyMapPage(),
      const PropertiesPage(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: Row(
          children: [
            _buildUserAndLanguageStatus(context, locale),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titles[_currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                final settings = Provider.of<SettingsProvider>(context, listen: false);
                settings.setLocale(
                  settings.locale.languageCode == 'fr'
                      ? const Locale('en', 'US')
                      : const Locale('fr', 'FR'),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                locale.languageCode.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Provider.of<SettingsProvider>(context).themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.white,
            ),
            onPressed: () {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              settings.setThemeMode(
                settings.themeMode == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: accentColor,
        unselectedItemColor: Theme.of(context).hintColor,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppTranslations.get('home', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: AppTranslations.get('map', locale, 'Carte'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_home_work),
            label: AppTranslations.get('properties', locale, 'Propriétés'),
          ),
        ],
      ),
    );
  }
}