// // lib/providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../api/auth_service.dart';
// import '../models/user.dart';

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();
//   bool _isLoggedIn = false;
//   User? _currentUser;
//   bool _isLoading = true;

//   bool get isLoggedIn => _isLoggedIn;
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;

//   AuthProvider() {
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     _isLoading = false;
//     // Tenter de récupérer les données utilisateur si loggedIn
//     if (_isLoggedIn) {
//       // NOTE: Idéalement, on utiliserait le token pour appeler l'endpoint /me ici
//       // mais pour l'exemple, on s'en tient au statut de base.
//     }
//     notifyListeners();
//   }

//   Future<void> login(String username, String password) async {
//     try {
//       _currentUser = await _authService.login(username, password);
//       _isLoggedIn = true;
//       notifyListeners();
//     } catch (e) {
//       // Propager l'erreur pour affichage dans l'UI
//       _isLoggedIn = false;
//       notifyListeners();
//       rethrow; 
//     }
//   }
  
//   // Note: la logique de _logout est plus simple ici car elle utilise le service.
//   Future<void> logout() async {
//     await _authService.logout();
//     _isLoggedIn = false;
//     _currentUser = null;
//     notifyListeners();
//   }

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
//     // Après l'inscription, l'utilisateur devra se connecter.
//   }
// }
// lib/providers/auth_provider.dart
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
      _currentUser = await _authService.login(username, password);
      _isLoggedIn = true;
      
      // Sauvegarde le statut de connexion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Met à jour le token après connexion
      await _loadAccessToken();
      
      notifyListeners();
    } catch (e) {
      _isLoggedIn = false;
      _accessToken = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> logout() async {
    await _authService.logout();
    
    _isLoggedIn = false;
    _currentUser = null;
    _accessToken = null;
    
    // Supprime les données de connexion
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('access_token');
    
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
      // Implémentation pour recharger les données utilisateur
      // en utilisant l'accessToken
    }
  }
}