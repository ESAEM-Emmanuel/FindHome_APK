// // lib/models/user.dart
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
//   final Town? town;
//   final List<Property>? owned_properties;
//   final List<Signal>? reported_signals;
//   final List<Signal>? offender_signals;
//   final List<Favorite>? favorites;
//   final List<dynamic>? subscriptions;

//   // Getters camelCase pour utiliser dans le code Dart
//   List<Property>? get ownedProperties => owned_properties;
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
//       town: json['town'] != null ? Town.fromJson(json['town']) : null,
//       owned_properties: json['owned_properties'] != null 
//           ? (json['owned_properties'] as List).map((i) => Property.fromJson(i)).toList()
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
// }

// class Town {
//   final String id;
//   final String name;
//   final String? country_id;
//   final Country? country;

//   Town({
//     required this.id,
//     required this.name,
//     this.country_id,
//     this.country,
//   });

//   factory Town.fromJson(Map<String, dynamic> json) {
//     return Town(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       country_id: json['country_id']?.toString(),
//       country: json['country'] != null ? Country.fromJson(json['country']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'country_id': country_id,
//       'country': country?.toJson(),
//     };
//   }
// }

// class Country {
//   final String id;
//   final String name;

//   Country({
//     required this.id,
//     required this.name,
//   });

//   factory Country.fromJson(Map<String, dynamic> json) {
//     return Country(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//     };
//   }
// }

// class Property {
//   final String id;
//   final String? title;
//   final String? description;
//   final num? monthly_price; // CHANGÉ: int? → num?
//   final num? area; // CHANGÉ: int? → num?
//   final num? compartment_number; // CHANGÉ: int? → num?
//   final num? nb_visite; // CHANGÉ: int? → num?
//   final String? address;
//   final String? main_image;
//   final List<String>? other_images;
//   final List<String>? location;
//   final bool? certified;
//   final String? status;
//   final String? town_id;
//   final Town? town;
//   final String? category_property_id;
//   final Category? category;

//   // Getters camelCase avec conversion en int si nécessaire
//   int? get monthlyPrice => monthly_price?.toInt();
//   int? get areaInt => area?.toInt();
//   int? get compartmentNumber => compartment_number?.toInt();
//   int? get nbVisite => nb_visite?.toInt();
//   String? get mainImage => main_image;
//   List<String>? get otherImages => other_images;
//   String? get townId => town_id;
//   String? get categoryPropertyId => category_property_id;

//   Property({
//     required this.id,
//     this.title,
//     this.description,
//     this.monthly_price,
//     this.area,
//     this.compartment_number,
//     this.nb_visite,
//     this.address,
//     this.main_image,
//     this.other_images,
//     this.location,
//     this.certified,
//     this.status,
//     this.town_id,
//     this.town,
//     this.category_property_id,
//     this.category,
//   });

//   factory Property.fromJson(Map<String, dynamic> json) {
//     return Property(
//       id: json['id']?.toString() ?? '',
//       title: json['title']?.toString(),
//       description: json['description']?.toString(),
//       monthly_price: _parseNum(json['monthly_price']),
//       area: _parseNum(json['area']),
//       compartment_number: _parseNum(json['compartment_number']),
//       nb_visite: _parseNum(json['nb_visite']),
//       address: json['address']?.toString(),
//       main_image: json['main_image']?.toString(),
//       other_images: json['other_images'] != null 
//           ? List<String>.from(json['other_images'])
//           : null,
//       location: json['location'] != null
//           ? List<String>.from(json['location'])
//           : null,
//       certified: _parseBool(json['certified']),
//       status: json['status']?.toString(),
//       town_id: json['town_id']?.toString(),
//       town: json['town'] != null ? Town.fromJson(json['town']) : null,
//       category_property_id: json['category_property_id']?.toString(),
//       category: json['category'] != null ? Category.fromJson(json['category']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'monthly_price': monthly_price,
//       'area': area,
//       'compartment_number': compartment_number,
//       'nb_visite': nb_visite,
//       'address': address,
//       'main_image': main_image,
//       'other_images': other_images,
//       'location': location,
//       'certified': certified,
//       'status': status,
//       'town_id': town_id,
//       'town': town?.toJson(),
//       'category_property_id': category_property_id,
//       'category': category?.toJson(),
//     };
//   }
// }

// class Category {
//   final String id;
//   final String name;

//   Category({
//     required this.id,
//     required this.name,
//   });

//   factory Category.fromJson(Map<String, dynamic> json) {
//     return Category(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//     };
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
//   final Property? property;

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
//       property: json['property'] != null ? Property.fromJson(json['property']) : null,
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
//   final Property? property;

//   // Getters camelCase
//   String? get ownerId => owner_id;
//   String? get propertyId => property_id;

//   Favorite({
//     required this.id,
//     this.owner_id,
//     this.property_id,
//     this.owner,
//     this.property,
//   });

//   factory Favorite.fromJson(Map<String, dynamic> json) {
//     return Favorite(
//       id: json['id']?.toString() ?? '',
//       owner_id: json['owner_id']?.toString(),
//       property_id: json['property_id']?.toString(),
//       owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
//       property: json['property'] != null ? Property.fromJson(json['property']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'owner_id': owner_id,
//       'property_id': property_id,
//       'owner': owner?.toJson(),
//       'property': property?.toJson(),
//     };
//   }
// }

// // =============================================================================
// // FONCTIONS D'AIDE POUR LE PARSING
// // =============================================================================

// // Fonction pour parser les nombres (gère int, double et String)
// num? _parseNum(dynamic value) {
//   if (value == null) return null;
//   if (value is num) return value;
//   if (value is String) {
//     return num.tryParse(value);
//   }
//   return null;
// }

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
// lib/models/user.dart - VERSION CORRIGÉE
import './town.dart' as town_model;
import './property_model.dart' as property_model;
import './category.dart' as category_model;

class User {
  // Champs avec underscore (correspondent à l'API)
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
  final town_model.Town? town; // Utilise le Town du fichier town.dart
  final List<property_model.Property>? owned_properties; // Utilise le Property du fichier property_model.dart
  final List<Signal>? reported_signals;
  final List<Signal>? offender_signals;
  final List<Favorite>? favorites;
  final List<dynamic>? subscriptions;

  // Getters camelCase pour utiliser dans le code Dart
  List<property_model.Property>? get ownedProperties => owned_properties;
  List<Signal>? get reportedSignals => reported_signals;
  List<Signal>? get offenderSignals => offender_signals;
  String? get townId => town_id;
  String? get createdAt => created_at;
  String? get updatedAt => updated_at;
  String? get createdBy => created_by;
  String? get updatedBy => updated_by;
  bool? get isStaff => is_staff;

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

  factory User.fromJson(Map<String, dynamic> json) {
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
      owned_properties: json['owned_properties'] != null 
          ? (json['owned_properties'] as List).map((i) => property_model.Property.fromJson(i)).toList()
          : null,
      reported_signals: json['reported_signals'] != null
          ? (json['reported_signals'] as List).map((i) => Signal.fromJson(i)).toList()
          : null,
      offender_signals: json['offender_signals'] != null
          ? (json['offender_signals'] as List).map((i) => Signal.fromJson(i)).toList()
          : null,
      favorites: json['favorites'] != null
          ? (json['favorites'] as List).map((i) => Favorite.fromJson(i)).toList()
          : null,
      subscriptions: json['subscriptions'],
    );
  }

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

  // Méthode pour créer un User à partir des données d'inscription
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

  // Méthode pour mettre à jour les informations de l'utilisateur
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

  // Méthode utilitaire pour vérifier si l'utilisateur a un profil complet
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

  // Méthode pour obtenir l'âge de l'utilisateur
  int? get age {
    if (birthday == null) return null;
    try {
      final birthDate = DateTime.parse(birthday!);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  // Méthode pour vérifier si l'utilisateur est majeur
  bool get isAdult {
    final userAge = age;
    return userAge != null && userAge >= 18;
  }
}

class Signal {
  final String id;
  final String? owner_id;
  final String? description;
  final String? offender_id;
  final String? property_id;
  final User? owner;
  final User? offender;
  final property_model.Property? property; // Utilise Property du fichier property_model.dart

  // Getters camelCase
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

class Favorite {
  final String id;
  final String? owner_id;
  final String? property_id;
  final User? owner;
  final property_model.Property? property; // Utilise Property du fichier property_model.dart

  // Getters camelCase
  String? get ownerId => owner_id;
  String? get propertyId => property_id;

  Favorite({
    required this.id,
    this.owner_id,
    this.property_id,
    this.owner,
    this.property,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id']?.toString() ?? '',
      owner_id: json['owner_id']?.toString(),
      property_id: json['property_id']?.toString(),
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      property: json['property'] != null ? property_model.Property.fromJson(json['property']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': owner_id,
      'property_id': property_id,
      'owner': owner?.toJson(),
      'property': property?.toJson(),
    };
  }
}

// =============================================================================
// FONCTIONS D'AIDE POUR LE PARSING
// =============================================================================

// Fonction pour parser les booléens (gère bool, int, String)
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