// // lib/services/property_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/property_model.dart';

// class PropertyService {
//   static const String _baseUrl = 'http://127.0.0.1:8000';
  
//   // Définit les paramètres de requête de manière structurée
//   // Ici, nous ne gérons qu'une partie des filtres
//   Future<PropertyListResponse> getProperties({
//     int page = 1,
//     int limit = 10,
//     String? categoryId,
//     String? townId,
//     Map<String, dynamic>? filters,
//   }) async {
//     // Construction des paramètres de requête
//     final Map<String, String> queryParams = {
//       'page': page.toString(),
//       'limit': limit.toString(),
//       'order': 'asc',
//       'sort_by': 'title',
//     };
    
//     if (categoryId != null) queryParams['category_property_id'] = categoryId;
//     if (townId != null) queryParams['town_id'] = townId;
    
//     // Ajout des filtres personnalisés (status, certified, etc.)
//     if (filters != null) {
//       filters.forEach((key, value) {
//         if (value != null) {
//           queryParams[key] = value.toString();
//         }
//       });
//     }

//     final uri = Uri.parse('$_baseUrl/properties/').replace(queryParameters: queryParams);
    
//     try {
//       final response = await http.get(uri, headers: {'accept': 'application/json'});

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return PropertyListResponse.fromJson(data);
//       } else {
//         // Gérer les erreurs de serveur (404, 500, etc.)
//         throw Exception('Échec du chargement des propriétés: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Gérer les erreurs de réseau ou de parsing
//       throw Exception('Erreur de connexion ou de traitement des données: $e');
//     }
//   }

//   // Future<Property> getPropertyDetail(String id) async { ... }
// }
// lib/services/property_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/property_model.dart';
// import '../constants/api_constants.dart';

// class PropertyService {
//   // ADRESSE IP DU SERVEUR BACKEND - VÉRIFIEZ QUE C'EST CORRECT
//   static const String _baseUrl = ApiConstants.baseUrl; 
//   // static const String _baseUrl = 'http://172.19.120.38:8000'; 

//   // 1. Récupérer la liste des propriétés (pour HomePage)
//   Future<PropertyListResponse> getProperties({
//     int page = 1,
//     int limit = 10,
//     String? search, 
//     String? categoryId,
//     String? townId,
//     Map<String, dynamic>? filters,
//   }) async {
//     final Map<String, String> queryParams = {
//       'page': page.toString(),
//       'limit': limit.toString(),
//       'order': 'asc',
//       'sort_by': 'title',
//     };
    
//     if (search != null && search.isNotEmpty) queryParams['search'] = search;
//     if (categoryId != null) queryParams['category_property_id'] = categoryId;
//     if (townId != null) queryParams['town_id'] = townId;
    
//     // Ajout des filtres dynamiques
//     if (filters != null) {
//       filters.forEach((key, value) {
//         if (value != null) {
//           queryParams[key] = value.toString();
//         }
//       });
//     }

//     final uri = Uri.parse('$_baseUrl/properties/').replace(queryParameters: queryParams);
    
//     try {
//       final response = await http.get(uri, headers: {'accept': 'application/json'});

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return PropertyListResponse.fromJson(data);
//       } else {
//         throw Exception('Échec du chargement des propriétés: Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Propagation de l'erreur pour affichage sur l'UI
//       throw Exception('Erreur de connexion ou de traitement des données: $e');
//     }
//   }

//   // 2. Récupérer les détails d'une propriété (pour PropertyDetailPage)
//   Future<Property> getPropertyDetail(String id) async {
//     final uri = Uri.parse('$_baseUrl/properties/$id');
    
//     try {
//       final response = await http.get(uri, headers: {'accept': 'application/json'});

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         // Utilise le même modèle Property étendu
//         return Property.fromJson(data); 
//       } else {
//         throw Exception('Échec du chargement des détails: Code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Propagation de l'erreur pour affichage sur l'UI
//       throw Exception('Erreur de connexion ou de traitement des données: $e');
//     }
//   }
// }
// lib/services/property_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../constants/api_constants.dart';

class PropertyService {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Headers communs pour les requêtes API
  static const Map<String, String> _defaultHeaders = {
    'accept': 'application/json',
  };

  /// Headers pour les requêtes avec body JSON
  static Map<String, String> _jsonHeaders(String? accessToken) {
    final headers = {
      'Content-Type': 'application/json',
      ..._defaultHeaders,
    };
    
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    return headers;
  }

  /// Gère les réponses HTTP et lance les exceptions appropriées
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    if (statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      final detail = errorBody['detail'] as String? ?? 'Erreur inconnue';
      
      switch (statusCode) {
        case 401:
        case 403:
          throw Exception('Authentification requise. Veuillez vous reconnecter.');
        case 404:
          throw Exception('Ressource non trouvée.');
        case 500:
          throw Exception('Erreur interne du serveur.');
        default:
          throw Exception('Échec de la requête: Code $statusCode. Détail: $detail');
      }
    }
  }

  /// Effectue une requête HTTP avec gestion d'erreur centralisée
  Future<dynamic> _makeRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on FormatException {
      throw Exception('Erreur de format des données reçues.');
    } on http.ClientException {
      throw Exception('Erreur de connexion. Vérifiez votre connexion internet.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Construit les paramètres de requête pour la liste des propriétés
  Map<String, String> _buildPropertyQueryParams({
    required int page,
    required int limit,
    String? search,
    String? categoryId,
    String? townId,
    Map<String, dynamic>? filters,
  }) {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'order': 'asc',
      'sort_by': 'title',
    };

    // Ajout des paramètres optionnels
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['category_property_id'] = categoryId;
    }
    if (townId != null) {
      queryParams['town_id'] = townId;
    }

    // Ajout des filtres dynamiques
    if (filters != null) {
      for (final entry in filters.entries) {
        if (entry.value != null) {
          queryParams[entry.key] = entry.value.toString();
        }
      }
    }

    return queryParams;
  }

  /// Récupère la liste des propriétés avec filtres
  Future<PropertyListResponse> getProperties({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? townId,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = _buildPropertyQueryParams(
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
      townId: townId,
      filters: filters,
    );

    final uri = Uri.parse('$_baseUrl/properties/').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les détails d'une propriété spécifique
  Future<Property> getPropertyDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/properties/$id');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return Property.fromJson(data);
  }

  /// Ajoute ou retire une propriété des favoris
  Future<Favorite> toggleFavorite(String propertyId, String accessToken) async {
    final uri = Uri.parse('$_baseUrl/favorites/');
    final body = json.encode({'property_id': propertyId});

    final data = await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
    
    return Favorite.fromJson(data);
  }

  /// Récupère la liste des propriétés favorites de l'utilisateur
  Future<PropertyListResponse> getFavorites(String accessToken) async {
    final uri = Uri.parse('$_baseUrl/favorites/');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return PropertyListResponse.fromJson(data);
  }

  /// Vérifie si une propriété est dans les favoris de l'utilisateur
  Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
    final uri = Uri.parse('$_baseUrl/favorites/check/$propertyId');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return data['is_favorite'] as bool? ?? false;
  }
}