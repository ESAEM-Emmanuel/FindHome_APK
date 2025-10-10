// lib/models/property_model.dart

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
  // Country est omis pour la simplicité, mais peut être ajouté si nécessaire

  Town({required this.id, required this.name});

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'] as String,
      name: json['name'] as String,
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
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Gestion de la liste d'images (peut être null ou vide dans l'API)
    List<dynamic> otherImagesJson = json['other_images'] ?? [];
    List<String> otherImages = otherImagesJson.map((e) => e.toString()).toList();

    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      monthlyPrice: json['monthly_price'] as int,
      area: json['area'] as int,
      roomsNb: json['rooms_nb'] as int,
      bathroomsNb: json['bathrooms_nb'] as int,
      mainImage: json['main_image'] as String,
      otherImages: otherImages,
      certified: json['certified'] as bool,
      status: json['status'] as String,
      town: Town.fromJson(json['town'] as Map<String, dynamic>),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}

// Modèle pour la réponse paginée de la liste des propriétés
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