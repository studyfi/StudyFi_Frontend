class Comment {
  final int commentId;
  final int postId;
  final String content;
  final String timestamp;
  final CommentUser user;

  Comment({
    required this.commentId,
    required this.postId,
    required this.content,
    required this.timestamp,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      postId: json['postId'],
      content: json['content'],
      timestamp: json['timestamp'],
      user: CommentUser.fromJson(json['user']),
    );
  }
}

class CommentUser {
  final int id;
  final String name;
  final String? profileImageUrl;

  CommentUser({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
