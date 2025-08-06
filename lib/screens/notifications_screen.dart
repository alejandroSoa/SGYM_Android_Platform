import 'package:flutter/material.dart';
import '../interfaces/notification_interface.dart';
import '../services/LocalNotificationService.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onNotificationChanged;
  final VoidCallback? onBack;

  const NotificationsScreen({
    super.key, 
    this.onNotificationChanged,
    this.onBack,
  });

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
      final loadedNotifications =
          await LocalNotificationService.getNotifications();
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

    // Notificar al padre que cambió el estado de las notificaciones
    if (widget.onNotificationChanged != null) {
      widget.onNotificationChanged!();
    }
  }

  Future<void> _markAllAsRead() async {
    await LocalNotificationService.markAllAsRead();
    _loadNotifications(); // Recargar para actualizar UI

    // Notificar al padre que cambió el estado de las notificaciones
    if (widget.onNotificationChanged != null) {
      widget.onNotificationChanged!();
    }

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

    // Notificar al padre que cambió el estado de las notificaciones
    if (widget.onNotificationChanged != null) {
      widget.onNotificationChanged!();
    }
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

      // Notificar al padre que cambió el estado de las notificaciones
      if (widget.onNotificationChanged != null) {
        widget.onNotificationChanged!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones eliminadas'),
            backgroundColor: Colors.green,
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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).canPop() ? Navigator.pop(context) : null;
            }
          },
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
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
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
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
            'Todo tranquilo por aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
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
        color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: notification.isRead 
            ? null 
            : Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(notification.isRead ? 0.05 : 0.08),
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
          child: const Icon(Icons.delete, color: Colors.white, size: 24),
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
                // Ícono de notificación
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB19CD9).withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // Punto indicador para notificaciones no leídas
                    if (!notification.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Contenido de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (notification.body.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    notification.body,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
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
