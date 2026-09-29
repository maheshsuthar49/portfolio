class ProjectModel {
  final String title;
  final String description;
  final String imageUrl;
  final String? playStoreLink;
  final String? appStoreLink;
  final String? githubLink;

  ProjectModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.playStoreLink,
    this.appStoreLink,
    this.githubLink,
  });
}
