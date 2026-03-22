// // ---------------------------- EditorWidget (Optimized) ----------------------------
import 'package:flutter/material.dart';

class EditorWidget extends StatelessWidget {
  final TextEditingController codeController;
  final String defaultCode;
  final Function(String) onCopy;
  final VoidCallback onRun;
  final VoidCallback onReset;

  const EditorWidget({
    super.key,
    required this.codeController,
    required this.defaultCode,
    required this.onCopy,
    required this.onRun,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0D1117),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // 🔹 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF161B22),
              ),
              child: Row(
                children: [
                  // Mac style dots
                  Row(
                    children: const [
                      _Dot(color: Colors.red),
                      SizedBox(width: 6),
                      _Dot(color: Colors.yellow),
                      SizedBox(width: 6),
                      _Dot(color: Colors.green),
                    ],
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "DART",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  _iconBtn(Icons.copy, () => onCopy(codeController.text)),
                  _iconBtn(Icons.refresh, onReset),
                ],
              ),
            ),

            // 🔥 EDITOR AREA (FIXED)
            Container(
              height: 260, // ✅ IMPORTANT FIX
              padding: const EdgeInsets.all(12),
              child: Scrollbar(
                thumbVisibility: true,
                child: TextField(
                  controller: codeController,
                  expands: true, // ✅ KEY FIX
                  maxLines: null,
                  keyboardType: TextInputType.multiline,

                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),

                  cursorColor: Colors.blueAccent,

                  decoration: const InputDecoration(
                    fillColor: Colors.black,
                    border: InputBorder.none,
                    hintText: "Start typing code...",
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),

            // 🔹 FOOTER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF1F2937)),
                ),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Reset"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: onRun,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Run Code"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A5298),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Icon Button
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.white70),
        ),
      ),
    );
  }
}

// 🔹 Mac style dots
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------- ScoreCard (Optimized) ----------------------------
class ScoreCard extends StatelessWidget {
  final int score;
  final int total;

  const ScoreCard({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total == 0 ? 0 : score / total;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔹 TITLE
          const Text(
            "Your Score",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 SCORE
          Text(
            "$score / $total",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 PERCENT TEXT
          Text(
            "${(percentage * 100).toStringAsFixed(0)}% Completed",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 RESULT MESSAGE
          _buildResultText(percentage),
        ],
      ),
    );
  }

  Widget _buildResultText(double percentage) {
    String text;
    Color color;

    if (percentage >= 0.8) {
      text = "Excellent! 🎉";
      color = Colors.greenAccent;
    } else if (percentage >= 0.5) {
      text = "Good Job 👍";
      color = Colors.orangeAccent;
    } else {
      text = "Keep Practicing 💪";
      color = Colors.redAccent;
    }

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

// ---------------------------- QuizButtons (Optimized) ----------------------------
class QuizButtons extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  const QuizButtons({super.key, required this.onSubmit, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.check),
            label: const Text('Submit Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5298),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2A5298),
              side: const BorderSide(color: Color(0xFF2A5298), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------- NavigationButtons (Optimized) ----------------------------
class NavigationButtons extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  const NavigationButtons({super.key, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('← Previous'),
            ),
            OutlinedButton(
              onPressed: onNext,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Next →'),
            ),
          ],
        ),
      ),
    );
  }
}