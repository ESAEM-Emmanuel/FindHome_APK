// // lib/pages/forgot_password_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';
// import '../constants/app_themes.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _authService = AuthService();
//   bool _isLoading = false;

//   Future<void> _handleForgotPassword() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     final locale = context.read<SettingsProvider>().locale;
//     try {
//       await _authService.forgotPassword(_emailController.text.trim());
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(AppTranslations.get('reset_email_sent_success', locale)),
//             backgroundColor: successColor1,
//           ),
//         );
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${AppTranslations.get('reset_email_error', locale)} : $e'),
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
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = context.watch<SettingsProvider>().locale;

//     return Scaffold(
//       appBar: AppBar(title: Text(AppTranslations.get('forgot_password_title', locale))),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(32),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Icon(Icons.lock_reset, size: 80, color: accentColor1),
//                 const SizedBox(height: 16),
//                 Text(
//                   AppTranslations.get('forgot_password_title', locale),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor1,
//                       ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   AppTranslations.get('forgot_password_instruction', locale),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 40),

//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: AppTranslations.get('email', locale),
//                     prefixIcon: const Icon(Icons.email, color: primaryColor1),
//                   ),
//                   validator: (v) => v!.isEmpty || !v.contains('@')
//                       ? AppTranslations.get('email_validation_msg', locale)
//                       : null,
//                 ),
//                 const SizedBox(height: 32),

//                 FilledButton(
//                   onPressed: _isLoading ? null : _handleForgotPassword,
//                   style: FilledButton.styleFrom(
//                     backgroundColor: primaryColor1,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//                     child: _isLoading
//                         ? const SizedBox(
//                             key: ValueKey('spinner'),
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                           )
//                         : Text(
//                             AppTranslations.get('send_reset_link', locale),
//                             key: const ValueKey('text'),
//                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
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
// lib/pages/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/settings_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';

/// Page de réinitialisation de mot de passe permettant aux utilisateurs
/// de demander un lien de réinitialisation par email
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // === VARIABLES DE FORMULAIRE ===
  
  /// Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();
  
  /// Contrôleur pour le champ email
  final _emailController = TextEditingController();
  
  // === SERVICES ET ÉTATS ===
  
  /// Service d'authentification pour gérer la réinitialisation
  final _authService = AuthService();
  
  /// Indicateur de chargement pendant la requête
  bool _isLoading = false;

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  /// Nettoie les contrôleurs pour éviter les fuites de mémoire
  void _cleanupControllers() {
    _emailController.dispose();
  }

  /// Gère le processus de réinitialisation de mot de passe
  Future<void> _handleForgotPassword() async {
    // Valide le formulaire avant de procéder
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final locale = context.read<SettingsProvider>().locale;
    
    try {
      // Envoi de la demande de réinitialisation
      await _authService.forgotPassword(_emailController.text.trim());
      
      // Affichage du succès et retour en arrière
      if (mounted) {
        _showSuccessSnackbar(
          AppTranslations.get('reset_email_sent_success', locale),
        );
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      // Gestion des erreurs
      if (mounted) {
        _showErrorSnackbar(
          '${AppTranslations.get('reset_email_error', locale)} : $e',
        );
      }
    } finally {
      // Arrêt de l'indicateur de chargement
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Affiche un message de succès
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor1,
      ),
    );
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

  /// Valide le format de l'email
  String? _validateEmail(String? value, Locale locale) {
    if (value == null || value.isEmpty) {
      return AppTranslations.get('email_validation_msg', locale);
    }
    
    // Validation basique du format email
    if (!value.contains('@')) {
      return AppTranslations.get('email_validation_msg', locale);
    }
    
    return null;
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
      title: Text(
        AppTranslations.get('forgot_password_title', locale),
      ),
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
              // En-tête avec icône et texte explicatif
              _buildHeader(locale),
              const SizedBox(height: 40),

              // Champ email
              _buildEmailField(locale),
              const SizedBox(height: 32),

              // Bouton d'envoi
              _buildSubmitButton(locale),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête avec icône et instructions
  Widget _buildHeader(Locale locale) {
    return Column(
      children: [
        // Icône illustrative
        Icon(
          Icons.lock_reset, 
          size: 80, 
          color: accentColor1,
        ),
        const SizedBox(height: 16),
        
        // Titre principal
        Text(
          AppTranslations.get('forgot_password_title', locale),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor1,
              ),
        ),
        const SizedBox(height: 8),
        
        // Instructions
        Text(
          AppTranslations.get('forgot_password_instruction', locale),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Construit le champ de saisie d'email
  Widget _buildEmailField(Locale locale) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: AppTranslations.get('email', locale),
        prefixIcon: const Icon(Icons.email, color: primaryColor1),
      ),
      validator: (value) => _validateEmail(value, locale),
    );
  }

  /// Construit le bouton d'envoi avec animation de chargement
  Widget _buildSubmitButton(Locale locale) {
    return FilledButton(
      onPressed: _isLoading ? null : _handleForgotPassword,
      style: _getSubmitButtonStyle(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading 
            ? _buildLoadingIndicator() 
            : _buildButtonText(locale),
      ),
    );
  }

  /// Retourne le style du bouton de soumission
  ButtonStyle _getSubmitButtonStyle() {
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

  /// Construit l'indicateur de chargement animé
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      key: ValueKey('spinner'),
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: Colors.white, 
        strokeWidth: 2,
      ),
    );
  }

  /// Construit le texte du bouton
  Widget _buildButtonText(Locale locale) {
    return Text(
      AppTranslations.get('send_reset_link', locale),
      key: const ValueKey('text'),
      style: const TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.bold,
      ),
    );
  }
}