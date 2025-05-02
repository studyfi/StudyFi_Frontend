class GroupCountModel {
  final int contentCount;
  final int newsCount;
  final int userCount;

  GroupCountModel({
    required this.contentCount,
    required this.newsCount,
    required this.userCount,
  });

  factory GroupCountModel.fromJson(Map<String, dynamic> json) {
    return GroupCountModel(
      contentCount: json['contentCount'] ?? 0,
      newsCount: json['newsCount'] ?? 0,
      userCount: json['userCount'] ?? 0,
    );
  }
}
