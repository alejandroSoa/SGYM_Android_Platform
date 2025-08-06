class Routine {
  final int id;
  final String day;
  final String name;
  final String? description;
  final int userId;

  Routine({
    required this.id,
    required this.day,
    required this.name,
    this.description,
    required this.userId,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as int? ?? 0,
      day: json['day'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'name': name,
      'description': description,
      'userId': userId,
    };
  }
}

typedef RoutineList = List<Routine>;

// Interfaz para el ejercicio anidado en la respuesta de ejercicios de rutina
class RoutineExerciseDetail {
  final int id;
  final String name;
  final String description;
  final String equipmentType;
  final String? videoUrl;

  RoutineExerciseDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.equipmentType,
    this.videoUrl,
  });

  factory RoutineExerciseDetail.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      equipmentType: json['equipmentType'] as String? ?? '',
      videoUrl: json['videoUrl'] as String?,
    );
  }
}

// Interfaz para la respuesta completa de ejercicios de rutina
class RoutineExerciseResponse {
  final int id;
  final int exerciseId;
  final int routineId;
  final RoutineExerciseDetail exercise;

  RoutineExerciseResponse({
    required this.id,
    required this.exerciseId,
    required this.routineId,
    required this.exercise,
  });

  factory RoutineExerciseResponse.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseResponse(
      id: json['id'] as int? ?? 0,
      exerciseId: json['exerciseId'] as int? ?? 0,
      routineId: json['routineId'] as int? ?? 0,
      exercise: RoutineExerciseDetail.fromJson(
        json['exercise'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

typedef RoutineExerciseResponseList = List<RoutineExerciseResponse>;
