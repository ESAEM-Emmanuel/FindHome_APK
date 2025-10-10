// lib/constants/app_translations.dart
import 'package:flutter/material.dart';
class AppTranslations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome',
      'login_to_continue': 'Log in to continue',
      'username': 'Username',
      'password': 'Password',
      'login_button': 'LOG IN',
      'forgot_password': 'Forgot Password?',
      'signup_prompt': 'Don\'t have an account? Sign Up',
      'home': 'Home',
      'markets': 'Markets',
      'status': 'Status',
      'logout_tooltip': 'Logout',
      'register_title': 'Create Account',
      'register_prompt': 'Enter your details to sign up.',
      'email': 'Email',
      'phone': 'Phone',
      'confirm_password': 'Confirm Password',
      'register_button': 'REGISTER',
      'forgot_password_title': 'Forgot Password',
      'forgot_password_instruction': 'Enter your email address below to receive a password reset link.',
      'send_reset_link': 'SEND RESET LINK',
      'search_placeholder': 'Search for a property...',
      'no_properties': 'No properties found for the moment.',
      'features': 'Features',
      'description': 'Description',
      'gallery': 'Image Gallery',
      'contact_owner': 'Contact the Owner',
      'error': 'Error',
    },
    'fr': {
      'welcome': 'Bienvenue',
      'login_to_continue': 'Connectez-vous pour continuer',
      'username': 'Nom d\'utilisateur',
      'password': 'Mot de passe',
      'login_button': 'CONNEXION',
      'forgot_password': 'Mot de passe oublié?',
      'signup_prompt': 'Pas de compte? Inscrivez-vous',
      'home': 'Accueil',
      'markets': 'Liste des Marchés',
      'status': 'Statut',
      'logout_tooltip': 'Déconnexion',
      'register_title': 'Créer un Compte',
      'register_prompt': 'Entrez vos informations pour vous inscrire.',
      'email': 'Email',
      'phone': 'Téléphone',
      'confirm_password': 'Confirmer le Mot de Passe',
      'register_button': 'INSCRIPTION',
      'forgot_password_title': 'Mot de Passe Oublié',
      'forgot_password_instruction': 'Entrez votre adresse email ci-dessous pour recevoir un lien de réinitialisation de mot de passe.',
      'send_reset_link': 'ENVOYER LE LIEN DE RÉINITIALISATION',
      'search_placeholder': 'Rechercher un logement...',
      'no_properties': 'Aucune propriété trouvée pour l\'instant.',
      'features': 'Équipements',
      'description': 'Description',
      'gallery': 'Galerie d\'images',
      'contact_owner': 'Contacter le Propriétaire',
      'error': 'Erreur',
    },
  };

  static String get(String key, Locale locale, [String? defaultValue]) {
    String langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
    _localizedValues['en']?[key] ?? 
    defaultValue ??
    key;
  }
}