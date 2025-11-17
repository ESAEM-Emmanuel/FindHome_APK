// lib/services/category_service.dart (version simplifiée)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart'; // CategoryListResponse est maintenant ici
import '../constants/api_constants.dart';

class CategoryService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Récupérer toutes les catégories
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category_properties/'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final categoryResponse = CategoryListResponse.fromJson(jsonResponse);
        return categoryResponse.records;
      } else {
        throw Exception('Échec du chargement des catégories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Rechercher des catégories par nom
  Future<CategoryListResponse> searchCategories(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category_properties/?name=$query'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return CategoryListResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Échec de la recherche des catégories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer une catégorie par son ID
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/category_properties/$id'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Category.fromJson(jsonResponse);
      } else {
        throw Exception('Échec du chargement de la catégorie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}