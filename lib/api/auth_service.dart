// lib/api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/api_constants.dart'; // Nous allons le créer

class AuthService {
  // Simule l'URL de base
  static const String baseUrl = ApiConstants.baseUrl; 

  // --- Connexion ---
  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': '',
        'client_id': '', // À compléter si nécessaire
        'client_secret': '', // À compléter si nécessaire
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Sauvegarde des tokens
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      await prefs.setBool('isLoggedIn', true); // Mise à jour du statut

      return User.fromJson(data['user']);
    } else {
      // Gérer les erreurs spécifiques d'API (ex: identifiants invalides)
      throw Exception('Échec de la connexion: ${response.statusCode}');
    }
  }

  // --- Déconnexion ---
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) return;

    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // Nettoyage des données locales quelle que soit la réponse de l'API
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('isLoggedIn', false);
  }

  // --- Inscription ---
  Future<User> register({
    required String username,
    required String phone,
    required String email,
    required String password,
    // ... autres champs
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "phone": phone,
        "email": email,
        "password": password,
        "confirm_password": password,
        "role": "user",
        // Ajouter d'autres champs obligatoires
        "birthday": "1990-01-01", 
        "gender": "M",
        "town_id": "e98a1690-b589-4005-9849-b93fa88bde8d",
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  // --- Mot de passe oublié ---
  // Future<void> forgotPassword(String email) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/forgot-password?email=$email'),
  //     headers: {'Accept': 'application/json'},
  //   );

  //   if (response.statusCode != 200) {
  //      throw Exception('Échec de l\'envoi de l\'email: ${response.body}');
  //   }
  // }
  Future<void> forgotPassword(String email) async {
    // 1. Utiliser le chemin d'API correct : /auth/forgot_password
    final url = Uri.parse('$baseUrl/auth/forgot_password');
    
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json', // Indispensable pour envoyer du JSON
      },
      // 2. Envoyer l'email dans le corps de la requête JSON
      body: json.encode({
        'email': email, 
      }),
    );

    if (response.statusCode == 200) {
      // Succès: L'email a été envoyé
      return;
    } else {
      // Échec: Tente d'extraire le message d'erreur du corps de la réponse si disponible
      String errorMessage = 'Échec de l\'envoi de l\'email (Code: ${response.statusCode})';
      try {
        final errorData = json.decode(response.body);
        // Cela dépend de la structure de l'erreur renvoyée par votre backend (par exemple FastAPI)
        errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage; 
      } catch (e) {
        // Ignorer l'erreur de décodage si le corps n'est pas JSON
      }
      throw Exception(errorMessage);
    }
  }

  // Note: La fonction `refresh-token` et `get me` devrait être gérée 
  // dans une couche d'interception HTTP si vous avez des appels nécessitant 
  // le token pour toute l'application. Pour l'instant, on se concentre sur l'UI.
}