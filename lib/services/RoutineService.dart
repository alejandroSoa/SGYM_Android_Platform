import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/bussiness/routine_interface.dart';
import '../interfaces/bussiness/routine_excersice_interface.dart';
import 'UserService.dart';

class RoutineService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  static Future<String?> _getToken() async => await UserService.getToken();

  // Listar rutinas
  static Future<RoutineList?> fetchRoutines() async {
    final token = await _getToken();
    final url = '$_baseUrl/routines';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Routine.fromJson(e)).toList();
    }
    return null;
  }

  // Crear rutina
  static Future<Routine?> createRoutine({
    required String day,
    required String name,
    String? description,
    required int userId,
  }) async {
    final token = await _getToken();
    final url = '$_baseUrl/routines';
    final body = {
      'day': day,
      'name': name,
      'description': description,
      'user_id': userId,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
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
    final token = await _getToken();
    final url = '$_baseUrl/routines/$id';
    final body = {
      'day': day,
      'name': name,
      'description': description,
    };
    final response = await http.put(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Routine.fromJson(data);
    }
    return null;
  }

  // Eliminar rutina
  static Future<bool> deleteRoutine(int id) async {
    final token = await _getToken();
    final url = '$_baseUrl/routines/$id';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  // Obtener rutina por ID
  static Future<Routine?> fetchRoutineById(int id) async {
    final token = await _getToken();
    final url = '$_baseUrl/routines/$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
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
    final token = await _getToken();
    final url = '$_baseUrl/routine-exercises';
    final body = {
      'routine_id': routineId,
      'exercise_id': exerciseId,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return RoutineExercise.fromJson(data);
    }
    return null;
  }

  // Listar ejercicios de una rutina
  static Future<List<Map<String, dynamic>>?> fetchExercisesOfRoutine(int routineId) async {
    final token = await _getToken();
    final url = '$_baseUrl/routines/$routineId/exercises';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // Quitar ejercicio de una rutina
  static Future<bool> removeExerciseFromRoutine(int routineExerciseId) async {
    final token = await _getToken();
    final url = '$_baseUrl/routine-exercises/$routineExerciseId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}