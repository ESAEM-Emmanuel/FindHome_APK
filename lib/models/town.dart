// class Town {
//   final String id;
//   final String name;
//   final String countryId;
//   final Country country;

//   Town({
//     required this.id,
//     required this.name,
//     required this.countryId,
//     required this.country,
//   });

//   factory Town.fromJson(Map<String, dynamic> json) {
//     return Town(
//       id: json['id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       countryId: json['country_id']?.toString() ?? '',
//       country: Country.fromJson(json['country']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'country_id': countryId,
//       'country': country.toJson(),
//     };
//   }

//   @override
//   String toString() {
//     return name;
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Town && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
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

//   @override
//   String toString() {
//     return name;
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Country && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }

// class TownsResponse {
//   final List<Town> records;
//   final Map<String, dynamic> metadata;

//   TownsResponse({
//     required this.records,
//     required this.metadata,
//   });

//   factory TownsResponse.fromJson(Map<String, dynamic> json) {
//     return TownsResponse(
//       records: (json['records'] as List)
//           .map((item) => Town.fromJson(item as Map<String, dynamic>))
//           .toList(),
//       metadata: json['metadata'] ?? {},
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'records': records.map((town) => town.toJson()).toList(),
//       'metadata': metadata,
//     };
//   }
// }

class Town {
  final String id;
  final String name;
  final String countryId;
  final Country country;

  // Constructeur avec named parameters
  Town({
    required this.id,
    required this.name,
    required this.countryId,
    required this.country,
  });

  // Factory pour créer un Town vide (par défaut)
  factory Town.empty() {
    return Town(
      id: '',
      name: 'Ville inconnue',
      countryId: '',
      country: Country.empty(),
    );
  }

  // Factory pour parser depuis JSON
  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      countryId: json['country_id']?.toString() ?? '',
      // Protection contre les nulls
      country: json['country'] != null && json['country'] is Map<String, dynamic>
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : Country.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'country': country.toJson(),
    };
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Town && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Country {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  // Factory pour créer un Country vide (par défaut)
  factory Country.empty() {
    return Country(
      id: '',
      name: 'Pays inconnu',
    );
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TownsResponse {
  final List<Town> records;
  final Map<String, dynamic> metadata;

  TownsResponse({
    required this.records,
    required this.metadata,
  });

  factory TownsResponse.fromJson(Map<String, dynamic> json) {
    return TownsResponse(
      records: (json['records'] as List)
          .map((item) => Town.fromJson(item as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((town) => town.toJson()).toList(),
      'metadata': metadata,
    };
  }
}