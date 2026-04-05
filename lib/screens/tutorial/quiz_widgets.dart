import 'package:flutter/material.dart';
import 'package:techtutorial/models/quiz_question.dart';

// ─── Design tokens (keep in sync with tutorial_page.dart) ──────────────────
const _navy = Color(0xFF0A0F1E);
const _surface = Color(0xFF111827);
const _card = Color(0xFF1A2235);
const _cardHover = Color(0xFF1F2A40);
const _accent = Color(0xFF3B82F6);
const _accentGlow = Color(0xFF60A5FA);
const _accentSoft = Color(0xFF1D3461);
const _success = Color(0xFF10B981);
const _successSoft = Color(0xFF0D2B22);
const _danger = Color(0xFFEF4444);
const _dangerSoft = Color(0xFF2D1515);
const _border = Color(0xFF1E2D45);
const _textPrimary = Color(0xFFE2E8F0);
const _textSecondary = Color(0xFF94A3B8);
const _textMuted = Color(0xFF475569);

class QuizQuestionState {
  int? selectedAnswer;
  bool? isCorrect;
  String? explanation;
}

// ─── QuizCard ─────────────────────────────────────────────────────────────────
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: submitted
              ? (state.isCorrect == true
                  ? _success.withValues(alpha:0.4)
                  : state.isCorrect == false
                      ? _danger.withValues(alpha:0.4)
                      : _border)
              : _border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _accentGlow,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'of $total',
                  style: const TextStyle(fontSize: 12, color: _textMuted),
                ),
                const Spacer(),
                if (submitted)
                  _ResultBadge(isCorrect: state.isCorrect ?? false),
              ],
            ),
          ),

          // Question text
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
                height: 1.5,
              ),
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(children: _buildOptionList()),
          ),

          // Explanation
          if (submitted && state.isCorrect == false && question.explanation != null)
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
        index: i,
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
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha:0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: _accentGlow, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              question.explanation!,
              style: const TextStyle(color: _textSecondary, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool isCorrect;
  const _ResultBadge({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isCorrect ? _successSoft : _dangerSoft,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isCorrect ? _success.withValues(alpha:0.35) : _danger.withValues(alpha:0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 12,
            color: isCorrect ? _success : _danger,
          ),
          const SizedBox(width: 5),
          Text(
            isCorrect ? 'Correct' : 'Wrong',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isCorrect ? _success : _danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── QuizOptionItem ───────────────────────────────────────────────────────────
class QuizOptionItem extends StatefulWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool submitted;
  final VoidCallback? onTap;

  const QuizOptionItem({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.submitted,
    required this.onTap,
  });

  @override
  State<QuizOptionItem> createState() => _QuizOptionItemState();
}

class _QuizOptionItemState extends State<QuizOptionItem> {
  bool _hovered = false;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    Color borderColor = _border;
    Color bgColor = Colors.transparent;
    Color labelColor = _textMuted;
    Color textColor = _textSecondary;

    if (widget.isCorrect) {
      borderColor = _success.withValues(alpha:0.6);
      bgColor = _successSoft;
      labelColor = _success;
      textColor = _success;
    } else if (widget.isWrong) {
      borderColor = _danger.withValues(alpha:0.6);
      bgColor = _dangerSoft;
      labelColor = _danger;
      textColor = _danger;
    } else if (widget.isSelected) {
      borderColor = _accent;
      bgColor = _accentSoft;
      labelColor = _accentGlow;
      textColor = _accentGlow;
    } else if (_hovered && !widget.submitted) {
      borderColor = _accent.withValues(alpha:0.4);
      bgColor = _accentSoft.withValues(alpha:0.5);
    }

    final letter = widget.index < _letters.length ? _letters[widget.index] : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: widget.isCorrect
                      ? _success.withValues(alpha:0.2)
                      : widget.isWrong
                          ? _danger.withValues(alpha:0.2)
                          : widget.isSelected
                              ? _accentSoft
                              : _border,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(fontSize: 14, color: textColor, height: 1.4),
                ),
              ),
              if (widget.submitted && widget.isCorrect)
                Icon(Icons.check_circle_rounded, color: _success, size: 18),
              if (widget.submitted && widget.isWrong)
                Icon(Icons.cancel_rounded, color: _danger, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// // ─── ScoreCard ────────────────────────────────────────────────────────────────
// class ScoreCard extends StatelessWidget {
//   final int score;
//   final int total;

//   const ScoreCard({super.key, required this.score, required this.total});

//   @override
//   Widget build(BuildContext context) {
//     final double percentage = total == 0 ? 0 : score / total;
//     final bool excellent = percentage >= 0.8;
//     final bool good = percentage >= 0.5;

//     final Color accentColor = excellent ? _success : good ? const Color(0xFFF59E0B) : _danger;
//     final String emoji = excellent ? '🎉' : good ? '👍' : '💪';
//     final String message = excellent ? 'Excellent work!' : good ? 'Good job!' : 'Keep practicing!';

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: _card,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: accentColor.withValues(alpha:0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: accentColor.withValues(alpha:0.08),
//             blurRadius: 20,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Score circle
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: accentColor, width: 3),
//               color: accentColor.withValues(alpha:0.08),
//             ),
//             child: Center(
//               child: Text(
//                 '$score/$total',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: accentColor,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Progress bar
//           ClipRRect(
//             borderRadius: BorderRadius.circular(6),
//             child: LinearProgressIndicator(
//               value: percentage,
//               minHeight: 7,
//               backgroundColor: _border,
//               valueColor: AlwaysStoppedAnimation(accentColor),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             '${(percentage * 100).toStringAsFixed(0)}% Correct',
//             style: TextStyle(fontSize: 13, color: accentColor, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: accentColor.withValues(alpha:0.08),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Text(
//               '$emoji  $message',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: accentColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── QuizButtons ──────────────────────────────────────────────────────────────
// class QuizButtons extends StatelessWidget {
//   final VoidCallback onSubmit;
//   final VoidCallback onReset;
//   const QuizButtons({super.key, required this.onSubmit, required this.onReset});

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Row(
//         children: [
//           Expanded(
//             child: _PrimaryButton(
//               label: 'Submit Quiz',
//               icon: Icons.check_circle_rounded,
//               onTap: onSubmit,
//             ),
//           ),
//           const SizedBox(width: 12),
//           _OutlineButton(
//             label: 'Reset',
//             icon: Icons.refresh_rounded,
//             onTap: onReset,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── NavigationButtons ────────────────────────────────────────────────────────
// class NavigationButtons extends StatelessWidget {
//   final VoidCallback onPrevious;
//   final VoidCallback onNext;
//   const NavigationButtons({super.key, required this.onPrevious, required this.onNext});

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           children: [
//             _OutlineButton(
//               label: 'Previous',
//               icon: Icons.arrow_back_rounded,
//               onTap: onPrevious,
//               iconLeading: true,
//             ),
//             const Spacer(),
//             _PrimaryButton(
//               label: 'Next',
//               icon: Icons.arrow_forward_rounded,
//               onTap: onNext,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ─── Shared button components ─────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: _hovered ? _accentGlow : _accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [BoxShadow(color: _accent.withValues(alpha:0.35), blurRadius: 14, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 17),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool iconLeading;
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconLeading = false,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: _hovered ? _accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? _accent : _border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.iconLeading
                ? [
                    Icon(widget.icon, color: _hovered ? _accentGlow : _textSecondary, size: 17),
                    const SizedBox(width: 7),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accentGlow : _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accentGlow : _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(widget.icon, color: _hovered ? _accentGlow : _textSecondary, size: 17),
                  ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:techtutorial/models/quiz_question.dart';

// class QuizQuestionState {
//   int? selectedAnswer;
//   bool? isCorrect;
//   String? explanation;
// }

// class QuizCard extends StatelessWidget {
//   final int index;
//   final int total;
//   final QuizQuestion question;
//   final QuizQuestionState state;
//   final bool submitted;
//   final ValueChanged<int> onAnswerSelected;

//   const QuizCard({
//     super.key,
//     required this.index,
//     required this.total,
//     required this.question,
//     required this.state,
//     required this.submitted,
//     required this.onAnswerSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 14),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.04),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔹 HEADER
//           Text(
//             "Question ${index + 1} / $total",
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.grey,
//             ),
//           ),

//           const SizedBox(height: 10),

//           // 🔹 QUESTION
//           Text(
//             question.question,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1E3C72),
//             ),
//           ),

//           const SizedBox(height: 18),

//           // 🔹 OPTIONS
//           ..._buildOptionList(),

//           // 🔹 EXPLANATION
//           if (submitted &&
//               state.isCorrect == false &&
//               question.explanation != null)
//             _buildExplanation(),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildOptionList() {
//     return question.options.asMap().entries.map((opt) {
//       final i = opt.key;

//       final isSelected = state.selectedAnswer == i;
//       final isCorrect = submitted && i == question.answer;
//       final isWrong = submitted && isSelected && i != question.answer;

//       return QuizOptionItem(
//         text: opt.value,
//         isSelected: isSelected,
//         isCorrect: isCorrect,
//         isWrong: isWrong,
//         submitted: submitted,
//         onTap: submitted ? null : () => onAnswerSelected(i),
//       );
//     }).toList();
//   }

//   Widget _buildExplanation() {
//     return Container(
//       margin: const EdgeInsets.only(top: 14),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.blue.withValues(alpha:0.08),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.withValues(alpha:0.2)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.lightbulb, color: Colors.blue),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               question.explanation!,
//               style: const TextStyle(
//                 color: Colors.blue,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class QuizOptionItem extends StatelessWidget {
//   final String text;
//   final bool isSelected;
//   final bool isCorrect;
//   final bool isWrong;
//   final bool submitted;
//   final VoidCallback? onTap;

//   const QuizOptionItem({
//     super.key,
//     required this.text,
//     required this.isSelected,
//     required this.isCorrect,
//     required this.isWrong,
//     required this.submitted,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Color borderColor = Colors.grey.shade300;
//     Color bgColor = Colors.white;

//     if (isCorrect) {
//       borderColor = Colors.green;
//       bgColor = Colors.green.withValues(alpha:0.08);
//     } else if (isWrong) {
//       borderColor = Colors.red;
//       bgColor = Colors.red.withValues(alpha:0.08);
//     } else if (isSelected) {
//       borderColor = const Color(0xFF2A5298);
//       bgColor = const Color(0xFF2A5298).withValues(alpha:0.08);
//     }

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: borderColor, width: 1.5),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   text,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),

//               if (submitted && isCorrect)
//                 const Icon(Icons.check_circle, color: Colors.green),

//               if (submitted && isWrong)
//                 const Icon(Icons.cancel, color: Colors.red),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }