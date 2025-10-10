// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart'; // ✅ CORRECTION : Importation du provider de paramètres
import '../constants/app_themes.dart';
import '../constants/app_translations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
      final String successMessage = AppTranslations.get('login_success', locale);
      final String failMessage = AppTranslations.get('login_failed', locale);

      try {
        // Appel de la méthode de connexion du provider
        await Provider.of<AuthProvider>(context, listen: false).login(
          _usernameController.text,
          _passwordController.text,
        );
        
        // Affichage du succès
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successMessage), backgroundColor: primaryBlue),
            );
        }

      } catch (e) {
        // Affichage de l'erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$failMessage : $e'), backgroundColor: Colors.red),
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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Le type SettingsProvider est maintenant reconnu
    final locale = Provider.of<SettingsProvider>(context).locale; 

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Zone Logo/Icône
                const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 100,
                  color: primaryBlue,
                ),
                const SizedBox(height: 16),
                
                // 2. Titre et Sous-titre
                Text(
                  AppTranslations.get('welcome', locale),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('login_to_continue', locale),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // 3. Champ Nom d'utilisateur
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('username', locale),
                    prefixIcon: const Icon(Icons.person_outline, color: primaryBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTranslations.get('required_username', locale); // Utilisez la traduction pour la validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // 4. Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppTranslations.get('password', locale),
                    prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTranslations.get('required_password', locale); // Utilisez la traduction pour la validation
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 5. Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: Text(
                      AppTranslations.get('forgot_password', locale),
                      style: const TextStyle(color: accentOrange),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 6. Bouton de Connexion
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          AppTranslations.get('login_button', locale),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // 7. Lien d'Inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Note: Le découpage avec .split('?') est complexe et sujet à erreur. 
                    // Il est préférable d'avoir deux clés de traduction séparées (ex: 'no_account' et 'signup_link').
                    Text(AppTranslations.get('signup_prompt', locale).split('?')[0]),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(
                        // Ceci est juste pour que ça fonctionne avec votre structure de clé actuelle
                        AppTranslations.get('signup_prompt', locale).split('?')[1].trim(), 
                        style: const TextStyle(color: accentOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}