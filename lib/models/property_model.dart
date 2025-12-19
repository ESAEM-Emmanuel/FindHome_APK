// // lib/models/property_model.dart
// import 'package:flutter/material.dart';
// import 'town.dart'; // Import depuis le fichier dédié
// import 'category.dart'; // Import depuis le fichier dédié

// // =============================================================================
// // MODÈLE FAVORI
// // =============================================================================

// /// Représente un bien immobilier marqué comme favori par un utilisateur
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

//   /// Factory constructor pour créer un Favorite à partir de données JSON
//   factory Favorite.fromJson(Map<String, dynamic> json) {
//     return Favorite(
//       id: json['id'] as String,
//       propertyId: json['property_id'] as String,
//       createdById: json['created_by'] as String,
//       refNumber: json['refnumber'] as String? ?? 'N/A',
//       active: json['active'] as bool? ?? true,
//     );
//   }

//   /// Convertit l'objet Favorite en Map JSON pour l'API
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'property_id': propertyId,
//       'created_by': createdById,
//       'refnumber': refNumber,
//       'active': active,
//     };
//   }
// }

// // =============================================================================
// // MODÈLE PROPRIÉTÉ
// // =============================================================================

// /// Représente un bien immobilier avec toutes ses caractéristiques et équipements
// class Property {
//   // === INFORMATIONS DE BASE ===
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
//   final Town town; // Utilise la classe Town du fichier town.dart
//   final Category category; // Utilise la classe Category du fichier category.dart

//   // === CARACTÉRISTIQUES DÉTAILLÉES ===
//   final String refNumber;
//   final int livingRoomsNb;
//   final bool hasInternalKitchen;
//   final bool hasExternalKitchen;
//   final bool hasAParking;
//   final bool hasAirConditioning;
//   final bool hasSecurityGuards;
//   final bool hasBalcony;
  
//   // === INFORMATIONS PROPRIÉTAIRE ===
//   final String ownerId;
  
//   // === LOCALISATION GÉOGRAPHIQUE ===
//   final List<String> location;
//   final double? latitude;
//   final double? longitude;

//   // === SERVICES ET ÉQUIPEMENTS ===
//   final String waterSupply;
//   final String electricalConnection;
//   final int compartmentNumber;

//   // === ÉTAT DE VÉRIFICATION ===
//   final bool hasSendVerifiedRequest;

//   /// Constructeur principal de la classe Property
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
//     required this.refNumber,
//     required this.livingRoomsNb,
//     required this.hasInternalKitchen,
//     required this.hasExternalKitchen,
//     required this.hasAParking,
//     required this.hasAirConditioning,
//     required this.hasSecurityGuards,
//     required this.hasBalcony,
//     required this.ownerId,
//     required this.location,
//     this.latitude,
//     this.longitude,
//     required this.waterSupply,
//     required this.electricalConnection,
//     required this.compartmentNumber,
//     required this.hasSendVerifiedRequest,
//   });

//   // === MÉTHODES DE PARSING JSON ===

//   /// Factory constructor pour créer un Property à partir de données JSON
//   factory Property.fromJson(Map<String, dynamic> json) {
//     return Property(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       description: json['description'] as String? ?? 'Description non disponible.',
//       address: json['address'] as String? ?? 'Adresse non spécifiée',
      
//       // Parsing des valeurs numériques avec gestion des nulls
//       monthlyPrice: (json['monthly_price'] as num?)?.toInt() ?? 0,
//       area: (json['area'] as num?)?.toInt() ?? 0,
//       roomsNb: (json['rooms_nb'] as num?)?.toInt() ?? 0,
//       bathroomsNb: (json['bathrooms_nb'] as num?)?.toInt() ?? 0,
//       livingRoomsNb: (json['living_rooms_nb'] as num?)?.toInt() ?? 0,
//       compartmentNumber: (json['compartment_number'] as num?)?.toInt() ?? 0,
      
//       // Gestion des images
//       mainImage: json['main_image'] as String? ?? '',
//       otherImages: _parseOtherImages(json['other_images']),
      
//       // Parsing des booléens avec valeurs par défaut
//       certified: json['certified'] as bool? ?? false,
//       hasInternalKitchen: json['has_internal_kitchen'] as bool? ?? false,
//       hasExternalKitchen: json['has_external_kitchen'] as bool? ?? false,
//       hasAParking: json['has_a_parking'] as bool? ?? false,
//       hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
//       hasSecurityGuards: json['has_security_guards'] as bool? ?? false,
//       hasBalcony: json['has_balcony'] as bool? ?? false,
//       hasSendVerifiedRequest: json['has_send_verified_request'] as bool? ?? false,
      
//       status: json['status'] as String? ?? 'free',
      
//       // Parsing des objets imbriqués
//       town: Town.fromJson(json['town'] as Map<String, dynamic>),
//       category: Category.fromJson(json['category'] as Map<String, dynamic>),
      
//       refNumber: json['refnumber'] as String? ?? 'N/A',
//       ownerId: _parseOwnerId(json),
      
//       // Parsing de la localisation
//       location: _parseLocation(json['location']),
//       latitude: _parseLatitude(json['location']),
//       longitude: _parseLongitude(json['location']),
      
//       // Services avec valeurs par défaut
//       waterSupply: json['water_supply'] as String? ?? 'not_available',
//       electricalConnection: json['electrical_connection'] as String? ?? 'not_available',
//     );
//   }

//   /// Convertit l'objet Property en Map JSON pour l'API
//   Map<String, dynamic> toJson() {
//     return {
//       // Informations de base
//       'id': id,
//       'title': title,
//       'description': description,
//       'address': address,
//       'monthly_price': monthlyPrice,
//       'area': area,
//       'rooms_nb': roomsNb,
//       'bathrooms_nb': bathroomsNb,
//       'main_image': mainImage,
//       'other_images': otherImages,
//       'certified': certified,
//       'status': status,
      
//       // Objets imbriqués
//       'town': town.toJson(),
//       'category': category.toJson(),
      
//       // Caractéristiques détaillées
//       'refnumber': refNumber,
//       'living_rooms_nb': livingRoomsNb,
//       'has_internal_kitchen': hasInternalKitchen,
//       'has_external_kitchen': hasExternalKitchen,
//       'has_a_parking': hasAParking,
//       'has_air_conditioning': hasAirConditioning,
//       'has_security_guards': hasSecurityGuards,
//       'has_balcony': hasBalcony,
      
//       // Propriétaire
//       'owner_id': ownerId,
      
//       // Localisation
//       'location': location,
//       'latitude': latitude,
//       'longitude': longitude,
      
//       // Services
//       'water_supply': waterSupply,
//       'electrical_connection': electricalConnection,
//       'compartment_number': compartmentNumber,
      
//       // Vérification
//       'has_send_verified_request': hasSendVerifiedRequest,
//     };
//   }

//   // === MÉTHODES UTILITAIRES PRIVÉES ===

//   /// Parse la liste des images supplémentaires
//   static List<String> _parseOtherImages(dynamic imagesJson) {
//     final List<dynamic> otherImagesJson = imagesJson ?? [];
//     return otherImagesJson
//         .where((e) => e != null)
//         .map((e) => e.toString())
//         .toList();
//   }

//   /// Parse l'ID du propriétaire depuis différentes sources possibles
//   static String _parseOwnerId(Map<String, dynamic> json) {
//     if (json['owner_id'] != null) {
//       return json['owner_id'] as String;
//     } else if (json['owner'] != null && json['owner'] is Map<String, dynamic>) {
//       return (json['owner'] as Map<String, dynamic>)['id'] as String? ?? '';
//     } else {
//       return '';
//     }
//   }

//   /// Parse la liste de localisation
//   static List<String> _parseLocation(dynamic locationJson) {
//     final List<dynamic> locationList = locationJson ?? [];
//     return locationList.map((e) => e.toString()).toList();
//   }

//   /// Parse la latitude depuis les données de localisation
//   static double? _parseLatitude(dynamic locationJson) {
//     return _parseCoordinate(locationJson, 1); // Index 1 = latitude
//   }

//   /// Parse la longitude depuis les données de localisation
//   static double? _parseLongitude(dynamic locationJson) {
//     return _parseCoordinate(locationJson, 2); // Index 2 = longitude
//   }

//   /// Parse une coordonnée géographique spécifique
//   static double? _parseCoordinate(dynamic locationJson, int index) {
//     try {
//       final List<dynamic> locationList = locationJson ?? [];
//       if (locationList.length >= index + 1) {
//         return double.tryParse(locationList[index].toString());
//       }
//     } catch (e) {
//       debugPrint("Erreur parsing coordonnée à l'index $index: $e");
//     }
//     return null;
//   }

//   // === MÉTHODES PUBLIQUES UTILITAIRES ===

//   /// Crée une nouvelle instance de Property avec les champs mis à jour
//   Property copyWith({
//     String? id,
//     String? title,
//     String? description,
//     String? address,
//     int? monthlyPrice,
//     int? area,
//     int? roomsNb,
//     int? bathroomsNb,
//     String? mainImage,
//     List<String>? otherImages,
//     bool? certified,
//     String? status,
//     Town? town,
//     Category? category,
//     String? refNumber,
//     int? livingRoomsNb,
//     bool? hasInternalKitchen,
//     bool? hasExternalKitchen,
//     bool? hasAParking,
//     bool? hasAirConditioning,
//     bool? hasSecurityGuards,
//     bool? hasBalcony,
//     String? ownerId,
//     List<String>? location,
//     double? latitude,
//     double? longitude,
//     String? waterSupply,
//     String? electricalConnection,
//     int? compartmentNumber,
//     bool? hasSendVerifiedRequest,
//   }) {
//     return Property(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       address: address ?? this.address,
//       monthlyPrice: monthlyPrice ?? this.monthlyPrice,
//       area: area ?? this.area,
//       roomsNb: roomsNb ?? this.roomsNb,
//       bathroomsNb: bathroomsNb ?? this.bathroomsNb,
//       mainImage: mainImage ?? this.mainImage,
//       otherImages: otherImages ?? this.otherImages,
//       certified: certified ?? this.certified,
//       status: status ?? this.status,
//       town: town ?? this.town,
//       category: category ?? this.category,
//       refNumber: refNumber ?? this.refNumber,
//       livingRoomsNb: livingRoomsNb ?? this.livingRoomsNb,
//       hasInternalKitchen: hasInternalKitchen ?? this.hasInternalKitchen,
//       hasExternalKitchen: hasExternalKitchen ?? this.hasExternalKitchen,
//       hasAParking: hasAParking ?? this.hasAParking,
//       hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
//       hasSecurityGuards: hasSecurityGuards ?? this.hasSecurityGuards,
//       hasBalcony: hasBalcony ?? this.hasBalcony,
//       ownerId: ownerId ?? this.ownerId,
//       location: location ?? this.location,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       waterSupply: waterSupply ?? this.waterSupply,
//       electricalConnection: electricalConnection ?? this.electricalConnection,
//       compartmentNumber: compartmentNumber ?? this.compartmentNumber,
//       hasSendVerifiedRequest: hasSendVerifiedRequest ?? this.hasSendVerifiedRequest,
//     );
//   }

//   /// Vérifie si la localisation GPS est disponible
//   bool get hasValidLocation => latitude != null && longitude != null;

//   /// Retourne le prix formaté pour l'affichage
//   String get formattedPrice => '$monthlyPrice FCFA/mois';

//   /// Retourne la surface formatée pour l'affichage
//   String get formattedArea => '$area m²';

//   /// Vérifie si la propriété est disponible à la location
//   bool get isAvailable => status == 'free' || status == 'available';

//   /// Retourne la liste des équipements/aménités sous forme de texte
//   List<String> get amenities {
//     final List<String> amenitiesList = [];
    
//     if (hasInternalKitchen) amenitiesList.add('Cuisine interne');
//     if (hasExternalKitchen) amenitiesList.add('Cuisine externe');
//     if (hasAParking) amenitiesList.add('Parking');
//     if (hasAirConditioning) amenitiesList.add('Climatisation');
//     if (hasSecurityGuards) amenitiesList.add('Gardiennage');
//     if (hasBalcony) amenitiesList.add('Balcon');
    
//     return amenitiesList;
//   }

//   /// Retourne le statut d'approvisionnement en eau sous forme lisible
//   String get formattedWaterSupply {
//     switch (waterSupply) {
//       case 'available':
//         return 'Eau disponible';
//       case 'not_available':
//         return 'Eau non disponible';
//       case 'planned':
//         return 'Eau prévue';
//       default:
//         return 'Non spécifié';
//     }
//   }

//   /// Retourne le statut de connexion électrique sous forme lisible
//   String get formattedElectricalConnection {
//     switch (electricalConnection) {
//       case 'available':
//         return 'Électricité disponible';
//       case 'not_available':
//         return 'Électricité non disponible';
//       case 'planned':
//         return 'Électricité prévue';
//       default:
//         return 'Non spécifié';
//     }
//   }

//   /// Retourne le nombre total de pièces (chambres + salons)
//   int get totalRooms => roomsNb + livingRoomsNb;

//   /// Vérifie si la propriété a au moins une image
//   bool get hasImages => mainImage.isNotEmpty || otherImages.isNotEmpty;

//   /// Retourne toutes les images (principale + secondaires)
//   List<String> get allImages {
//     final List<String> images = [];
//     if (mainImage.isNotEmpty) images.add(mainImage);
//     images.addAll(otherImages);
//     return images;
//   }
// }

// // =============================================================================
// // RÉPONSE PAGINÉE DE PROPRIÉTÉS
// // =============================================================================

// /// Représente une réponse paginée de la liste des propriétés
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

//   /// Factory constructor pour créer une PropertyListResponse à partir de données JSON
//   factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
//     final metadata = json['metadata'] as Map<String, dynamic>;
//     final recordsJson = json['records'] as List<dynamic>;

//     return PropertyListResponse(
//       records: recordsJson
//           .map((e) => Property.fromJson(e as Map<String, dynamic>))
//           .toList(),
//       totalRecords: metadata['total_records'] as int,
//       totalPages: metadata['total_pages'] as int,
//       currentPage: metadata['current_page'] as int,
//     );
//   }

//   /// Convertit l'objet PropertyListResponse en Map JSON pour l'API
//   Map<String, dynamic> toJson() {
//     return {
//       'records': records.map((property) => property.toJson()).toList(),
//       'metadata': {
//         'total_records': totalRecords,
//         'total_pages': totalPages,
//         'current_page': currentPage,
//       },
//     };
//   }

//   /// Vérifie s'il y a une page suivante
//   bool get hasNextPage => currentPage < totalPages;

//   /// Vérifie s'il y a une page précédente
//   bool get hasPreviousPage => currentPage > 1;

//   /// Retourne le nombre d'éléments sur la page actuelle
//   int get currentPageSize => records.length;
// }
// lib/models/property_model.dart
import 'package:flutter/material.dart';
import 'town.dart'; // Import depuis le fichier dédié
import 'category.dart'; // Import depuis le fichier dédié
import 'user.dart';

// =============================================================================
// MODÈLE FAVORI
// =============================================================================

/// Représente un bien immobilier marqué comme favori par un utilisateur
class Favorite {
  final String id;
  final String propertyId;
  final String createdById;
  final String refNumber;
  final bool active;

  // Dans property_model.dart, ajoutez à la classe Favorite
  factory Favorite.empty() {
    return Favorite(
      id: '',
      propertyId: '',
      createdById: '',
      refNumber: '',
      active: false,
    );
  }

  Favorite({
    required this.id,
    required this.propertyId,
    required this.createdById,
    required this.refNumber,
    required this.active,
  });

  /// Factory constructor pour créer un Favorite à partir de données JSON
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      createdById: json['created_by'] as String,
      refNumber: json['refnumber'] as String? ?? 'N/A',
      active: json['active'] as bool? ?? true,
    );
  }

  /// Convertit l'objet Favorite en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'created_by': createdById,
      'refnumber': refNumber,
      'active': active,
    };
  }
}

// =============================================================================
// MODÈLE PROPRIÉTÉ
// =============================================================================

/// Représente un bien immobilier avec toutes ses caractéristiques et équipements
class Property {
  // === INFORMATIONS DE BASE ===
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
  final Town town; // Utilise la classe Town du fichier town.dart
  final Category category; // Utilise la classe Category du fichier category.dart

  // === CARACTÉRISTIQUES DÉTAILLÉES ===
  final String refNumber;
  final int livingRoomsNb;
  final bool hasInternalKitchen;
  final bool hasExternalKitchen;
  final bool hasAParking;
  final bool hasAirConditioning;
  final bool hasSecurityGuards;
  final bool hasBalcony;
  
  // === INFORMATIONS PROPRIÉTAIRE ===
  final String ownerId;
  final User owner; 
  
  // === LOCALISATION GÉOGRAPHIQUE ===
  final List<String> location;
  final double? latitude;
  final double? longitude;

  // === SERVICES ET ÉQUIPEMENTS ===
  final String waterSupply;
  final String electricalConnection;
  final int compartmentNumber;

  // === ÉTAT DE VÉRIFICATION ===
  final bool hasSendVerifiedRequest;
  // Dans property_model.dart, ajoutez à la classe Property
  factory Property.empty() {
    return Property(
      // Informations de base
      id: '',
      title: 'Propriété non disponible',
      description: 'Description non disponible',
      address: 'Adresse non spécifiée',
      monthlyPrice: 0,
      area: 0,
      roomsNb: 0,
      bathroomsNb: 0,
      mainImage: '',
      otherImages: [],
      certified: false,
      status: 'free',
      
      // Objets imbriqués
      town: Town.empty(),
      category: Category.empty(),
      
      // Caractéristiques détaillées
      refNumber: 'N/A',
      livingRoomsNb: 0,
      hasInternalKitchen: false,
      hasExternalKitchen: false,
      hasAParking: false,
      hasAirConditioning: false,
      hasSecurityGuards: false,
      hasBalcony: false,
      
      // Propriétaire
      ownerId: '',
      owner: User.empty(),
      
      // Localisation
      location: [],
      latitude: null,
      longitude: null,
      
      // Services
      waterSupply: 'not_available',
      electricalConnection: 'not_available',
      compartmentNumber: 0,
      
      // Vérification
      hasSendVerifiedRequest: false,
    );
  }
  

  /// Constructeur principal de la classe Property
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
    required this.owner,
    required this.location,
    this.latitude,
    this.longitude,
    required this.waterSupply,
    required this.electricalConnection,
    required this.compartmentNumber,
    required this.hasSendVerifiedRequest,
  });

  // === MÉTHODES DE PARSING JSON ===

  /// Factory constructor pour créer un Property à partir de données JSON
  // factory Property.fromJson(Map<String, dynamic> json) {
  //   return Property(
  //     id: json['id'] as String,
  //     title: json['title'] as String,
  //     description: json['description'] as String? ?? 'Description non disponible.',
  //     address: json['address'] as String? ?? 'Adresse non spécifiée',
      
  //     // Parsing des valeurs numériques avec gestion des nulls
  //     monthlyPrice: (json['monthly_price'] as num?)?.toInt() ?? 0,
  //     area: (json['area'] as num?)?.toInt() ?? 0,
  //     roomsNb: (json['rooms_nb'] as num?)?.toInt() ?? 0,
  //     bathroomsNb: (json['bathrooms_nb'] as num?)?.toInt() ?? 0,
  //     livingRoomsNb: (json['living_rooms_nb'] as num?)?.toInt() ?? 0,
  //     compartmentNumber: (json['compartment_number'] as num?)?.toInt() ?? 0,
      
  //     // Gestion des images
  //     mainImage: json['main_image'] as String? ?? '',
  //     otherImages: _parseOtherImages(json['other_images']),
      
  //     // Parsing des booléens avec valeurs par défaut
  //     certified: json['certified'] as bool? ?? false,
  //     hasInternalKitchen: json['has_internal_kitchen'] as bool? ?? false,
  //     hasExternalKitchen: json['has_external_kitchen'] as bool? ?? false,
  //     hasAParking: json['has_a_parking'] as bool? ?? false,
  //     hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
  //     hasSecurityGuards: json['has_security_guards'] as bool? ?? false,
  //     hasBalcony: json['has_balcony'] as bool? ?? false,
  //     hasSendVerifiedRequest: json['has_send_verified_request'] as bool? ?? false,
      
  //     status: json['status'] as String? ?? 'free',
      
  //     // Parsing des objets imbriqués
  //     town: Town.fromJson(json['town'] as Map<String, dynamic>),
  //     category: Category.fromJson(json['category'] as Map<String, dynamic>),
      
  //     refNumber: json['refnumber'] as String? ?? 'N/A',
  //     ownerId: _parseOwnerId(json),
  //     owner: User.fromJson(json['owner'] as Map<String, dynamic>),
      
  //     // Parsing de la localisation
  //     location: _parseLocation(json['location']),
  //     latitude: _parseLatitude(json['location']),
  //     longitude: _parseLongitude(json['location']),
      
  //     // Services avec valeurs par défaut
  //     waterSupply: json['water_supply'] as String? ?? 'not_available',
  //     electricalConnection: json['electrical_connection'] as String? ?? 'not_available',
  //   );
  // }
  factory Property.fromJson(Map<String, dynamic> json) {
    // Parse Town avec vérification
    final town = json['town'] != null && json['town'] is Map<String, dynamic>
        ? Town.fromJson(json['town'] as Map<String, dynamic>)
        : Town.empty();

    // Parse Category avec vérification
    final category = json['category'] != null && json['category'] is Map<String, dynamic>
        ? Category.fromJson(json['category'] as Map<String, dynamic>)
        : Category.empty();

    // Parse User (owner) avec vérification
    final owner = json['owner'] != null && json['owner'] is Map<String, dynamic>
        ? User.fromJson(json['owner'] as Map<String, dynamic>)
        : User.empty();

    return Property(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Titre non disponible',
      description: json['description'] as String? ?? 'Description non disponible.',
      address: json['address'] as String? ?? 'Adresse non spécifiée',
      
      // Parsing des valeurs numériques
      monthlyPrice: (json['monthly_price'] as num?)?.toInt() ?? 0,
      area: (json['area'] as num?)?.toInt() ?? 0,
      roomsNb: (json['rooms_nb'] as num?)?.toInt() ?? 0,
      bathroomsNb: (json['bathrooms_nb'] as num?)?.toInt() ?? 0,
      livingRoomsNb: (json['living_rooms_nb'] as num?)?.toInt() ?? 0,
      compartmentNumber: (json['compartment_number'] as num?)?.toInt() ?? 0,
      
      // Gestion des images
      mainImage: json['main_image'] as String? ?? '',
      otherImages: _parseOtherImages(json['other_images']),
      
      // Parsing des booléens
      certified: json['certified'] as bool? ?? false,
      hasInternalKitchen: json['has_internal_kitchen'] as bool? ?? false,
      hasExternalKitchen: json['has_external_kitchen'] as bool? ?? false,
      hasAParking: json['has_a_parking'] as bool? ?? false,
      hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
      hasSecurityGuards: json['has_security_guards'] as bool? ?? false,
      hasBalcony: json['has_balcony'] as bool? ?? false,
      hasSendVerifiedRequest: json['has_send_verified_request'] as bool? ?? false,
      
      status: json['status'] as String? ?? 'free',
      
      // Utilisation des objets parsés sécuritairement
      town: town,
      category: category,
      
      refNumber: json['refnumber'] as String? ?? 'N/A',
      ownerId: _parseOwnerId(json),
      owner: owner, // ← Déjà parsé avec vérification
      
      // Parsing de la localisation
      location: _parseLocation(json['location']),
      latitude: _parseLatitude(json['location']),
      longitude: _parseLongitude(json['location']),
      
      // Services
      waterSupply: json['water_supply'] as String? ?? 'not_available',
      electricalConnection: json['electrical_connection'] as String? ?? 'not_available',
    );
  }

  /// Convertit l'objet Property en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      // Informations de base
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'monthly_price': monthlyPrice,
      'area': area,
      'rooms_nb': roomsNb,
      'bathrooms_nb': bathroomsNb,
      'main_image': mainImage,
      'other_images': otherImages,
      'certified': certified,
      'status': status,
      
      // Objets imbriqués
      'town': town.toJson(),
      'category': category.toJson(),
      
      // Caractéristiques détaillées
      'refnumber': refNumber,
      'living_rooms_nb': livingRoomsNb,
      'has_internal_kitchen': hasInternalKitchen,
      'has_external_kitchen': hasExternalKitchen,
      'has_a_parking': hasAParking,
      'has_air_conditioning': hasAirConditioning,
      'has_security_guards': hasSecurityGuards,
      'has_balcony': hasBalcony,
      
      // Propriétaire
      'owner_id': ownerId,
      
      // Localisation
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      
      // Services
      'water_supply': waterSupply,
      'electrical_connection': electricalConnection,
      'compartment_number': compartmentNumber,
      
      // Vérification
      'has_send_verified_request': hasSendVerifiedRequest,
    };
  }

  // === MÉTHODES UTILITAIRES PRIVÉES ===

  /// Parse la liste des images supplémentaires
  static List<String> _parseOtherImages(dynamic imagesJson) {
    final List<dynamic> otherImagesJson = imagesJson ?? [];
    return otherImagesJson
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList();
  }

  /// Parse l'ID du propriétaire depuis différentes sources possibles
  static String _parseOwnerId(Map<String, dynamic> json) {
    if (json['owner_id'] != null) {
      return json['owner_id'] as String;
    } else if (json['owner'] != null && json['owner'] is Map<String, dynamic>) {
      return (json['owner'] as Map<String, dynamic>)['id'] as String? ?? '';
    } else {
      return '';
    }
  }

  /// Parse la liste de localisation
  static List<String> _parseLocation(dynamic locationJson) {
    final List<dynamic> locationList = locationJson ?? [];
    return locationList.map((e) => e.toString()).toList();
  }

  /// Parse la latitude depuis les données de localisation
  static double? _parseLatitude(dynamic locationJson) {
    return _parseCoordinate(locationJson, 1); // Index 1 = latitude
  }

  /// Parse la longitude depuis les données de localisation
  static double? _parseLongitude(dynamic locationJson) {
    return _parseCoordinate(locationJson, 2); // Index 2 = longitude
  }

  /// Parse une coordonnée géographique spécifique
  static double? _parseCoordinate(dynamic locationJson, int index) {
    try {
      final List<dynamic> locationList = locationJson ?? [];
      if (locationList.length >= index + 1) {
        return double.tryParse(locationList[index].toString());
      }
    } catch (e) {
      debugPrint("Erreur parsing coordonnée à l'index $index: $e");
    }
    return null;
  }

  // === MÉTHODES PUBLIQUES UTILITAIRES ===

  /// Crée une nouvelle instance de Property avec les champs mis à jour
  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    int? monthlyPrice,
    int? area,
    int? roomsNb,
    int? bathroomsNb,
    String? mainImage,
    List<String>? otherImages,
    bool? certified,
    String? status,
    Town? town,
    Category? category,
    String? refNumber,
    int? livingRoomsNb,
    bool? hasInternalKitchen,
    bool? hasExternalKitchen,
    bool? hasAParking,
    bool? hasAirConditioning,
    bool? hasSecurityGuards,
    bool? hasBalcony,
    String? ownerId,
    User? owner,
    List<String>? location,
    double? latitude,
    double? longitude,
    String? waterSupply,
    String? electricalConnection,
    int? compartmentNumber,
    bool? hasSendVerifiedRequest,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      area: area ?? this.area,
      roomsNb: roomsNb ?? this.roomsNb,
      bathroomsNb: bathroomsNb ?? this.bathroomsNb,
      mainImage: mainImage ?? this.mainImage,
      otherImages: otherImages ?? this.otherImages,
      certified: certified ?? this.certified,
      status: status ?? this.status,
      town: town ?? this.town,
      category: category ?? this.category,
      refNumber: refNumber ?? this.refNumber,
      livingRoomsNb: livingRoomsNb ?? this.livingRoomsNb,
      hasInternalKitchen: hasInternalKitchen ?? this.hasInternalKitchen,
      hasExternalKitchen: hasExternalKitchen ?? this.hasExternalKitchen,
      hasAParking: hasAParking ?? this.hasAParking,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasSecurityGuards: hasSecurityGuards ?? this.hasSecurityGuards,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      ownerId: ownerId ?? this.ownerId,
      owner: owner ?? this.owner,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      waterSupply: waterSupply ?? this.waterSupply,
      electricalConnection: electricalConnection ?? this.electricalConnection,
      compartmentNumber: compartmentNumber ?? this.compartmentNumber,
      hasSendVerifiedRequest: hasSendVerifiedRequest ?? this.hasSendVerifiedRequest,
    );
  }

  /// Vérifie si la localisation GPS est disponible
  bool get hasValidLocation => latitude != null && longitude != null;

  /// Retourne le prix formaté pour l'affichage
  String get formattedPrice => '$monthlyPrice FCFA/mois';

  /// Retourne la surface formatée pour l'affichage
  String get formattedArea => '$area m²';

  /// Vérifie si la propriété est disponible à la location
  bool get isAvailable => status == 'free' || status == 'available';

  /// Retourne la liste des équipements/aménités sous forme de texte
  List<String> get amenities {
    final List<String> amenitiesList = [];
    
    if (hasInternalKitchen) amenitiesList.add('Cuisine interne');
    if (hasExternalKitchen) amenitiesList.add('Cuisine externe');
    if (hasAParking) amenitiesList.add('Parking');
    if (hasAirConditioning) amenitiesList.add('Climatisation');
    if (hasSecurityGuards) amenitiesList.add('Gardiennage');
    if (hasBalcony) amenitiesList.add('Balcon');
    
    return amenitiesList;
  }

  /// Retourne le statut d'approvisionnement en eau sous forme lisible
  String get formattedWaterSupply {
    switch (waterSupply) {
      case 'available':
        return 'Eau disponible';
      case 'not_available':
        return 'Eau non disponible';
      case 'planned':
        return 'Eau prévue';
      default:
        return 'Non spécifié';
    }
  }

  /// Retourne le statut de connexion électrique sous forme lisible
  String get formattedElectricalConnection {
    switch (electricalConnection) {
      case 'available':
        return 'Électricité disponible';
      case 'not_available':
        return 'Électricité non disponible';
      case 'planned':
        return 'Électricité prévue';
      default:
        return 'Non spécifié';
    }
  }

  /// Retourne le nombre total de pièces (chambres + salons)
  int get totalRooms => roomsNb + livingRoomsNb;

  /// Vérifie si la propriété a au moins une image
  bool get hasImages => mainImage.isNotEmpty || otherImages.isNotEmpty;

  /// Retourne toutes les images (principale + secondaires)
  List<String> get allImages {
    final List<String> images = [];
    if (mainImage.isNotEmpty) images.add(mainImage);
    images.addAll(otherImages);
    return images;
  }
}

// =============================================================================
// RÉPONSE PAGINÉE DE PROPRIÉTÉS
// =============================================================================

/// Représente une réponse paginée de la liste des propriétés
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

  /// Factory constructor pour créer une PropertyListResponse à partir de données JSON
  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>;
    final recordsJson = json['records'] as List<dynamic>;

    return PropertyListResponse(
      records: recordsJson
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRecords: metadata['total_records'] as int,
      totalPages: metadata['total_pages'] as int,
      currentPage: metadata['current_page'] as int,
    );
  }

  /// Convertit l'objet PropertyListResponse en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'records': records.map((property) => property.toJson()).toList(),
      'metadata': {
        'total_records': totalRecords,
        'total_pages': totalPages,
        'current_page': currentPage,
      },
    };
  }

  /// Vérifie s'il y a une page suivante
  bool get hasNextPage => currentPage < totalPages;

  /// Vérifie s'il y a une page précédente
  bool get hasPreviousPage => currentPage > 1;

  /// Retourne le nombre d'éléments sur la page actuelle
  int get currentPageSize => records.length;
}