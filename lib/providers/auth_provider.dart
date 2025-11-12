// // lib/providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../api/auth_service.dart';
// import '../models/user.dart';

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();
  
//   // États d'authentification
//   bool _isLoggedIn = false;
//   User? _currentUser;
//   bool _isLoading = true;
//   String? _accessToken;

//   // Getters
//   bool get isLoggedIn => _isLoggedIn;
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get accessToken => _accessToken;

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
//       _currentUser = await _authService.login(username, password);
//       _isLoggedIn = true;
      
//       // Sauvegarde le statut de connexion
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
      
//       // Met à jour le token après connexion
//       await _loadAccessToken();
      
//       notifyListeners();
//     } catch (e) {
//       _isLoggedIn = false;
//       _accessToken = null;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   /// Déconnecte l'utilisateur
//   Future<void> logout() async {
//     await _authService.logout();
    
//     _isLoggedIn = false;
//     _currentUser = null;
//     _accessToken = null;
    
//     // Supprime les données de connexion
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('isLoggedIn');
//     await prefs.remove('access_token');
    
//     notifyListeners();
//   }

//   /// Inscrit un nouvel utilisateur
//   Future<void> register({
//     required String username,
//     required String phone,
//     required String email,
//     required String password,
//   }) async {
//     await _authService.register(
//       username: username,
//       phone: phone,
//       email: email,
//       password: password,
//     );
//   }

//   /// Recharge les données utilisateur (à implémenter si nécessaire)
//   Future<void> refreshUserData() async {
//     if (_accessToken != null) {
//       // Implémentation pour recharger les données utilisateur
//       // en utilisant l'accessToken
//     }
//   }
// }


// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // États d'authentification
  bool _isLoggedIn = false;
  User? _currentUser;
  bool _isLoading = true;
  String? _accessToken;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;

  AuthProvider() {
    _checkLoginStatus();
  }

  /// Charge le token d'accès depuis SharedPreferences
  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Charge les données utilisateur depuis SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
      } catch (e) {
        debugPrint('Erreur lors du parsing des données utilisateur: $e');
      }
    }
  }

  /// Vérifie le statut de connexion au démarrage
  Future<void> _checkLoginStatus() async {
    await _loadAccessToken();
    await _loadUserData();
    
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isLoading = false;

    notifyListeners();
  }

  /// Connecte l'utilisateur
  Future<void> login(String username, String password) async {
    try {
      _currentUser = await _authService.login(username, password);
      _isLoggedIn = true;
      
      // Sauvegarde le statut de connexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Sauvegarde les données utilisateur
      if (_currentUser != null) {
        await prefs.setString('user_data', json.encode(_currentUser!.toJson()));
      }
      
      // Met à jour le token après connexion
      await _loadAccessToken();
      
      notifyListeners();
    } catch (e) {
      _isLoggedIn = false;
      _currentUser = null;
      _accessToken = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion API: $e');
      // Continue quand même la déconnexion locale en cas d'erreur API
    }
    
    _isLoggedIn = false;
    _currentUser = null;
    _accessToken = null;
    
    // Supprime les données de connexion
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('access_token');
    await prefs.remove('user_data');
    
    notifyListeners();
  }

  /// Inscrit un nouvel utilisateur
  Future<void> register({
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _authService.register(
      username: username,
      phone: phone,
      email: email,
      password: password,
    );
  }

  /// Recharge les données utilisateur (à implémenter si nécessaire)
  Future<void> refreshUserData() async {
    if (_accessToken != null) {
      try {
        // Implémentation pour recharger les données utilisateur
        // en utilisant l'accessToken
        // _currentUser = await _authService.getUserProfile(_accessToken!);
        notifyListeners();
      } catch (e) {
        debugPrint('Erreur lors du rafraîchissement des données utilisateur: $e');
      }
    }
  }

  /// Vérifie si l'utilisateur a un token valide
  bool get hasValidToken {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  /// Met à jour les données utilisateur
  Future<void> updateUserData(User newUserData) async {
    _currentUser = newUserData;
    
    // Sauvegarde les nouvelles données
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('user_data', json.encode(_currentUser!.toJson()));
    }
    
    notifyListeners();
  }

  /// Vérifie si l'utilisateur est administrateur
  bool get isAdmin {
    return _currentUser?.role == 'admin' || _currentUser?.isStaff == true;
  }

  /// Rafraîchit le token d'accès
  Future<void> refreshToken() async {
    if (_accessToken != null) {
      try {
        // Implémentation pour rafraîchir le token
        // final newToken = await _authService.refreshToken(_accessToken!);
        // _accessToken = newToken;
        
        // Sauvegarde le nouveau token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        
        notifyListeners();
      } catch (e) {
        debugPrint('Erreur lors du rafraîchissement du token: $e');
        // En cas d'erreur, déconnecter l'utilisateur
        await logout();
      }
    }
  }

  /// Vérifie si l'utilisateur peut effectuer une action nécessitant des privilèges
  bool canPerformAction(String action) {
    if (!_isLoggedIn) return false;
    
    switch (action) {
      case 'manage_properties':
        return isAdmin || _currentUser?.role == 'owner';
      case 'report_content':
        return _isLoggedIn;
      case 'manage_users':
        return isAdmin;
      default:
        return _isLoggedIn;
    }
  }
}