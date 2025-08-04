class TrainerAppointment {
  final int id;
  final int userId;
  final int trainerId;
  final String date;
  final String startTime;
  final String endTime;

  TrainerAppointment({
    required this.id,
    required this.userId,
    required this.trainerId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TrainerAppointment.fromJson(Map<String, dynamic> json) {
    return TrainerAppointment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      trainerId: json['trainerId'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'trainerId': trainerId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class NutritionistAppointment {
  final int id;
  final int userId;
  final int nutritionistId;
  final String date;
  final String startTime;
  final String endTime;

  NutritionistAppointment({
    required this.id,
    required this.userId,
    required this.nutritionistId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory NutritionistAppointment.fromJson(Map<String, dynamic> json) {
    return NutritionistAppointment(
      id: json['id'] as int,
      userId: json['userId'] as int,
      nutritionistId: json['nutritionistId'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nutritionistId': nutritionistId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

// Para las citas del usuario que incluyen trainer_id pero no nutritionist_id
class UserTrainerAppointment {
  final int id;
  final int trainerId;
  final String date;
  final String startTime;
  final String endTime;

  UserTrainerAppointment({
    required this.id,
    required this.trainerId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory UserTrainerAppointment.fromJson(Map<String, dynamic> json) {
    return UserTrainerAppointment(
      id: json['id'] as int,
      trainerId: json['trainerId'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

typedef TrainerAppointmentList = List<TrainerAppointment>;
typedef NutritionistAppointmentList = List<NutritionistAppointment>;
typedef UserTrainerAppointmentList = List<UserTrainerAppointment>;
