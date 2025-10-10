class Market {
  int? id;
  final String owner;
  final String description;
  final String hours;
  final String avatar;

  Market({
    this.id,
    required this.owner,
    required this.description,
    required this.hours,
    required this.avatar,
  });

  factory Market.fromMap(Map<String, dynamic> data) {
    return Market(
      id: data['id'],
      owner: data['owner'],
      description: data['description'],
      hours: data['hours'],
      avatar: data['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'description': description,
      'hours': hours,
      'avatar': avatar,
    };
  }
}