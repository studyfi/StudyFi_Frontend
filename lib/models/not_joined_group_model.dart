class NotJoinedGroupModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;

  NotJoinedGroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory NotJoinedGroupModel.fromJson(Map<String, dynamic> json) {
    return NotJoinedGroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
