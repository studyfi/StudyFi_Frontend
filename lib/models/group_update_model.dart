class GroupUpdateModel {
  final String name;
  final String description;
  final String? imageFilePath; // Local file path, nullable

  GroupUpdateModel({
    required this.name,
    required this.description,
    this.imageFilePath,
  });
}
