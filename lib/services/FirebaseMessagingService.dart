import 'package:firebase_messaging/firebase_messaging.dart';
import 'LocalNotificationService.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Inicializar Firebase Messaging
  static Future<void> initialize() async {
    // Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Usuario autorizó las notificaciones');
      
      // Configurar handlers
      await _setupHandlers();
    } else {
      print('Usuario denegó las notificaciones');
    }
  }

  // Configurar handlers para notificaciones
  static Future<void> _setupHandlers() async {
    // Cuando la app está abierta y recibe una notificación
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en foreground: ${message.notification?.title}');
      
      // Guardar la notificación localmente
      _saveNotificationLocally(message);
    });

    // Cuando el usuario toca una notificación y la app estaba cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación tocada: ${message.notification?.title}');
      
      // NO guardamos aquí porque ya se guardó cuando llegó la notificación
      // Solo manejamos la navegación si es necesario
      
      // Aquí puedes navegar a una pantalla específica si es necesario
      // _navigateToSpecificScreen(message);
    });

    // Cuando la app se abre desde una notificación inicial
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App abierta desde notificación: ${initialMessage.notification?.title}');
      // NO guardamos aquí porque ya se guardó cuando llegó la notificación
      // Solo manejamos la navegación si es necesario
      // _navigateToSpecificScreen(initialMessage);
    }
  }

  // Guardar notificación localmente
  static Future<void> _saveNotificationLocally(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notificación';
    final body = message.notification?.body ?? '';
    final data = message.data.isNotEmpty ? message.data.toString() : null;

    await LocalNotificationService.saveNotification(
      title: title,
      body: body,
      data: data,
    );
  }

  // Método público para guardar notificaciones desde background handler
  static Future<void> saveBackgroundNotification(RemoteMessage message) async {
    await _saveNotificationLocally(message);
  }

  // Obtener token FCM
  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error obteniendo token FCM: $e');
      return null;
    }
  }

  // Suscribirse a un topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Suscrito al topic: $topic');
    } catch (e) {
      print('Error suscribiéndose al topic $topic: $e');
    }
  }

  // Desuscribirse de un topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Desuscrito del topic: $topic');
    } catch (e) {
      print('Error desuscribiéndose del topic $topic: $e');
    }
  }
}
