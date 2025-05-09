import 'dart:io';

class CreateNewsModel {
  final String headline;
  final String content;
  final String author;
  final List<int> groupIds;
  final File? imageFile;

  CreateNewsModel({
    required this.headline,
    required this.content,
    required this.author,
    required this.groupIds,
    this.imageFile,
  });

  // Helper method to check if model is valid
  bool isValid() {
    return headline.isNotEmpty &&
        content.isNotEmpty &&
        author.isNotEmpty &&
        groupIds.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'content': content,
      'author': author,
      'groupIds': groupIds,
      if (imageFile != null) 'imageUrl': imageFile,
    };
  }
}
