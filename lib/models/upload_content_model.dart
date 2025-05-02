import 'dart:io';

class UploadContentModel {
  final String title;
  final String contentText;
  final String author;
  final int groupId;
  final File file;

  UploadContentModel({
    required this.title,
    required this.contentText,
    required this.author,
    required this.groupId,
    required this.file,
  });
}
