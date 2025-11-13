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
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../api/auth_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
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
}