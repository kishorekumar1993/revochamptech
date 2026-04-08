// ==================== OPTIMIZED COURSE DETAIL SHEET ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/models/course_model.dart';
import 'package:techtutorial/screens/home.dart';

class ElegantCourseDetailSheet extends StatelessWidget {
  final Course course;

  const ElegantCourseDetailSheet({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: PremiumTheme.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Hero(
                  tag: 'course_emoji_${course.id}',
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(course.color).withValues(alpha: 0.08),
                          Color(course.color).withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        course.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildDetailTag(course.category, Color(course.color)),
                          _buildDetailTag(course.level, PremiumTheme.richBlue),
                          _buildDetailTag("FREE", PremiumTheme.success),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.textDark,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: PremiumTheme.textMuted,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _buildDetailChip(Icons.access_time, course.duration),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            Icons.people,
                            "${(course.studentCount / 1000).toStringAsFixed(0)}k",
                          ),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            Icons.school,
                            "${course.topics.length} modules",
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(height: 1, color: PremiumTheme.lightGray),
                      const SizedBox(height: 28),
                      const Text(
                        "What You'll Learn",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...course.topics.map(
                        (topic) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: PremiumTheme.success.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: PremiumTheme.success,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  topic,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: PremiumTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //    SnackBar(
                            //     content: Text(
                            //       "🎓 Course started! Happy learning! ${course.slug}",
                            //     ),
                            //     behavior: SnackBarBehavior.floating,
                            //     backgroundColor: PremiumTheme.success,
                            //   ),
                            // );
                            // context.go('/tech/${course.slug}');
                            context.go('/${course.slug}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumTheme.richBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Start Learning Free",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PremiumTheme.lightGray, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PremiumTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: PremiumTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class QuizElegantCourseDetailSheet extends StatelessWidget {
  final Course course;

  const QuizElegantCourseDetailSheet({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: PremiumTheme.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Hero(
                  tag: 'course_emoji_${course.id}',
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(course.color).withValues(alpha: 0.08),
                          Color(course.color).withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        course.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildDetailTag(course.category, Color(course.color)),
                          _buildDetailTag(course.level, PremiumTheme.richBlue),
                          _buildDetailTag("FREE", PremiumTheme.success),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.textDark,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: PremiumTheme.textMuted,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _buildDetailChip(Icons.access_time, course.duration),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            Icons.people,
                            "${(course.studentCount / 1000).toStringAsFixed(0)}k",
                          ),
                          const SizedBox(width: 12),
                          _buildDetailChip(
                            Icons.school,
                            "${course.topics.length} modules",
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(height: 1, color: PremiumTheme.lightGray),
                      const SizedBox(height: 28),
                      const Text(
                        "What You'll Learn",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...course.topics.map(
                        (topic) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: PremiumTheme.success.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: PremiumTheme.success,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  topic,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: PremiumTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //    SnackBar(
                            //     content: Text(
                            //       "🎓 Course started! Happy learning! ${course.slug}",
                            //     ),
                            //     behavior: SnackBarBehavior.floating,
                            //     backgroundColor: PremiumTheme.success,
                            //   ),
                            // );
                            // context.go('/tech/${course.slug}');
                            context.go('/interview/${course.slug}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumTheme.richBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Start Learning Free",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PremiumTheme.lightGray, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PremiumTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: PremiumTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


