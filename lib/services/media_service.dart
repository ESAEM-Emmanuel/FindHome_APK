// // lib/api/media_service.dart
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../constants/api_constants.dart';

// class MediaService {
//   static const String baseUrl = ApiConstants.baseUrl;

//   /// Upload un fichier image
//   Future<List<String>> uploadFiles(List<File> files) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/medias/uploadfiles/'),
//       );

//       // Ajouter chaque fichier à la requête
//       for (var file in files) {
//         var multipartFile = await http.MultipartFile.fromPath(
//           'files',
//           file.path,
//           filename: _generateFileName(file.path),
//         );
//         request.files.add(multipartFile);
//       }

//       request.headers['accept'] = 'application/json';

//       var response = await request.send();
//       final responseString = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         final data = json.decode(responseString);
//         final List<dynamic> mediaUrls = data['media_urls'];
//         return mediaUrls.cast<String>();
//       } else {
//         throw Exception('Échec de l\'upload: ${response.statusCode} - $responseString');
//       }
//     } catch (e) {
//       throw Exception('Erreur lors de l\'upload: $e');
//     }
//   }

//   /// Génère un nom de fichier unique
//   String _generateFileName(String filePath) {
//     final originalFileName = filePath.split('/').last;
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     return '${timestamp}_$originalFileName';
//   }

//   /// Upload un seul fichier (cas le plus courant)
//   Future<String> uploadSingleFile(File file) async {
//     final urls = await uploadFiles([file]);
//     return urls.first;
//   }
// }

// lib/services/media_service.dart (version alternative)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class MediaService {
  static const String baseUrl = ApiConstants.baseUrl;

  /// Upload un fichier image
  Future<List<String>> uploadFiles(List<File> files) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/medias/uploadfiles/'),
      );

      // Ajouter chaque fichier à la requête
      for (var file in files) {
        // Utiliser un nom de fichier sécurisé
        var multipartFile = await http.MultipartFile.fromPath(
          'files',
          file.path,
          filename: _generateSecureFileName(file.path),
        );
        request.files.add(multipartFile);
      }

      request.headers['accept'] = 'application/json';

      debugPrint('🔄 Envoi de la requête d\'upload...');
      var response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint('📡 Statut HTTP upload: ${response.statusCode}');
      debugPrint('📦 Réponse upload: $responseString');

      if (response.statusCode == 200) {
        final data = json.decode(responseString);
        final List<dynamic> mediaUrls = data['media_urls'];
        debugPrint('✅ Upload réussi: ${mediaUrls.length} fichiers');
        return mediaUrls.cast<String>();
      } else {
        throw Exception('Échec de l\'upload: ${response.statusCode} - $responseString');
      }
    } catch (e) {
      debugPrint('❌ Erreur upload: $e');
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Génère un nom de fichier sécurisé et unique
  String _generateSecureFileName(String filePath) {
    // Extraire seulement le nom du fichier
    final originalFileName = filePath.split(RegExp(r'[\\/]')).last;
    
    // Nettoyer le nom de fichier (enlever les caractères spéciaux)
    final cleanFileName = _cleanFileName(originalFileName);
    
    // Générer un timestamp unique
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Retourner un nom de fichier sécurisé
    return '${timestamp}_$cleanFileName';
  }

  /// Nettoie le nom de fichier des caractères spéciaux
  String _cleanFileName(String fileName) {
    // Enlever les caractères non autorisés dans les noms de fichiers
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Upload un seul fichier
  Future<String> uploadSingleFile(File file) async {
    final urls = await uploadFiles([file]);
    return urls.first;
  }
}