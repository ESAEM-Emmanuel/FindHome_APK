// lib/api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';

class AuthService {
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
      await prefs.setBool('isLoggedIn', true);

      return User.fromJson(data['user']);
    } else {
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

    // Nettoyage des données locales
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('isLoggedIn', false);
  }

  // --- INSCRIPTION COMPLÈTE AVEC TOUS LES CHAMPS ---
  Future<User> register({
    required String username,
    required String phone,
    required String email,
    required String birthday,
    required String password,
    required String confirmPassword,
    required String townId,
    String? gender,
    String? role,
    String? image,
    bool isStaff = false,
  }) async {
    // Construction des données
    final Map<String, dynamic> requestData = {
      "username": username,
      "phone": phone,
      "email": email,
      "birthday": birthday,
      "password": password,
      "confirm_password": confirmPassword,
      "town_id": townId,
      "is_staff": isStaff,
    };

    // Ajouter les champs facultatifs seulement s'ils sont fournis
    if (gender != null && gender.isNotEmpty) {
      requestData["gender"] = gender;
    }
    if (role != null && role.isNotEmpty) {
      requestData["role"] = role;
    }
    if (image != null && image.isNotEmpty) {
      requestData["image"] = image;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      // Gestion améliorée des erreurs
      final errorMessage = _parseErrorResponse(response.body);
      throw Exception(errorMessage);
    }
  }

  // --- Méthode d'inscription basique (pour compatibilité) ---
  Future<User> registerBasic({
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    return register(
      username: username,
      phone: phone,
      email: email,
      birthday: '1990-01-01',
      password: password,
      confirmPassword: password,
      townId: 'e98a1690-b589-4005-9849-b93fa88bde8d',
      gender: 'M',
      role: 'user',
      isStaff: false,
    );
  }

  // --- Mot de passe oublié ---
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot_password');
    
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email, 
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      String errorMessage = 'Échec de l\'envoi de l\'email (Code: ${response.statusCode})';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage; 
      } catch (e) {
        // Ignorer l'erreur de décodage
      }
      throw Exception(errorMessage);
    }
  }

  // --- Parse les erreurs de l'API ---
  String _parseErrorResponse(String responseBody) {
    try {
      final errorData = json.decode(responseBody);
      
      if (errorData is String) {
        return errorData;
      } else if (errorData is Map<String, dynamic>) {
        if (errorData.containsKey('detail')) {
          return errorData['detail'];
        }
        
        // Extraction des erreurs de validation détaillées
        final errors = <String>[];
        errorData.forEach((key, value) {
          if (value is List) {
            errors.add('${_capitalize(key)}: ${value.join(', ')}');
          } else {
            errors.add('${_capitalize(key)}: $value');
          }
        });
        
        return errors.join('\n');
      }
    } catch (e) {
      // Si le parsing échoue, retourner le corps brut
      return responseBody;
    }
    
    return 'Erreur lors de l\'inscription';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // --- Rafraîchissement du token ---
  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Accept': 'application/json'},
        body: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access_token']);
      } else {
        // Si le refresh échoue, déconnecter l'utilisateur
        await logout();
      }
    } catch (e) {
      // En cas d'erreur réseau, on garde le token actuel
      print('Erreur lors du rafraîchissement du token: $e');
    }
  }

  // --- Vérification du statut de connexion ---
  Future<bool> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn || accessToken == null) {
      return false;
    }

    // Optionnel: Vérifier avec l'API si le token est toujours valide
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Récupération des données utilisateur ---
  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}