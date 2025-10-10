// lib/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_service.dart'; // Appel direct au service pour cette action simple
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService(); // Instance du service
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.forgotPassword(_emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Un email de réinitialisation a été envoyé.'),
              backgroundColor: Colors.green,
            ),
          );
          // Retourne à la page de connexion après succès
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Erreur d\'envoi de l\'email: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: L\'email n\'a pas pu être envoyé. $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

    // Ajoutons quelques traductions pour cette page
    final String title = AppTranslations.get('forgot_password_title', locale);
    final String instruction = AppTranslations.get('forgot_password_instruction', locale);
    final String emailLabel = AppTranslations.get('email', locale);
    final String sendButton = AppTranslations.get('send_reset_link', locale);


    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset, 
                  size: 80,
                  color: accentOrange,
                ),
                const SizedBox(height: 16),
                
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                
                // Champ Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: emailLabel,
                    hintText: 'votre.email@exemple.com',
                    prefixIcon: const Icon(Icons.email, color: primaryBlue),
                  ),
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Veuillez entrer un email valide' : null,
                ),
                const SizedBox(height: 40),
                
                // Bouton d'envoi
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          sendButton,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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