// // lib/pages/forgot_password_page.dart (Corrigé et Amélioré)
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// // import '../api/auth_servic…e.dart'; 
// import '../services/auth_service.dart'; 
// import '../providers/settings_provider.dart';
// import '../constants/app_translations.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final AuthService _authService = AuthService();
//   bool _isLoading = false;

//   Future<void> _handleForgotPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         await _authService.forgotPassword(_emailController.text.trim());

//         if (mounted) {
//           final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(AppTranslations.get('reset_email_sent_success', locale)),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.of(context).pop();
//         }
//       } catch (e) {
//         debugPrint('Erreur d\'envoi de l\'email: $e');
//         if (mounted) {
//           final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('${AppTranslations.get('reset_email_error', locale)}: ${e.toString().contains('Exception:') ? e.toString().substring(e.toString().indexOf(':') + 1).trim() : 'Veuillez vérifier l\'email ou réessayer.'}'),
//               backgroundColor: Theme.of(context).colorScheme.error,
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
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final locale = Provider.of<SettingsProvider>(context).locale;
//     // Récupération des couleurs du thème
//     final Color primaryColor = Theme.of(context).colorScheme.primary; 
//     final Color accentColor = Theme.of(context).colorScheme.secondary; 
//     final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary; 

//     // Récupération des traductions
//     final String title = AppTranslations.get('forgot_password_title', locale);
//     final String instruction = AppTranslations.get('forgot_password_instruction', locale);
//     final String emailLabel = AppTranslations.get('email', locale);
//     final String sendButton = AppTranslations.get('send_reset_link', locale);
//     final String emailValidationMsg = AppTranslations.get('email_validation_msg', locale);


//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
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
//                 // Utilisation de la couleur accent/secondaire
//                 Icon(
//                   Icons.lock_reset, 
//                   size: 80,
//                   color: accentColor,
//                 ),
//                 const SizedBox(height: 16),
                
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     // Utilisation de la couleur primaire
//                     color: primaryColor, 
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   instruction,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 40),
                
//                 // Champ Email
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: emailLabel,
//                     hintText: 'votre.email@exemple.com',
//                     prefixIcon: Icon(Icons.email, color: primaryColor),
//                     // Amélioration de la décoration du champ
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   // Utilisation de la traduction
//                   validator: (value) => value!.isEmpty || !value.contains('@') ? emailValidationMsg : null,
//                 ),
//                 const SizedBox(height: 40),
                
//                 // Bouton d'envoi (Rendu amélioré)
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _handleForgotPassword,
//                   style: ElevatedButton.styleFrom(
//                     // Utilisation de la couleur primaire du thème
//                     backgroundColor: primaryColor, 
//                     // Couleur du texte sur le bouton
//                     foregroundColor: onPrimaryColor, 
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     // Coins arrondis pour un look moderne
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     elevation: 5,
//                   ),
//                   // Animation de transition entre le texte et le spinner
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//                     child: _isLoading
//                         ? SizedBox(
//                             key: const ValueKey('spinner'),
//                             height: 20, 
//                             width: 20, 
//                             // Couleur du spinner qui contraste avec le fond
//                             child: CircularProgressIndicator(color: onPrimaryColor, strokeWidth: 2),
//                           )
//                         : Text(
//                             sendButton,
//                             key: const ValueKey('text'),
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onPrimaryColor),
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
// Material 3 – palette 2025 – animations douces

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/settings_provider.dart';
import '../constants/app_translations.dart';
import '../constants/app_themes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final locale = context.read<SettingsProvider>().locale;
    try {
      await _authService.forgotPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('reset_email_sent_success', locale)),
            backgroundColor: successColor1,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('reset_email_error', locale)} : $e'),
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('forgot_password_title', locale))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_reset, size: 80, color: accentColor1),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.get('forgot_password_title', locale),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('forgot_password_instruction', locale),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('email', locale),
                    prefixIcon: const Icon(Icons.email, color: primaryColor1),
                  ),
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? AppTranslations.get('email_validation_msg', locale)
                      : null,
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading
                        ? const SizedBox(
                            key: ValueKey('spinner'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            AppTranslations.get('send_reset_link', locale),
                            key: const ValueKey('text'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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