
enum ContentType { heading, text, code, list }

class ContentItem {
  final ContentType type;
  final String value;
  final String? language;

  ContentItem({required this.type, required this.value, this.language});
}

