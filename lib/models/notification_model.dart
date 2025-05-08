class NotificationModel {
  final int id;
  final String message;
  final bool read;
  final String? timestamp;
  final int userId;
  final int? groupId;
  final String? groupName;

  NotificationModel({
    required this.id,
    required this.message,
    required this.read,
    this.timestamp,
    required this.userId,
    this.groupId,
    this.groupName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      message: json['message'] as String,
      read: json['read'] as bool,
      timestamp: json['timestamp'] as String?,
      userId: json['userId'] as int,
      groupId: json['groupId'] as int?,
      groupName: json['groupName'] as String?,
    );
  }
}
