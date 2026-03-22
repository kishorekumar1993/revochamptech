import 'package:techtutorial/models/content_item.dart';
import 'package:techtutorial/models/quiz_question.dart';

class TutorialData {
  final String title;
  final String subtitle;
  final String difficulty;
  final String readTime;
  final Map<String, dynamic>? meta;
  final List<Map<String, dynamic>> faq;
  final List<ContentItem> content;
  final List<QuizQuestion> quiz;
  final String defaultCode;
  final List<String> relatedSlugs;

  TutorialData({
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.readTime,
    this.meta,
    required this.faq,
    required this.content,
    required this.quiz,
    required this.defaultCode,
    required this.relatedSlugs,
  });
}


