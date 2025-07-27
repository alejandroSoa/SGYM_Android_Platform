import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../interfaces/notifications/notification_interface.dart';
import '../network/NetworkService.dart';

class NotificationService {
  /// Enviar notificación externa
  ///
  /// [channel] - Canal de notificación: "email" o "push"
  /// [message] - Mensaje de la notificación
  /// [userIds] - Lista de IDs de usuarios destinatarios
  /// [subject] - Asunto (obligatorio para email)
  /// [data] - Datos adicionales para notificaciones push
  ///
  /// Returns [NotificationResponse] confirmando el envío
  static Future<NotificationResponse> sendNotification({
    required String channel,
    required String message,
    required List<int> userIds,
    String? subject,
    NotificationData? data,
  }) async {
    try {
      // Validaciones
      if (channel != 'email' && channel != 'push') {
        throw Exception('Canal no válido. Debe ser "email" o "push"');
      }

      if (channel == 'email' && (subject == null || subject.isEmpty)) {
        throw Exception(
          'El subject es obligatorio para notificaciones de email',
        );
      }

      if (userIds.isEmpty) {
        throw Exception('Debe especificar al menos un usuario destinatario');
      }

      final baseUrl = dotenv.env['NOTIFICATION_BASE_URL'];
      final fullUrl = '$baseUrl/notifications/send';

      print('Enviando notificación a: $fullUrl'); // Debug log

      final request = NotificationRequest(
        channel: channel,
        subject: subject,
        message: message,
        userIds: userIds,
        data: data,
      );

      final response = await NetworkService.post(
        fullUrl,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
          'Notificación enviada exitosamente: ${responseData['data']['notifications_sent']} notificaciones',
        ); // Debug log
        return NotificationResponse.fromJson(responseData);
      } else {
        print('Error al enviar notificación: ${response.body}'); // Debug log
        throw Exception(response.body);
      }
    } catch (e) {
      print('Excepción en sendNotification: $e'); // Debug log
      throw e;
    }
  }
}
