import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/NetworkService.dart';
import '../interfaces/bussiness/diet_food_interface.dart';
import '../interfaces/bussiness/user_diet_interface.dart';

class DietService {
  static String get _baseUrl => dotenv.env['BUSINESS_BASE_URL'] ?? '';

  // Listar dietas del usuario autenticado
  static Future<List<UserDiet>?> fetchUserDiets() async {
    try {
      final fullUrl = '$_baseUrl/user_diet';
      print('=== USER DIET SERVICE DEBUG ===');
      print('URL de consulta: $fullUrl');

      final response = await NetworkService.get(fullUrl);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de dietas de usuario extraída: $data');
        print('Cantidad de dietas: ${data.length}');

        // Procesar cada elemento individualmente con logging detallado
        final List<UserDiet> result = [];
        for (int i = 0; i < data.length; i++) {
          try {
            print('Procesando dieta de usuario $i: ${data[i]}');
            print('Tipo del elemento $i: ${data[i].runtimeType}');
            final userDiet = UserDiet.fromJson(data[i]);
            result.add(userDiet);
            print(
              'Dieta de usuario $i convertida exitosamente: ${userDiet.name}',
            );
          } catch (e) {
            print('Error al convertir dieta de usuario $i: $e');
            print('Datos del elemento problemático: ${data[i]}');
            // Continúa con las otras dietas en lugar de fallar completamente
          }
        }

        print('Resultado final: ${result.length} dietas de usuario cargadas');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN USER DIET SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Listar dietas (endpoint para administración)
  static Future<List<Map<String, dynamic>>?> fetchDiets() async {
    try {
      final fullUrl = '$_baseUrl/diets';
      print('=== DIET SERVICE DEBUG ===');
      print('URL de consulta: $fullUrl');

      final response = await NetworkService.get(fullUrl);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de dietas extraída: $data');
        print('Cantidad de dietas: ${data.length}');

        final result = data.map((e) => Map<String, dynamic>.from(e)).toList();
        print('Resultado final: $result');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN DIET SERVICE ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      rethrow;
    }
  }

  // Crear dieta
  static Future<Map<String, dynamic>?> createDiet({
    required String name,
    String? description,
  }) async {
    final fullUrl = '$_baseUrl/diets';
    final body = {'name': name, 'description': description};
    final response = await NetworkService.post(fullUrl, body: body);
    if (response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Actualizar dieta
  static Future<Map<String, dynamic>?> updateDiet({
    required int id,
    required String name,
    String? description,
  }) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final body = {'name': name, 'description': description};
    final response = await NetworkService.put(fullUrl, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Obtener dieta por ID
  static Future<Map<String, dynamic>?> fetchDietById(int id) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final response = await NetworkService.get(fullUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // Eliminar dieta
  static Future<bool> deleteDiet(int id) async {
    final fullUrl = '$_baseUrl/diets/$id';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }

  // Agregar alimentos a dieta
  static Future<DietFoodList?> addFoodsToDiet({
    required int dietId,
    required List<int> foodIds,
  }) async {
    try {
      final fullUrl = '$_baseUrl/diets/$dietId/foods';
      final body = {'food_ids': foodIds};

      print('=== ADD FOODS TO DIET DEBUG ===');
      print('URL: $fullUrl');
      print('Body enviado: $body');
      print('Diet ID: $dietId');
      print('Food IDs: $foodIds');

      final response = await NetworkService.post(fullUrl, body: body);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de datos extraída: $data');
        print('Cantidad de elementos: ${data.length}');

        // Procesar cada elemento individualmente con logging detallado
        final List<DietFood> result = [];
        for (int i = 0; i < data.length; i++) {
          try {
            print('Procesando elemento $i: ${data[i]}');
            print('Tipo del elemento $i: ${data[i].runtimeType}');
            final dietFood = DietFood.fromJson(data[i]);
            result.add(dietFood);
            print('Elemento $i convertido exitosamente: $dietFood');
          } catch (e) {
            print('Error al convertir elemento $i: $e');
            print('Datos del elemento problemático: ${data[i]}');
            rethrow;
          }
        }

        print('Resultado final convertido: $result');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN ADD FOODS TO DIET ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      print('Stack trace: $e');
      return null;
    }
  }

  // Listar alimentos de una dieta
  static Future<List<Map<String, dynamic>>?> fetchFoodsOfDiet(
    int dietId,
  ) async {
    try {
      final fullUrl = '$_baseUrl/diets/$dietId/foods';

      print('=== FETCH FOODS OF DIET DEBUG ===');
      print('URL: $fullUrl');
      print('Diet ID: $dietId');

      final response = await NetworkService.get(fullUrl);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de datos extraída: $data');
        print('Cantidad de elementos: ${data.length}');

        for (int i = 0; i < data.length; i++) {
          print('Elemento $i: ${data[i]}');
          print('Tipo del elemento $i: ${data[i].runtimeType}');
        }

        final result = data.map((e) => Map<String, dynamic>.from(e)).toList();
        print('Resultado final convertido: $result');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN FETCH FOODS OF DIET ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      print('Stack trace: $e');
      return null;
    }
  }

  // Listar alimentos de una dieta de usuario
  static Future<List<Map<String, dynamic>>?> fetchFoodsOfUserDiet(
    int dietId,
  ) async {
    try {
      final fullUrl = '$_baseUrl/diets/$dietId/foods';

      print('=== FETCH FOODS OF USER DIET DEBUG ===');
      print('URL: $fullUrl');
      print('Diet ID: $dietId');

      final response = await NetworkService.get(fullUrl);

      print('Status code de respuesta: ${response.statusCode}');
      print('Headers de respuesta: ${response.headers}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Datos decodificados: $responseData');

        final data = responseData['data'] as List;
        print('Lista de datos extraída: $data');
        print('Cantidad de elementos: ${data.length}');

        for (int i = 0; i < data.length; i++) {
          print('Elemento $i: ${data[i]}');
          print('Tipo del elemento $i: ${data[i].runtimeType}');
        }

        final result = data.map((e) => Map<String, dynamic>.from(e)).toList();
        print('Resultado final convertido: $result');
        return result;
      } else {
        print('Error en respuesta - Status: ${response.statusCode}');
        print('Mensaje de error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== ERROR EN FETCH FOODS OF USER DIET ===');
      print('Excepción capturada: $e');
      print('Tipo de excepción: ${e.runtimeType}');
      print('Stack trace: $e');
      return null;
    }
  }

  // Eliminar alimento de una dieta
  static Future<bool> removeFoodFromDiet({
    required int dietId,
    required int dietFoodId,
  }) async {
    final fullUrl = '$_baseUrl/diets/$dietId/foods/$dietFoodId';
    final response = await NetworkService.delete(fullUrl);
    return response.statusCode == 200;
  }
}
