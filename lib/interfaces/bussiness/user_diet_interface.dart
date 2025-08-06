class UserDiet {
  final int id;
  final String name;
  final String? description;
  final String day;

  UserDiet({
    required this.id,
    required this.name,
    this.description,
    required this.day,
  });

  factory UserDiet.fromJson(Map<String, dynamic> json) {
    return UserDiet(
      id: json['id'],
      name: json['name'] ?? 'Sin nombre',
      description: json['description'],
      day: json['day'] ?? 'Sin día',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'day': day,
    };
  }
}

typedef UserDietList = List<UserDiet>;
