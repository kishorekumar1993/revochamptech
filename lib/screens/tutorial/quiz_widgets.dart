import 'package:flutter/material.dart';
import 'package:techtutorial/models/quiz_question.dart';

class QuizQuestionState {
  int? selectedAnswer;
  bool? isCorrect;
  String? explanation;
}

class QuizCard extends StatelessWidget {
  final int index;
  final int total;
  final QuizQuestion question;
  final QuizQuestionState state;
  final bool submitted;
  final ValueChanged<int> onAnswerSelected;

  const QuizCard({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.state,
    required this.submitted,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 HEADER
          Text(
            "Question ${index + 1} / $total",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 QUESTION
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3C72),
            ),
          ),

          const SizedBox(height: 18),

          // 🔹 OPTIONS
          ..._buildOptionList(),

          // 🔹 EXPLANATION
          if (submitted &&
              state.isCorrect == false &&
              question.explanation != null)
            _buildExplanation(),
        ],
      ),
    );
  }

  List<Widget> _buildOptionList() {
    return question.options.asMap().entries.map((opt) {
      final i = opt.key;

      final isSelected = state.selectedAnswer == i;
      final isCorrect = submitted && i == question.answer;
      final isWrong = submitted && isSelected && i != question.answer;

      return QuizOptionItem(
        text: opt.value,
        isSelected: isSelected,
        isCorrect: isCorrect,
        isWrong: isWrong,
        submitted: submitted,
        onTap: submitted ? null : () => onAnswerSelected(i),
      );
    }).toList();
  }

  Widget _buildExplanation() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              question.explanation!,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizOptionItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool submitted;
  final VoidCallback? onTap;

  const QuizOptionItem({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.submitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;

    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.08);
    } else if (isWrong) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.08);
    } else if (isSelected) {
      borderColor = const Color(0xFF2A5298);
      bgColor = const Color(0xFF2A5298).withOpacity(0.08);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              if (submitted && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),

              if (submitted && isWrong)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}