import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/routine_excersice_interface.dart';
import '../network/NetworkService.dart';

class RoutineService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar rutinas
  static Future<RoutineList?> fetchRoutines() async {
    try {
      final url = '$_baseUrl/routines';
      final response = await NetworkService.get(url);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Decoded response: $responseData');
        
        final data = responseData['data'] as List;
        print('Data list: $data');
        
        return data.map((e) {
          print('Processing routine item: $e');
          return Routine.fromJson(e);
        }).toList();
      }
      return null;
    } catch (e) {
      print('Error in fetchRoutines: $e');
      rethrow;
    }
  }

  // Crear rutina
  static Future<Routine?> createRoutine({
    required String day,
    required String name,
    String? description,
    required int userId,
  }) async {
    final url = '$_baseUrl/routines';
    final body = {
      'day': day,
      'name': name,
      'description': description,
      'user_id': userId,
    };
    final response = await NetworkService.post(url, body: body);
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Actualizar rutina
  static Future<Routine?> updateRoutine({
    required int id,
    required String day,
    required String name,
    String? description,
  }) async {
    final url = '$_baseUrl/routines/$id';
    final body = {
      'day': day,
      'name': name,
      'description': description,
    };
    final response = await NetworkService.put(url, body: body);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Eliminar rutina
  static Future<bool> deleteRoutine(int id) async {
    final url = '$_baseUrl/routines/$id';
    final response = await NetworkService.delete(url);
    
    return response.statusCode == 200;
  }

  // Obtener rutina por ID
  static Future<Routine?> fetchRoutineById(int id) async {
    final url = '$_baseUrl/routines/$id';
    final response = await NetworkService.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Asignar ejercicio a rutina
  static Future<RoutineExercise?> assignExerciseToRoutine({
    required int routineId,
    required int exerciseId,
  }) async {
    final url = '$_baseUrl/routine-exercises';
    final body = {
      'routine_id': routineId,
      'exercise_id': exerciseId,
    };
    final response = await NetworkService.post(url, body: body);
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return RoutineExercise.fromJson(data);
    }
    return null;
  }

  // Listar ejercicios de una rutina
  static Future<List<Map<String, dynamic>>?> fetchExercisesOfRoutine(int routineId) async {
    final url = '$_baseUrl/routines/$routineId/exercises';
    final response = await NetworkService.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Quitar ejercicio de una rutina
  static Future<bool> removeExerciseFromRoutine(int routineExerciseId) async {
    final url = '$_baseUrl/routine-exercises/$routineExerciseId';
    final response = await NetworkService.delete(url);
    
    return response.statusCode == 200;
  }
}