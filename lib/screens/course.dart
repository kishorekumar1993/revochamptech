// ==================== COURSE PAGE - SEO OPTIMIZED & HIGH PERFORMANCE ====================
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/models/course_model.dart';
import 'package:techtutorial/service/api_call.dart';
import 'package:techtutorial/widget/course_detail_layout.dart';
import 'package:techtutorial/widget/footer_card.dart';
import 'package:collection/collection.dart';

import '../widget/category_card.dart';
import '../widget/course_card.dart';
import '../core/theme.dart';

// ==================== GLOBAL CACHE FOR SEO PERFORMANCE ====================
class CourseDataCache {
  static List<Course>? _cachedCourses;
  static List<CategoryItem>? _cachedCategories;
  static Map<String, List<Course>>? _coursesByCategory;
  static DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 10);
  
  static bool get hasValidCache => 
      _cachedCourses != null && 
      _lastFetchTime != null && 
      DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  
  static void setCourses(List<Course> courses) {
    _cachedCourses = courses;
    _lastFetchTime = DateTime.now();
    _precomputeCategoryData(courses);
  }
  
  static void _precomputeCategoryData(List<Course> courses) {
    _coursesByCategory = groupBy(courses, (c) => c.category);
    
    final categoryCounts = <String, int>{};
    for (final course in courses) {
      categoryCounts[course.category] = (categoryCounts[course.category] ?? 0) + 1;
    }
    
    _cachedCategories = [
      CategoryItem(name: 'All', emoji: '🎯', color: 0xff64748b, count: courses.length),
      ...categoryCounts.entries.map((entry) => CategoryItem(
        name: entry.key,
        emoji: _getStaticCategoryEmoji(entry.key),
        color: _getStaticCategoryColor(entry.key),
        count: entry.value,
      )).toList()..sort((a, b) => b.count.compareTo(a.count))
    ];
  }
  
  static List<Course>? get courses => _cachedCourses;
  static List<CategoryItem>? get categories => _cachedCategories;
  static Map<String, List<Course>>? get coursesByCategory => _coursesByCategory;
  
  static String _getStaticCategoryEmoji(String category) {
    const emojiMap = {
      'Frontend': '🎨', 'Backend': '⚙️', 'Full Stack': '🧩', 'Mobile': '📱',
      'AI & ML': '🤖', 'Data Science': '📊', 'DevOps': '☁️', 'Cloud': '🌩️',
      'Programming': '💻', 'Database': '🗄️', 'Testing': '🧪', 'Cyber Security': '🔐',
      'UI/UX': '🖌️', 'System Design': '🏗️', 'Tools': '🛠️', 'Interview Prep': '🎯',
    };
    return emojiMap[category] ?? '📚';
  }
  
  static int _getStaticCategoryColor(String category) {
    const colorMap = {
      'Frontend': 0xff1e40af, 'Backend': 0xff047857, 'Full Stack': 0xff0f766e,
      'Mobile': 0xff0369a1, 'AI & ML': 0xff9f1239, 'Data Science': 0xff7c2d12,
      'DevOps': 0xff6b21a8, 'Cloud': 0xff1d4ed8, 'Programming': 0xff374151,
      'Database': 0xff065f46, 'Testing': 0xffb45309, 'Cyber Security': 0xff991b1b,
      'UI/UX': 0xffbe185d, 'System Design': 0xff4338ca, 'Tools': 0xff475569,
      'Interview Prep': 0xff0ea5e9,
    };
    return colorMap[category] ?? 0xff64748b;
  }
}

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

// ==================== FILTER PARAMS FOR ISOLATE ====================
class _FilterParams {
  final List<Course> courses;
  final String category;
  final String? level;
  final String query;
  
  _FilterParams({
    required this.courses,
    required this.category,
    required this.level,
    required this.query,
  });
}

// ==================== MAIN COURSE PAGE ====================
class CoursePage extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;

  const CoursePage({super.key, this.initialCategory, this.initialSearchQuery});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> with TickerProviderStateMixin, WidgetsBindingObserver {
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
  List<CategoryItem> _categories = [];
  
  // Performance optimizations
  Map<String, List<Course>> _coursesByCategory = {};
  final ScrollController _scrollController = ScrollController();
  
  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // SEO tracking
  String _currentPageUrl = '';
  int _impressionStartTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _trackPageView();
    _initializePage();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _initializePage() async {
    await _loadCoursesOptimized();
    _applyInitialFilters();
    _generateSEOMetadata();
    _trackImpression();
  }

  Future<void> _loadCoursesOptimized() async {
    try {
      // Check cache first
      if (CourseDataCache.hasValidCache) {
        setState(() {
          _courses = CourseDataCache.courses!;
          _categories = CourseDataCache.categories!;
          _coursesByCategory = CourseDataCache.coursesByCategory!;
          _filteredCourses = _courses;
          _isLoading = false;
        });
        _fadeController.forward();
        return;
      }
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Fetch with timeout
      final data = await CourseService.fetchCourses()
          .timeout(const Duration(seconds: 8));
      
      // Process in background
      await compute(_processCourseData, data);
      
      setState(() {
        _courses = data;
        _filteredCourses = data;
        _isLoading = false;
      });
      
      _fadeController.forward();
      
    } catch (e) {
      debugPrint('Error loading courses: $e');
      setState(() {
        _errorMessage = _getUserFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection is slow. Please check your internet and try again.';
    }
    return 'Unable to load courses. Please try again.';
  }

  void _applyInitialFilters() {
    if (widget.initialCategory != null && widget.initialCategory != "All") {
      _selectedCategory = widget.initialCategory!;
    }
    
    if (widget.initialSearchQuery?.isNotEmpty == true) {
      _searchController.text = widget.initialSearchQuery!;
    }
    
    _applyFilters();
  }

  void _generateSEOMetadata() {
    final courseCount = _courses.length;
    final categories = _categories.map((c) => c.name).join(', ');
    final popularCategories = _categories.take(5).map((c) => c.name).join(', ');
    
    // Main SEO metadata
    MetaService.updateMetaTags(
      title: "Free Programming Courses | Learn ${popularCategories} | RevoChamp",
      description: "Access $courseCount+ free programming courses including $categories. "
          "Learn web development, mobile apps, AI, cloud computing & more. "
          "Start your tech career today with RevoChamp's comprehensive course library.",
      slug: "courses",
      keywords: ["free programming courses, learn coding, $categories, "
          "web development tutorial, mobile app development, AI courses, "
          "programming for beginners, online tech courses"],
    );

    // Enhanced Structured Data for SEO
    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "CollectionPage",
      "name": "Free Programming Courses Library",
      "headline": "Comprehensive Free Tech Courses for All Skill Levels",
      "description": "Access $courseCount+ free programming courses including $popularCategories. "
          "Learn from beginner to advanced level with hands-on projects.",
      "url": "https://revochamp.site/tech/courses",
      "inLanguage": "en",
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "https://revochamp.site/tech/courses",
        "primaryImageOfPage": {
          "@type": "ImageObject",
          "url": "https://revochamp.site/tech/courses-og-image.jpg",
          "width": "1200",
          "height": "630"
        }
      },
      "mainEntity": {
        "@type": "ItemList",
        "numberOfItems": courseCount,
        "itemListElement": _courses.take(10).map((course) => {
          "@type": "ListItem",
          "position": _courses.indexOf(course) + 1,
          "item": {
            "@type": "Course",
            "name": course.title,
            "description": course.description,
            "provider": {
              "@type": "Organization",
              "name": "RevoChamp",
              "sameAs": "https://revochamp.site"
            },
            "educationalLevel": course.level,
            "url": "https://revochamp.site/tech/course/${_getSlug(course.title)}"
          }
        }).toList(),
      },
      "publisher": {
        "@type": "Organization",
        "name": "RevoChamp",
        "url": "https://revochamp.site",
        "logo": {
          "@type": "ImageObject",
          "url": "https://revochamp.site/logo.png",
          "width": "600",
          "height": "60"
        }
      },
      "offers": {
        "@type": "Offer",
        "price": "0",
        "priceCurrency": "USD",
        "availability": "https://schema.org/InStock"
      }
    });

    // BreadcrumbList for SEO
    MetaService.setBreadcrumbData(
      title: "All Courses",
      slug: "courses",
      parents: [
        {"name": "Home", "url": "https://revochamp.site/tech"},
      ],
    );
    
    // FAQ Schema for SEO
    MetaService.setFAQSchema([
      {
        "@type": "Question",
        "name": "What programming courses are available for free?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "RevoChamp offers $courseCount+ free courses covering Frontend (React, Flutter), "
              "Backend (Node.js, Python), Mobile Development, AI & Machine Learning, "
              "Cloud Computing, DevOps, Data Science, and more. All courses include "
              "hands-on projects and certificates of completion."
        }
      },
      {
        "@type": "Question",
        "name": "Are these courses suitable for beginners?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes! We offer courses for all skill levels including ${_getLevelCount('Beginner')} "
              "beginner-friendly courses that start from fundamentals. Each course includes "
              "step-by-step tutorials, practical exercises, and community support."
        }
      },
      {
        "@type": "Question",
        "name": "Do I get a certificate after completing courses?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes, all RevoChamp courses provide free certificates of completion. "
              "These certificates can be shared on LinkedIn and added to your professional portfolio."
        }
      }
    ]);
  }

  String _getSlug(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s]+'), '-');
  }

  int _getLevelCount(String level) {
    return _courses.where((c) => c.level == level).length;
  }

  void _trackPageView() {
    _currentPageUrl = 'https://revochamp.site/tech/courses';
    _impressionStartTime = DateTime.now().millisecondsSinceEpoch;
    
    // Track in analytics (implement your analytics service)
    if (kReleaseMode) {
      // FirebaseAnalytics.instance.logScreenView(screenName: 'CoursesPage');
    }
  }

  void _trackImpression() {
    // Track course impressions for analytics
    Future.delayed(const Duration(seconds: 2), () {
      final timeSpent = DateTime.now().millisecondsSinceEpoch - _impressionStartTime;
      if (timeSpent > 2000) {
        // Track meaningful engagement
        debugPrint('📊 Page viewed for ${timeSpent}ms with ${_courses.length} courses');
      }
    });
  }

  // Optimized filter application
  void _applyFilters() {
    setState(() {
      if (_selectedCategory == "All" && 
          _selectedLevel == null && 
          _searchController.text.isEmpty) {
        _filteredCourses = _courses;
        return;
      }
      
      // Use pre-grouped data for faster filtering
      Iterable<Course> filtered = _selectedCategory != "All" 
          ? _coursesByCategory[_selectedCategory] ?? []
          : _courses;
      
      // Level filter
      if (_selectedLevel != null) {
        filtered = filtered.where((c) => c.level == _selectedLevel);
      }
      
      // Search filter with optimization
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase().trim();
        filtered = filtered.where((c) {
          // Quick check first
          if (c.title.toLowerCase().contains(query)) return true;
          if (c.description.toLowerCase().contains(query)) return true;
          // Only check topics if necessary
          return c.topics.any((t) => t.toLowerCase().contains(query));
        });
      }
      
      _filteredCourses = filtered.toList();
    });
    
    // Update URL for SEO (if using web)
    _updateSEOURL();
  }

  void _updateSEOURL() {
    final params = <String>[];
    if (_selectedCategory != "All") params.add('category=${Uri.encodeComponent(_selectedCategory)}');
    if (_selectedLevel != null) params.add('level=${Uri.encodeComponent(_selectedLevel!)}');
    if (_searchController.text.isNotEmpty) params.add('q=${Uri.encodeComponent(_searchController.text)}');
    
    final url = params.isEmpty 
        ? '/tech/courses' 
        : '/tech/courses?${params.join('&')}';
    
    // Update meta tags for filtered view
    if (params.isNotEmpty) {
      MetaService.updateMetaTags(
        title: "${_filteredCourses.length} ${_selectedCategory != "All" ? _selectedCategory : ""} "
            "${_selectedLevel ?? ""} Courses | RevoChamp",
        description: "Browse ${_filteredCourses.length} free ${_selectedCategory} "
            "${_selectedLevel ?? ""} courses. Learn from expert-led tutorials and hands-on projects.",
        slug: "courses",
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
    
    // Track category selection
    if (kReleaseMode) {
      // Analytics.logEvent('category_selected', {'category': category});
    }
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
    // Track course view
    if (kReleaseMode) {
      // Analytics.logEvent('course_viewed', {'course_id': course.id, 'course_name': course.title});
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ElegantCourseDetailSheet(course: course),
    );
  }

  int get _totalStudents => _courses.fold(0, (sum, course) => sum + course.studentCount);
  int get _totalTopics => _courses.fold(0, (sum, course) => sum + course.topics.length);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data if needed when app resumes
      if (!CourseDataCache.hasValidCache) {
        _loadCoursesOptimized();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final mobile = isMobile;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildSkeletonLoader(mobile)
          : _errorMessage != null
              ? _buildErrorState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      _buildAppBar(mobile),
                      _buildHeroSection(mobile),
                      _buildStatsBanner(mobile),
                      _buildCategoriesSection(mobile),
                      _buildCoursesSection(mobile),
                      _buildCTASection(mobile),
                      _buildSEOSection(mobile),
                      SliverToBoxAdapter(child: Footer(isMobile: mobile)),
                    ],
                  ),
                ),
    );
  }

  // ==================== SKELETON LOADER ====================
  Widget _buildSkeletonLoader(bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(isMobile),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(height: 60, width: 200),
                const SizedBox(height: 20),
                _buildSkeletonBox(height: 120),
                const SizedBox(height: 30),
                _buildSkeletonBox(height: 30, width: 150),
                const SizedBox(height: 20),
                _buildSkeletonGrid(isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonBox({double height = 100, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(),
    );
  }

  Widget _buildSkeletonGrid(bool isMobile) {
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(8, (index) => _buildSkeletonBox()),
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
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
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
        IconButton(
          icon: const Icon(Icons.filter_list, size: 20),
          color: PremiumTheme.textDark,
          onPressed: () => _showFilterBottomSheet(context),
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
                "📚 Complete Library",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Master Tech Skills",
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
                "100% Free Forever",
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
                "${_courses.length}+ courses available. All completely free. "
                "Find exactly what you need to advance your career in tech.",
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
            _buildStatItem("${_courses.length}+", "Free Courses"),
            Container(width: 1, height: 30, color: PremiumTheme.lightGray),
            _buildStatItem("${(_totalStudents / 1000).toStringAsFixed(0)}K+", "Active Learners"),
            Container(width: 1, height: 30, color: PremiumTheme.lightGray),
            _buildStatItem("$_totalTopics+", "Topics Covered"),
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
              "Popular Categories",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: PremiumTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Explore courses by technology stack",
              style: TextStyle(
                fontSize: 14,
                color: PremiumTheme.textMuted,
                fontWeight: FontWeight.w500,
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
          childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 1.0,
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
                      "Available Courses",
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
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    final counts = levels.map((l) => _courses.where((c) => c.level == l).length).toList();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLevelChip("All Levels (${_courses.length})", 
              _selectedLevel == null, () => _onLevelChanged(null)),
          const SizedBox(width: 12),
          ...levels.asMap().entries.map((entry) => [
            _buildLevelChip("${entry.value} (${counts[entry.key]})",
                _selectedLevel == entry.value, () => _onLevelChanged(entry.value)),
            const SizedBox(width: 12),
          ]).expand((x) => x),
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
            childAspectRatio: constraints.maxWidth > 800 ? 0.95 : 1.05,
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

  // SEO Section with hidden structured content
  Widget _buildSEOSection(bool isMobile) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 30),
            // Visible content for users, helps with SEO
            Text(
              "Learn Programming with RevoChamp's Free Course Library",
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) => Chip(
                label: Text("${cat.emoji} ${cat.name}"),
                backgroundColor: PremiumTheme.softGray,
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Whether you're a complete beginner or an experienced developer looking "
              "to expand your skills, our comprehensive library of ${_courses.length}+ "
              "free courses has something for everyone. All courses include hands-on "
              "projects, downloadable resources, and certificates of completion.",
              style: TextStyle(
                fontSize: 14,
                color: PremiumTheme.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
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
                hintText: "Search courses by title, topic, or skill...",
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
              decoration: InputDecoration(
                hintText: "Search courses...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter Courses",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) => ChoiceChip(
                  label: Text("${cat.emoji} ${cat.name}"),
                  selected: _selectedCategory == cat.name,
                  onSelected: (_) {
                    setModalState(() {});
                    _onCategorySelected(cat.name);
                  },
                )).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Level", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Beginner', 'Intermediate', 'Advanced'].map((level) => 
                  ChoiceChip(
                    label: Text(level),
                    selected: _selectedLevel == level,
                    onSelected: (_) {
                      setModalState(() {});
                      _onLevelChanged(_selectedLevel == level ? null : level);
                    },
                  )
                ).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Clear All"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              onPressed: _loadCoursesOptimized,
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

// ==================== BACKGROUND PROCESSING ====================
void _processCourseData(List<Course> courses) {
  CourseDataCache.setCourses(courses);
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