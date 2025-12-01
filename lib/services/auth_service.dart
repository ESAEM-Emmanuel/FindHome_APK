// // lib/api/auth_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user.dart';
// import '../constants/api_constants.dart';

// class AuthService {
//   static const String baseUrl = ApiConstants.baseUrl;

//   // --- Connexion ---
//   Future<User> login(String username, String password) async {
//     try {
//       print('🔄 Envoi de la requête login...');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/login'),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'grant_type': 'password',
//           'username': username,
//           'password': password,
//           'scope': '',
//           'client_id': 'string',
//           'client_secret': 'string',
//         },
//       );

//       print('📡 Statut HTTP: ${response.statusCode}');
//       print('📦 Corps de la réponse: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('🔍 Structure des données: ${data.keys}');
        
//         // Sauvegarde des tokens
//         SharedPreferences prefs = await SharedPreferences.getInstance();
        
//         final accessToken = data['access_token'];
//         final refreshToken = data['refresh_token'];
        
//         print('🔑 Access Token: ${accessToken != null ? "PRÉSENT" : "ABSENT"}');
//         print('🔑 Refresh Token: ${refreshToken != null ? "PRÉSENT" : "ABSENT"}');
        
//         if (accessToken == null) {
//           throw Exception('Aucun token d\'accès trouvé dans la réponse');
//         }
        
//         await prefs.setString('access_token', accessToken);
//         if (refreshToken != null) {
//           await prefs.setString('refresh_token', refreshToken);
//         }
//         await prefs.setBool('isLoggedIn', true);

//         // CORRECTION : L'utilisateur est dans data['user']
//         if (data['user'] != null) {
//           print('👤 Données utilisateur trouvées');
//           final user = User.fromJson(data['user']);
//           print('✅ Utilisateur parsé: ${user.username}');
//           return user;
//         } else {
//           throw Exception('Données utilisateur manquantes dans la réponse');
//         }
        
//       } else {
//         String errorMessage = 'Échec de la connexion: ${response.statusCode}';
//         try {
//           final errorData = json.decode(response.body);
//           errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
//         } catch (e) {
//           // Ignorer si le parsing échoue
//         }
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       print('❌ Erreur lors du login: $e');
//       rethrow;
//     }
//   }
//   // --- Déconnexion ---
//   Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) return;

//     await http.post(
//       Uri.parse('$baseUrl/logout'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//     );

//     // Nettoyage des données locales
//     await prefs.remove('access_token');
//     await prefs.remove('refresh_token');
//     await prefs.setBool('isLoggedIn', false);
//   }

//   // --- INSCRIPTION COMPLÈTE AVEC TOUS LES CHAMPS ---
//   Future<User> register({
//     required String username,
//     required String phone,
//     required String email,
//     required String birthday,
//     required String password,
//     required String confirmPassword,
//     required String townId,
//     String? gender,
//     String? role,
//     String? image,
//     bool isStaff = false,
//   }) async {
//     // Construction des données
//     final Map<String, dynamic> requestData = {
//       "username": username,
//       "phone": phone,
//       "email": email,
//       "birthday": birthday,
//       "password": password,
//       "confirm_password": confirmPassword,
//       "town_id": townId,
//       "is_staff": isStaff,
//     };

//     // Ajouter les champs facultatifs seulement s'ils sont fournis
//     if (gender != null && gender.isNotEmpty) {
//       requestData["gender"] = gender;
//     }
//     if (role != null && role.isNotEmpty) {
//       requestData["role"] = role;
//     }
//     if (image != null && image.isNotEmpty) {
//       requestData["image"] = image;
//     }

//     final response = await http.post(
//       Uri.parse('$baseUrl/users/'),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode(requestData),
//     );

//     if (response.statusCode == 201 || response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return User.fromJson(data);
//     } else {
//       // Gestion améliorée des erreurs
//       final errorMessage = _parseErrorResponse(response.body);
//       throw Exception(errorMessage);
//     }
//   }

//   // --- Méthode d'inscription basique (pour compatibilité) ---
//   Future<User> registerBasic({
//     required String username,
//     required String phone,
//     required String email,
//     required String password,
//   }) async {
//     return register(
//       username: username,
//       phone: phone,
//       email: email,
//       birthday: '1990-01-01',
//       password: password,
//       confirmPassword: password,
//       townId: 'e98a1690-b589-4005-9849-b93fa88bde8d',
//       gender: 'M',
//       role: 'user',
//       isStaff: false,
//     );
//   }

//   // --- Mot de passe oublié ---
//   Future<void> forgotPassword(String email) async {
//     final url = Uri.parse('$baseUrl/auth/forgot_password');
    
//     final response = await http.post(
//       url,
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'email': email, 
//       }),
//     );

//     if (response.statusCode == 200) {
//       return;
//     } else {
//       String errorMessage = 'Échec de l\'envoi de l\'email (Code: ${response.statusCode})';
//       try {
//         final errorData = json.decode(response.body);
//         errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage; 
//       } catch (e) {
//         // Ignorer l'erreur de décodage
//       }
//       throw Exception(errorMessage);
//     }
//   }

//   // --- Parse les erreurs de l'API ---
//   String _parseErrorResponse(String responseBody) {
//     try {
//       final errorData = json.decode(responseBody);
      
//       if (errorData is String) {
//         return errorData;
//       } else if (errorData is Map<String, dynamic>) {
//         if (errorData.containsKey('detail')) {
//           return errorData['detail'];
//         }
        
//         // Extraction des erreurs de validation détaillées
//         final errors = <String>[];
//         errorData.forEach((key, value) {
//           if (value is List) {
//             errors.add('${_capitalize(key)}: ${value.join(', ')}');
//           } else {
//             errors.add('${_capitalize(key)}: $value');
//           }
//         });
        
//         return errors.join('\n');
//       }
//     } catch (e) {
//       // Si le parsing échoue, retourner le corps brut
//       return responseBody;
//     }
    
//     return 'Erreur lors de l\'inscription';
//   }

//   String _capitalize(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }

//   // --- Rafraîchissement du token ---
//   Future<void> refreshToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final refreshToken = prefs.getString('refresh_token');

//     if (refreshToken == null) return;

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/refresh'),
//         headers: {'Accept': 'application/json'},
//         body: {
//           'refresh_token': refreshToken,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await prefs.setString('access_token', data['access_token']);
//       } else {
//         // Si le refresh échoue, déconnecter l'utilisateur
//         await logout();
//       }
//     } catch (e) {
//       // En cas d'erreur réseau, on garde le token actuel
//       print('Erreur lors du rafraîchissement du token: $e');
//     }
//   }

//   // --- Vérification du statut de connexion ---
//   Future<bool> checkAuthStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

//     if (!isLoggedIn || accessToken == null) {
//       return false;
//     }

//     // Optionnel: Vérifier avec l'API si le token est toujours valide
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/auth/me'),
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       return false;
//     }
//   }

//   // --- Récupération des données utilisateur ---
//   Future<User?> getCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) return null;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/auth/me'),
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $accessToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return User.fromJson(data);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }

//   // --- Récupération des données utilisateur détaillées ---
//   Future<User> getUserProfile(String userId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) {
//       throw Exception('Non authentifié');
//     }

//     final response = await http.get(
//       Uri.parse('$baseUrl/users/$userId'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return User.fromJson(data);
//     } else {
//       throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}');
//     }
//   }

//   // --- Mise à jour du profil utilisateur ---
//   Future<User> updateUserProfile({
//     required String userId,
//     String? username,
//     String? phone,
//     String? email,
//     String? birthday,
//     String? gender,
//     String? image,
//     String? townId,
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) {
//       throw Exception('Non authentifié');
//     }

//     // Construction des données de mise à jour
//     final Map<String, dynamic> updateData = {};
    
//     if (username != null) updateData['username'] = username;
//     if (phone != null) updateData['phone'] = phone;
//     if (email != null) updateData['email'] = email;
//     if (birthday != null) updateData['birthday'] = birthday;
//     if (gender != null) updateData['gender'] = gender;
//     if (image != null) updateData['image'] = image;
//     if (townId != null) updateData['town_id'] = townId;

//     print('🔄 Envoi de la mise à jour du profil...');
//     print('📤 Données envoyées: $updateData');

//     final response = await http.put(
//       Uri.parse('$baseUrl/users/$userId'),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: json.encode(updateData),
//     );

//     print('📡 Statut HTTP: ${response.statusCode}');
//     print('📦 Réponse: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return User.fromJson(data);
//     } else {
//       final errorMessage = _parseErrorResponse(response.body);
//       throw Exception('Erreur lors de la mise à jour: $errorMessage');
//     }
//   }

//   // --- Changement de mot de passe ---
//   Future<void> changePassword({
//     required String userId,
//     required String currentPassword,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) {
//       throw Exception('Non authentifié');
//     }

//     print('🔄 Envoi du changement de mot de passe...');
//     print('👤 User ID: $userId');

//     // CORRECTION : Utiliser PUT au lieu de POST et les bons noms de champs
//     final response = await http.put(
//       Uri.parse('$baseUrl/users/$userId'),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: json.encode({
//         'password': currentPassword,        // Ancien mot de passe
//         'new_password': newPassword,        // Nouveau mot de passe
//         'confirm_new_password': confirmPassword, // Confirmation du nouveau mot de passe
//       }),
//     );

//     print('📡 Statut HTTP: ${response.statusCode}');
//     print('📦 Réponse: ${response.body}');

//     if (response.statusCode == 200) {
//       print('✅ Mot de passe changé avec succès');
//       return;
//     } else {
//       final errorMessage = _parseErrorResponse(response.body);
//       throw Exception('Erreur lors du changement de mot de passe: $errorMessage');
//     }
//   }

//   /// Récupère les données utilisateur avec ses favoris via /me
//   Future<User> getCurrentUserWithFavorites() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('access_token');

//     if (accessToken == null) {
//       throw Exception('Non authentifié');
//     }

//     final response = await http.get(
//       Uri.parse('$baseUrl/me'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('🔄 Données utilisateur récupérées avec favoris');
//       print('❤️ Nombre de favoris: ${data['favorites']?.length ?? 0}');
//       return User.fromJson(data);
//     } else {
//       throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}');
//     }
//   }
// }
// lib/api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';

/// Service de gestion de l'authentification et des opérations utilisateur
/// Gère le login, logout, inscription, tokens, et profils utilisateurs
class AuthService {
  static const String baseUrl = ApiConstants.baseUrl;

  // ===========================================================================
  // MÉTHODES D'AUTHENTIFICATION
  // ===========================================================================

  /// Authentifie un utilisateur avec son nom d'utilisateur et mot de passe
  /// [username] : Nom d'utilisateur ou email
  /// [password] : Mot de passe de l'utilisateur
  /// Retourne l'objet User si l'authentification réussit
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
        return await _handleSuccessfulLogin(response);
      } else {
        throw _handleLoginError(response);
      }
    } catch (e) {
      print('❌ Erreur lors du login: $e');
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur et nettoie les données locales
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    // Appel API de déconnexion si token disponible
    if (accessToken != null) {
      await _callLogoutApi(accessToken);
    }

    // Nettoyage des données locales
    await _clearLocalAuthData(prefs);
  }

  /// Vérifie le statut d'authentification de l'utilisateur
  /// Retourne true si l'utilisateur est authentifié et le token valide
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn || accessToken == null) {
      return false;
    }

    // Vérification avec l'API si le token est toujours valide
    return await _verifyTokenWithApi(accessToken);
  }

  // ===========================================================================
  // MÉTHODES D'INSCRIPTION
  // ===========================================================================

  /// Inscrit un nouvel utilisateur avec tous les champs requis
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
    final requestData = _buildRegistrationData(
      username: username,
      phone: phone,
      email: email,
      birthday: birthday,
      password: password,
      confirmPassword: confirmPassword,
      townId: townId,
      gender: gender,
      role: role,
      image: image,
      isStaff: isStaff,
    );

    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: _getJsonHeaders(),
      body: json.encode(requestData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception(_parseErrorResponse(response.body));
    }
  }

  /// Inscription basique avec champs minimaux (pour compatibilité)
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
      townId: 'e98a1690-b589-4005-9849-b93fa88bde8d', // Ville par défaut
      gender: 'M',
      role: 'user',
      isStaff: false,
    );
  }

  // ===========================================================================
  // GESTION DES MOTS DE PASSE
  // ===========================================================================

  /// Envoie un email de réinitialisation de mot de passe
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot_password');
    
    final response = await http.post(
      url,
      headers: _getJsonHeaders(),
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseErrorResponse(response.body));
    }
  }

  /// Change le mot de passe de l'utilisateur
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final accessToken = await _getAccessToken();
    
    print('🔄 Envoi du changement de mot de passe...');
    print('👤 User ID: $userId');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getAuthJsonHeaders(accessToken!),
      body: json.encode({
        'password': currentPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmPassword,
      }),
    );

    print('📡 Statut HTTP: ${response.statusCode}');
    print('📦 Réponse: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Mot de passe changé avec succès');
    } else {
      throw Exception('Erreur lors du changement de mot de passe: ${_parseErrorResponse(response.body)}');
    }
  }

  // ===========================================================================
  // GESTION DES PROFILS UTILISATEURS
  // ===========================================================================

  /// Récupère les données de l'utilisateur connecté
  Future<User?> getCurrentUser() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getAuthHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      print('❌ Erreur récupération utilisateur: $e');
    }
    return null;
  }

  /// Récupère les données utilisateur avec ses favoris via /me
  Future<User> getCurrentUserWithFavorites() async {
    final accessToken = await _getAccessToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _getAuthHeaders(accessToken!),
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

  /// Récupère le profil détaillé d'un utilisateur par son ID
  Future<User> getUserProfile(String userId) async {
    final accessToken = await _getAccessToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getAuthHeaders(accessToken!),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}');
    }
  }

  /// Met à jour le profil utilisateur
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
    final accessToken = await _getAccessToken();
    
    final updateData = _buildProfileUpdateData(
      username: username,
      phone: phone,
      email: email,
      birthday: birthday,
      gender: gender,
      image: image,
      townId: townId,
    );

    print('🔄 Envoi de la mise à jour du profil...');
    print('📤 Données envoyées: $updateData');

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getAuthJsonHeaders(accessToken!),
      body: json.encode(updateData),
    );

    print('📡 Statut HTTP: ${response.statusCode}');
    print('📦 Réponse: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${_parseErrorResponse(response.body)}');
    }
  }

  // ===========================================================================
  // GESTION DES TOKENS
  // ===========================================================================

  /// Rafraîchit le token d'accès en utilisant le refresh token
  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: _getJsonHeaders(),
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access_token']);
      } else {
        // Si le refresh échoue, déconnecter l'utilisateur
        await logout();
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement du token: $e');
    }
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - GESTION DES RÉPONSES
  // ===========================================================================

  /// Gère une réponse de login réussie
  Future<User> _handleSuccessfulLogin(http.Response response) async {
    final data = json.decode(response.body);
    print('🔍 Structure des données: ${data.keys}');
    
    // Sauvegarde des tokens
    await _saveTokens(data);
    
    // Récupération des données utilisateur
    if (data['user'] != null) {
      print('👤 Données utilisateur trouvées');
      final user = User.fromJson(data['user']);
      print('✅ Utilisateur parsé: ${user.username}');
      return user;
    } else {
      throw Exception('Données utilisateur manquantes dans la réponse');
    }
  }

  /// Gère les erreurs de login
  Exception _handleLoginError(http.Response response) {
    String errorMessage = 'Échec de la connexion: ${response.statusCode}';
    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
    } catch (e) {
      // Ignorer si le parsing échoue
    }
    return Exception(errorMessage);
  }

  /// Sauvegarde les tokens dans le stockage local
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
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
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - CONSTRUCTION DE DONNÉES
  // ===========================================================================

  /// Construit les données pour l'inscription
  Map<String, dynamic> _buildRegistrationData({
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
  }) {
    final requestData = {
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
    if (gender != null && gender.isNotEmpty) requestData["gender"] = gender;
    if (role != null && role.isNotEmpty) requestData["role"] = role;
    if (image != null && image.isNotEmpty) requestData["image"] = image;

    return requestData;
  }

  /// Construit les données pour la mise à jour du profil
  Map<String, dynamic> _buildProfileUpdateData({
    String? username,
    String? phone,
    String? email,
    String? birthday,
    String? gender,
    String? image,
    String? townId,
  }) {
    final updateData = <String, dynamic>{};
    
    if (username != null) updateData['username'] = username;
    if (phone != null) updateData['phone'] = phone;
    if (email != null) updateData['email'] = email;
    if (birthday != null) updateData['birthday'] = birthday;
    if (gender != null) updateData['gender'] = gender;
    if (image != null) updateData['image'] = image;
    if (townId != null) updateData['town_id'] = townId;

    return updateData;
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - UTILITAIRES
  // ===========================================================================

  /// Parse les erreurs de l'API
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
    
    return 'Erreur lors de l\'opération';
  }

  /// Capitalise la première lettre d'un texte
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Récupère le token d'accès depuis le stockage local
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Appelle l'API de déconnexion
  Future<void> _callLogoutApi(String accessToken) async {
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _getAuthHeaders(accessToken),
    );
  }

  /// Nettoie les données d'authentification locales
  Future<void> _clearLocalAuthData(SharedPreferences prefs) async {
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('isLoggedIn', false);
  }

  /// Vérifie la validité du token avec l'API
  Future<bool> _verifyTokenWithApi(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getAuthHeaders(accessToken),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - CONFIGURATION DES HEADERS
  // ===========================================================================

  /// Retourne les headers pour les requêtes JSON
  Map<String, String> _getJsonHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Retourne les headers avec authentification
  Map<String, String> _getAuthHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Retourne les headers JSON avec authentification
  Map<String, String> _getAuthJsonHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}