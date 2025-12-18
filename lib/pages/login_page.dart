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
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     final locale = context.read<SettingsProvider>().locale;
//     try {
//       await context.read<AuthProvider>().login(
//             _usernameController.text.trim(),
//             _passwordController.text.trim(),
//           );
//       if (mounted) Navigator.of(context).pop();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${AppTranslations.get('login_failed', locale)} : $e'),
//             backgroundColor: errorColor1,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
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
//     final locale = context.watch<SettingsProvider>().locale;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//         ),
//         title: Text(AppTranslations.get('login', locale)),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Logo
//                 Image.asset('assets/images/find_home_logo.png', height: 100),
//                 const SizedBox(height: 16),
//                 Text(
//                   AppTranslations.get('welcome', locale),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor1,
//                       ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   AppTranslations.get('login_to_continue', locale),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 40),

//                 // Username
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('username', locale),
//                     prefixIcon: const Icon(Icons.person_outline, color: primaryColor1),
//                   ),
//                   validator: (v) => v!.isEmpty ? AppTranslations.get('required_username', locale) : null,
//                 ),
//                 const SizedBox(height: 16),

//                 // Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('password', locale),
//                     prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
//                           color: primaryColor1),
//                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                   ),
//                   validator: (v) => v!.isEmpty ? AppTranslations.get('required_password', locale) : null,
//                 ),
//                 const SizedBox(height: 8),

//                 // Forgot password
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed('/forgot-password'),
//                     child: Text(AppTranslations.get('forgot_password', locale),
//                         style: TextStyle(color: accentColor1)),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Login button
//                 FilledButton(
//                   onPressed: _isLoading ? null : _handleLogin,
//                   style: FilledButton.styleFrom(
//                     backgroundColor: primaryColor1,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 20, height: 20,
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text(AppTranslations.get('login_button', locale),
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(height: 16),

//                 // Sign-up link
//                 Center(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(AppTranslations.get('no_account', locale)),
//                       TextButton(
//                         onPressed: _isLoading ? null : () => Navigator.of(context).pushNamed('/register'),
//                         child: Text(AppTranslations.get('signup', locale),
//                             style: const TextStyle(color: accentColor1, fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

/// Page de connexion permettant aux utilisateurs de s'authentifier
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // === VARIABLES DE FORMULAIRE ===
  
  /// Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();
  
  /// Contrôleurs pour les champs de texte
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // === ÉTATS DE L'UI ===
  
  /// Indicateur de chargement pendant la connexion
  bool _isLoading = false;
  
  /// Masque ou affiche le mot de passe
  bool _obscurePassword = true;

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  /// Nettoie les contrôleurs pour éviter les fuites de mémoire
  void _cleanupControllers() {
    _usernameController.dispose();
    _passwordController.dispose();
  }

  /// Gère le processus de connexion
  Future<void> _handleLogin() async {
    // Valide le formulaire avant de procéder
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final locale = context.read<SettingsProvider>().locale;
    
    try {
      // Tentative de connexion
      await context.read<AuthProvider>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // Retour à l'écran précédent en cas de succès
      if (mounted) Navigator.of(context).pop();
      
    } catch (e) {
      // Affichage de l'erreur en cas d'échec
      if (mounted) {
        _showErrorSnackbar(
          '${AppTranslations.get('login_failed', locale)} : $e',
        );
      }
    } finally {
      // Arrêt de l'indicateur de chargement
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Affiche un message d'erreur
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor1,
      ),
    );
  }

  /// Alterne la visibilité du mot de passe
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  /// Navigue vers la page d'inscription
  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  /// Navigue vers la page de mot de passe oublié
  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;

    return Scaffold(
      appBar: _buildAppBar(locale),
      body: _buildBody(locale),
    );
  }

  /// Construit l'AppBar de la page
  AppBar _buildAppBar(Locale locale) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      ),
      title: Text(AppTranslations.get('login', locale)),
    );
  }

  /// Construit le corps de la page
  Widget _buildBody(Locale locale) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec logo et texte
              _buildHeader(locale),
              const SizedBox(height: 40),

              // Champs de formulaire
              _buildUsernameField(locale),
              const SizedBox(height: 16),
              
              _buildPasswordField(locale),
              const SizedBox(height: 8),
              
              _buildForgotPasswordLink(locale),
              const SizedBox(height: 24),

              // Bouton de connexion
              _buildLoginButton(locale),
              const SizedBox(height: 16),

              // Lien vers l'inscription
              _buildSignupLink(locale),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête avec logo et texte de bienvenue
  Widget _buildHeader(Locale locale) {
    return Column(
      children: [
        // Logo de l'application
        Image.asset(
          'assets/images/find_home_logo.png', 
          height: 100
        ),
        const SizedBox(height: 16),
        
        // Titre de bienvenue
        Text(
          AppTranslations.get('welcome', locale),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor1,
              ),
        ),
        const SizedBox(height: 8),
        
        // Sous-titre
        Text(
          AppTranslations.get('login_to_continue', locale),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Construit le champ nom d'utilisateur
  Widget _buildUsernameField(Locale locale) {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: AppTranslations.get('username', locale),
        prefixIcon: const Icon(Icons.person_outline, color: primaryColor1),
      ),
      validator: (value) => _validateUsername(value, locale),
    );
  }

  /// Valide le champ nom d'utilisateur
  String? _validateUsername(String? value, Locale locale) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_username', locale);
    }
    return null;
  }

  /// Construit le champ mot de passe avec toggle de visibilité
  Widget _buildPasswordField(Locale locale) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppTranslations.get('password', locale),
        prefixIcon: const Icon(Icons.lock_outline, color: primaryColor1),
        suffixIcon: _buildPasswordVisibilityToggle(),
      ),
      validator: (value) => _validatePassword(value, locale),
    );
  }

  /// Valide le champ mot de passe
  String? _validatePassword(String? value, Locale locale) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('required_password', locale);
    }
    return null;
  }

  /// Construit le bouton de toggle de visibilité du mot de passe
  Widget _buildPasswordVisibilityToggle() {
    return IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility : Icons.visibility_off,
        color: primaryColor1,
      ),
      onPressed: _togglePasswordVisibility,
    );
  }

  /// Construit le lien "Mot de passe oublié"
  Widget _buildForgotPasswordLink(Locale locale) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _navigateToForgotPassword,
        child: Text(
          AppTranslations.get('forgot_password', locale),
          style: TextStyle(color: accentColor1),
        ),
      ),
    );
  }

  /// Construit le bouton de connexion
  Widget _buildLoginButton(Locale locale) {
    return FilledButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: _getLoginButtonStyle(),
      child: _isLoading 
          ? _buildLoadingIndicator() 
          : _buildLoginButtonText(locale),
    );
  }

  /// Retourne le style du bouton de connexion
  ButtonStyle _getLoginButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: primaryColor1,
      foregroundColor: Colors.white,
      // padding: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  /// Construit l'indicateur de chargement
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 20, 
      height: 20,
      child: CircularProgressIndicator(
        color: Colors.white, 
        strokeWidth: 2,
      ),
    );
  }

  /// Construit le texte du bouton de connexion
  Widget _buildLoginButtonText(Locale locale) {
    return Text(
      AppTranslations.get('login_button', locale),
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Construit le lien vers la page d'inscription
  Widget _buildSignupLink(Locale locale) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppTranslations.get('no_account', locale)),
          TextButton(
            onPressed: _isLoading ? null : _navigateToRegister,
            child: Text(
              AppTranslations.get('signup', locale),
              style: const TextStyle(
                color: accentColor1, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}