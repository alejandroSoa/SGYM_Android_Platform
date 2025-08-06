class UserRoutine {
  final int id;
  final String name;
  final String? description;
  final String day;

  UserRoutine({
    required this.id,
    required this.name,
    this.description,
    required this.day,
  });

  factory UserRoutine.fromJson(Map<String, dynamic> json) {
    return UserRoutine(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      day: json['day'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'day': day};
  }
}

typedef UserRoutineList = List<UserRoutine>;
