class PostUser {
  final int id;
  final String name;
  final String? profileImageUrl;

  PostUser({
    required this.id,
    required this.name,
    this.profileImageUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class Post {
  final int postId;
  final int groupId;
  final String content;
  final String timestamp;
  final PostUser user;
  final int likeCount;
  final int commentCount;

  Post({
    required this.postId,
    required this.groupId,
    required this.content,
    required this.timestamp,
    required this.user,
    required this.likeCount,
    required this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      groupId: json['groupId'],
      content: json['content'],
      timestamp: json['timestamp'],
      user: PostUser.fromJson(json['user']),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
    );
  }
}

class PostComment {
  final int commentId;
  final String content;
  final String timestamp;
  final PostUser user;

  PostComment({
    required this.commentId,
    required this.content,
    required this.timestamp,
    required this.user,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      commentId: json['commentId'],
      content: json['content'],
      timestamp: json['timestamp'],
      user: PostUser.fromJson(json['user']),
    );
  }
}
