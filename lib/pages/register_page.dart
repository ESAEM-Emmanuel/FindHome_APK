// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.register(
          username: _usernameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie! Veuillez vous connecter.'),
              backgroundColor: Colors.green,
            ),
          );
          // Retourne à la page de connexion
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Erreur d\'inscription: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de l\'inscription: $e'),
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
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<SettingsProvider>(context).locale;

    // Ajoutons quelques traductions pour cette page
    final String title = AppTranslations.get('register_title', locale);
    final String prompt = AppTranslations.get('register_prompt', locale);
    final String usernameLabel = AppTranslations.get('username', locale);
    final String emailLabel = AppTranslations.get('email', locale);
    final String phoneLabel = AppTranslations.get('phone', locale);
    final String passwordLabel = AppTranslations.get('password', locale);
    final String confirmPasswordLabel = AppTranslations.get('confirm_password', locale);
    final String registerButton = AppTranslations.get('register_button', locale);

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Champ Nom d'utilisateur
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: usernameLabel,
                    prefixIcon: const Icon(Icons.person_outline, color: primaryBlue),
                  ),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom d\'utilisateur' : null,
                ),
                const SizedBox(height: 20),

                // Champ Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined, color: primaryBlue),
                  ),
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 20),
                
                // Champ Téléphone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: phoneLabel,
                    prefixIcon: const Icon(Icons.phone_outlined, color: primaryBlue),
                  ),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un numéro de téléphone' : null,
                ),
                const SizedBox(height: 20),

                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                  ),
                  validator: (value) => value!.length < 6 ? 'Le mot de passe doit contenir au moins 6 caractères' : null,
                ),
                const SizedBox(height: 20),

                // Champ Confirmation Mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: primaryBlue),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                // Bouton d'Inscription
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange, // Utiliser la couleur d'accent pour se démarquer
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
                          registerButton,
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