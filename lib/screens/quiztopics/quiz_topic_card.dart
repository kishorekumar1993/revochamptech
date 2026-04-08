import 'package:flutter/material.dart';
import 'package:techtutorial/models/tutorial_topic.dart';

class QuizTopicCard extends StatefulWidget {
  final TutorialTopic topic;
  final bool isCompleted;
  final VoidCallback onTap;

  const QuizTopicCard({
    super.key,
    required this.topic,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<QuizTopicCard> createState() => _QuizTopicCardState();
}

class _QuizTopicCardState extends State<QuizTopicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  // Premium color schemes per level
  static const Map<String, _LevelTheme> _levelThemes = {
    'Beginner': _LevelTheme(
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      gradientStart: Color(0xFF059669),
      gradientEnd: Color(0xFF10B981),
      bgLight: Color(0xFFECFDF5),
      icon: Icons.rocket_launch_rounded,
    ),
    'Intermediate': _LevelTheme(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF60A5FA),
      gradientStart: Color(0xFF2563EB),
      gradientEnd: Color(0xFF3B82F6),
      bgLight: Color(0xFFEFF6FF),
      icon: Icons.auto_awesome_rounded,
    ),
    'Advanced': _LevelTheme(
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA78BFA),
      gradientStart: Color(0xFF7C3AED),
      gradientEnd: Color(0xFF8B5CF6),
      bgLight: Color(0xFFF5F3FF),
      icon: Icons.bolt_rounded,
    ),
  };

  _LevelTheme get _theme => _levelThemes[widget.topic.level] ?? 
      const _LevelTheme(
        primary: Color(0xFF6B7280),
        secondary: Color(0xFF9CA3AF),
        gradientStart: Color(0xFF4B5563),
        gradientEnd: Color(0xFF6B7280),
        bgLight: Color(0xFFF3F4F6),
        icon: Icons.menu_book_rounded,
      );

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            elevation: _elevationAnimation.value,
            shadowColor: _theme.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [Colors.white, const Color(0xFFF9FAFB)],
              ),
              border: Border.all(
                color: _isHovered
                    ? _theme.primary.withValues(alpha: 0.5)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Animated gradient background on hover
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _theme.primary.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Decorative corner accent
                Positioned(
                  top: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isHovered ? 60 : 40,
                    height: _isHovered ? 60 : 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          _theme.primary.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Premium Avatar
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _theme.gradientStart,
                              _theme.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _theme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.topic.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.topic.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Difficulty badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _theme.bgLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _theme.primary.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _theme.icon,
                                        size: 12,
                                        color: _theme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.topic.level,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _theme.primary,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Duration indicator
                                if (widget.topic.estimatedHours != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${widget.topic.estimatedHours!.toInt()}h',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Trailing section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isCompleted
                              ? _theme.primary.withValues(alpha: 0.1)
                              : (_isHovered
                                  ? _theme.primary.withValues(alpha: 0.1)
                                  : Colors.transparent),
                        ),
                        child: widget.isCompleted
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 24,
                              )
                            : Icon(
                                _isHovered
                                    ? Icons.arrow_forward_rounded
                                    : Icons.chevron_right_rounded,
                                color: _isHovered
                                    ? _theme.primary
                                    : Colors.grey.shade400,
                                size: _isHovered ? 22 : 28,
                              ),
                      ),
                    ],
                  ),
                ),
                
                // Progress indicator for completed
                if (widget.isCompleted)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _theme.gradientStart,
                            _theme.gradientEnd,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Level theme configuration
class _LevelTheme {
  final Color primary;
  final Color secondary;
  final Color gradientStart;
  final Color gradientEnd;
  final Color bgLight;
  final IconData icon;

  const _LevelTheme({
    required this.primary,
    required this.secondary,
    required this.gradientStart,
    required this.gradientEnd,
    required this.bgLight,
    required this.icon,
  });
}