// // lib/models/category.dart

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

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//     };
//   }

//   @override
//   String toString() {
//     return 'Category(id: $id, name: $name)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Category && other.id == id && other.name == name;
//   }

//   @override
//   int get hashCode => id.hashCode ^ name.hashCode;
// }

// // Ajoutez cette classe dans le même fichier
// class CategoryListResponse {
//   final List<Category> records;
//   final int totalRecords;
//   final int totalPages;
//   final int currentPage;

//   CategoryListResponse({
//     required this.records,
//     required this.totalRecords,
//     required this.totalPages,
//     required this.currentPage,
//   });

//   factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
//     final metadata = json['metadata'] as Map<String, dynamic>;
//     final recordsJson = json['records'] as List<dynamic>;

//     return CategoryListResponse(
//       records: recordsJson.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
//       totalRecords: metadata['total_records'] as int,
//       totalPages: metadata['total_pages'] as int,
//       currentPage: metadata['current_page'] as int,
//     );
//   }
// }
// lib/models/category.dart
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
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
    return 'Category(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class CategoryListResponse {
  final List<Category> records;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  CategoryListResponse({
    required this.records,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>;
    final recordsJson = json['records'] as List<dynamic>;

    return CategoryListResponse(
      records: recordsJson.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
      totalRecords: metadata['total_records'] as int,
      totalPages: metadata['total_pages'] as int,
      currentPage: metadata['current_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((category) => category.toJson()).toList(),
      'metadata': {
        'total_records': totalRecords,
        'total_pages': totalPages,
        'current_page': currentPage,
      },
    };
  }
}