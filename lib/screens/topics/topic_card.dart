import 'package:flutter/material.dart';
import 'package:techtutorial/models/tutorial_topic.dart';

class TopicCard extends StatefulWidget {
  final TutorialTopic topic;
  final bool isCompleted;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  // Level-based gradient palettes
  static const Map<String, List<Color>> _levelGradients = {
    'Beginner': [Color(0xFF11998E), Color(0xFF38EF7D)],
    'Intermediate': [Color(0xFF4776E6), Color(0xFF8E54E9)],
    'Advanced': [Color(0xFFFF416C), Color(0xFFFF4B2B)],
  };

  static const Map<String, Color> _levelChipColors = {
    'Beginner': Color(0xFF11998E),
    'Intermediate': Color(0xFF4776E6),
    'Advanced': Color(0xFFFF416C),
  };

  List<Color> get _gradientColors =>
      _levelGradients[widget.topic.level] ??
      [const Color(0xFF2A5298), const Color(0xFF1E3C72)];

  Color get _accentColor =>
      _levelChipColors[widget.topic.level] ?? const Color(0xFF2A5298);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark ? const Color(0xFF1E2535) : Colors.white,
              border: Border.all(
                color: _isHovered
                    ? _accentColor.withValues(alpha:0.4)
                    : (isDark
                        ? Colors.white.withValues(alpha:0.06)
                        : Colors.grey.shade200),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? _accentColor.withValues(alpha:0.15)
                      : Colors.black.withValues(alpha:isDark ? 0.3 : 0.06),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle gradient tint on hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withValues(alpha:0.04),
                            Colors.transparent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                // Left accent bar
                Positioned(
                  left: 0,
                  top: 12,
                  bottom: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isHovered ? 4 : 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
                  child: Row(
                    children: [
                      // Emoji avatar with gradient ring
                      _buildEmojiAvatar(),

                      const SizedBox(width: 14),

                      // Title + subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topic.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: -0.2,
                                color: isDark
                                    ? Colors.white.withValues(alpha:0.92)
                                    : const Color(0xFF0F1923),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 11,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Tutorial + Quiz",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                if (widget.topic.level.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  _buildLevelChip(),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Trailing icon
                      _buildTrailing(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiAvatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.first.withValues(alpha:0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.topic.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildLevelChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.topic.level,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: _accentColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildTrailing(bool isDark) {
    if (widget.isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF11998E).withValues(alpha:0.12),
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, color: Color(0xFF11998E), size: 18),
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isHovered
            ? _accentColor.withValues(alpha:0.12)
            : (isDark
                ? Colors.white.withValues(alpha:0.05)
                : Colors.grey.shade100),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 15,
          color: _isHovered ? _accentColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:techtutorial/models/tutorial_topic.dart';

// class TopicCard extends StatelessWidget {
//   final TutorialTopic topic;
//   final bool isCompleted;
//   final VoidCallback onTap;

//   const TopicCard({super.key, required this.topic, required this.isCompleted, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.grey.shade50],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: CircleAvatar(
//           radius: 24,
//           backgroundColor: const Color(0xFF2A5298).withValues(alpha:0.1),
//           child: Text(topic.emoji, style: const TextStyle(fontSize: 22)),
//         ),
//         title: Text(
//           topic.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: const Text("Interactive tutorial + quiz"),
//         trailing: isCompleted
//             ? const Icon(Icons.verified, color: Colors.green)
//             : const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }

