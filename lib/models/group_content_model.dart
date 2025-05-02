class GroupContent {
  final int id;
  final String title;
  final String content;
  final String author;
  final List<int> groupIds;
  final String fileURL;

  GroupContent({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.groupIds,
    required this.fileURL,
  });

  factory GroupContent.fromJson(Map<String, dynamic> json) {
    return GroupContent(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      groupIds: List<int>.from(json['groupIds']),
      fileURL: json['fileURL'],
    );
  }
}
