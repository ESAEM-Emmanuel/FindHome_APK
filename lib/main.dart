import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Imports de vos fichiers (ajustez les chemins si besoin)
import 'pages/camera_page.dart';
import 'pages/market_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart'; 
import 'pages/register_page.dart'; 
import 'pages/forgot_password_page.dart';
import 'pages/property_detail_page.dart'; 

// Services et Providers
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'constants/app_themes.dart';
import 'constants/app_translations.dart'; // Import corrigé

// NOTE : La couleur accent est désormais gérée par Theme.of(context).colorScheme.secondary

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialisation des caméras (gestion d'erreur incluse)
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Erreur lors de l\'initialisation des caméras: $e');
  }

  // 2. Lancement de l'application avec MultiProvider
  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(cameras: cameras),
    )
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
      title: 'B-to-B App',
      
      // --- Gestion du Thème ---
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: settingsProvider.themeMode,

      // --- Gestion de la Localisation ---
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
      
      // --- Configuration des Routes Nommées (Corrigé) ---
      initialRoute: '/',
      routes: {
        '/': (context) => _AuthWrapper(cameras: cameras), 
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        
        // ✅ CORRECTION du routage de PropertyDetailPage: 
        // Récupération et passage de l'argument 'id' requis
        '/property-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          final propertyId = args?['id'];

          if (propertyId == null) {
            // Affiche une erreur si l'ID n'a pas été passé
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

// ----------------------------------------------------------------------
// AUTHENTICATION WRAPPER
// ----------------------------------------------------------------------

class _AuthWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;
  const _AuthWrapper({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Redirige vers MainScreen si connecté, sinon vers LoginPage
        if (authProvider.isLoggedIn) {
          return MainScreen(cameras: cameras);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

// ----------------------------------------------------------------------
// MAIN APPLICATION SCREEN
// ----------------------------------------------------------------------

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MainScreen({super.key, required this.cameras});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Définition de la couleur accent via le thème
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    // ✅ Les appels à AppTranslations.get() n'incluent plus l'argument de valeur par défaut
    // (cela est géré interne à la fonction dans le fichier constants/app_translations.dart)
    final List<String> titles = [
      AppTranslations.get('home', locale), 
      AppTranslations.get('markets', locale),
      AppTranslations.get('status', locale),
    ];

    final List<Widget> pages = [
      const HomePage(),
      const MarketPage(),
      CameraPage(cameras: widget.cameras), 
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]), 
        actions: [
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppTranslations.get('logout_tooltip', locale),
            onPressed: authProvider.logout, 
          ),
          // Bouton de changement de langue
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              final newLocale = settingsProvider.locale.languageCode == 'fr' 
                  ? const Locale('en', 'US') 
                  : const Locale('fr', 'FR');
              settingsProvider.setLocale(newLocale);
            },
          ),
          // Bouton de changement de thème
          IconButton(
            icon: Provider.of<SettingsProvider>(context).themeMode == ThemeMode.light 
                  ? const Icon(Icons.light_mode) 
                  : const Icon(Icons.dark_mode),
            onPressed: () {
              final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
              final newTheme = settingsProvider.themeMode == ThemeMode.light 
                  ? ThemeMode.dark 
                  : ThemeMode.light;
              settingsProvider.setThemeMode(newTheme);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // ✅ Utilisation de la couleur accent du thème
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
            icon: const Icon(Icons.calendar_month),
            label: AppTranslations.get('markets', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt), 
            label: AppTranslations.get('status', locale),
          ),
        ],
      ),
    );
  }
}