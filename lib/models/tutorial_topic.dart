class TutorialTopic {
  final String slug;
  final String title;
  final String emoji;
  final String category;

  TutorialTopic({
    required this.slug,
    required this.title,
    required this.emoji,
    required this.category,
  });

  factory TutorialTopic.fromJson(Map<String, dynamic> json) {
    return TutorialTopic(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      emoji: json['emoji']?.toString() ?? '📘',
      category: json['category']?.toString() ?? 'Other',
    );
  }
}
