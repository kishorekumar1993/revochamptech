

enum ContentType {
  heading,
  subheading,
  text,
  code,
  list,
  table,
  callout,
}

class ContentItem {
  final ContentType type;
  final dynamic value; // Changed from String to dynamic
  final String? language;
  final Map<String, dynamic>? tableData;
  final String? variant;

  ContentItem({
    required this.type,
    this.value,
    this.language,
    this.tableData,
    this.variant,
  });

  @override
  String toString() {
    return 'ContentItem(type: $type, value: $value, language: $language, tableData: $tableData, variant: $variant)';
  }
}
