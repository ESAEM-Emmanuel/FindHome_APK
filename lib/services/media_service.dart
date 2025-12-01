// // lib/services/media_service.dart (version alternative)
// import 'dart:io';
// import 'package:flutter/material.dart';
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
//         // Utiliser un nom de fichier sécurisé
//         var multipartFile = await http.MultipartFile.fromPath(
//           'files',
//           file.path,
//           filename: _generateSecureFileName(file.path),
//         );
//         request.files.add(multipartFile);
//       }

//       request.headers['accept'] = 'application/json';

//       debugPrint('🔄 Envoi de la requête d\'upload...');
//       var response = await request.send();
//       final responseString = await response.stream.bytesToString();

//       debugPrint('📡 Statut HTTP upload: ${response.statusCode}');
//       debugPrint('📦 Réponse upload: $responseString');

//       if (response.statusCode == 200) {
//         final data = json.decode(responseString);
//         final List<dynamic> mediaUrls = data['media_urls'];
//         debugPrint('✅ Upload réussi: ${mediaUrls.length} fichiers');
//         return mediaUrls.cast<String>();
//       } else {
//         throw Exception('Échec de l\'upload: ${response.statusCode} - $responseString');
//       }
//     } catch (e) {
//       debugPrint('❌ Erreur upload: $e');
//       throw Exception('Erreur lors de l\'upload: $e');
//     }
//   }

//   /// Génère un nom de fichier sécurisé et unique
//   String _generateSecureFileName(String filePath) {
//     // Extraire seulement le nom du fichier
//     final originalFileName = filePath.split(RegExp(r'[\\/]')).last;
    
//     // Nettoyer le nom de fichier (enlever les caractères spéciaux)
//     final cleanFileName = _cleanFileName(originalFileName);
    
//     // Générer un timestamp unique
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
    
//     // Retourner un nom de fichier sécurisé
//     return '${timestamp}_$cleanFileName';
//   }

//   /// Nettoie le nom de fichier des caractères spéciaux
//   String _cleanFileName(String fileName) {
//     // Enlever les caractères non autorisés dans les noms de fichiers
//     return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
//   }

//   /// Upload un seul fichier
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

/// Service de gestion des médias pour l'upload de fichiers
/// Gère l'upload de fichiers vers le serveur avec sécurité et robustesse
class MediaService {
  static const String baseUrl = ApiConstants.baseUrl;

  // ===========================================================================
  // CONSTANTES ET CONFIGURATION
  // ===========================================================================

  /// Endpoint pour l'upload de fichiers
  static const String _uploadEndpoint = '/medias/uploadfiles/';

  /// Headers communs pour les requêtes
  static const Map<String, String> _defaultHeaders = {
    'accept': 'application/json',
  };

  /// Caractères non autorisés dans les noms de fichiers
  static final RegExp _invalidFileNameChars = RegExp(r'[<>:"/\\|?*]');

  // ===========================================================================
  // MÉTHODES PRINCIPALES D'UPLOAD
  // ===========================================================================

  /// Upload une liste de fichiers vers le serveur
  /// [files] : Liste des fichiers à uploader
  /// Retourne la liste des URLs des médias uploadés
  /// Lance une exception en cas d'échec
  Future<List<String>> uploadFiles(List<File> files) async {
    _validateFiles(files);

    try {
      debugPrint('🔄 Début de l\'upload de ${files.length} fichier(s)...');

      final request = await _createUploadRequest(files);
      final response = await request.send();
      final responseData = await _handleUploadResponse(response);

      debugPrint('✅ Upload réussi: ${responseData.length} fichier(s) traités');
      return responseData;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'upload: $e');
      throw Exception('Échec de l\'upload des fichiers: $e');
    }
  }

  /// Upload un seul fichier vers le serveur
  /// [file] : Fichier unique à uploader
  /// Retourne l'URL du média uploadé
  /// Lance une exception en cas d'échec
  Future<String> uploadSingleFile(File file) async {
    debugPrint('📤 Upload d\'un fichier unique: ${file.path}');

    final urls = await uploadFiles([file]);
    
    if (urls.isEmpty) {
      throw Exception('Aucune URL retournée après l\'upload');
    }

    debugPrint('✅ Fichier unique uploadé avec succès: ${urls.first}');
    return urls.first;
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - GESTION DES REQUÊTES
  // ===========================================================================

  /// Crée une requête multipart pour l'upload de fichiers
  Future<http.MultipartRequest> _createUploadRequest(List<File> files) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$_uploadEndpoint'),
    );

    // Configuration des headers
    request.headers.addAll(_defaultHeaders);

    // Ajout des fichiers à la requête
    await _addFilesToRequest(request, files);

    return request;
  }

  /// Ajoute les fichiers à la requête multipart
  Future<void> _addFilesToRequest(
    http.MultipartRequest request, 
    List<File> files,
  ) async {
    for (final file in files) {
      final multipartFile = await _createMultipartFile(file);
      request.files.add(multipartFile);
      
      debugPrint('📎 Fichier ajouté à la requête: ${file.path}');
    }
  }

  /// Crée un MultipartFile sécurisé à partir d'un File
  Future<http.MultipartFile> _createMultipartFile(File file) async {
    return await http.MultipartFile.fromPath(
      'files', // Nom du champ dans la requête
      file.path,
      filename: _generateSecureFileName(file.path),
    );
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - GESTION DES RÉPONSES
  // ===========================================================================

  /// Gère la réponse de l'upload et extrait les URLs des médias
  Future<List<String>> _handleUploadResponse(http.StreamedResponse response) async {
    final responseString = await response.stream.bytesToString();
    
    debugPrint('📡 Statut HTTP upload: ${response.statusCode}');
    debugPrint('📦 Réponse upload: $responseString');

    if (response.statusCode == 200) {
      return _parseSuccessfulResponse(responseString);
    } else {
      throw _createUploadException(response.statusCode, responseString);
    }
  }

  /// Parse une réponse réussie et extrait les URLs des médias
  List<String> _parseSuccessfulResponse(String responseString) {
    try {
      final data = json.decode(responseString);
      final List<dynamic> mediaUrls = data['media_urls'];
      
      if (mediaUrls == null) {
        throw Exception('Champ "media_urls" manquant dans la réponse');
      }
      
      return mediaUrls.cast<String>();
    } catch (e) {
      debugPrint('❌ Erreur de parsing de la réponse: $e');
      throw Exception('Format de réponse invalide: $e');
    }
  }

  /// Crée une exception appropriée selon le statut HTTP
  Exception _createUploadException(int statusCode, String responseBody) {
    final errorMessage = 'Échec de l\'upload: $statusCode';
    
    try {
      final errorData = json.decode(responseBody);
      final detail = errorData['detail'] ?? errorData['message'] ?? responseBody;
      return Exception('$errorMessage - $detail');
    } catch (e) {
      return Exception('$errorMessage - $responseBody');
    }
  }

  // ===========================================================================
  // MÉTHODES PRIVÉES - SÉCURITÉ ET VALIDATION
  // ===========================================================================

  /// Valide la liste des fichiers avant l'upload
  void _validateFiles(List<File> files) {
    if (files.isEmpty) {
      throw ArgumentError('La liste des fichiers ne peut pas être vide');
    }

    for (final file in files) {
      if (!file.existsSync()) {
        throw Exception('Le fichier ${file.path} n\'existe pas');
      }
    }

    debugPrint('✅ Validation des fichiers réussie: ${files.length} fichier(s) valide(s)');
  }

  /// Génère un nom de fichier sécurisé et unique
  /// [filePath] : Chemin d'accès original du fichier
  /// Retourne un nom de fichier nettoyé avec timestamp
  String _generateSecureFileName(String filePath) {
    final originalFileName = _extractFileName(filePath);
    final cleanFileName = _cleanFileName(originalFileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final secureFileName = '${timestamp}_$cleanFileName';
    
    debugPrint('🔒 Nom de fichier sécurisé généré: $secureFileName');
    return secureFileName;
  }

  /// Extrait le nom du fichier depuis le chemin complet
  String _extractFileName(String filePath) {
    return filePath.split(RegExp(r'[\\/]')).last;
  }

  /// Nettoie le nom de fichier des caractères spéciaux non autorisés
  /// [fileName] : Nom de fichier original
  /// Retourne un nom de fichier sécurisé
  String _cleanFileName(String fileName) {
    final cleanName = fileName.replaceAll(_invalidFileNameChars, '_');
    
    // S'assurer que le nom n'est pas vide après nettoyage
    if (cleanName.isEmpty) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return cleanName;
  }

  // ===========================================================================
  // MÉTHODES UTILITAIRES
  // ===========================================================================

  /// Vérifie si un fichier est une image basée sur son extension
  /// [file] : Fichier à vérifier
  /// Retourne true si le fichier est une image
  bool isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(extension);
  }

  /// Vérifie si un fichier est une vidéo basée sur son extension
  /// [file] : Fichier à vérifier
  /// Retourne true si le fichier est une vidéo
  bool isVideoFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'];
    return videoExtensions.contains(extension);
  }

  /// Obtient la taille d'un fichier en format lisible
  /// [file] : Fichier à analyser
  /// Retourne la taille formatée (ex: "2.5 MB")
  String getFileSize(File file) {
    final sizeInBytes = file.lengthSync();
    
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Valide la taille d'un fichier par rapport à une limite maximale
  /// [file] : Fichier à valider
  /// [maxSizeInBytes] : Taille maximale autorisée en bytes
  /// Retourne true si le fichier respecte la limite de taille
  bool validateFileSize(File file, int maxSizeInBytes) {
    final fileSize = file.lengthSync();
    final isValid = fileSize <= maxSizeInBytes;
    
    if (!isValid) {
      debugPrint('⚠️ Fichier trop volumineux: ${getFileSize(file)} > ${getFileSize(File('dummy'))}');
    }
    
    return isValid;
  }
}