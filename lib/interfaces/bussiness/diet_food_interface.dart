class DietFood {
  final int id;
  final int foodId;
  final int dietId;

  DietFood({
    required this.id,
    required this.foodId,
    required this.dietId,
  });

  factory DietFood.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final foodId = json['foodId'] ?? json['food_id'];
    final dietId = json['dietId'] ?? json['diet_id'];
    
    if (id == null || foodId == null || dietId == null) {
      throw ArgumentError('Missing required fields in DietFood JSON: $json');
    }
    
    return DietFood(
      id: id is int ? id : int.parse(id.toString()),
      foodId: foodId is int ? foodId : int.parse(foodId.toString()),
      dietId: dietId is int ? dietId : int.parse(dietId.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_id': foodId,
      'diet_id': dietId,
    };
  }
}

typedef DietFoodList = List<DietFood>;