// // lib/models/property_model.dart

// class Category {
//   final String id;
//   final String name;

//   Category({required this.id, required this.name});

//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id'] as String,
//       name: json['name'] as String,
//     );
//   }
// }

// class Town {
//   final String id;
//   final String name;

//   Town({required this.id, required this.name});

//   factory Town.fromJson(Map<String, dynamic> json) {
//     return Town(
//       id: json['id'] as String,
//       name: json['name'] as String,
//     );
//   }
// }

// class Favorite {
//   final String id;
//   final String propertyId;
//   final String createdById;
//   final String refNumber;
//   final bool active;

//   Favorite({
//     required this.id,
//     required this.propertyId,
//     required this.createdById,
//     required this.refNumber,
//     required this.active,
//   });

//   factory Favorite.fromJson(Map<String, dynamic> json) {
//     return Favorite(
//       id: json['id'] as String,
//       propertyId: json['property_id'] as String,
//       createdById: json['created_by'] as String,
//       refNumber: json['refnumber'] as String? ?? 'N/A',
//       active: json['active'] as bool? ?? true,
//     );
//   }
// }

// class Property {
//   final String id;
//   final String title;
//   final String description;
//   final String address;
//   final int monthlyPrice;
//   final int area;
//   final int roomsNb;
//   final int bathroomsNb;
//   final String mainImage;
//   final List<String> otherImages;
//   final bool certified;
//   final String status;
//   final Town town;
//   final Category category;

//   // Champs de détail supplémentaires (utilisés dans PropertyDetailPage)
//   final String refNumber;
//   final int livingRoomsNb;
//   final bool hasInternalKitchen;
//   final bool hasExternalKitchen;
//   final bool hasAParking;
//   final bool hasAirConditioning;
//   final bool hasSecurityGuards;
//   final bool hasBalcony;
  
//   // NOUVEAU : Champ pour l'ID du propriétaire (nécessaire pour le signalement)
//   final String ownerId;
  
//   // NOTE: Les champs 'nb_visite' et 'compartment_number' sont ignorés pour la simplicité de ce modèle.

//   Property({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.address,
//     required this.monthlyPrice,
//     required this.area,
//     required this.roomsNb,
//     required this.bathroomsNb,
//     required this.mainImage,
//     required this.otherImages,
//     required this.certified,
//     required this.status,
//     required this.town,
//     required this.category,
//     // Champs de détail
//     required this.refNumber,
//     required this.livingRoomsNb,
//     required this.hasInternalKitchen,
//     required this.hasExternalKitchen,
//     required this.hasAParking,
//     required this.hasAirConditioning,
//     required this.hasSecurityGuards,
//     required this.hasBalcony,
//     required this.ownerId,
//   });

//   factory Property.fromJson(Map<String, dynamic> json) {
//     // 1. Gestion des listes d'images
//     List<dynamic> otherImagesJson = json['other_images'] ?? [];
//     List<String> otherImages = otherImagesJson
//         .where((e) => e != null) // Assure qu'aucun élément null ne passe
//         .map((e) => e.toString())
//         .toList();

//     // 2. Gestion robuste des champs numériques/booléens (pour List ET Detail)
//     final price = (json['monthly_price'] as num?)?.toInt() ?? 0;
//     final areaValue = (json['area'] as num?)?.toInt() ?? 0;
//     final rooms = (json['rooms_nb'] as num?)?.toInt() ?? 0;
//     final bathrooms = (json['bathrooms_nb'] as num?)?.toInt() ?? 0;
    
//     // Ces champs peuvent être absents dans la réponse de la LISTE, d'où les valeurs par défaut.
//     final livingRooms = (json['living_rooms_nb'] as num?)?.toInt() ?? 0; 
    
//     final isCertified = json['certified'] as bool? ?? false;
//     final hasIntKitchen = json['has_internal_kitchen'] as bool? ?? false;
//     final hasExtKitchen = json['has_external_kitchen'] as bool? ?? false;
//     final hasParking = json['has_a_parking'] as bool? ?? false;
//     final hasAC = json['has_air_conditioning'] as bool? ?? false;
//     final hasSecurity = json['has_security_guards'] as bool? ?? false;
//     final hasBaly = json['has_balcony'] as bool? ?? false;

//     // La description peut être longue ou manquante dans la liste, on la laisse telle quelle
//     final descriptionValue = json['description'] as String? ?? 'Description non disponible.';

//     // NOUVEAU : Récupération de l'ID du propriétaire
//     // Selon votre réponse API, le propriétaire peut être dans 'owner_id' ou dans 'owner'
//     String ownerId;
//     if (json['owner_id'] != null) {
//       ownerId = json['owner_id'] as String;
//     } else if (json['owner'] != null && json['owner'] is Map<String, dynamic>) {
//       ownerId = (json['owner'] as Map<String, dynamic>)['id'] as String? ?? '';
//     } else {
//       ownerId = ''; // Valeur par défaut si non trouvé
//     }

//     return Property(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       description: descriptionValue,
//       address: json['address'] as String? ?? 'Adresse non spécifiée',
      
//       monthlyPrice: price,
//       area: areaValue,
//       roomsNb: rooms,
//       bathroomsNb: bathrooms,
      
//       mainImage: json['main_image'] as String? ?? '', 
//       otherImages: otherImages,
//       certified: isCertified,
//       status: json['status'] as String? ?? 'N/A',
      
//       town: Town.fromJson(json['town'] as Map<String, dynamic>),
//       category: Category.fromJson(json['category'] as Map<String, dynamic>),
      
//       // Champs de détail robustes (prend 'N/A' si non trouvé dans la liste)
//       refNumber: json['refnumber'] as String? ?? 'N/A',
//       livingRoomsNb: livingRooms,
//       hasInternalKitchen: hasIntKitchen,
//       hasExternalKitchen: hasExtKitchen,
//       hasAParking: hasParking,
//       hasAirConditioning: hasAC,
//       hasSecurityGuards: hasSecurity,
//       hasBalcony: hasBaly,
      
//       // NOUVEAU : ID du propriétaire
//       ownerId: ownerId,
//     );
//   }
// }

// // Modèle pour la réponse paginée de la liste des propriétés (pour HomePage)
// class PropertyListResponse {
//   final List<Property> records;
//   final int totalRecords;
//   final int totalPages;
//   final int currentPage;

//   PropertyListResponse({
//     required this.records,
//     required this.totalRecords,
//     required this.totalPages,
//     required this.currentPage,
//   });

//   factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
//     final metadata = json['metadata'] as Map<String, dynamic>;
//     final recordsJson = json['records'] as List<dynamic>;

//     return PropertyListResponse(
//       records: recordsJson.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList(),
//       totalRecords: metadata['total_records'] as int,
//       totalPages: metadata['total_pages'] as int,
//       currentPage: metadata['current_page'] as int,
//     );
//   }
// }

// lib/models/property_model.dart

import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class Town {
  final String id;
  final String name;

  Town({required this.id, required this.name});

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class Favorite {
  final String id;
  final String propertyId;
  final String createdById;
  final String refNumber;
  final bool active;

  Favorite({
    required this.id,
    required this.propertyId,
    required this.createdById,
    required this.refNumber,
    required this.active,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      createdById: json['created_by'] as String,
      refNumber: json['refnumber'] as String? ?? 'N/A',
      active: json['active'] as bool? ?? true,
    );
  }
}

class Property {
  final String id;
  final String title;
  final String description;
  final String address;
  final int monthlyPrice;
  final int area;
  final int roomsNb;
  final int bathroomsNb;
  final String mainImage;
  final List<String> otherImages;
  final bool certified;
  final String status;
  final Town town;
  final Category category;

  // Champs de détail supplémentaires
  final String refNumber;
  final int livingRoomsNb;
  final bool hasInternalKitchen;
  final bool hasExternalKitchen;
  final bool hasAParking;
  final bool hasAirConditioning;
  final bool hasSecurityGuards;
  final bool hasBalcony;
  
  // Champ pour l'ID du propriétaire
  final String ownerId;
  
  // NOUVEAU : Champs pour la localisation
  final List<String> location;
  final double? latitude;
  final double? longitude;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.monthlyPrice,
    required this.area,
    required this.roomsNb,
    required this.bathroomsNb,
    required this.mainImage,
    required this.otherImages,
    required this.certified,
    required this.status,
    required this.town,
    required this.category,
    required this.refNumber,
    required this.livingRoomsNb,
    required this.hasInternalKitchen,
    required this.hasExternalKitchen,
    required this.hasAParking,
    required this.hasAirConditioning,
    required this.hasSecurityGuards,
    required this.hasBalcony,
    required this.ownerId,
    // NOUVEAU : Localisation
    required this.location,
    this.latitude,
    this.longitude,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // 1. Gestion des listes d'images
    List<dynamic> otherImagesJson = json['other_images'] ?? [];
    List<String> otherImages = otherImagesJson
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();

    // 2. Gestion robuste des champs numériques/booléens
    final price = (json['monthly_price'] as num?)?.toInt() ?? 0;
    final areaValue = (json['area'] as num?)?.toInt() ?? 0;
    final rooms = (json['rooms_nb'] as num?)?.toInt() ?? 0;
    final bathrooms = (json['bathrooms_nb'] as num?)?.toInt() ?? 0;
    
    final livingRooms = (json['living_rooms_nb'] as num?)?.toInt() ?? 0; 
    
    final isCertified = json['certified'] as bool? ?? false;
    final hasIntKitchen = json['has_internal_kitchen'] as bool? ?? false;
    final hasExtKitchen = json['has_external_kitchen'] as bool? ?? false;
    final hasParking = json['has_a_parking'] as bool? ?? false;
    final hasAC = json['has_air_conditioning'] as bool? ?? false;
    final hasSecurity = json['has_security_guards'] as bool? ?? false;
    final hasBaly = json['has_balcony'] as bool? ?? false;

    final descriptionValue = json['description'] as String? ?? 'Description non disponible.';

    // 3. Gestion de l'ID du propriétaire
    String ownerId;
    if (json['owner_id'] != null) {
      ownerId = json['owner_id'] as String;
    } else if (json['owner'] != null && json['owner'] is Map<String, dynamic>) {
      ownerId = (json['owner'] as Map<String, dynamic>)['id'] as String? ?? '';
    } else {
      ownerId = '';
    }

    // 4. NOUVEAU : Gestion de la localisation
    List<dynamic> locationJson = json['location'] ?? [];
    List<String> locationList = locationJson.map((e) => e.toString()).toList();
    
    // Extraction des coordonnées GPS
    double? parsedLatitude;
    double? parsedLongitude;
    
    if (locationList.length >= 3) {
      try {
        parsedLatitude = double.tryParse(locationList[1]); // Index 1 = latitude
        parsedLongitude = double.tryParse(locationList[2]); // Index 2 = longitude
      } catch (e) {
        debugPrint("Erreur parsing coordonnées: $e");
      }
    }

    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: descriptionValue,
      address: json['address'] as String? ?? 'Adresse non spécifiée',
      
      monthlyPrice: price,
      area: areaValue,
      roomsNb: rooms,
      bathroomsNb: bathrooms,
      
      mainImage: json['main_image'] as String? ?? '', 
      otherImages: otherImages,
      certified: isCertified,
      status: json['status'] as String? ?? 'N/A',
      
      town: Town.fromJson(json['town'] as Map<String, dynamic>),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      
      refNumber: json['refnumber'] as String? ?? 'N/A',
      livingRoomsNb: livingRooms,
      hasInternalKitchen: hasIntKitchen,
      hasExternalKitchen: hasExtKitchen,
      hasAParking: hasParking,
      hasAirConditioning: hasAC,
      hasSecurityGuards: hasSecurity,
      hasBalcony: hasBaly,
      
      ownerId: ownerId,
      
      // NOUVEAU : Localisation
      location: locationList,
      latitude: parsedLatitude,
      longitude: parsedLongitude,
    );
  }

  // Méthode utilitaire pour vérifier si la localisation est disponible
  bool get hasValidLocation => latitude != null && longitude != null;
}

// Modèle pour la réponse paginée
class PropertyListResponse {
  final List<Property> records;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  PropertyListResponse({
    required this.records,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>;
    final recordsJson = json['records'] as List<dynamic>;

    return PropertyListResponse(
      records: recordsJson.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList(),
      totalRecords: metadata['total_records'] as int,
      totalPages: metadata['total_pages'] as int,
      currentPage: metadata['current_page'] as int,
    );
  }
}