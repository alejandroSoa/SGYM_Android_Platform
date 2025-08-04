class Food {
  final int id;
  final String name;
  final double grams;
  final double calories;
  final String? otherInfo;

  Food({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    this.otherInfo,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      grams: _parseDouble(json['grams']),
      calories: _parseDouble(json['calories']),
      otherInfo: _parseOtherInfo(json['otherInfo'] ?? json['other_info']),
    );
  }

  // Método auxiliar para convertir String o num a double de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Método auxiliar para manejar other_info de manera segura
  static String? _parseOtherInfo(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      // Si es string vacío, devolver null también
      return value.trim().isEmpty ? null : value.trim();
    }
    // Si no es string, convertirlo a string
    return value.toString().trim().isEmpty ? null : value.toString().trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grams': grams,
      'calories': calories,
      'other_info': otherInfo,
    };
  }
}

typedef FoodList = List<Food>;
