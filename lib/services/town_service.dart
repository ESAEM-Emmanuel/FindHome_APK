// lib/api/town_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/town.dart';
import '../constants/api_constants.dart';

class TownService {
  static const String baseUrl = ApiConstants.baseUrl;

  Future<TownsResponse> searchTowns(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/towns/?name=$query'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TownsResponse.fromJson(data);
      } else {
        throw Exception('Erreur lors de la recherche des villes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<List<Town>> getAllTowns() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/towns/'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final townsResponse = TownsResponse.fromJson(data);
        return townsResponse.records;
      } else {
        throw Exception('Erreur lors du chargement des villes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}