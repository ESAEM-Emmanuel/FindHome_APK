// // lib/providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import '../api/auth_service.dart';
// import '../services/auth_service.dart';
// import '../models/user.dart';

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();
  
//   // États d'authentification
//   bool _isLoggedIn = false;
//   User? _currentUser;
//   bool _isLoading = true;
//   String? _accessToken;
//   String? _errorMessage;

//   // Getters
//   bool get isLoggedIn => _isLoggedIn;
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get accessToken => _accessToken;
//   String? get errorMessage => _errorMessage;

//   AuthProvider() {
//     _checkLoginStatus();
//   }

//   /// Charge le token d'accès depuis SharedPreferences
//   Future<void> _loadAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _accessToken = prefs.getString('access_token');
//   }

//   /// Vérifie le statut de connexion au démarrage
//   Future<void> _checkLoginStatus() async {
//     await _loadAccessToken();
    
//     final prefs = await SharedPreferences.getInstance();
//     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     _isLoading = false;

//     notifyListeners();
//   }

//   /// Connecte l'utilisateur
//   Future<void> login(String username, String password) async {
//     try {
//       _isLoading = true;
//       _errorMessage = null;
//       notifyListeners();

//       _currentUser = await _authService.login(username, password);
//       _isLoggedIn = true;
      
//       // Sauvegarde le statut de connexion
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
      
//       // Met à jour le token après connexion
//       await _loadAccessToken();
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _isLoggedIn = false;
//       _currentUser = null;
//       _accessToken = null;
//       _errorMessage = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Déconnecte l'utilisateur
//   Future<void> logout() async {
//     try {
//       await _authService.logout();
//     } finally {
//       _isLoggedIn = false;
//       _currentUser = null;
//       _accessToken = null;
//       _errorMessage = null;
      
//       // Supprime les données de connexion
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('isLoggedIn');
//       await prefs.remove('access_token');
      
//       notifyListeners();
//     }
//   }

//   /// Inscrit un nouvel utilisateur avec tous les champs
//   Future<void> register({
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
//     try {
//       _isLoading = true;
//       _errorMessage = null;
//       notifyListeners();

//       _currentUser = await _authService.register(
//         username: username,
//         phone: phone,
//         email: email,
//         birthday: birthday,
//         password: password,
//         confirmPassword: confirmPassword,
//         townId: townId,
//         gender: gender,
//         role: role,
//         image: image,
//         isStaff: isStaff,
//       );

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Efface les messages d'erreur
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   /// Recharge les données utilisateur
//   Future<void> refreshUserData() async {
//     if (_accessToken != null) {
//       // Implémentation pour recharger les données utilisateur
//       // en utilisant l'accessToken
//     }
//   }
// }
// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/property_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();
  
  // États d'authentification
  bool _isLoggedIn = false;
  User? _currentUser;
  bool _isLoading = true;
  String? _accessToken;
  String? _errorMessage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkLoginStatus();
  }

  /// Charge le token d'accès depuis SharedPreferences
  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Vérifie le statut de connexion au démarrage
  Future<void> _checkLoginStatus() async {
    await _loadAccessToken();
    
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    // Charger les données utilisateur si connecté
    if (_isLoggedIn && _accessToken != null) {
      await fetchUserProfile();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Connecte l'utilisateur
  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.login(username, password);
      _isLoggedIn = true;
      
      // Sauvegarde le statut de connexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Met à jour le token après connexion
      await _loadAccessToken();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isLoggedIn = false;
      _currentUser = null;
      _accessToken = null;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _isLoggedIn = false;
      _currentUser = null;
      _accessToken = null;
      _errorMessage = null;
      
      // Supprime les données de connexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('access_token');
      
      notifyListeners();
    }
  }

  /// Inscrit un nouvel utilisateur avec tous les champs
  Future<void> register({
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
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.register(
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Efface les messages d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Recharge les données utilisateur
  Future<void> refreshUserData() async {
    if (_accessToken != null) {
      // Implémentation pour recharger les données utilisateur
      // en utilisant l'accessToken
    }
  }

  // --- Vérifier si une propriété est en favoris actif ---
  bool isPropertyFavorite(String propertyId) {
    if (_currentUser == null || _currentUser!.favorites == null) {
      return false;
    }

    // Vérifier les favoris avec active = true ou null (considéré comme true par défaut)
    return _currentUser!.favorites!.any((favorite) {
      // Si active est null, on considère que c'est true (comportement par défaut)
      final isActive = favorite.active ?? true;
      final hasProperty = favorite.property != null;
      final isMatchingProperty = hasProperty && favorite.property!.id == propertyId;
      
      if (isMatchingProperty) {
        print('🔍 Favori trouvé: ${favorite.id}, Active: ${favorite.active} (considéré comme: $isActive)');
      }
      
      return isMatchingProperty && isActive;
    });
  }

  // --- Ajouter/retirer un favori ---
  Future<void> toggleFavorite(String propertyId) async {
    if (_accessToken == null || _currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Sauvegarder l'état précédent pour le rollback si nécessaire
      final wasFavorite = isPropertyFavorite(propertyId);
      
      // Appel API
      await _propertyService.toggleFavorite(propertyId, _accessToken!);
      
      // Recharger les données utilisateur pour synchroniser
      await fetchUserProfile();
      
    } catch (e) {
      // En cas d'erreur, recharger pour s'assurer de l'état correct
      await fetchUserProfile();
      throw Exception('Erreur lors de la modification des favoris: $e');
    }
  }

  // --- Récupération des données utilisateur détaillées ---
  // --- Récupération des données utilisateur détaillées ---
  Future<void> fetchUserProfile() async {
    if (_accessToken == null) {
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _authService.getCurrentUserWithFavorites();
      _currentUser = userData;
      
      // DEBUG DÉTAILLÉ
      print('🔄 Données utilisateur chargées');
      print('👤 Utilisateur: ${_currentUser?.username}');
      print('❤️ Nombre de favoris: ${_currentUser?.favorites?.length ?? 0}');
      
      if (_currentUser?.favorites != null) {
        for (var fav in _currentUser!.favorites!) {
          print('   - Favori: ${fav.id}');
          print('     Active: ${fav.active} (type: ${fav.active.runtimeType})');
          print('     Property ID: ${fav.property?.id}');
          print('     Property Title: ${fav.property?.title}');
        }
      }
      
      // Test de la méthode isPropertyFavorite
      if (_currentUser?.favorites != null && _currentUser!.favorites!.isNotEmpty) {
        final testPropertyId = _currentUser!.favorites!.first.property?.id;
        if (testPropertyId != null) {
          final testResult = isPropertyFavorite(testPropertyId);
          print('🧪 Test isPropertyFavorite($testPropertyId): $testResult');
        }
      }
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // --- Mise à jour du profil ---
  Future<void> updateProfile({
    String? username,
    String? phone,
    String? email,
    String? birthday,
    String? gender,
    String? image,
    String? townId,
  }) async {
    if (_currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedUser = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        username: username,
        phone: phone,
        email: email,
        birthday: birthday,
        gender: gender,
        image: image,
        townId: townId,
      );

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // --- Changement de mot de passe CORRIGÉ ---
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔄 Début du changement de mot de passe...');
      
      await _authService.changePassword(
        userId: _currentUser!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      _isLoading = false;
      
      // SUPPRIMÉ: La gestion des contrôleurs doit être faite dans le UI, pas dans le provider
      // _currentPasswordController?.clear();
      // _newPasswordController?.clear();
      // _confirmPasswordController?.clear();
      
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}