import 'package:flutter/material.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const _editorBg = Color(0xFF0D1117);
const _editorHeader = Color(0xFF161B22);
const _editorBorder = Color(0xFF21262D);
const _accent = Color(0xFF3B82F6);
const _accentGlow = Color(0xFF60A5FA);
const _accentSoft = Color(0xFF1D3461);
const _textPrimary = Color(0xFFE2E8F0);
const _textMuted = Color(0xFF8B949E);
const _success = Color(0xFF3FB950);
const _warning = Color(0xFFF0883E);

// ─── EditorWidget ──────────────────────────────────────────────────────────
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
        color: _editorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _editorBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildHeader(),
            _buildEditor(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _editorHeader,
        border: const Border(bottom: BorderSide(color: _editorBorder)),
      ),
      child: Row(
        children: [
          // Mac dots
          const _MacDots(),
          const SizedBox(width: 14),
          // File tab
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _editorBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _editorBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'main.dart',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Language badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'DART',
              style: TextStyle(
                color: _accentGlow,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _EditorIconBtn(
            icon: Icons.copy_rounded,
            tooltip: 'Copy',
            onTap: () => onCopy(codeController.text),
          ),
          const SizedBox(width: 4),
          _EditorIconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Reset',
            onTap: onReset,
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(color: _editorBg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers gutter
          _LineNumbers(controller: codeController),
          const SizedBox(width: 12),
          // Code area
          Expanded(
            child: Scrollbar(
              thumbVisibility: false,
              child: TextField(
                controller: codeController,
                expands: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.5,
                  // color: _textPrimary,
                  height: 1.65,
                ),
                cursorColor: _accentGlow,
                cursorWidth: 2,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(color: Color(0xFF3D4A5A), fontFamily: 'monospace'),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: _editorHeader,
        border: Border(top: BorderSide(color: _editorBorder)),
      ),
      child: Row(
        children: [
          // Status indicators
          _StatusDot(color: _success, label: 'No errors'),
          const SizedBox(width: 16),
          _StatusDot(color: const Color(0xFF8B949E), label: 'Dart SDK'),
          const Spacer(),
          // Reset button
          _TextBtn(
            label: 'Reset',
            icon: Icons.refresh_rounded,
            onTap: onReset,
          ),
          const SizedBox(width: 10),
          // Run button
          _RunButton(onTap: onRun),
        ],
      ),
    );
  }
}

// ─── Line Numbers ─────────────────────────────────────────────────────────────
class _LineNumbers extends StatefulWidget {
  final TextEditingController controller;
  const _LineNumbers({required this.controller});

  @override
  State<_LineNumbers> createState() => _LineNumbersState();
}

class _LineNumbersState extends State<_LineNumbers> {
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateLines);
    _updateLines();
  }

  void _updateLines() {
    final newCount = '\n'.allMatches(widget.controller.text).length + 1;
    if (newCount != _lineCount && mounted) {
      setState(() => _lineCount = newCount);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateLines);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_lineCount, (i) {
          return SizedBox(
            height: 22.25, // matches line height
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                color: Color(0xFF3D4A5A),
                height: 1.65,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Mac Dots ─────────────────────────────────────────────────────────────────
class _MacDots extends StatelessWidget {
  const _MacDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Dot(color: Color(0xFFFF5F56)),
        SizedBox(width: 6),
        _Dot(color: Color(0xFFFFBD2E)),
        SizedBox(width: 6),
        _Dot(color: Color(0xFF27C93F)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha:0.4), blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }
}

// ─── Editor Icon Button ───────────────────────────────────────────────────────
class _EditorIconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _EditorIconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_EditorIconBtn> createState() => _EditorIconBtnState();
}

class _EditorIconBtnState extends State<_EditorIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFF21262D) : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _hovered ? _editorBorder : Colors.transparent),
            ),
            child: Icon(
              widget.icon,
              size: 15,
              color: _hovered ? _textPrimary : _textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Status Dot ───────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
      ],
    );
  }
}

// ─── Text Button ──────────────────────────────────────────────────────────────
class _TextBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _TextBtn({required this.label, required this.icon, required this.onTap});

  @override
  State<_TextBtn> createState() => _TextBtnState();
}

class _TextBtnState extends State<_TextBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: _hovered ? _textPrimary : _textMuted),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                color: _hovered ? _textPrimary : _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Run Button ───────────────────────────────────────────────────────────────
class _RunButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RunButton({required this.onTap});

  @override
  State<_RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<_RunButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF27C93F) : _success,
            borderRadius: BorderRadius.circular(9),
            boxShadow: _hovered
                ? [BoxShadow(color: _success.withValues(alpha:0.35), blurRadius: 12, offset: const Offset(0, 3))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Run',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ScoreCard ────────────────────────────────────────────────────────────────
class ScoreCard extends StatelessWidget {
  final int score;
  final int total;
  const ScoreCard({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final double percentage = total == 0 ? 0 : score / total;
    final bool excellent = percentage >= 0.8;
    final bool good = percentage >= 0.5;
    final Color color = excellent
        ? const Color(0xFF10B981)
        : good
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final String emoji = excellent ? '🎉' : good ? '👍' : '💪';
    final String msg = excellent ? 'Excellent work!' : good ? 'Good job!' : 'Keep practicing!';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: color.withValues(alpha:0.08),
            ),
            child: Center(
              child: Text(
                '$score/$total',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E2D45),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}% Correct',
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            '$emoji  $msg',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── QuizButtons ──────────────────────────────────────────────────────────────
class QuizButtons extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  const QuizButtons({super.key, required this.onSubmit, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSubmit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 17),
                    SizedBox(width: 8),
                    Text(
                      'Submit Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2D45), width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, color: _textMuted, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'Reset',
                    style: TextStyle(color: _textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NavigationButtons ────────────────────────────────────────────────────────
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
          children: [
            _NavBtn(label: 'Previous', icon: Icons.arrow_back_rounded, onTap: onPrevious, leading: true),
            const Spacer(),
            _NavBtn(label: 'Next', icon: Icons.arrow_forward_rounded, onTap: onNext, leading: false),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool leading;
  const _NavBtn({required this.label, required this.icon, required this.onTap, required this.leading});

  @override
  State<_NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<_NavBtn> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? _accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? _accent : const Color(0xFF1E2D45), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.leading
                ? [
                    Icon(widget.icon, color: _hovered ? _accentGlow : _textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accentGlow : _textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                : [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _hovered ? _accentGlow : _textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: _hovered ? _accentGlow : _textMuted, size: 16),
                  ],
          ),
        ),
      ),
    );
  }
}
