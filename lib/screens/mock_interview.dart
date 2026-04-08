// ==================== COURSE PAGE - IMPROVED VERSION ====================
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/models/course_model.dart';
import 'package:techtutorial/service/api_call.dart';
import 'package:techtutorial/widget/course_detail_layout.dart';
import 'package:techtutorial/widget/footer_card.dart';

import '../widget/category_card.dart';
import '../widget/course_card.dart';
import '../core/theme.dart';


// ==================== HELPER CLASS ====================
class CategoryItem {
  final String name;
  final String emoji;
  final int color;
  int count;

  CategoryItem({
    required this.name,
    required this.emoji,
    required this.color,
    required this.count,
  });
}

class MockInterviewPage extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;

  const MockInterviewPage({super.key, this.initialCategory, this.initialSearchQuery});

  @override
  State<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends State<MockInterviewPage> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  // State variables
  String _selectedCategory = "All";
  String? _selectedLevel;
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Cache for categories
  List<CategoryItem> _categories = [];
  
  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializePage();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  Future<void> _initializePage() async {
    await _loadCourses();
    _applyInitialFilters();
    _updateMetaTags();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final data = await CourseService.fetchCourses();
      
      setState(() {
        _courses = data;
        _filteredCourses = data;
        _isLoading = false;
        _buildCategories(); // Build categories after loading
      });
      
      // Start fade animation after data loads
      _fadeController.forward();
      
    } catch (e) {
      debugPrint('Error loading courses: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _buildCategories() {
    // Dynamic category generation from actual data
    final Map<String, CategoryItem> categoryMap = {};
    
    for (final course in _courses) {
      final category = course.category;
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = CategoryItem(
          name: category,
          emoji: _getCategoryEmoji(category),
          color: _getCategoryColor(category),
          count: 0,
        );
      }
      categoryMap[category]!.count++;
    }
    
    // Add "All" category
    final allCategory = CategoryItem(
      name: 'All',
      emoji: '🎯',
      color: 0xff64748b,
      count: _courses.length,
    );
    
    final sortedCategories = categoryMap.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    
    _categories = [allCategory, ...sortedCategories];
  }

  String _getCategoryEmoji(String category) {
    final emojiMap = {
      'Frontend': '🎨',
      'Backend': '⚙️',
      'Full Stack': '🧩',
      'Mobile': '📱',
      'AI & ML': '🤖',
      'Data Science': '📊',
      'DevOps': '☁️',
      'Cloud': '🌩️',
      'Programming': '💻',
      'Database': '🗄️',
      'Testing': '🧪',
      'Cyber Security': '🔐',
      'UI/UX': '🖌️',
      'System Design': '🏗️',
      'Tools': '🛠️',
      'Interview Prep': '🎯',
    };
    return emojiMap[category] ?? '📚';
  }

  int _getCategoryColor(String category) {
    final colorMap = {
      'Frontend': 0xff1e40af,
      'Backend': 0xff047857,
      'Full Stack': 0xff0f766e,
      'Mobile': 0xff0369a1,
      'AI & ML': 0xff9f1239,
      'Data Science': 0xff7c2d12,
      'DevOps': 0xff6b21a8,
      'Cloud': 0xff1d4ed8,
      'Programming': 0xff374151,
      'Database': 0xff065f46,
      'Testing': 0xffb45309,
      'Cyber Security': 0xff991b1b,
      'UI/UX': 0xffbe185d,
      'System Design': 0xff4338ca,
      'Tools': 0xff475569,
      'Interview Prep': 0xff0ea5e9,
    };
    return colorMap[category] ?? 0xff64748b;
  }

  void _applyInitialFilters() {
    // Handle initial category from navigation
    if (widget.initialCategory != null && widget.initialCategory != "All") {
      _selectedCategory = widget.initialCategory!;
    }
    
    // Handle initial search query from navigation
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      _applyFilters();
    } else {
      _applyFilters();
    }
  }

  void _updateMetaTags() {
    MetaService.updateMetaTags(
      title: "All Courses | Learn Programming, Flutter, React & More",
      description:
          "Browse all free programming courses on RevoChamp including Flutter, React, Web Development, Backend, DevOps, and AI.",
      slug: "courses",
    );

    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "CollectionPage",
      "name": "All Courses",
      "description":
          "Browse all free programming courses including Flutter, React, Backend, DevOps, and AI.",
      "url": "https://revochamp.site/tech/courses",
      "inLanguage": "en",
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "https://revochamp.site/tech/courses",
      },
      "mainEntity": {
        "@type": "ItemList",
        "numberOfItems": _filteredCourses.length,
      },
      "publisher": {"@type": "Organization", "name": "RevoChamp"},
    });

    MetaService.setBreadcrumbData(
      title: "Courses",
      slug: "courses",
      parents: [
        {"name": "Home", "url": "https://revochamp.site/tech"},
      ],
    );
  }

  void _applyFilters() {
    setState(() {
      var filtered = List<Course>.from(_courses);

      // Apply category filter
      if (_selectedCategory != "All") {
        filtered = filtered.where((c) => c.category == _selectedCategory).toList();
      }

      // Apply level filter
      if (_selectedLevel != null) {
        filtered = filtered.where((c) => c.level == _selectedLevel).toList();
      }

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        filtered = filtered.where((c) =>
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.topics.any((t) => t.toLowerCase().contains(query))
        ).toList();
      }

      _filteredCourses = filtered;
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // void _onCategorySelected(String category) {
  //   setState(() {
  //     _selectedCategory = category;
  //   });
  //   _applyFilters();
  // }

  void _onCategorySelected(String category) {
  // Update UI selection
  setState(() {
    _selectedCategory = category;
  });

  // Convert category → slug
  final slug = _getCategorySlug(category);

  // Navigate to Topics Screen
  context.go('/tech/interview/$slug');
}
String _getCategorySlug(String category) {
  return category
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(' ', '-');
}

  void _onLevelChanged(String? level) {
    setState(() {
      _selectedLevel = level;
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = "All";
      _selectedLevel = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _showCourseDetail(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizElegantCourseDetailSheet(course: course),
    );
  }

  int get _totalStudents {
    return _courses.fold(0, (sum, course) => sum + course.studentCount);
  }

  int get _totalTopics {
    return _courses.fold(0, (sum, course) => sum + course.topics.length);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(mobile),
                      _buildHeroSection(mobile),
                      _buildStatsBanner(mobile),
                      _buildCategoriesSection(mobile),
                      _buildCoursesSection(mobile),
                      _buildCTASection(mobile),
                      SliverToBoxAdapter(child: Footer(isMobile: mobile)),
                    ],
                  ),
                ),
    );
  }

  // ==================== BUILD METHODS ====================

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha:0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: PremiumTheme.textDark,
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "All Courses",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Browse and explore courses",
            style: TextStyle(
              fontSize: 12,
              color: PremiumTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            color: PremiumTheme.textDark,
            onPressed: _showSearchDialog,
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: PremiumTheme.lightGray.withValues(alpha:0.6),
        ),
      ),
    );
  }

  // Widget _buildHeroSection(bool isMobile) {
  //   return SliverToBoxAdapter(
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: isMobile ? 24 : 80,
  //         vertical: isMobile ? 40 : 60,
  //       ),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [
  //             PremiumTheme.richBlue.withValues(alpha: 0.05),
  //             Colors.white,
  //             PremiumTheme.softGray.withValues(alpha: 0.5),
  //           ],
  //         ),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: PremiumTheme.richBlue,
  //               borderRadius: BorderRadius.circular(50),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: PremiumTheme.richBlue.withValues(alpha: 0.3),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: const Text(
  //               "📚 Complete Library",
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           Text(
  //             "Browse our",
  //             style: TextStyle(
  //               fontSize: isMobile ? 32 : 48,
  //               fontWeight: FontWeight.w800,
  //               color: PremiumTheme.textDark,
  //               letterSpacing: -0.5,
  //               height: 1.1,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           ShaderMask(
  //             shaderCallback: (bounds) => const LinearGradient(
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //               colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
  //             ).createShader(bounds),
  //             child: Text(
  //               "entire course catalog",
  //               style: TextStyle(
  //                 fontSize: isMobile ? 32 : 48,
  //                 fontWeight: FontWeight.w800,
  //                 color: Colors.white,
  //                 height: 1.1,
  //                 letterSpacing: -0.5,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Container(
  //             constraints: const BoxConstraints(maxWidth: 600),
  //             child: Text(
  //               "${_courses.length}+ courses available. All completely free. Find exactly what you need to advance your career.",
  //               style: TextStyle(
  //                 fontSize: isMobile ? 14 : 16,
  //                 color: PremiumTheme.textMuted,
  //                 height: 1.5,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ),
  //           if (!isMobile) ...[
  //             const SizedBox(height: 32),
  //             _buildSearchBar(isMobile),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }


Widget _buildHeroSection(bool isMobile) {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 40 : 60,
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
              "🎯 Mock Interview Hub",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Ace your next",
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
            ).createShader(bounds),
            child: Text(
              "technical interview",
              style: TextStyle(
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              "Practice with real interview scenarios. 50+ mock interviews across SWE, System Design, and Behavioral tracks. Instant AI feedback included.",
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: PremiumTheme.textMuted,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 32),
            _buildSearchBar(isMobile),
          ],
        ],
      ),
    ),
  );
}
// For first version:
// For third version (most impressive):
final int _totalPracticeSessions = 275;      // 275K sessions
final double _avgRating = 4.8;
final int _faangHires = 1250;    

Widget _buildStatsBanner(bool isMobile) {
  return SliverToBoxAdapter(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("${_totalPracticeSessions}K+", "Practice Sessions"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("$_avgRating", "User Rating"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("$_faangHires+", "FAANG Hires"),
        ],
      ),
    ),
  );
}


  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: PremiumTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: PremiumTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Browse by Category",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: PremiumTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            _buildCategoryGrid(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 6
            : (constraints.maxWidth > 600 ? 3 : 2);
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio:constraints.maxWidth > 600 ? 1.2:1.0,
          physics: const NeverScrollableScrollPhysics(),
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category.name;
            return CategoryCard(
              name: category.name,
              emoji: category.emoji,
              color: category.color,
              courseCount: category.count,
              isSelected: isSelected,
              onTap: () => _onCategorySelected(category.name),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCoursesSection(bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
        color: PremiumTheme.softGray,
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
                      "All Courses",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: PremiumTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_filteredCourses.length} courses available",
                      style: const TextStyle(
                        fontSize: 14,
                        color: PremiumTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_selectedCategory != "All" || _selectedLevel != null || _searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text("Clear Filters"),
                    style: TextButton.styleFrom(
                      foregroundColor: PremiumTheme.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLevelFilters(isMobile),
            const SizedBox(height: 40),
            if (_filteredCourses.isEmpty)
              _buildEmptyState()
            else
              _buildCourseGrid(_filteredCourses, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelFilters(bool isMobile) {
    final beginnerCount = _courses.where((c) => c.level == 'Beginner').length;
    final intermediateCount = _courses.where((c) => c.level == 'Intermediate').length;
    final advancedCount = _courses.where((c) => c.level == 'Advanced').length;
    final allCount = _courses.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLevelChip("All Levels ($allCount)", _selectedLevel == null, () => _onLevelChanged(null)),
          const SizedBox(width: 12),
          _buildLevelChip("Beginner ($beginnerCount)", _selectedLevel == "Beginner", () => _onLevelChanged("Beginner")),
          const SizedBox(width: 12),
          _buildLevelChip("Intermediate ($intermediateCount)", _selectedLevel == "Intermediate", () => _onLevelChanged("Intermediate")),
          const SizedBox(width: 12),
          _buildLevelChip("Advanced ($advancedCount)", _selectedLevel == "Advanced", () => _onLevelChanged("Advanced")),
        ],
      ),
    );
  }

  Widget _buildLevelChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: PremiumTheme.richBlue.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? PremiumTheme.richBlue : PremiumTheme.textMuted,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? PremiumTheme.richBlue.withValues(alpha: 0.3) : PremiumTheme.lightGray,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildCourseGrid(List<Course> courses, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 800 ? 3 : 1);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio:constraints.maxWidth > 800 ? 0.95: 1.05,
          ),
          itemBuilder: (_, i) => CourseCard(
            course: courses[i],
            onTap: () => _showCourseDetail(courses[i]),
            onStartLearning: () => _showSnackBar("🎓 Starting ${courses[i].title}"),
          ),
        );
      },
    );
  }

  Widget _buildCTASection(bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 40),
        padding: EdgeInsets.all(isMobile ? 24 : 32),
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
            const Text("🎯", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              "Not sure where to start?",
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Take our skill assessment to find the perfect course for your level",
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showSnackBar("🎓 Skill assessment coming soon!"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: PremiumTheme.richBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                "Take Assessment →",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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
                hintText: "Search 100+ free courses...",
                hintStyle: TextStyle(
                  color: PremiumTheme.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18, color: PremiumTheme.textLight),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged("");
              },
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

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search courses...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation(PremiumTheme.richBlue),
              backgroundColor: PremiumTheme.lightGray,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading courses...',
            style: TextStyle(
              color: PremiumTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 24),
            Text(
              'Failed to load courses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: PremiumTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCourses,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.richBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              "No courses found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filters or search term",
              style: TextStyle(fontSize: 14, color: PremiumTheme.textMuted),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Clear all filters"),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
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
}

// ==================== HELPER CLASSES ====================

class CategoryInfo {
  final String name;
  final String emoji;
  final int color;
  int count;

  CategoryInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.count,
  });
}