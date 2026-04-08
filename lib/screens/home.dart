// ==================== HOME PAGE - MAIN DASHBOARD ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/models/course_model.dart';
import 'dart:async';

import 'package:techtutorial/widget/course_card.dart';
import 'package:techtutorial/widget/course_detail_layout.dart';
import 'package:techtutorial/widget/feature_card.dart';
import 'package:techtutorial/widget/footer_card.dart';
import 'package:techtutorial/widget/stats_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../widget/category_card.dart';

// ==================== HOME PAGE - FIXED VERSION ====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;
  String _searchQuery = "";

  late AnimationController _heroController;
  late Animation<double> _heroAnimation;

  final GlobalKey _coursesSectionKey = GlobalKey();

  // FIXED: Removed unsafe getter that uses MediaQuery
  // Now we'll get isMobile inside build() method

  // HOME PAGE ONLY SHOWS FEATURED COURSES (Limited to 4-6)
  List<Course> get _featuredCourses {
    return allCourses.take(4).toList();
  }

  // Search results limited to 3 on home page (preview only)
  List<Course> get _searchResults {
    if (_searchQuery.isEmpty) return [];

    final query = _searchQuery.toLowerCase();
    var results = allCourses
        .where(
          (c) =>
              c.title.toLowerCase().contains(query) ||
              c.description.toLowerCase().contains(query) ||
              c.topics.any((t) => t.toLowerCase().contains(query)),
        )
        .toList();

    return results.take(3).toList();
  }

  @override
  void initState() {
    super.initState();

    MetaService.updateMetaTags(
      title: "RevoChamp - Free Programming Courses & Tech Learning Platform",
      description:
          "Learn Flutter, React, Backend, DevOps, AI and more with RevoChamp. Free online programming courses designed for developers.",
      slug: "",
    );

    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@graph": [
        {
          "@type": "Organization",
          "name": "RevoChamp",
          "url": "https://revochamp.site/tech",
          "logo": "https://revochamp.site/logo.png",
        },
        {
          "@type": "WebSite",
          "name": "RevoChamp",
          "url": "https://revochamp.site/tech",
          "potentialAction": {
            "@type": "SearchAction",
            "target":
                "https://revochamp.site/tech/courses?search={search_term_string}",
            "query-input": "required name=search_term_string",
          },
        },
      ],
    });
    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "Are the courses free?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes, all courses on RevoChamp are completely free.",
          },
        },
        {
          "@type": "Question",
          "name": "What technologies are covered?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "We cover Flutter, React, Backend, DevOps, AI and more.",
          },
        },
      ],
    });
    _setupAnimations();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _heroController.forward();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // FIXED: Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = "";
      _searchController.clear();
    });
  }

  void _scrollToCourses() {
    // FIXED: Added null check for context
    final context = _coursesSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: PremiumTheme.richBlue,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCourseDetail(Course course) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ElegantCourseDetailSheet(course: course),
    );
  }

  void _navigateToCourses() {
    if (!mounted) return;
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CoursePage()),
    // );

    context.go('/courses');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Get isMobile inside build where MediaQuery is safe
    final isMobile = MediaQuery.of(context).size.width < 600;
    final featuredCourses = _featuredCourses;
    final searchResults = _searchResults;
    final hasSearchResults =
        _searchQuery.isNotEmpty && searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Premium App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: _buildLogo(),
            centerTitle: false,
            actions: [
              if (!isMobile) ...[
                TextButton(
                  onPressed: _scrollToCourses,
                  child: const Text(
                    "Courses",
                    style: TextStyle(
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => navigateToAbout(context),
                  child: const Text(
                    "About",
                    style: TextStyle(
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => navigateToContact(context),
                  child: const Text(
                    "Contact",
                    style: TextStyle(
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () => _showSnackBar("Login feature coming soon"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: PremiumTheme.lightGray,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showSnackBar("Sign up feature coming soon"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumTheme.richBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _heroAnimation,
              child: _buildHeroSection(isMobile),
            ),
          ),

          // Search Results (only shown when searching)
          if (hasSearchResults)
            SliverToBoxAdapter(
              child: _buildSearchResultsSection(searchResults, isMobile),
            ),

          // Featured Courses Section
          SliverToBoxAdapter(
            child: Container(
              key: _coursesSectionKey,
              color: Colors.white,
              child: _buildFeaturedCoursesSection(featuredCourses, isMobile),
            ),
          ),

          // Categories Section (Quick browse)
          SliverToBoxAdapter(child: _buildCategoriesSection(isMobile)),

          // Why Choose Us Section
          SliverToBoxAdapter(child: _buildWhyChooseUsSection(isMobile)),

          // Stats Section
          SliverToBoxAdapter(child: _buildStatsSection(isMobile)),

          // Testimonial Section
          SliverToBoxAdapter(child: _buildTestimonialSection(isMobile)),

          // CTA Section
          SliverToBoxAdapter(child: _buildCTASection(isMobile)),

          // Footer
          SliverToBoxAdapter(child: Footer(isMobile: isMobile)),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.richBlue.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "RL",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "RevoChamp",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 50 : 70,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumTheme.richBlue.withValues(alpha: 0.05),
            Colors.white,
            PremiumTheme.softGray.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: PremiumTheme.richBlue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              "✨ 100% Free Learning",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Master modern",
            style: TextStyle(
              fontSize: isMobile ? 36 : 52,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
            ).createShader(bounds),
            child: Text(
              "tech skills",
              style: TextStyle(
                fontSize: isMobile ? 36 : 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              "Learn from industry experts through comprehensive, project-based courses. Start your journey today — completely free.",
              style: TextStyle(
                fontSize: isMobile ? 15 : 17,
                color: PremiumTheme.textMuted,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildSearchBar(isMobile),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _scrollToCourses,
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumTheme.richBlue,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Explore All Courses →",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 560,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: PremiumTheme.textLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search courses...",
                hintStyle: TextStyle(
                  color: PremiumTheme.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear,
                size: 18,
                color: PremiumTheme.textLight,
              ),
              onPressed: _clearSearch,
            ),
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Search",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection(List<Course> results, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 30,
      ),
      color: PremiumTheme.softGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Search Results (${results.length})",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                ),
              ),
              TextButton(
                onPressed: _navigateToCourses,
                child: const Text(
                  "View All Courses →",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.richBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, i) => CourseCard(
                  course: results[i],
                  onTap: () => _showCourseDetail(results[i]),
                  onStartLearning: () =>
                      _showSnackBar("🎓 Starting ${results[i].title}"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildFeaturedCoursesSection(List<Course> courses, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Featured Courses",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${courses.length} hand-picked courses to get you started",
                    style: const TextStyle(
                      fontSize: 14,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _navigateToCourses,
                child: const Text(
                  "Browse All →",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.richBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: constraints.maxWidth > 900
                      ? 0.85
                      : constraints.maxWidth > 600
                      ? 0.82
                      : 0.9,
                ),
                itemBuilder: (_, i) => CourseCard(
                  course: courses[i],
                  onTap: () {
                    if (courses[i].title == "RevoChamp Learning") {
                      _showSnackBar("🎓 Starting ${courses[i].title}");
                      context.go('/courses');
                    } else if (courses[i].title == "Interview Prep") {
                    } else if (courses[i].title == "Mock Interview") {
                      context.go('/mockinterview');
                    } else {
                      openUrl("https://revochamp.site/blog/");
                    }
                    // _showCourseDetail(courses[i]);
                  },
                  onStartLearning: () =>
                      _showSnackBar("🎓 Starting ${courses[i].title}"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isMobile) {
    final categories = [
      {'name': 'Frontend', 'emoji': '🎨', 'color': 0xff1e40af, 'count': 5},
      {'name': 'Backend', 'emoji': '⚙️', 'color': 0xff047857, 'count': 3},
      {'name': 'DevOps', 'emoji': '☁️', 'color': 0xff6b21a8, 'count': 2},
      {'name': 'AI & ML', 'emoji': '🤖', 'color': 0xff9f1239, 'count': 2},
      {'name': 'Mobile', 'emoji': '📱', 'color': 0xff0369a1, 'count': 2},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      color: PremiumTheme.softGray,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Popular Categories",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Explore courses by topic",
            style: TextStyle(
              fontSize: 16,
              color: PremiumTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 5
                  : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: categories.map((category) {
                  return CategoryCard(
                    name: category['name'] as String,
                    emoji: category['emoji'] as String,
                    color: category['color'] as int,
                    courseCount: category['count'] as int,
                    onTap: () {
                      _showSnackBar(
                        "Filtering by ${category['name']} coming soon",
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Why Choose RevoChamp?",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "What makes us different",
            style: TextStyle(
              fontSize: 16,
              color: PremiumTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 2.1,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  FeatureCard(
                    emoji: "🎓",
                    title: "Expert-Led",
                    description: "Learn from industry professionals",
                  ),
                  FeatureCard(
                    emoji: "💰",
                    title: "Always Free",
                    description: "No hidden costs or subscriptions",
                  ),
                  FeatureCard(
                    emoji: "🚀",
                    title: "Practical Skills",
                    description: "Build job-ready portfolios",
                  ),
                  FeatureCard(
                    emoji: "📈",
                    title: "Lifetime Access",
                    description: "Learn at your own pace",
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PremiumTheme.richBlue, Color(0xff1e3a8a)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.richBlue.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text("📊", style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Impact Numbers",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Trusted by learners worldwide",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                mainAxisSpacing: 30,
                crossAxisSpacing: 20,
                childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.2,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  StatCard(number: "10,000+", label: "Learners", icon: "👥"),
                  StatCard(
                    number: "${allCourses.length}+",
                    label: "Courses",
                    icon: "📚",
                  ),

                  StatCard(
                    number: "${_featuredCourses.length}",
                    label: "Featured",
                    icon: "⭐",
                  ),
                  // StatCard(number: "50+", label: "Experts", icon: "👨‍🏫"),
                  StatCard(number: "100%", label: "Free", icon: "🎁"),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTestimonialSection(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 40,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        children: [
          const Text("❤️", style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            "What Our Learners Say",
            style: TextStyle(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star,
                      color: PremiumTheme.accentGold,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "\"RevoChamp completely transformed my career. The quality of courses is outstanding, and the fact that it's free makes it truly revolutionary. I went from a complete beginner to landing my first developer job in 6 months!\"",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: PremiumTheme.textMuted,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "— Sarah Johnson",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PremiumTheme.textDark,
                  ),
                ),
                const Text(
                  "Frontend Developer",
                  style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: 40,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 50,
        horizontal: isMobile ? 30 : 60,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xfff0f4f9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            "Ready to Transform Your Career?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Join thousands of successful learners already mastering in-demand tech skills for free",
            style: TextStyle(
              fontSize: 14,
              color: PremiumTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToCourses,
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumTheme.richBlue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Browse All Courses →",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
