class QuizQuestion {
  final String question;
  final List<String> options;
  final int answer;
  final String? explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });
}

