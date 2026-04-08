// ==================== DATA MODELS ====================
class Course {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String emoji;
  final int studentCount;
  final int color;
  final String category;
  final List<String> topics;
  final String duration;
  final String level;
  final double rating;

  const Course({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.emoji,
    required this.studentCount,
    required this.color,
    required this.category,
    required this.topics,
    required this.duration,
    required this.level,
    this.rating = 4.8,
  });

  /// ✅ ADD THIS METHOD
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📘',

      /// 🔥 Important conversions
      studentCount: (json['studentCount'] ?? 0) as int,

      /// If color comes like "0xff1e40af" (string), convert it
      color: json['color'] is String
          ? int.parse(json['color'])
          : (json['color'] ?? 0),

      category: json['category'] ?? '',

      /// Convert dynamic list → List<String>
      topics:
          (json['topics'] as List?)?.map((e) => e.toString()).toList() ?? [],

      duration: json['duration'] ?? '',
      level: json['level'] ?? '',

      /// Ensure double
      rating: (json['rating'] ?? 4.8).toDouble(),
    );
  }
}
// class Course {
//   final String id;
//   final String title;
//   final String description;
//   final String emoji;
//   final int studentCount;
//   final int color;
//   final String category;
//   final List<String> topics;
//   final String duration;
//   final String level;
//   final double rating;

//   const Course({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.emoji,
//     required this.studentCount,
//     required this.color,
//     required this.category,
//     required this.topics,
//     required this.duration,
//     required this.level,
//     this.rating = 4.8,
//   });
// }

// ==================== COURSE DATA ====================
const List<Course> allCourses = [
  Course(
    id: "c1",
    title: "RevoChamp Learning",
    description:
        "Learn development with structured courses and real-world practice",
    emoji: "📱",
    studentCount: 15000,
    color: 0xff6366F1,
    category: "Courses",
    topics: ["FrontEnd", "BackEnd", "AI", "Testing", "AWS", "Mobile APP"],
    duration: "14 hours",
    level: "Beginner",
    slug: "flutter",
  ),

  /// 💼 INTERVIEW PREPARATION
  Course(
    id: "i1",
    title: "Interview Prep",
    description: "Build confidence, sharpen skills, and land your dream job",
    emoji: "💼",
    studentCount: 8200,
    color: 0xff10B981,
    category: "Interview Preparation",
    topics: ["FrontEnd", "BackEnd", "AI", "Testing", "AWS", "Mobile APP"],
    duration: "6 hours",
    level: "Intermediate",
    slug: "flutter-interview",
  ),

  /// 🎤 MOCK INTERVIEW
  Course(
    id: "m1",
    title: "Mock Interview",
    description:
        "Practice real-time interview scenarios with coding challenges, system design, and expert feedback",
    emoji: "🎤",
    studentCount: 5400,
    color: 0xffF59E0B,
    category: "Mock Interview",
    topics: ["Live Questions", "Coding", "System Design", "Feedback"],
    duration: "2 hours",
    level: "All Levels",
    slug: "mock-interview",
  ),

  /// 📝 BLOG
  Course(
    id: "b1",
    title: "Flutter Best Practices",
    description:
        "Explore expert tips, clean architecture patterns, performance optimization, and real-world development insights",
    emoji: "📝",
    studentCount: 12000,
    color: 0xffEF4444,
    category: "Blog",
    topics: ["Clean Code", "Performance", "Architecture", "Tips"],
    duration: "5 min read",
    level: "All Levels",
    slug: "flutter-blog",
  ),

];

List<String> getCategories() {
  final categories = allCourses.map((c) => c.category).toSet().toList();
  return ['All', ...categories];
}
