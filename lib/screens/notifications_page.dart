import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/notification_model.dart';
import 'package:studyfi/screens/groups/contents_page.dart';
import 'package:studyfi/screens/groups/news_page.dart';
import 'package:studyfi/screens/groups/post_page.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<NotificationModel>> _notificationsFuture;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _notifications = await _apiService.fetchNotifications(widget.userId);

      // Mark notifications as read when the page is opened
      // Here we should make an API call to mark them as read
      for (var notification in _notifications.where((n) => !n.read)) {
        await _apiService.markNotificationAsRead(widget.userId);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading notifications: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomPoppinsText(
          text: 'Notifications',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNotifications();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(
                    child: CustomPoppinsText(
                      text: 'No notifications',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          onTap: () {
                            final message = notification.message.toLowerCase();

                            if (notification.groupId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "No group associated with this notification.")),
                              );
                              return;
                            }

                            if (message.startsWith('new news')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewsPage(
                                    groupId: notification.groupId!,
                                    groupName:
                                        notification.groupName ?? 'Group',
                                  ),
                                ),
                              );
                            } else if (message.startsWith('new content')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentsPage(
                                    groupId: notification.groupId!,
                                    groupName:
                                        notification.groupName ?? 'Group',
                                    groupImageUrl: null, // optional
                                  ),
                                ),
                              );
                            } else if (message.startsWith('new posst')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostsPage(
                                    groupId: notification.groupId!,
                                    groupName:
                                    notification.groupName ?? 'Group',
                                    groupImageUrl: null, // optional
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostsPage(
                                    groupId: notification.groupId!,
                                    groupName:
                                    notification.groupName ?? 'Group',
                                    groupImageUrl: null, // optional
                                  ),
                                ),
                              );
                            }
                            // else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //         content:
                            //             Text("Unknown notification type.")),
                            //   );
                            // }
                          },
                          title: CustomPoppinsText(
                            text: notification.message,
                            fontSize: 16,
                            fontWeight: notification.read
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: Colors.black,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (notification.groupName != null)
                                CustomPoppinsText(
                                  text: notification.groupName!,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Constants.dgreen,
                                ),
                              const SizedBox(height: 4),
                              CustomPoppinsText(
                                text: _formatTimestamp(notification.timestamp),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600] ?? Colors.grey,
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Constants.lgreen,
                            child: Icon(
                              notification.message
                                      .toLowerCase()
                                      .contains('news')
                                  ? Icons.newspaper
                                  : Icons.article,
                              color: Constants.dgreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
