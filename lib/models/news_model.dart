class NewsModel {
  final int id;
  final String headline;
  final String content;
  final String author;
  final List<int> groupIds;
  final String? imageUrl;

  NewsModel({
    required this.id,
    required this.headline,
    required this.content,
    required this.author,
    required this.groupIds,
    required this.imageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      headline: json['headline'],
      content: json['content'],
      author: json['author'],
      groupIds: List<int>.from(json['groupIds']),
      imageUrl: json['imageUrl'] != null ? json['imageUrl'] as String : '',
    );
  }
}
