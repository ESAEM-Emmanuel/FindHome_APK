// // lib/services/property_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/property_model.dart';
// import '../constants/api_constants.dart';

// class PropertyService {
//   static const String _baseUrl = ApiConstants.baseUrl;

//   /// Headers communs pour les requêtes API
//   static const Map<String, String> _defaultHeaders = {
//     'accept': 'application/json',
//   };

//   /// Headers pour les requêtes avec body JSON
//   static Map<String, String> _jsonHeaders(String? accessToken) {
//     final headers = {
//       'Content-Type': 'application/json',
//       ..._defaultHeaders,
//     };
    
//     if (accessToken != null) {
//       headers['Authorization'] = 'Bearer $accessToken';
//     }
    
//     return headers;
//   }

//   /// Gère les réponses HTTP et lance les exceptions appropriées
//   dynamic _handleResponse(http.Response response) {
//     final statusCode = response.statusCode;
    
//     if (statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       final errorBody = json.decode(response.body);
//       final detail = errorBody['detail'] as String? ?? 'Erreur inconnue';
      
//       switch (statusCode) {
//         case 401:
//         case 403:
//           throw Exception('Authentification requise. Veuillez vous reconnecter.');
//         case 404:
//           throw Exception('Ressource non trouvée.');
//         case 500:
//           throw Exception('Erreur interne du serveur.');
//         default:
//           throw Exception('Échec de la requête: Code $statusCode. Détail: $detail');
//       }
//     }
//   }

//   /// Effectue une requête HTTP avec gestion d'erreur centralisée
//   Future<dynamic> _makeRequest(Future<http.Response> Function() request) async {
//     try {
//       final response = await request();
//       return _handleResponse(response);
//     } on FormatException {
//       throw Exception('Erreur de format des données reçues.');
//     } on http.ClientException {
//       throw Exception('Erreur de connexion. Vérifiez votre connexion internet.');
//     } catch (e) {
//       if (e is Exception) rethrow;
//       throw Exception('Erreur inattendue: $e');
//     }
//   }

//   /// Construit les paramètres de requête pour la liste des propriétés
//   Map<String, String> _buildPropertyQueryParams({
//     required int page,
//     required int limit,
//     String? search,
//     String? categoryId,
//     String? townId,
//     Map<String, dynamic>? filters,
//   }) {
//     final queryParams = <String, String>{
//       'page': page.toString(),
//       'limit': limit.toString(),
//       'order': 'asc',
//       'sort_by': 'title',
//     };

//     // Ajout des paramètres optionnels
//     if (search != null && search.isNotEmpty) {
//       queryParams['search'] = search;
//     }
//     if (categoryId != null) {
//       queryParams['category_property_id'] = categoryId;
//     }
//     if (townId != null) {
//       queryParams['town_id'] = townId;
//     }

//     // Ajout des filtres dynamiques
//     if (filters != null) {
//       for (final entry in filters.entries) {
//         if (entry.value != null) {
//           queryParams[entry.key] = entry.value.toString();
//         }
//       }
//     }

//     return queryParams;
//   }

//   /// Récupère la liste des propriétés avec filtres
//   Future<PropertyListResponse> getProperties({
//     int page = 1,
//     int limit = 10,
//     String? search,
//     String? categoryId,
//     String? townId,
//     Map<String, dynamic>? filters,
//   }) async {
//     final queryParams = _buildPropertyQueryParams(
//       page: page,
//       limit: limit,
//       search: search,
//       categoryId: categoryId,
//       townId: townId,
//       filters: filters,
//     );

//     final uri = Uri.parse('$_baseUrl/properties/').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les détails d'une propriété spécifique
//   Future<Property> getPropertyDetail(String id) async {
//     final uri = Uri.parse('$_baseUrl/properties/$id');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return Property.fromJson(data);
//   }

//   /// Ajoute ou retire une propriété des favoris
//   Future<Favorite> toggleFavorite(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$_baseUrl/favorites/');
//     final body = json.encode({'property_id': propertyId});

//     final data = await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
    
//     return Favorite.fromJson(data);
//   }

//   /// Récupère la liste des propriétés favorites de l'utilisateur
//   Future<PropertyListResponse> getFavorites(String accessToken) async {
//     final uri = Uri.parse('$_baseUrl/favorites/');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Vérifie si une propriété est dans les favoris de l'utilisateur
//   Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$_baseUrl/favorites/check/$propertyId');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return data['is_favorite'] as bool? ?? false;
//   }
// }

// lib/services/property_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../constants/api_constants.dart';

class PropertyService {
  static const String baseUrl = ApiConstants.baseUrl;

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
    
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {}; // Retourne un Map vide si pas de contenu
      }
      return json.decode(response.body);
    } else {
      String errorDetail = 'Erreur inconnue';
      
      try {
        final errorBody = json.decode(response.body);
        errorDetail = errorBody['detail'] as String? ?? errorBody['message'] as String? ?? 'Erreur inconnue';
      } catch (e) {
        errorDetail = 'Erreur de format de réponse';
      }
      
      switch (statusCode) {
        case 401:
        case 403:
          throw Exception('Authentification requise. Veuillez vous reconnecter.');
        case 404:
          throw Exception('Ressource non trouvée.');
        case 500:
          throw Exception('Erreur interne du serveur.');
        default:
          throw Exception('Échec de la requête: Code $statusCode. Détail: $errorDetail');
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

    final uri = Uri.parse('$baseUrl/properties/').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les détails d'une propriété spécifique
  Future<Property> getPropertyDetail(String id) async {
    final uri = Uri.parse('$baseUrl/properties/$id');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return Property.fromJson(data);
  }

  /// Vérifie si une propriété est en favoris
  Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/favorites/check/$propertyId');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return data['is_favorite'] as bool? ?? false;
  }

  /// Ajoute/retire une propriété des favoris
  Future<void> toggleFavorite(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/favorites/toggle');
    final body = json.encode({'property_id': propertyId});

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
  }

  /// Récupère la liste des propriétés favorites de l'utilisateur
  Future<PropertyListResponse> getFavorites(String accessToken) async {
    final uri = Uri.parse('$baseUrl/favorites/');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return PropertyListResponse.fromJson(data);
  }

  /// Signale une propriété
  Future<void> reportProperty(String propertyId, String description, String accessToken) async {
    final uri = Uri.parse('$baseUrl/signals/');
    final body = json.encode({
      'property_id': propertyId,
      'description': description,
    });

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
  }

  /// Signale un utilisateur
  Future<void> reportUser(String offenderId, String description, String accessToken) async {
    final uri = Uri.parse('$baseUrl/signals/');
    final body = json.encode({
      'offender_id': offenderId,
      'description': description,
    });

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
  }
}