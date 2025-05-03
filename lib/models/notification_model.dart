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
      id: json['id'],
      message: json['message'],
      read: json['read'],
      timestamp: json['timestamp'],
      userId: json['userId'],
      groupId: json['groupId'],
      groupName: json['groupName'],
    );
  }
}
