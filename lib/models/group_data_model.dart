class GroupData {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;

  GroupData({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
