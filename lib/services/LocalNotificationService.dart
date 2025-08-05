import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/notification_interface.dart';

class LocalNotificationService {
  static const String _notificationsKey = 'stored_notifications';
  static const int _maxNotifications = 50; // Máximo 50 notificaciones

  // Guardar una nueva notificación
  static Future<void> saveNotification({
    required String title,
    required String body,
    String? data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener notificaciones existentes
      final notifications = await getNotifications();
      
      // Verificar duplicados: misma notificación en los últimos 10 segundos
      final now = DateTime.now();
      final isDuplicate = notifications.any((notification) {
        final timeDiff = now.difference(notification.timestamp).inSeconds;
        return notification.title == title && 
               notification.body == body && 
               timeDiff < 10; // Menos de 10 segundos
      });
      
      if (isDuplicate) {
        print('Notificación duplicada detectada, no se guardará: $title');
        return;
      }
      
      // Crear nueva notificación
      final notification = NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: now,
        data: data,
      );

      // Agregar la nueva notificación al principio
      notifications.insert(0, notification);
      
      // Mantener solo las últimas _maxNotifications
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }

      // Convertir a JSON y guardar
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(jsonList));
      
      print('Notificación guardada: $title');
    } catch (e) {
      print('Error guardando notificación: $e');
    }
  }

  // Obtener todas las notificaciones
  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);
      
      if (jsonString == null) return [];
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => NotificationItem.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo notificaciones: $e');
      return [];
    }
  }

  // Marcar notificación como leída
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].id == notificationId) {
          notifications[i] = notifications[i].copyWith(isRead: true);
          break;
        }
      }

      // Guardar cambios
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(jsonList));
    } catch (e) {
      print('Error marcando notificación como leída: $e');
    }
  }

  // Marcar todas como leídas
  static Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      
      for (int i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }

      // Guardar cambios
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(jsonList));
    } catch (e) {
      print('Error marcando todas las notificaciones como leídas: $e');
    }
  }

  // Eliminar una notificación
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      // Guardar cambios
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(jsonList));
    } catch (e) {
      print('Error eliminando notificación: $e');
    }
  }

  // Limpiar todas las notificaciones
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      print('Error limpiando notificaciones: $e');
    }
  }

  // Obtener contador de notificaciones no leídas
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      print('Error obteniendo contador de no leídas: $e');
      return 0;
    }
  }
}
