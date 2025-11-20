// // lib/pages/login_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_themes.dart';
// import '../constants/app_translations.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
      
//       final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//       final String successMessage = AppTranslations.get('login_success', locale);
//       final String failMessage = AppTranslations.get('login_failed', locale);

//       try {
//         // Appel de la méthode de connexion du provider
//         await Provider.of<AuthProvider>(context, listen: false).login(
//           _usernameController.text,
//           _passwordController.text,
//         );
        
//         // ✅ SUCCÈS : Retour à la page précédente (HomePage)
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(successMessage), 
//               backgroundColor: primaryColor1,
//               duration: const Duration(seconds: 2),
//             ),
//           );
          
//           // Retour à l'écran précédent (HomePage)
//           Navigator.of(context).pop();
//         }

//       } catch (e) {
//         // Affichage de l'erreur
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('$failMessage : $e'), 
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale; 

//     return Scaffold(
//       // ✅ BOUTON RETOUR EN HAUT À GAUCHE
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: _isLoading ? null : () {
//             Navigator.of(context).pop(); // Retour à la HomePage
//           },
//         ),
//         title: Text(AppTranslations.get('login', locale, 'Connexion')),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // // 1. Zone Logo/Icône
//                 // const Icon(
//                 //   Icons.store_mall_directory_outlined,
//                 //   size: 100,
//                 //   color: primaryColor1,
//                 // ),
//                 // const SizedBox(height: 16),
//                 Image.asset(
//                   'assets/images/find_home_logo.png', // Assurez-vous que le chemin correspond à votre fichier
//                   height: 100,
//                   width: 100,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(height: 16),
                
//                 // 2. Titre et Sous-titre
//                 Text(
//                   AppTranslations.get('welcome', locale, 'Bienvenue'),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor1,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   AppTranslations.get('login_to_continue', locale, 'Connectez-vous pour continuer'),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 // 3. Champ Nom d'utilisateur
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('username', locale, 'Nom d\'utilisateur'),
//                     prefixIcon: const Icon(Icons.person_outline, color: primaryColor1),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_username', locale, 'Le nom d\'utilisateur est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
                
//                 // 4. Champ Mot de passe
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('password', locale, 'Mot de passe'),
//                     prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return AppTranslations.get('required_password', locale, 'Le mot de passe est requis');
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),

//                 // 5. Mot de passe oublié
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: _isLoading ? null : () {
//                       Navigator.of(context).pushNamed('/forgot-password');
//                     },
//                     child: Text(
//                       AppTranslations.get('forgot_password', locale, 'Mot de passe oublié ?'),
//                       style: const TextStyle(color: accentColor1),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // 6. Bouton de Connexion
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor1,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 5,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20, 
//                           width: 20, 
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(
//                           AppTranslations.get('login_button', locale, 'Se connecter'),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(height: 20),

//                 // 7. Lien d'Inscription
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(AppTranslations.get('no_account', locale, 'Pas de compte ?')),
//                     TextButton(
//                       onPressed: _isLoading ? null : () {
//                         Navigator.of(context).pushNamed('/register');
//                       },
//                       child: Text(
//                         AppTranslations.get('signup', locale, 'S\'inscrire'),
//                         style: const TextStyle(color: accentColor1, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/pages/login_page.dart
// Material 3 – palette 2025 – formes arrondies – ombres douces

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final locale = context.read<SettingsProvider>().locale;
    try {
      await context.read<AuthProvider>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('login_failed', locale)} : $e'),
            backgroundColor: errorColor1,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: Text(AppTranslations.get('login', locale)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset('assets/images/find_home_logo.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.get('welcome', locale),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('login_to_continue', locale),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('username', locale),
                    prefixIcon: const Icon(Icons.person_outline, color: primaryColor1),
                  ),
                  validator: (v) => v!.isEmpty ? AppTranslations.get('required_username', locale) : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('password', locale),
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: primaryColor1),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? AppTranslations.get('required_password', locale) : null,
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed('/forgot-password'),
                    child: Text(AppTranslations.get('forgot_password', locale),
                        style: TextStyle(color: accentColor1)),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                FilledButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(AppTranslations.get('login_button', locale),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                // Sign-up link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppTranslations.get('no_account', locale)),
                      TextButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed('/register'),
                        child: Text(AppTranslations.get('signup', locale),
                            style: const TextStyle(color: accentColor1, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}