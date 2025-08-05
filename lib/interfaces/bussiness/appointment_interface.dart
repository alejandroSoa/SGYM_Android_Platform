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

// Para las citas del usuario con nutriólogo
class UserNutritionistAppointment {
  final int id;
  final int nutritionistId;
  final String date;
  final String startTime;
  final String endTime;

  UserNutritionistAppointment({
    required this.id,
    required this.nutritionistId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory UserNutritionistAppointment.fromJson(Map<String, dynamic> json) {
    return UserNutritionistAppointment(
      id: json['id'] as int,
      nutritionistId: json['nutritionistId'] as int,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nutritionistId': nutritionistId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

// Clase unificada para todas las citas del usuario
class UserAppointment {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String type; // 'trainer' o 'nutritionist'
  final int? trainerId;
  final int? nutritionistId;

  UserAppointment({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.trainerId,
    this.nutritionistId,
  });

  factory UserAppointment.fromTrainerAppointment(
    UserTrainerAppointment appointment,
  ) {
    return UserAppointment(
      id: appointment.id,
      date: appointment.date,
      startTime: appointment.startTime,
      endTime: appointment.endTime,
      type: 'trainer',
      trainerId: appointment.trainerId,
    );
  }

  factory UserAppointment.fromNutritionistAppointment(
    UserNutritionistAppointment appointment,
  ) {
    return UserAppointment(
      id: appointment.id,
      date: appointment.date,
      startTime: appointment.startTime,
      endTime: appointment.endTime,
      type: 'nutritionist',
      nutritionistId: appointment.nutritionistId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'trainerId': trainerId,
      'nutritionistId': nutritionistId,
    };
  }
}

typedef TrainerAppointmentList = List<TrainerAppointment>;
typedef NutritionistAppointmentList = List<NutritionistAppointment>;
typedef UserTrainerAppointmentList = List<UserTrainerAppointment>;
typedef UserNutritionistAppointmentList = List<UserNutritionistAppointment>;
typedef UserAppointmentList = List<UserAppointment>;
