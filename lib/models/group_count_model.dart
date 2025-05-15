class GroupCountModel {
  final int contentCount;
  final int newsCount;
  final int userCount;
  final int postsCount;

  GroupCountModel({
    required this.contentCount,
    required this.newsCount,
    required this.userCount,
    required this.postsCount,
  });

  factory GroupCountModel.fromJson(Map<String, dynamic> json) {
    return GroupCountModel(
      contentCount: json['contentCount'] ?? 0,
      newsCount: json['newsCount'] ?? 0,
      userCount: json['userCount'] ?? 0,
      postsCount: json['chatCount'] ?? 0,
    );
  }
}
