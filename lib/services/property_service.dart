// // lib/services/property_service.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../models/property_model.dart';
// import '../constants/api_constants.dart';

// /// Service de gestion des propriétés immobilières
// /// Centralise toutes les opérations liées aux propriétés : récupération, création, modification, favoris, etc.
// class PropertyService {
//   static const String baseUrl = ApiConstants.baseUrl;

//   // ===========================================================================
//   // CONSTANTES ET CONFIGURATION
//   // ===========================================================================

//   /// Headers communs pour les requêtes API sans authentification
//   static const Map<String, String> _defaultHeaders = {
//     'accept': 'application/json',
//   };

//   /// Paramètres de pagination par défaut
//   static const int _defaultPage = 1;
//   static const int _defaultLimit = 10;
//   static const String _defaultOrder = 'asc';
//   static const String _defaultSortBy = 'title';

//   /// Endpoints de l'API
//   static const String _propertiesEndpoint = '/properties/';
//   static const String _favoritesEndpoint = '/favorites/';
//   static const String _signalsEndpoint = '/signals/';
//   static const String _townsEndpoint = '/towns/';
//   static const String _categoriesEndpoint = '/categories/';

//   // ===========================================================================
//   // MÉTHODES UTILITAIRES PRIVÉES
//   // ===========================================================================

//   /// Construit les headers pour les requêtes avec authentification et JSON
//   /// [accessToken] : Token JWT pour l'authentification (optionnel)
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
//   /// [response] : Réponse HTTP à traiter
//   /// Retourne les données décodées ou lance une exception
//   dynamic _handleResponse(http.Response response) {
//     final statusCode = response.statusCode;
    
//     // Gestion des codes de succès
//     if (statusCode >= 200 && statusCode < 300) {
//       if (response.body.isEmpty) {
//         return {}; // Retourne un Map vide si pas de contenu
//       }
//       return json.decode(response.body);
//     } else {
//       // Gestion des erreurs
//       String errorDetail = 'Erreur inconnue';
      
//       try {
//         final errorBody = json.decode(response.body);
//         errorDetail = errorBody['detail'] as String? ?? 
//                      errorBody['message'] as String? ?? 
//                      'Erreur inconnue';
//       } catch (e) {
//         errorDetail = 'Erreur de format de réponse';
//       }
      
//       // Exceptions spécifiques selon le code HTTP
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
//   /// [request] : Fonction retournant une Future<http.Response>
//   /// Retourne les données traitées ou lance une exception
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
//       'order': _defaultOrder,
//       'sort_by': _defaultSortBy,
//     };

//     // Ajout des paramètres optionnels de base
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
//         if (entry.value != null && entry.value.toString().isNotEmpty) {
//           queryParams[entry.key] = entry.value.toString();
//         }
//       }
//     }

//     return queryParams;
//   }

//   // ===========================================================================
//   // MÉTHODES DE RÉCUPÉRATION DE PROPRIÉTÉS
//   // ===========================================================================

//   /// Récupère la liste paginée des propriétés avec filtres optionnels
//   Future<PropertyListResponse> getProperties({
//     int page = _defaultPage,
//     int limit = _defaultLimit,
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

//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les détails d'une propriété spécifique par son ID
//   Future<Property> getPropertyDetail(String id) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$id');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return Property.fromJson(data);
//   }

//   /// Recherche avancée de propriétés avec plusieurs critères
//   Future<PropertyListResponse> searchProperties({
//     int page = _defaultPage,
//     int limit = _defaultLimit,
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
    
//     // Construction des filtres de recherche
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

//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les propriétés similaires à une propriété donnée
//   Future<PropertyListResponse> getSimilarProperties(String propertyId, {int limit = 5}) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/similar?limit=$limit');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère les propriétés d'un utilisateur spécifique
//   Future<PropertyListResponse> getUserProperties(String userId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint/user/$userId');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return PropertyListResponse.fromJson(data);
//   }

//   // ===========================================================================
//   // MÉTHODES DE GESTION DES PROPRIÉTÉS (CRUD)
//   // ===========================================================================

//   /// Crée une nouvelle propriété
//   Future<Property> createProperty(Map<String, dynamic> propertyData, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint');
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

//   /// Met à jour une propriété existante
//   Future<Property> updateProperty(String propertyId, Map<String, dynamic> propertyData, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId');
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
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId');

//     await _makeRequest(
//       () => http.delete(
//         uri,
//         headers: _jsonHeaders(accessToken),
//       ),
//     );
//   }

//   // ===========================================================================
//   // MÉTHODES DE GESTION DES FAVORIS
//   // ===========================================================================

//   /// Ajoute ou retire une propriété des favoris de l'utilisateur
//   Future<void> toggleFavorite(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_favoritesEndpoint');
//     final body = json.encode({'property_id': propertyId});

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//         body: body,
//       ),
//     );
//   }

//   /// Récupère la liste paginée des propriétés favorites de l'utilisateur
//   Future<PropertyListResponse> getFavorites(String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_favoritesEndpoint');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère toutes les propriétés favorites de l'utilisateur avec statut actif
//   Future<List<Property>> getUserFavorites(String accessToken, {String? ownerId}) async {
//     final queryParams = <String, String>{
//       'order': _defaultOrder,
//       'sort_by': 'created_at',
//       'page': _defaultPage.toString(),
//       'get_all': 'true',
//       'active': 'true', // Seulement les favoris actifs
//     };

//     if (ownerId != null) {
//       queryParams['owner_id'] = ownerId;
//     }

//     final uri = Uri.parse('$baseUrl$_favoritesEndpoint').replace(queryParameters: queryParams);

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     // Extraire les propriétés des favoris
//     final records = data['records'] as List<dynamic>;
//     return records.map((fav) => Property.fromJson(fav['property'])).toList();
//   }

//   /// Vérifie si une propriété est dans les favoris actifs de l'utilisateur
//   Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
//     try {
//       final queryParams = <String, String>{
//         'order': _defaultOrder,
//         'sort_by': 'created_at',
//         'page': _defaultPage.toString(),
//         'get_all': 'true',
//         'active': 'true',
//         'property_id': propertyId, // Filtrer par propriété spécifique
//       };

//       final uri = Uri.parse('$baseUrl$_favoritesEndpoint').replace(queryParameters: queryParams);

//       final data = await _makeRequest(
//         () => http.get(uri, headers: _jsonHeaders(accessToken)),
//       );
      
//       final records = data['records'] as List<dynamic>;
//       // Si on a au moins un favori actif pour cette propriété
//       return records.isNotEmpty;
//     } catch (e) {
//       debugPrint("Erreur lors de la vérification des favoris: $e");
//       return false;
//     }
//   }

//   // ===========================================================================
//   // MÉTHODES DE SIGNALEMENT
//   // ===========================================================================

//   /// Signale une propriété pour contenu inapproprié
//   Future<void> reportProperty(String propertyId, String description, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_signalsEndpoint');
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

//   /// Signale un utilisateur pour comportement inapproprié
//   Future<void> reportUser(String offenderId, String description, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_signalsEndpoint');
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

//   // ===========================================================================
//   // MÉTHODES DE STATISTIQUES ET PERMISSIONS
//   // ===========================================================================

//   /// Incrémente le compteur de visites d'une propriété
//   Future<void> incrementVisitCount(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/visit');

//     await _makeRequest(
//       () => http.post(
//         uri,
//         headers: _jsonHeaders(accessToken),
//       ),
//     );
//   }

//   /// Vérifie les permissions de l'utilisateur sur une propriété
//   Future<Map<String, dynamic>> checkPropertyPermissions(String propertyId, String accessToken) async {
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/permissions');

//     final data = await _makeRequest(
//       () => http.get(uri, headers: _jsonHeaders(accessToken)),
//     );
    
//     return data as Map<String, dynamic>;
//   }

//   // ===========================================================================
//   // MÉTHODES DE RÉCUPÉRATION DES DONNÉES DE RÉFÉRENCE
//   // ===========================================================================

//   /// Récupère la liste des villes disponibles
//   Future<List<dynamic>> getTowns() async {
//     final uri = Uri.parse('$baseUrl$_townsEndpoint');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return data['records'] as List<dynamic>;
//   }

//   /// Récupère la liste des catégories disponibles
//   Future<List<dynamic>> getCategories() async {
//     final uri = Uri.parse('$baseUrl$_categoriesEndpoint');

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return data['records'] as List<dynamic>;
//   }

//   // ===========================================================================
//   // MÉTHODES AVANCÉES DE FILTRAGE
//   // ===========================================================================

//   /// Récupère les propriétés avec des filtres avancés
//   Future<PropertyListResponse> getPropertiesWithFilters(Map<String, dynamic> filters) async {
//     final queryParams = _buildQueryParamsFromFilters(filters);
//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Récupère TOUTES les propriétés avec des filtres avancés (sans pagination)
//   Future<PropertyListResponse> getAllPropertiesWithFilters(Map<String, dynamic> filters) async {
//     final queryParams = _buildQueryParamsFromFilters(filters);
    
//     // FORCER la récupération de tous les éléments
//     queryParams['get_all'] = 'true';
//     queryParams['page'] = _defaultPage.toString();

//     // Paramètres par défaut pour la récupération complète
//     if (!queryParams.containsKey('order')) {
//       queryParams['order'] = _defaultOrder;
//     }
//     if (!queryParams.containsKey('active')) {
//       queryParams['active'] = 'true'; // Toujours les propriétés actives
//     }

//     final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

//     final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
//     return PropertyListResponse.fromJson(data);
//   }

//   /// Construit les paramètres de requête à partir d'un map de filtres
//   Map<String, String> _buildQueryParamsFromFilters(Map<String, dynamic> filters) {
//     final queryParams = <String, String>{};
    
//     // Ajouter tous les filtres non vides
//     filters.forEach((key, value) {
//       if (value != null && value.toString().isNotEmpty) {
//         queryParams[key] = value.toString();
//       }
//     });

//     // S'assurer que les paramètres de pagination sont présents
//     if (!queryParams.containsKey('page')) {
//       queryParams['page'] = _defaultPage.toString();
//     }
//     if (!queryParams.containsKey('limit')) {
//       queryParams['limit'] = _defaultLimit.toString();
//     }
//     if (!queryParams.containsKey('order')) {
//       queryParams['order'] = _defaultOrder;
//     }

//     return queryParams;
//   }

//   // ===========================================================================
//   // MÉTHODES UTILITAIRES
//   // ===========================================================================

//   /// Retourne les filtres par défaut pour l'interface utilisateur
//   Map<String, dynamic> getDefaultFilters() {
//     return {
//       'search': '',
//       'title': '',
//       'address': '',
//       'monthly_price': '',
//       'monthly_price_bis': '',
//       'monthly_price_operation': '',
//       'area': '',
//       'area_bis': '',
//       'area_operation': '',
//       'rooms_nb': '',
//       'rooms_nb_bis': '',
//       'rooms_nb_operation': '',
//       'bathrooms_nb': '',
//       'bathrooms_nb_bis': '',
//       'bathrooms_nb_operation': '',
//       'living_rooms_nb': '',
//       'living_rooms_nb_bis': '',
//       'living_rooms_nb_operation': '',
//       'compartment_number': '',
//       'compartment_number_bis': '',
//       'compartment_number_operation': '',
//       'status': '',
//       'water_supply': '',
//       'electrical_connection': '',
//       'town_id': '',
//       'category_property_id': '',
//       'certified': '',
//       'has_internal_kitchen': '',
//       'has_external_kitchen': '',
//       'has_a_parking': '',
//       'has_air_conditioning': '',
//       'has_security_guards': '',
//       'has_balcony': '',
//       'order': _defaultOrder,
//     };
//   }
// }
// lib/services/property_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../constants/api_constants.dart';

/// Service de gestion des propriétés immobilières
/// Centralise toutes les opérations liées aux propriétés : récupération, création, modification, favoris, etc.
class PropertyService {
  static const String baseUrl = ApiConstants.baseUrl;

  // ===========================================================================
  // CONSTANTES ET CONFIGURATION
  // ===========================================================================

  /// Headers communs pour les requêtes API sans authentification
  static const Map<String, String> _defaultHeaders = {
    'accept': 'application/json',
  };

  /// Paramètres de pagination par défaut
  static const int _defaultPage = 1;
  static const int _defaultLimit = 10;
  
  /// NOUVEAUX paramètres de tri par défaut
  static const String _defaultOrder = 'desc'; // Tri descendant pour certified (True d'abord)asc/desc
  static const String _defaultOrderSecondary = 'asc'; // Tri ascendant pour title
  static const String _defaultSortBy = 'certified'; // Premier critère: certified
  static const String _defaultSortSecondaryBy = 'title'; // Second critère: title

  /// Endpoints de l'API
  static const String _propertiesEndpoint = '/properties/';
  static const String _favoritesEndpoint = '/favorites/';
  static const String _signalsEndpoint = '/signals/';
  static const String _townsEndpoint = '/towns/';
  static const String _categoriesEndpoint = '/categories/';

  // ===========================================================================
  // MÉTHODES UTILITAIRES PRIVÉES
  // ===========================================================================

  /// Construit les headers pour les requêtes avec authentification et JSON
  /// [accessToken] : Token JWT pour l'authentification (optionnel)
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
  /// [response] : Réponse HTTP à traiter
  /// Retourne les données décodées ou lance une exception
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Gestion des codes de succès
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {}; // Retourne un Map vide si pas de contenu
      }
      return json.decode(response.body);
    } else {
      // Gestion des erreurs
      String errorDetail = 'Erreur inconnue';
      
      try {
        final errorBody = json.decode(response.body);
        errorDetail = errorBody['detail'] as String? ?? 
                     errorBody['message'] as String? ?? 
                     'Erreur inconnue';
      } catch (e) {
        errorDetail = 'Erreur de format de réponse';
      }
      
      // Exceptions spécifiques selon le code HTTP
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
  /// [request] : Fonction retournant une Future<http.Response>
  /// Retourne les données traitées ou lance une exception
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
      'order': _defaultOrder,
      'order_secondary': _defaultOrderSecondary,
      'sort_by': _defaultSortBy,
      'sort_secondary_by': _defaultSortSecondaryBy,
    };

    // Ajout des paramètres optionnels de base
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

  // ===========================================================================
  // MÉTHODES DE RÉCUPÉRATION DE PROPRIÉTÉS
  // ===========================================================================

  /// Récupère la liste paginée des propriétés avec filtres optionnels
  Future<PropertyListResponse> getProperties({
    int page = _defaultPage,
    int limit = _defaultLimit,
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

    final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les détails d'une propriété spécifique par son ID
  Future<Property> getPropertyDetail(String id) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$id');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return Property.fromJson(data);
  }

  /// Recherche avancée de propriétés avec plusieurs critères
  Future<PropertyListResponse> searchProperties({
    int page = _defaultPage,
    int limit = _defaultLimit,
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
    
    // Construction des filtres de recherche
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

    final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les propriétés similaires à une propriété donnée
  Future<PropertyListResponse> getSimilarProperties(String propertyId, {int limit = 5}) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/similar?limit=$limit');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère les propriétés d'un utilisateur spécifique
  Future<PropertyListResponse> getUserProperties(String userId, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint/user/$userId');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return PropertyListResponse.fromJson(data);
  }

  // ===========================================================================
  // MÉTHODES DE GESTION DES PROPRIÉTÉS (CRUD)
  // ===========================================================================

  /// Crée une nouvelle propriété
  Future<Property> createProperty(Map<String, dynamic> propertyData, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint');
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

  /// Met à jour une propriété existante
  Future<Property> updateProperty(String propertyId, Map<String, dynamic> propertyData, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId');
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
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId');

    await _makeRequest(
      () => http.delete(
        uri,
        headers: _jsonHeaders(accessToken),
      ),
    );
  }

  // ===========================================================================
  // MÉTHODES DE GESTION DES FAVORIS
  // ===========================================================================

  /// Ajoute ou retire une propriété des favoris de l'utilisateur
  Future<void> toggleFavorite(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_favoritesEndpoint');
    final body = json.encode({'property_id': propertyId});

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
        body: body,
      ),
    );
  }

  /// Récupère la liste paginée des propriétés favorites de l'utilisateur
  Future<PropertyListResponse> getFavorites(String accessToken) async {
    final uri = Uri.parse('$baseUrl$_favoritesEndpoint');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère toutes les propriétés favorites de l'utilisateur avec statut actif
  Future<List<Property>> getUserFavorites(String accessToken, {String? ownerId}) async {
    final queryParams = <String, String>{
      'order': _defaultOrder,
      'sort_by': 'created_at',
      'page': _defaultPage.toString(),
      'get_all': 'true',
      'active': 'true', // Seulement les favoris actifs
    };

    if (ownerId != null) {
      queryParams['owner_id'] = ownerId;
    }

    final uri = Uri.parse('$baseUrl$_favoritesEndpoint').replace(queryParameters: queryParams);

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    // Extraire les propriétés des favoris
    final records = data['records'] as List<dynamic>;
    return records.map((fav) => Property.fromJson(fav['property'])).toList();
  }

  /// Vérifie si une propriété est dans les favoris actifs de l'utilisateur
  Future<bool> isPropertyFavorite(String propertyId, String accessToken) async {
    try {
      final queryParams = <String, String>{
        'order': _defaultOrder,
        'sort_by': 'created_at',
        'page': _defaultPage.toString(),
        'get_all': 'true',
        'active': 'true',
        'property_id': propertyId, // Filtrer par propriété spécifique
      };

      final uri = Uri.parse('$baseUrl$_favoritesEndpoint').replace(queryParameters: queryParams);

      final data = await _makeRequest(
        () => http.get(uri, headers: _jsonHeaders(accessToken)),
      );
      
      final records = data['records'] as List<dynamic>;
      // Si on a au moins un favori actif pour cette propriété
      return records.isNotEmpty;
    } catch (e) {
      debugPrint("Erreur lors de la vérification des favoris: $e");
      return false;
    }
  }

  // ===========================================================================
  // MÉTHODES DE SIGNALEMENT
  // ===========================================================================

  /// Signale une propriété pour contenu inapproprié
  Future<void> reportProperty(String propertyId, String description, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_signalsEndpoint');
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

  /// Signale un utilisateur pour comportement inapproprié
  Future<void> reportUser(String offenderId, String description, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_signalsEndpoint');
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

  // ===========================================================================
  // MÉTHODES DE STATISTIQUES ET PERMISSIONS
  // ===========================================================================

  /// Incrémente le compteur de visites d'une propriété
  Future<void> incrementVisitCount(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/visit');

    await _makeRequest(
      () => http.post(
        uri,
        headers: _jsonHeaders(accessToken),
      ),
    );
  }

  /// Vérifie les permissions de l'utilisateur sur une propriété
  Future<Map<String, dynamic>> checkPropertyPermissions(String propertyId, String accessToken) async {
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint$propertyId/permissions');

    final data = await _makeRequest(
      () => http.get(uri, headers: _jsonHeaders(accessToken)),
    );
    
    return data as Map<String, dynamic>;
  }

  // ===========================================================================
  // MÉTHODES DE RÉCUPÉRATION DES DONNÉES DE RÉFÉRENCE
  // ===========================================================================

  /// Récupère la liste des villes disponibles
  Future<List<dynamic>> getTowns() async {
    final uri = Uri.parse('$baseUrl$_townsEndpoint');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return data['records'] as List<dynamic>;
  }

  /// Récupère la liste des catégories disponibles
  Future<List<dynamic>> getCategories() async {
    final uri = Uri.parse('$baseUrl$_categoriesEndpoint');

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return data['records'] as List<dynamic>;
  }

  // ===========================================================================
  // MÉTHODES AVANCÉES DE FILTRAGE
  // ===========================================================================

  /// Récupère les propriétés avec des filtres avancés
  Future<PropertyListResponse> getPropertiesWithFilters(Map<String, dynamic> filters) async {
    // Ajoutez les paramètres de tri par défaut s'ils ne sont pas déjà présents
    final enhancedFilters = Map<String, dynamic>.from(filters);
    
    if (!enhancedFilters.containsKey('order')) {
      enhancedFilters['order'] = _defaultOrder;
    }
    if (!enhancedFilters.containsKey('order_secondary')) {
      enhancedFilters['order_secondary'] = _defaultOrderSecondary;
    }
    if (!enhancedFilters.containsKey('sort_by')) {
      enhancedFilters['sort_by'] = _defaultSortBy;
    }
    if (!enhancedFilters.containsKey('sort_secondary_by')) {
      enhancedFilters['sort_secondary_by'] = _defaultSortSecondaryBy;
    }
    final queryParams = _buildQueryParamsFromFilters(enhancedFilters);
    // final queryParams = _buildQueryParamsFromFilters(filters);
    final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Récupère TOUTES les propriétés avec des filtres avancés (sans pagination)
  Future<PropertyListResponse> getAllPropertiesWithFilters(Map<String, dynamic> filters) async {
    final queryParams = _buildQueryParamsFromFilters(filters);
    
    // FORCER la récupération de tous les éléments
    queryParams['get_all'] = 'true';
    queryParams['page'] = _defaultPage.toString();

    // Paramètres par défaut pour la récupération complète
    if (!queryParams.containsKey('order')) {
      queryParams['order'] = _defaultOrder;
      queryParams['order_secondary'] = _defaultOrderSecondary;
      queryParams['sort_by'] = _defaultSortBy;
      queryParams['sort_secondary_by'] = _defaultSortSecondaryBy;
    }
    if (!queryParams.containsKey('active')) {
      queryParams['active'] = 'true'; // Toujours les propriétés actives
    }

    final uri = Uri.parse('$baseUrl$_propertiesEndpoint').replace(queryParameters: queryParams);

    final data = await _makeRequest(() => http.get(uri, headers: _defaultHeaders));
    return PropertyListResponse.fromJson(data);
  }

  /// Construit les paramètres de requête à partir d'un map de filtres
  Map<String, String> _buildQueryParamsFromFilters(Map<String, dynamic> filters) {
    final queryParams = <String, String>{};
    
    // Ajouter tous les filtres non vides
    filters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });

    // S'assurer que les paramètres de pagination sont présents
    if (!queryParams.containsKey('page')) {
      queryParams['page'] = _defaultPage.toString();
    }
    if (!queryParams.containsKey('limit')) {
      queryParams['limit'] = _defaultLimit.toString();
    }
    // TOUJOURS utiliser les paramètres de tri par défaut (s'ils ne sont pas déjà spécifiés)
    if (!queryParams.containsKey('order')) {
      queryParams['order'] = _defaultOrder;
    }
    if (!queryParams.containsKey('order_secondary')) {
      queryParams['order_secondary'] = _defaultOrderSecondary;
    }
    if (!queryParams.containsKey('sort_by')) {
      queryParams['sort_by'] = _defaultSortBy;
    }
    if (!queryParams.containsKey('sort_secondary_by')) {
      queryParams['sort_secondary_by'] = _defaultSortSecondaryBy;
    }

    return queryParams;
  }

  // ===========================================================================
  // MÉTHODES UTILITAIRES
  // ===========================================================================

  /// Retourne les filtres par défaut pour l'interface utilisateur
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
      // Les paramètres de tri par défaut
      'order': _defaultOrder,
      'order_secondary': _defaultOrderSecondary,
      'sort_by': _defaultSortBy,
      'sort_secondary_by': _defaultSortSecondaryBy,
    };
  }
}