class TutorialTopic {
  final String slug;
  final String title;
  final String emoji;
  final String category;
  final String level;
final double? estimatedHours; // <-- ADD THIS

  TutorialTopic({
    required this.slug,
    required this.title,
    required this.emoji,
    required this.category,
    required this.level,
required    this.estimatedHours,
  });

  factory TutorialTopic.fromJson(Map<String, dynamic> json) {
    return TutorialTopic(
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      emoji: json['emoji']?.toString() ?? '📘',
      category: json['category']?.toString() ?? 'Other',
      level: json['level']?.toString() ?? 'Other',
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(), // <-- ADD
    );
  }
}
