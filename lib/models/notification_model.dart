class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromMap(Map<String, dynamic> data, String id) =>
      AppNotification(
        id: id,
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        isRead: data['isRead'] ?? false,
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
      );
}
