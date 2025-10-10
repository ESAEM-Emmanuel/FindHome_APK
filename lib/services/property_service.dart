// lib/services/property_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class PropertyService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  
  // Définit les paramètres de requête de manière structurée
  // Ici, nous ne gérons qu'une partie des filtres
  Future<PropertyListResponse> getProperties({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? townId,
    Map<String, dynamic>? filters,
  }) async {
    // Construction des paramètres de requête
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'order': 'asc',
      'sort_by': 'title',
    };
    
    if (categoryId != null) queryParams['category_property_id'] = categoryId;
    if (townId != null) queryParams['town_id'] = townId;
    
    // Ajout des filtres personnalisés (status, certified, etc.)
    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });
    }

    final uri = Uri.parse('$_baseUrl/properties/').replace(queryParameters: queryParams);
    
    try {
      final response = await http.get(uri, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PropertyListResponse.fromJson(data);
      } else {
        // Gérer les erreurs de serveur (404, 500, etc.)
        throw Exception('Échec du chargement des propriétés: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les erreurs de réseau ou de parsing
      throw Exception('Erreur de connexion ou de traitement des données: $e');
    }
  }

  // Future<Property> getPropertyDetail(String id) async { ... }
}