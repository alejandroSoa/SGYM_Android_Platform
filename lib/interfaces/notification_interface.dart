class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? data; // Para data adicional del push notification

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  // Convertir desde JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  // Crear copia con cambios
  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? data,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
