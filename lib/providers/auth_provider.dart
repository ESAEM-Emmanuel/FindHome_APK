// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  User? _currentUser;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isLoading = false;
    // Tenter de récupérer les données utilisateur si loggedIn
    if (_isLoggedIn) {
      // NOTE: Idéalement, on utiliserait le token pour appeler l'endpoint /me ici
      // mais pour l'exemple, on s'en tient au statut de base.
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    try {
      _currentUser = await _authService.login(username, password);
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      // Propager l'erreur pour affichage dans l'UI
      _isLoggedIn = false;
      notifyListeners();
      rethrow; 
    }
  }
  
  // Note: la logique de _logout est plus simple ici car elle utilise le service.
  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

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
    // Après l'inscription, l'utilisateur devra se connecter.
  }
}