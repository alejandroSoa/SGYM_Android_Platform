import 'package:flutter/material.dart';
import '../interfaces/notification_interface.dart';
import '../services/LocalNotificationService.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedNotifications = await LocalNotificationService.getNotifications();
      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      print('Error cargando notificaciones: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await LocalNotificationService.markAsRead(notificationId);
    _loadNotifications(); // Recargar para actualizar UI
  }

  Future<void> _markAllAsRead() async {
    await LocalNotificationService.markAllAsRead();
    _loadNotifications(); // Recargar para actualizar UI
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    await LocalNotificationService.deleteNotification(notificationId);
    _loadNotifications(); // Recargar para actualizar UI
  }

  Future<void> _clearAllNotifications() async {
    // Mostrar diálogo de confirmación
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar notificaciones'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar todas las notificaciones?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar todas'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await LocalNotificationService.clearAllNotifications();
      _loadNotifications(); // Recargar para actualizar UI
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones eliminadas'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    _markAllAsRead();
                    break;
                  case 'clear_all':
                    _clearAllNotifications();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Marcar todas como leídas'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar todas'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFF6366F1),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => _markAsRead(notification.id),
                        onDelete: () => _deleteNotification(notification.id),
                        timeAgo: _formatDateTime(notification.timestamp),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las notificaciones push aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          // Botón para agregar notificación de prueba
          ElevatedButton(
            onPressed: () async {
              await LocalNotificationService.saveNotification(
                title: 'Notificación de prueba',
                body: 'Esta es una notificación de ejemplo para probar el sistema',
                data: 'test_data',
              );
              _loadNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar notificación de prueba'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String timeAgo;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFF0F0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[300]! : const Color(0xFF6366F1).withOpacity(0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),
        onDismissed: (direction) {
          onDelete();
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de no leída
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  decoration: BoxDecoration(
                    color: notification.isRead 
                        ? Colors.transparent 
                        : const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
                
                // Ícono de notificación
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Contenido de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead 
                              ? FontWeight.w500 
                              : FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
