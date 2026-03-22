class TutorialTopic {
  final String slug;
  final String title;
  final String emoji;
  final String category;
  final String level;

  TutorialTopic({
    required this.slug,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
  });

  factory TutorialTopic.fromJson(Map<String, dynamic> json) {
    return TutorialTopic(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      emoji: json['emoji']?.toString() ?? '📘',
      category: json['category']?.toString() ?? 'Other',
      level: json['level']?.toString() ?? 'Other',
    );
  }
}
