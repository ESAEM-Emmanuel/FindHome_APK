
// // lib/services/property_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/property_model.dart';
// import '../constants/api_constants.dart';

// class PropertyService {
//   static const String baseUrl = ApiConstants.baseUrl;

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
    
//     if (statusCode >= 200 && statusCode < 300) {
//       if (response.body.isEmpty) {
//         return {}; // Retourne un Map vide si pas de contenu
//       }
//       return json.decode(response.body);
//     } else {
//       String errorDetail = 'Erreur inconnue';
      
//       try {
//         final errorBody = json.decode(response.body);
//         errorDetail = errorBody['detail'] as String? ?? errorBody['message'] as String? ?? 'Erreur inconnue';
//       } catch (e) {
//         errorDetail = 'Erreur de format de réponse';
//       }
      
//       switch (statusCode) {
//         case 401:
//         case 403:
//           throw Exception('Authentification requise. Veuillez vous reconnecter.');
//         case 404:
//           throw Exception('Ressource non trouvée.');
//         case 500:
//           throw Exception('Erreur interne du serveur.');
//         default:
//           throw Exception('Échec de la requête: Code $statusCode. Détail: $errorDetail');
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

//     final uri = Uri.parse('$baseUrl/properties/').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les détails d'une propriété spécifique
//   Future<Property> getPropertyDetail(String id) async {
//     final uri = Uri.parse('$baseUrl/properties/$id');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return Property.fromJson(data);
//   }

//   /// Crée une nouvelle propriété
//   Future<Property> createProperty(Map<String, dynamic> propertyData, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/');
//     final body = json.encode(propertyData);

//     final data = await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
    
//     return Property.fromJson(data);
//   }

//   /// Vérifie si une propriété est en favoris
//   Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/favorites/check/$propertyId');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return data['is_favorite'] as bool? ?? false;
//   }

//   /// Ajoute/retire une propriété des favoris
//   Future<void> toggleFavorite(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/favorites/toggle');
//     final body = json.encode({'property_id': propertyId});

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
//   }

//   /// Récupère la liste des propriétés favorites de l'utilisateur
//   Future<PropertyListResponse> getFavorites(String accessToken) async {
//     final uri = Uri.parse('$baseUrl/favorites/');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Signale une propriété
//   Future<void> reportProperty(String propertyId, String description, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/signals/');
//     final body = json.encode({
//       'property_id': propertyId,
//       'description': description,
//     });

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
//   }

//   /// Signale un utilisateur
//   Future<void> reportUser(String offenderId, String description, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/signals/');
//     final body = json.encode({
//       'offender_id': offenderId,
//       'description': description,
//     });

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
//   }

//   /// Met à jour une propriété existante
//   Future<Property> updateProperty(String propertyId, Map<String, dynamic> propertyData, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/$propertyId');
//     final body = json.encode(propertyData);

//     final data = await _makeRequest(
//       () => http.put(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
    
//     return Property.fromJson(data);
//   }

//   /// Supprime une propriété
//   Future<void> deleteProperty(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/$propertyId');

//     await _makeRequest(
//       () => http.delete(
//         uri,
//         headers: _jsonHeaders(accessToken),
//       ),
//     );
//   }

//   /// Recherche avancée de propriétés avec plusieurs critères
//   Future<PropertyListResponse> searchProperties({
//     int page = 1,
//     int limit = 10,
//     String? title,
//     String? description,
//     int? minPrice,
//     int? maxPrice,
//     int? minArea,
//     int? maxArea,
//     String? townId,
//     String? categoryId,
//     bool? certified,
//   }) async {
//     final filters = <String, dynamic>{};
    
//     if (title != null && title.isNotEmpty) filters['title'] = title;
//     if (description != null && description.isNotEmpty) filters['description'] = description;
//     if (minPrice != null) filters['min_price'] = minPrice;
//     if (maxPrice != null) filters['max_price'] = maxPrice;
//     if (minArea != null) filters['min_area'] = minArea;
//     if (maxArea != null) filters['max_area'] = maxArea;
//     if (certified != null) filters['certified'] = certified;

//     final queryParams = _buildPropertyQueryParams(
//       page: page,
//       limit: limit,
//       townId: townId,
//       categoryId: categoryId,
//       filters: filters,
//     );

//     final uri = Uri.parse('$baseUrl/properties/').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les propriétés d'un utilisateur spécifique
//   Future<PropertyListResponse> getUserProperties(String userId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/user/$userId');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les propriétés similaires
//   Future<PropertyListResponse> getSimilarProperties(String propertyId, {int limit = 5}) async {
//     final uri = Uri.parse('$baseUrl/properties/$propertyId/similar?limit=$limit');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Incrémente le compteur de visites d'une propriété
//   Future<void> incrementVisitCount(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/$propertyId/visit');

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//       ),
//     );
//   }

//   /// Vérifie les permissions de l'utilisateur sur une propriété
//   Future<Map<String, dynamic>> checkPropertyPermissions(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl/properties/$propertyId/permissions');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return data as Map<String, dynamic>;
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
        if (entry.value != null && entry.value.toString().isNotEmpty) {
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

  /// Crée une nouvelle propriété
  Future<Property> createProperty(Map<String, dynamic> propertyData, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/');
    final body = json.encode(propertyData);

    final data = await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
    
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

  /// Met à jour une propriété existante
  Future<Property> updateProperty(String propertyId, Map<String, dynamic> propertyData, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/$propertyId');
    final body = json.encode(propertyData);

    final data = await _makeRequest(
      () => http.put(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
    
    return Property.fromJson(data);
  }

  /// Supprime une propriété
  Future<void> deleteProperty(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/$propertyId');

    await _makeRequest(
      () => http.delete(
        uri,
        headers: _jsonHeaders(accessToken),
      ),
    );
  }

  /// Recherche avancée de propriétés avec plusieurs critères
  Future<PropertyListResponse> searchProperties({
    int page = 1,
    int limit = 10,
    String? title,
    String? description,
    int? minPrice,
    int? maxPrice,
    int? minArea,
    int? maxArea,
    String? townId,
    String? categoryId,
    bool? certified,
  }) async {
    final filters = <String, dynamic>{};
    
    if (title != null && title.isNotEmpty) filters['title'] = title;
    if (description != null && description.isNotEmpty) filters['description'] = description;
    if (minPrice != null) filters['min_price'] = minPrice;
    if (maxPrice != null) filters['max_price'] = maxPrice;
    if (minArea != null) filters['min_area'] = minArea;
    if (maxArea != null) filters['max_area'] = maxArea;
    if (certified != null) filters['certified'] = certified;

    final queryParams = _buildPropertyQueryParams(
      page: page,
      limit: limit,
      townId: townId,
      categoryId: categoryId,
      filters: filters,
    );

    final uri = Uri.parse('$baseUrl/properties/').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les propriétés d'un utilisateur spécifique
  Future<PropertyListResponse> getUserProperties(String userId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/user/$userId');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les propriétés similaires
  Future<PropertyListResponse> getSimilarProperties(String propertyId, {int limit = 5}) async {
    final uri = Uri.parse('$baseUrl/properties/$propertyId/similar?limit=$limit');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Incrémente le compteur de visites d'une propriété
  Future<void> incrementVisitCount(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/$propertyId/visit');

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
      ),
    );
  }

  /// Vérifie les permissions de l'utilisateur sur une propriété
  Future<Map<String, dynamic>> checkPropertyPermissions(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl/properties/$propertyId/permissions');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return data as Map<String, dynamic>;
  }

  /// NOUVELLE MÉTHODE : Récupère les propriétés avec des filtres avancés
  Future<PropertyListResponse> getPropertiesWithFilters(Map<String, dynamic> filters) async {
    try {
      // Construire les paramètres de requête
      final queryParams = <String, String>{};
      
      // Ajouter tous les filtres non vides
      filters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          queryParams[key] = value.toString();
        }
      });

      // S'assurer que les paramètres de pagination sont présents
      if (!queryParams.containsKey('page')) {
        queryParams['page'] = '1';
      }
      if (!queryParams.containsKey('limit')) {
        queryParams['limit'] = '10';
      }
      if (!queryParams.containsKey('order')) {
        queryParams['order'] = 'asc';
      }

      final uri = Uri.parse('$baseUrl/properties/').replace(queryParameters: queryParams);

      final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
      return PropertyListResponse.fromJson(data);
      
    } on FormatException {
      throw Exception('Erreur de format des données reçues.');
    } on http.ClientException {
      throw Exception('Erreur de connexion. Vérifiez votre connexion internet.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// NOUVELLE MÉTHODE : Récupère les villes disponibles
  Future<List<dynamic>> getTowns() async {
    final uri = Uri.parse('$baseUrl/towns/');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return data['records'] as List<dynamic>;
  }

  /// NOUVELLE MÉTHODE : Récupère les catégories disponibles
  Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories/');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return data['records'] as List<dynamic>;
  }

  /// NOUVELLE MÉTHODE : Réinitialise les filtres
  Map<String, dynamic> getDefaultFilters() {
    return {
      'search': '',
      'title': '',
      'address': '',
      'monthly_price': '',
      'monthly_price_bis': '',
      'monthly_price_operation': '',
      'area': '',
      'area_bis': '',
      'area_operation': '',
      'rooms_nb': '',
      'rooms_nb_bis': '',
      'rooms_nb_operation': '',
      'bathrooms_nb': '',
      'bathrooms_nb_bis': '',
      'bathrooms_nb_operation': '',
      'living_rooms_nb': '',
      'living_rooms_nb_bis': '',
      'living_rooms_nb_operation': '',
      'compartment_number': '',
      'compartment_number_bis': '',
      'compartment_number_operation': '',
      'status': '',
      'water_supply': '',
      'electrical_connection': '',
      'town_id': '',
      'category_property_id': '',
      'certified': '',
      'has_internal_kitchen': '',
      'has_external_kitchen': '',
      'has_a_parking': '',
      'has_air_conditioning': '',
      'has_security_guards': '',
      'has_balcony': '',
      'order': 'asc',
    };
  }
}