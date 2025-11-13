// lib/models/town.dart
class Town {
  final String id;
  final String name;
  final String countryId;
  final Country country;

  Town({
    required this.id,
    required this.name,
    required this.countryId,
    required this.country,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      country: Country.fromJson(json['country']),
    );
  }
}

class Country {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
    );
  }
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
          .map((item) => Town.fromJson(item))
          .toList(),
      metadata: json['metadata'] ?? {},
    );
  }
}