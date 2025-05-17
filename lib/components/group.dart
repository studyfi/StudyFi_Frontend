import 'package:flutter/material.dart';
import 'package:studyfi/components/custom_poppins_text.dart';
import 'package:studyfi/constants.dart';
import 'package:studyfi/screens/groups/group_info_page.dart';

class Group extends StatelessWidget {
  final int groupId;
  final String? imagePath;
  final String title;
  final String description;
  final RouteObserver<ModalRoute> routeObserver;

  const Group({
    super.key,
    required this.groupId,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.routeObserver,
  });

  String _trimDescription(String desc, {int maxLength = 100}) {
    if (desc.length <= maxLength) return desc;
    return '${desc.substring(0, maxLength - 3)}...';
  }

  ImageProvider _getImageProvider() {
    if (imagePath != null && imagePath!.isNotEmpty && imagePath!.startsWith('http')) {
      return NetworkImage(imagePath!);
    }
    return const AssetImage('assets/group_icon.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupInfoPage(
              groupId: groupId,
              imagePath: imagePath,
              title: title,
              description: description,
              routeObserver: routeObserver,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'group_image_$groupId',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Constants.lgreen, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: _getImageProvider(),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Group image load error: $exception');
                      },
                      child: _getImageProvider() is AssetImage
                          ? null
                          : const Icon(
                        Icons.group,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPoppinsText(
                        text: title,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      CustomPoppinsText(
                        text: _trimDescription(description),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfoPage(
                        groupId: groupId,
                        imagePath: imagePath,
                        title: title,
                        description: description,
                        routeObserver: routeObserver,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.dgreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                ),
                child: const CustomPoppinsText(
                  text: "View Details",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}