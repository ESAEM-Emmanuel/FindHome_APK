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
    try {
      print('🔄 Envoi de la requête login...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string',
        },
      );

      print('📡 Statut HTTP: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Structure des données: ${data.keys}');
        
        // Sauvegarde des tokens
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        
        print('🔑 Access Token: ${accessToken != null ? "PRÉSENT" : "ABSENT"}');
        print('🔑 Refresh Token: ${refreshToken != null ? "PRÉSENT" : "ABSENT"}');
        
        if (accessToken == null) {
          throw Exception('Aucun token d\'accès trouvé dans la réponse');
        }
        
        await prefs.setString('access_token', accessToken);
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }
        await prefs.setBool('isLoggedIn', true);

        // CORRECTION : L'utilisateur est dans data['user']
        if (data['user'] != null) {
          print('👤 Données utilisateur trouvées');
          final user = User.fromJson(data['user']);
          print('✅ Utilisateur parsé: ${user.username}');
          return user;
        } else {
          throw Exception('Données utilisateur manquantes dans la réponse');
        }
        
      } else {
        String errorMessage = 'Échec de la connexion: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          // Ignorer si le parsing échoue
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Erreur lors du login: $e');
      rethrow;
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

  // --- Récupération des données utilisateur détaillées ---
  Future<User> getUserProfile(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}');
    }
  }

  // --- Mise à jour du profil utilisateur ---
  Future<User> updateUserProfile({
    required String userId,
    String? username,
    String? phone,
    String? email,
    String? birthday,
    String? gender,
    String? image,
    String? townId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Non authentifié');
    }

    // Construction des données de mise à jour
    final Map<String, dynamic> updateData = {};
    
    if (username != null) updateData['username'] = username;
    if (phone != null) updateData['phone'] = phone;
    if (email != null) updateData['email'] = email;
    if (birthday != null) updateData['birthday'] = birthday;
    if (gender != null) updateData['gender'] = gender;
    if (image != null) updateData['image'] = image;
    if (townId != null) updateData['town_id'] = townId;

    print('🔄 Envoi de la mise à jour du profil...');
    print('📤 Données envoyées: $updateData');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(updateData),
    );

    print('📡 Statut HTTP: ${response.statusCode}');
    print('📦 Réponse: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      final errorMessage = _parseErrorResponse(response.body);
      throw Exception('Erreur lors de la mise à jour: $errorMessage');
    }
  }

  // --- Changement de mot de passe ---
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Non authentifié');
    }

    print('🔄 Envoi du changement de mot de passe...');
    print('👤 User ID: $userId');

    // CORRECTION : Utiliser PUT au lieu de POST et les bons noms de champs
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'password': currentPassword,        // Ancien mot de passe
        'new_password': newPassword,        // Nouveau mot de passe
        'confirm_new_password': confirmPassword, // Confirmation du nouveau mot de passe
      }),
    );

    print('📡 Statut HTTP: ${response.statusCode}');
    print('📦 Réponse: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Mot de passe changé avec succès');
      return;
    } else {
      final errorMessage = _parseErrorResponse(response.body);
      throw Exception('Erreur lors du changement de mot de passe: $errorMessage');
    }
  }

  /// Récupère les données utilisateur avec ses favoris via /me
  Future<User> getCurrentUserWithFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      throw Exception('Non authentifié');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔄 Données utilisateur récupérées avec favoris');
      print('❤️ Nombre de favoris: ${data['favorites']?.length ?? 0}');
      return User.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}');
    }
  }
}