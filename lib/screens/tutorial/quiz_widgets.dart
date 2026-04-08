// ==================== QUIZ WIDGETS - PREMIUM LIGHT THEME ====================
// Complete quiz system with question cards, options, scoring, and feedback
// Designed to match HomePage's clean, professional aesthetic

import 'package:flutter/material.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/models/quiz_question.dart';

// ─── DESIGN TOKENS - MATCHING HOME PAGE PREMIUM THEME ─────────────────────────
const _accent = PremiumTheme.richBlue;           // Primary blue (#3B82F6)
const _accentGlow = Color(0xFF3B82F6);
const _accentSoft = Color(0xFFEFF6FF);            // Light blue background
const _success = Color(0xFF10B981);               // Green for correct answers
const _successSoft = Color(0xFFD1FAE5);           // Light green background
const _danger = Color(0xFFEF4444);                // Red for wrong answers
const _dangerSoft = Color(0xFFFEE2E2);            // Light red background
const _border = PremiumTheme.lightGray;           // Light gray border (#E2E8F0)
const _textPrimary = PremiumTheme.textDark;       // Dark text (#1E293B)
const _textSecondary = PremiumTheme.textMuted;    // Muted text (#64748B)
const _textLight = PremiumTheme.textLight;        // Light text (#94A3B8)
const _cardBg = Colors.white;                     // White card background

/// State management for each quiz question
/// Tracks selected answer, correctness, and explanation display
class QuizQuestionState {
  int? selectedAnswer;    // Index of selected option (0-based)
  bool? isCorrect;        // Whether the selected answer is correct
  String? explanation;    // Explanation shown after submission
}

// ==================== QUIZ CARD ====================
/// Individual quiz question card with:
/// - Question number and progress indicator
/// - Question text
/// - Multiple choice options with visual feedback
/// - Explanation for incorrect answers
/// - Result badge after submission
class QuizCard extends StatelessWidget {
  final int index;                      // Current question index (0-based)
  final int total;                     // Total number of questions
  final QuizQuestion question;         // Question data
  final QuizQuestionState state;       // Current state of this question
  final bool submitted;                // Whether quiz has been submitted
  final ValueChanged<int> onAnswerSelected; // Callback when option selected

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
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: submitted
              ? (state.isCorrect == true
                  ? _success.withValues(alpha: 0.3)
                  : state.isCorrect == false
                      ? _danger.withValues(alpha: 0.3)
                      : _border)
              : _border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question number and result badge
          _buildHeader(),
          
          // Question text
          _buildQuestionText(),
          
          // Answer options
          _buildOptionsList(),
          
          // Explanation (only shown for incorrect answers after submission)
          if (submitted && state.isCorrect == false && question.explanation != null)
            _buildExplanation(),
        ],
      ),
    );
  }

  /// Header section with question number, progress, and result badge
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          // Question number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_accent, Color(0xff1e40af)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Q${index + 1}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Progress text
          Text(
            'of $total',
            style: const TextStyle(
              fontSize: 12,
              color: _textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Result badge (shown after submission)
          if (submitted) _buildResultBadge(),
        ],
      ),
    );
  }

  /// Result badge showing correct/wrong status
  Widget _buildResultBadge() {
    final isCorrect = state.isCorrect ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCorrect ? _successSoft : _dangerSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? _success.withValues(alpha: 0.3) : _danger.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 14,
            color: isCorrect ? _success : _danger,
          ),
          const SizedBox(width: 6),
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

  /// Question text with proper styling
  Widget _buildQuestionText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Text(
        question.question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  /// List of answer options
  Widget _buildOptionsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: question.options.asMap().entries.map((opt) {
          final optionIndex = opt.key;
          final isSelected = state.selectedAnswer == optionIndex;
          final isCorrect = submitted && optionIndex == question.answer;
          final isWrong = submitted && isSelected && optionIndex != question.answer;
          
          return QuizOptionItem(
            index: optionIndex,
            text: opt.value,
            isSelected: isSelected,
            isCorrect: isCorrect,
            isWrong: isWrong,
            submitted: submitted,
            onTap: submitted ? null : () => onAnswerSelected(optionIndex),
          );
        }).toList(),
      ),
    );
  }

  /// Explanation section for incorrect answers
  Widget _buildExplanation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.explanation!,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUIZ OPTION ITEM ====================
/// Individual answer option with:
/// - Letter badge (A, B, C, D)
/// - Hover effects for better UX
/// - Visual feedback for selected/correct/wrong states
/// - Animated transitions between states
class QuizOptionItem extends StatefulWidget {
  final int index;                    // Option index (0-based)
  final String text;                 // Option text
  final bool isSelected;             // Whether this option is selected
  final bool isCorrect;              // Whether this is the correct answer
  final bool isWrong;                // Whether this was wrongly selected
  final bool submitted;              // Whether quiz has been submitted
  final VoidCallback? onTap;         // Selection callback

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
    // Determine colors based on state
    Color borderColor = _border;
    Color bgColor = _cardBg;
    Color labelColor = _textLight;
    Color textColor = _textSecondary;

    if (widget.isCorrect) {
      // Correct answer - green styling
      borderColor = _success;
      bgColor = _successSoft;
      labelColor = _success;
      textColor = _success;
    } else if (widget.isWrong) {
      // Wrong selected answer - red styling
      borderColor = _danger;
      bgColor = _dangerSoft;
      labelColor = _danger;
      textColor = _danger;
    } else if (widget.isSelected) {
      // Selected but not submitted - blue styling
      borderColor = _accent;
      bgColor = _accentSoft;
      labelColor = _accent;
      textColor = _accent;
    } else if (_hovered && !widget.submitted) {
      // Hover state - subtle blue
      borderColor = _accent.withValues(alpha: 0.4);
      bgColor = _accentSoft;
    }

    final letter = widget.index < _letters.length ? _letters[widget.index] : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.isCorrect
                      ? _success.withValues(alpha: 0.15)
                      : widget.isWrong
                          ? _danger.withValues(alpha: 0.15)
                          : widget.isSelected
                              ? _accent.withValues(alpha: 0.15)
                              : PremiumTheme.softGray,
                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 14),
              
              // Option text
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                    fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              
              // Status icons
              if (widget.submitted && widget.isCorrect)
                Icon(Icons.check_circle_rounded, color: _success, size: 20),
              if (widget.submitted && widget.isWrong)
                Icon(Icons.cancel_rounded, color: _danger, size: 20),
              if (widget.isSelected && !widget.submitted)
                Icon(Icons.radio_button_checked, color: _accent, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}


// ==================== QUIZ BUTTONS ====================
/// Action buttons for quiz:
/// - Submit: Finalize answers and show results
/// - Reset: Clear all answers and start over
class QuizButtons extends StatelessWidget {
  final VoidCallback onSubmit;   // Submit quiz callback
  final VoidCallback onReset;    // Reset quiz callback

  const QuizButtons({
    super.key,
    required this.onSubmit,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PrimaryButton(
            label: 'Submit Quiz',
            icon: Icons.check_circle_rounded,
            onTap: onSubmit,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OutlineButton(
            label: 'Reset',
            icon: Icons.refresh_rounded,
            onTap: onReset,
          ),
        ),
      ],
    );
  }
}

// ==================== NAVIGATION BUTTONS ====================
/// Previous/Next navigation for tutorial pages
class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;   // Previous page/tutorial
  final VoidCallback onNext;       // Next page/tutorial

  const NavigationButtons({
    super.key,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _OutlineButton(
              label: 'Previous',
              icon: Icons.arrow_back_rounded,
              onTap: onPrevious,
              iconLeading: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _PrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SHARED BUTTON COMPONENTS ====================
/// Primary filled button with gradient and hover effects
class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: _hovered
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accentGlow, _accent],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_accent, Color(0xff1e40af)],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
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

/// Outlined button with hover effects
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? _accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? _accent : _border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.iconLeading
                ? [
                    Icon(
                      widget.icon,
                      color: _hovered ? _accent : _textLight,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accent : _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accent : _textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      widget.icon,
                      color: _hovered ? _accent : _textLight,
                      size: 18,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
