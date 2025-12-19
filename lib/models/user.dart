// // lib/models/user.dart - VERSION CORRIGÉE
// import './town.dart' as town_model;
// import './property_model.dart' as property_model;
// import './category.dart' as category_model;

// class User {
//   // Champs avec underscore (correspondent à l'API)
//   final String id;
//   final String? refnumber;
//   final String? created_at;
//   final String? updated_at;
//   final String? created_by;
//   final dynamic creator;
//   final String? updated_by;
//   final dynamic updator;
//   final bool? active;
//   final String? username;
//   final String? phone;
//   final String? email;
//   final String? birthday;
//   final String? gender;
//   final String? role;
//   final String? image;
//   final bool? is_staff;
//   final String? town_id;
//   final town_model.Town? town; // Utilise le Town du fichier town.dart
//   final List<property_model.Property>? owned_properties; // Utilise le Property du fichier property_model.dart
//   final List<Signal>? reported_signals;
//   final List<Signal>? offender_signals;
//   final List<Favorite>? favorites;
//   final List<dynamic>? subscriptions;

//   // Getters camelCase pour utiliser dans le code Dart
//   List<property_model.Property>? get ownedProperties => owned_properties;
//   List<Signal>? get reportedSignals => reported_signals;
//   List<Signal>? get offenderSignals => offender_signals;
//   String? get townId => town_id;
//   String? get createdAt => created_at;
//   String? get updatedAt => updated_at;
//   String? get createdBy => created_by;
//   String? get updatedBy => updated_by;
//   bool? get isStaff => is_staff;

//   User({
//     required this.id,
//     this.refnumber,
//     this.created_at,
//     this.updated_at,
//     this.created_by,
//     this.creator,
//     this.updated_by,
//     this.updator,
//     this.active,
//     this.username,
//     this.phone,
//     this.email,
//     this.birthday,
//     this.gender,
//     this.role,
//     this.image,
//     this.is_staff,
//     this.town_id,
//     this.town,
//     this.owned_properties,
//     this.reported_signals,
//     this.offender_signals,
//     this.favorites,
//     this.subscriptions,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     print('🔍 Structure User JSON: ${json.keys}');
//     print('🔍 Favoris reçus: ${json['favorites']}');
    
//     if (json['favorites'] != null) {
//       print('🔍 Type des favoris: ${json['favorites'].runtimeType}');
//       if (json['favorites'] is List) {
//         for (var i = 0; i < (json['favorites'] as List).length; i++) {
//           print('   Favori $i: ${json['favorites'][i]}');
//         }
//       }
//     }
//     return User(
//       id: json['id']?.toString() ?? '',
//       refnumber: json['refnumber']?.toString(),
//       created_at: json['created_at']?.toString(),
//       updated_at: json['updated_at']?.toString(),
//       created_by: json['created_by']?.toString(),
//       creator: json['creator'],
//       updated_by: json['updated_by']?.toString(),
//       updator: json['updator'],
//       active: _parseBool(json['active']),
//       username: json['username']?.toString(),
//       phone: json['phone']?.toString(),
//       email: json['email']?.toString(),
//       birthday: json['birthday']?.toString(),
//       gender: json['gender']?.toString(),
//       role: json['role']?.toString(),
//       image: json['image']?.toString(),
//       is_staff: _parseBool(json['is_staff']),
//       town_id: json['town_id']?.toString(),
//       town: json['town'] != null ? town_model.Town.fromJson(json['town']) : null,
//       owned_properties: json['owned_properties'] != null 
//           ? (json['owned_properties'] as List).map((i) => property_model.Property.fromJson(i)).toList()
//           : null,
//       reported_signals: json['reported_signals'] != null
//           ? (json['reported_signals'] as List).map((i) => Signal.fromJson(i)).toList()
//           : null,
//       offender_signals: json['offender_signals'] != null
//           ? (json['offender_signals'] as List).map((i) => Signal.fromJson(i)).toList()
//           : null,
//       favorites: json['favorites'] != null
//           ? (json['favorites'] as List).map((i) => Favorite.fromJson(i)).toList()
//           : null,
//       subscriptions: json['subscriptions'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'refnumber': refnumber,
//       'created_at': created_at,
//       'updated_at': updated_at,
//       'created_by': created_by,
//       'creator': creator,
//       'updated_by': updated_by,
//       'updator': updator,
//       'active': active,
//       'username': username,
//       'phone': phone,
//       'email': email,
//       'birthday': birthday,
//       'gender': gender,
//       'role': role,
//       'image': image,
//       'is_staff': is_staff,
//       'town_id': town_id,
//       'town': town?.toJson(),
//       'owned_properties': owned_properties?.map((i) => i.toJson()).toList(),
//       'reported_signals': reported_signals?.map((i) => i.toJson()).toList(),
//       'offender_signals': offender_signals?.map((i) => i.toJson()).toList(),
//       'favorites': favorites?.map((i) => i.toJson()).toList(),
//       'subscriptions': subscriptions,
//     };
//   }

//   // Méthode pour créer un User à partir des données d'inscription
//   factory User.fromRegistrationData({
//     required String username,
//     required String phone,
//     required String email,
//     required String birthday,
//     required String password,
//     required String townId,
//     String? gender,
//     String? image,
//   }) {
//     return User(
//       id: '', // L'ID sera généré par le backend
//       username: username,
//       phone: phone,
//       email: email,
//       birthday: birthday,
//       gender: gender,
//       image: image,
//       town_id: townId,
//       active: true,
//       role: 'user',
//       is_staff: false,
//     );
//   }

//   // Méthode pour mettre à jour les informations de l'utilisateur
//   User copyWith({
//     String? username,
//     String? phone,
//     String? email,
//     String? birthday,
//     String? gender,
//     String? image,
//     String? townId,
//     town_model.Town? town,
//   }) {
//     return User(
//       id: id,
//       refnumber: refnumber,
//       created_at: created_at,
//       updated_at: updated_at,
//       created_by: created_by,
//       creator: creator,
//       updated_by: updated_by,
//       updator: updator,
//       active: active,
//       username: username ?? this.username,
//       phone: phone ?? this.phone,
//       email: email ?? this.email,
//       birthday: birthday ?? this.birthday,
//       gender: gender ?? this.gender,
//       role: role,
//       image: image ?? this.image,
//       is_staff: is_staff,
//       town_id: townId ?? town_id,
//       town: town ?? this.town,
//       owned_properties: owned_properties,
//       reported_signals: reported_signals,
//       offender_signals: offender_signals,
//       favorites: favorites,
//       subscriptions: subscriptions,
//     );
//   }

//   // Méthode utilitaire pour vérifier si l'utilisateur a un profil complet
//   bool get hasCompleteProfile {
//     return username != null &&
//         username!.isNotEmpty &&
//         phone != null &&
//         phone!.isNotEmpty &&
//         email != null &&
//         email!.isNotEmpty &&
//         birthday != null &&
//         birthday!.isNotEmpty &&
//         town_id != null &&
//         town_id!.isNotEmpty;
//   }

//   // Méthode pour obtenir l'âge de l'utilisateur
//   int? get age {
//     if (birthday == null) return null;
//     try {
//       final birthDate = DateTime.parse(birthday!);
//       final now = DateTime.now();
//       int age = now.year - birthDate.year;
//       if (now.month < birthDate.month ||
//           (now.month == birthDate.month && now.day < birthDate.day)) {
//         age--;
//       }
//       return age;
//     } catch (e) {
//       return null;
//     }
//   }

//   // Méthode pour vérifier si l'utilisateur est majeur
//   bool get isAdult {
//     final userAge = age;
//     return userAge != null && userAge >= 18;
//   }
// }

// class Signal {
//   final String id;
//   final String? owner_id;
//   final String? description;
//   final String? offender_id;
//   final String? property_id;
//   final User? owner;
//   final User? offender;
//   final property_model.Property? property; // Utilise Property du fichier property_model.dart

//   // Getters camelCase
//   String? get ownerId => owner_id;
//   String? get offenderId => offender_id;
//   String? get propertyId => property_id;

//   Signal({
//     required this.id,
//     this.owner_id,
//     this.description,
//     this.offender_id,
//     this.property_id,
//     this.owner,
//     this.offender,
//     this.property,
//   });

//   factory Signal.fromJson(Map<String, dynamic> json) {
//     return Signal(
//       id: json['id']?.toString() ?? '',
//       owner_id: json['owner_id']?.toString(),
//       description: json['description']?.toString(),
//       offender_id: json['offender_id']?.toString(),
//       property_id: json['property_id']?.toString(),
//       owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
//       offender: json['offender'] != null ? User.fromJson(json['offender']) : null,
//       property: json['property'] != null ? property_model.Property.fromJson(json['property']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'owner_id': owner_id,
//       'description': description,
//       'offender_id': offender_id,
//       'property_id': property_id,
//       'owner': owner?.toJson(),
//       'offender': offender?.toJson(),
//       'property': property?.toJson(),
//     };
//   }
// }

// class Favorite {
//   final String id;
//   final String? owner_id;
//   final String? property_id;
//   final User? owner;
//   final property_model.Property? property; // Utilise Property du fichier property_model.dart
//   final bool? active;

//   // Getters camelCase
//   String? get ownerId => owner_id;
//   String? get propertyId => property_id;
//   bool? get isActive => active; 

//   Favorite({
//     required this.id,
//     this.owner_id,
//     this.property_id,
//     this.owner,
//     this.property,
//     this.active,
//   });

//   factory Favorite.fromJson(Map<String, dynamic> json) {
//     print('🔍 Parsing Favorite JSON: $json');
//     return Favorite(
//       id: json['id']?.toString() ?? '',
//       owner_id: json['owner_id']?.toString(),
//       property_id: json['property_id']?.toString(),
//       owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
//       property: json['property'] != null ? property_model.Property.fromJson(json['property']) : null,
//       active: _parseBool(json['active']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'owner_id': owner_id,
//       'property_id': property_id,
//       'owner': owner?.toJson(),
//       'property': property?.toJson(),
//       'active': active,
//     };
//   }
// }

// // =============================================================================
// // FONCTIONS D'AIDE POUR LE PARSING
// // =============================================================================

// // Fonction pour parser les booléens (gère bool, int, String)
// bool? _parseBool(dynamic value) {
//   if (value == null) return null;
//   if (value is bool) return value;
//   if (value is num) return value != 0;
//   if (value is String) {
//     final lowerValue = value.toLowerCase();
//     return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
//   }
//   return null;
// }

// lib/models/user.dart - VERSION REFACTORISÉE

import './town.dart' as town_model;
import './property_model.dart' as property_model;
import './category.dart' as category_model;

/// Modèle représentant un utilisateur de l'application
/// Gère les données utilisateur, les signaux, les favoris et les méthodes associées
class User {
  // === CHAMPS PRIVÉS (correspondent aux noms de l'API) ===
  
  final String id;
  final String? refnumber;
  final String? created_at;
  final String? updated_at;
  final String? created_by;
  final dynamic creator;
  final String? updated_by;
  final dynamic updator;
  final bool? active;
  final String? username;
  final String? phone;
  final String? email;
  final String? birthday;
  final String? gender;
  final String? role;
  final String? image;
  final bool? is_staff;
  final String? town_id;
  final town_model.Town? town;
  final List<property_model.Property>? owned_properties;
  final List<Signal>? reported_signals;
  final List<Signal>? offender_signals;
  final List<Favorite>? favorites;
  final List<dynamic>? subscriptions;

  // === GETTERS PUBLIC (convention camelCase Dart) ===
  
  List<property_model.Property>? get ownedProperties => owned_properties;
  List<Signal>? get reportedSignals => reported_signals;
  List<Signal>? get offenderSignals => offender_signals;
  String? get townId => town_id;
  String? get createdAt => created_at;
  String? get updatedAt => updated_at;
  String? get createdBy => created_by;
  String? get updatedBy => updated_by;
  bool? get isStaff => is_staff;

  /// Constructeur principal de la classe User
  User({
    required this.id,
    this.refnumber,
    this.created_at,
    this.updated_at,
    this.created_by,
    this.creator,
    this.updated_by,
    this.updator,
    this.active,
    this.username,
    this.phone,
    this.email,
    this.birthday,
    this.gender,
    this.role,
    this.image,
    this.is_staff,
    this.town_id,
    this.town,
    this.owned_properties,
    this.reported_signals,
    this.offender_signals,
    this.favorites,
    this.subscriptions,
  });
  factory User.empty() {
  return User(
    id: '',
    refnumber: '',
    phone: '',
    username: 'Utilisateur inconnu',
    email: '',
    birthday: null,
    gender: null,
    image: null,
    active: false,
    // Ajoutez ces champs si votre modèle User les a
    role: 'user',
    is_staff: false,
    // town: Town.empty(), // Si vous avez un champ town dans User
    town: town_model.Town.empty(),
    owned_properties: [],
    favorites: [],
    reported_signals: [],
    offender_signals: [],
    subscriptions: [],
  );
}

  /// Factory constructor pour créer un User à partir de données JSON
  factory User.fromJson(Map<String, dynamic> json) {
    _debugUserJsonStructure(json);
    
    return User(
      id: json['id']?.toString() ?? '',
      refnumber: json['refnumber']?.toString(),
      created_at: json['created_at']?.toString(),
      updated_at: json['updated_at']?.toString(),
      created_by: json['created_by']?.toString(),
      creator: json['creator'],
      updated_by: json['updated_by']?.toString(),
      updator: json['updator'],
      active: _parseBool(json['active']),
      username: json['username']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      birthday: json['birthday']?.toString(),
      gender: json['gender']?.toString(),
      role: json['role']?.toString(),
      image: json['image']?.toString(),
      is_staff: _parseBool(json['is_staff']),
      town_id: json['town_id']?.toString(),
      town: json['town'] != null ? town_model.Town.fromJson(json['town']) : null,
      owned_properties: _parsePropertyList(json['owned_properties']),
      reported_signals: _parseSignalList(json['reported_signals']),
      offender_signals: _parseSignalList(json['offender_signals']),
      favorites: _parseFavoriteList(json['favorites']),
      subscriptions: json['subscriptions'],
    );
  }

  /// Convertit l'objet User en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refnumber': refnumber,
      'created_at': created_at,
      'updated_at': updated_at,
      'created_by': created_by,
      'creator': creator,
      'updated_by': updated_by,
      'updator': updator,
      'active': active,
      'username': username,
      'phone': phone,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'role': role,
      'image': image,
      'is_staff': is_staff,
      'town_id': town_id,
      'town': town?.toJson(),
      'owned_properties': owned_properties?.map((i) => i.toJson()).toList(),
      'reported_signals': reported_signals?.map((i) => i.toJson()).toList(),
      'offender_signals': offender_signals?.map((i) => i.toJson()).toList(),
      'favorites': favorites?.map((i) => i.toJson()).toList(),
      'subscriptions': subscriptions,
    };
  }

  /// Factory constructor pour créer un User à partir des données d'inscription
  factory User.fromRegistrationData({
    required String username,
    required String phone,
    required String email,
    required String birthday,
    required String password,
    required String townId,
    String? gender,
    String? image,
  }) {
    return User(
      id: '', // L'ID sera généré par le backend
      username: username,
      phone: phone,
      email: email,
      birthday: birthday,
      gender: gender,
      image: image,
      town_id: townId,
      active: true,
      role: 'user',
      is_staff: false,
    );
  }

  /// Crée une nouvelle instance de User avec les champs mis à jour
  User copyWith({
    String? username,
    String? phone,
    String? email,
    String? birthday,
    String? gender,
    String? image,
    String? townId,
    town_model.Town? town,
  }) {
    return User(
      id: id,
      refnumber: refnumber,
      created_at: created_at,
      updated_at: updated_at,
      created_by: created_by,
      creator: creator,
      updated_by: updated_by,
      updator: updator,
      active: active,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      role: role,
      image: image ?? this.image,
      is_staff: is_staff,
      town_id: townId ?? town_id,
      town: town ?? this.town,
      owned_properties: owned_properties,
      reported_signals: reported_signals,
      offender_signals: offender_signals,
      favorites: favorites,
      subscriptions: subscriptions,
    );
  }

  /// Vérifie si l'utilisateur a un profil complet (tous les champs requis remplis)
  bool get hasCompleteProfile {
    return username != null &&
        username!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        email != null &&
        email!.isNotEmpty &&
        birthday != null &&
        birthday!.isNotEmpty &&
        town_id != null &&
        town_id!.isNotEmpty;
  }

  /// Calcule l'âge de l'utilisateur à partir de sa date de naissance
  int? get age {
    if (birthday == null) return null;
    
    try {
      final birthDate = DateTime.parse(birthday!);
      final now = DateTime.now();
      int calculatedAge = now.year - birthDate.year;
      
      // Ajuste l'âge si l'anniversaire n'est pas encore passé cette année
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        calculatedAge--;
      }
      return calculatedAge;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si l'utilisateur est majeur (18 ans ou plus)
  bool get isAdult {
    final userAge = age;
    return userAge != null && userAge >= 18;
  }

  // === MÉTHODES PRIVÉES POUR LE PARSING ===

  /// Debug la structure JSON reçue pour le User
  static void _debugUserJsonStructure(Map<String, dynamic> json) {
    print('🔍 Structure User JSON: ${json.keys}');
    print('🔍 Favoris reçus: ${json['favorites']}');
    
    if (json['favorites'] != null) {
      print('🔍 Type des favoris: ${json['favorites'].runtimeType}');
      if (json['favorites'] is List) {
        for (var i = 0; i < (json['favorites'] as List).length; i++) {
          print('   Favori $i: ${json['favorites'][i]}');
        }
      }
    }
  }

  /// Parse une liste de propriétés depuis le JSON
  static List<property_model.Property>? _parsePropertyList(dynamic jsonList) {
    if (jsonList == null) return null;
    return (jsonList as List).map((i) => property_model.Property.fromJson(i)).toList();
  }

  /// Parse une liste de signaux depuis le JSON
  static List<Signal>? _parseSignalList(dynamic jsonList) {
    if (jsonList == null) return null;
    return (jsonList as List).map((i) => Signal.fromJson(i)).toList();
  }

  /// Parse une liste de favoris depuis le JSON
  static List<Favorite>? _parseFavoriteList(dynamic jsonList) {
    if (jsonList == null) return null;
    return (jsonList as List).map((i) => Favorite.fromJson(i)).toList();
  }
}

/// Modèle représentant un signal (signalement) entre utilisateurs
class Signal {
  final String id;
  final String? owner_id;
  final String? description;
  final String? offender_id;
  final String? property_id;
  final User? owner;
  final User? offender;
  final property_model.Property? property;

  // === GETTERS PUBLIC ===
  String? get ownerId => owner_id;
  String? get offenderId => offender_id;
  String? get propertyId => property_id;

  Signal({
    required this.id,
    this.owner_id,
    this.description,
    this.offender_id,
    this.property_id,
    this.owner,
    this.offender,
    this.property,
  });

  /// Factory constructor pour créer un Signal à partir de données JSON
  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id']?.toString() ?? '',
      owner_id: json['owner_id']?.toString(),
      description: json['description']?.toString(),
      offender_id: json['offender_id']?.toString(),
      property_id: json['property_id']?.toString(),
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      offender: json['offender'] != null ? User.fromJson(json['offender']) : null,
      property: json['property'] != null ? property_model.Property.fromJson(json['property']) : null,
    );
  }

  /// Convertit l'objet Signal en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': owner_id,
      'description': description,
      'offender_id': offender_id,
      'property_id': property_id,
      'owner': owner?.toJson(),
      'offender': offender?.toJson(),
      'property': property?.toJson(),
    };
  }
}

/// Modèle représentant un bien immobilier favori d'un utilisateur
class Favorite {
  final String id;
  final String? owner_id;
  final String? property_id;
  final User? owner;
  final property_model.Property? property;
  final bool? active;

  // === GETTERS PUBLIC ===
  String? get ownerId => owner_id;
  String? get propertyId => property_id;
  bool? get isActive => active;

  Favorite({
    required this.id,
    this.owner_id,
    this.property_id,
    this.owner,
    this.property,
    this.active,
  });

  /// Factory constructor pour créer un Favorite à partir de données JSON
  factory Favorite.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing Favorite JSON: $json');
    
    return Favorite(
      id: json['id']?.toString() ?? '',
      owner_id: json['owner_id']?.toString(),
      property_id: json['property_id']?.toString(),
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      property: json['property'] != null ? property_model.Property.fromJson(json['property']) : null,
      active: _parseBool(json['active']),
    );
  }

  /// Convertit l'objet Favorite en Map JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': owner_id,
      'property_id': property_id,
      'owner': owner?.toJson(),
      'property': property?.toJson(),
      'active': active,
    };
  }
}

// =============================================================================
// FONCTIONS UTILITAIRES POUR LE PARSING
// =============================================================================

/// Parse une valeur dynamique en booléen
/// Gère les types bool, int, String ('true', '1', 'yes')
bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lowerValue = value.toLowerCase();
    return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
  }
  return null;
}