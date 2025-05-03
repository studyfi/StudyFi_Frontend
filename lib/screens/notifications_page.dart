import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/models/notification_model.dart';
import 'package:studyfi/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationsFuture = _apiService.fetchNotifications();
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
          setState(() {
            _loadNotifications();
          });
        },
        child: FutureBuilder<List<NotificationModel>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: CustomPoppinsText(
                  text: 'Error loading notifications: ${snapshot.error}',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: CustomPoppinsText(
                  text: 'No notifications',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notification.read ? Colors.white : Colors.grey[50],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: CustomPoppinsText(
                      text: notification.message,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                        notification.message.contains('news')
                            ? Icons.newspaper
                            : Icons.article,
                        color: Constants.dgreen,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
