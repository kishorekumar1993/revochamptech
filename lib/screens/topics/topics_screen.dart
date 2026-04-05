// lib/screens/topics/topics_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtutorial/core/meta_service.dart';

import '../../models/topic_screen_config.dart';
import '../../models/tutorial_topic.dart';
import '../../utils/json_parser.dart';
import '../../core/theme.dart';
import 'topic_card.dart';

class TopicsScreen extends StatefulWidget {
  final String category;

  const TopicsScreen({super.key, required this.category});
  
  // ✅ Per-category caching
  static final Map<String, List<TutorialTopic>> _cachedTopics = {};
  
  // ✅ Category-specific method
  static List<TutorialTopic> getTopicsByCategory(String category) {
    return _cachedTopics[category.toLowerCase()] ?? [];
  }
  
  static void clearCache() {
    _cachedTopics.clear();
  }

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen>
    with TickerProviderStateMixin {
  // Data
  List<TutorialTopic> allTopics = [];
  Map<String, List<TutorialTopic>> groupedTopics = {};
  Map<String, List<TutorialTopic>> groupedFilteredTopics = {};

  // UI state
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _completedTopics = {};
  bool _isLoading = true;
  String? _lastTopicSlug;
  Timer? _debounce;
  String _selectedDifficulty = 'All';
  String _searchQuery = '';

  // Dynamic configuration
  ScreenConfig? _config;
  bool _isLoadingConfig = true;

  // Scroll controller for FAB
  final ScrollController _scrollController = ScrollController();

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  // Animation
  late AnimationController _heroController;
  late Animation<double> _heroAnimation;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _updateSEOMetaTags(); // ✅ Add SEO meta tags
    _loadConfiguration();
  if (kIsWeb) {
  _addH1("${widget.category} Tutorials");
}
    _initAll();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
    
  }

void _addH1(String text) {
  final existing = html.document.querySelector('h1');
  existing?.remove();

  final h1 = html.HeadingElement.h1()
    ..text = text
    ..style.display = 'none';

  html.document.body?.append(h1);
}

@override
void didUpdateWidget(covariant TopicsScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.category != widget.category) {
    _updateSEOMetaTags();
   if (kIsWeb) {
    _addH1("${widget.category} Tutorials");
  }
  }
}
  // ---------------- SEO Methods ----------------
  void _updateSEOMetaTags() {
    if (!kIsWeb) return;
    
    final categoryName = widget.category;
    final capitalizedCategory = categoryName[0].toUpperCase() + categoryName.substring(1);
    
    MetaService.updateMetaTags(
      title: "$capitalizedCategory Tutorials - Revochamp",
      description: "Learn $capitalizedCategory with step-by-step tutorials, practical examples, and best practices. Master ${capitalizedCategory.toLowerCase()} from beginner to advanced. Free tutorials with hands-on examples.",
      slug: categoryName,
      keywords: [categoryName, "tutorial", "learn $categoryName", "$categoryName guide", "programming", "$categoryName examples"],
      isArticle: false,
    );
  }

  void _updateFilteredMeta(String searchQuery, String difficulty, int resultCount) {
    if (!kIsWeb) return;
    
    if (searchQuery.isNotEmpty) {
      MetaService.updateMetaTags(
        title: "Search: $searchQuery - ${widget.category} Tutorials",
        description: "Found $resultCount results for '$searchQuery' in ${widget.category}. Learn ${widget.category} with our comprehensive tutorials.",
        slug: "${widget.category}?q=$searchQuery",
        isArticle: false,
        noIndex: true, // Search results should not be indexed
      );
      MetaService.setCanonical("https://revochamp.site/tech/${widget.category}");
    } else if (difficulty != 'All') {
      MetaService.updateMetaTags(
        title: "$difficulty Level ${widget.category} Tutorials",
        description: "Browse $difficulty level ${widget.category} tutorials. Perfect for ${difficulty.toLowerCase()} developers looking to enhance their skills.",
        slug: "${widget.category}/difficulty/${difficulty.toLowerCase()}",
        isArticle: false,
      );
    } else {
      _updateSEOMetaTags(); // Reset to default
    }
  }

  void _updateCollectionPageSchema() {
    if (!kIsWeb) return;
    
    final items = allTopics.take(20).map((topic) {
      return {
        'name': topic.title,
        'url': 'https://revochamp.site/tech/${widget.category}/${topic.slug}',
      };
    }).toList();
    
    MetaService.setCollectionPageSchema(
      name: "${widget.category} Tutorials",
      description: "Complete collection of ${widget.category} tutorials with practical examples",
      url: "https://revochamp.site/tech/${widget.category}",
      items: items,
    );
  }

  void _setBreadcrumbSchema() {
    if (!kIsWeb) return;
    
    MetaService.setBreadcrumbData(
      title: widget.category,
      slug: widget.category,
      parents: [
        {'name': 'Courses', 'url': 'https://revochamp.site/tech/courses'},
      ],
    );
  }

  // ---------------- API URL ----------------
  String getBaseUrl() => 'https://json.revochamp.site/${widget.category}/topics.json';
  String getConfigUrl() => 'https://json.revochamp.site/${widget.category}/config.json';

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    if (_config?.features.enableAnimations ?? true) {
      _heroController.forward();
    } else {
      _heroController.value = 1.0;
    }
  }

  Future<void> _loadConfiguration() async {
    try {
      final response = await http.get(Uri.parse(getConfigUrl()));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _config = ScreenConfig.fromJson(jsonData);
            _isLoadingConfig = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _config = ScreenConfig.getDefault();
            _isLoadingConfig = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading config: $e');
      if (mounted) {
        setState(() {
          _config = ScreenConfig.getDefault();
          _isLoadingConfig = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // 1. Initialisation
  // --------------------------------------------------------------
  Future<void> _initAll() async {
    final normalizedCategory = widget.category.toLowerCase();
    
    // Check cache first (category-specific)
    if (TopicsScreen._cachedTopics.containsKey(normalizedCategory)) {
      _applyData(
        topics: TopicsScreen._cachedTopics[normalizedCategory]!,
        completed: _completedTopics,
        lastTopic: _lastTopicSlug,
      );
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      // Fetch data
      final response = await http.get(Uri.parse(getBaseUrl()));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      // Parse in isolate
      final topics = await compute(parseTopics, response.body);

      if (topics.isEmpty) {
        throw Exception('No topics found in the response');
      }

      // Update cache per category (with normalized key)
      TopicsScreen._cachedTopics[normalizedCategory] = topics;

      // Get saved progress with category-specific keys
      final completedList = _prefs!.getStringList('completed_${widget.category}') ?? [];
      final lastTopic = _prefs!.getString('last_topic_${widget.category}');

      _applyData(
        topics: topics,
        completed: completedList,
        lastTopic: lastTopic,
      );
    } catch (e) {
      debugPrint('Error loading topics: $e');
      if (!mounted) return;
      _showErrorSnackbar('Failed to load topics: ${e.toString()}');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyData({
    required List<TutorialTopic> topics,
    required Iterable<String> completed,
    String? lastTopic,
  }) {
    compute(_groupTopicsIsolate, topics)
        .then((grouped) {
          if (!mounted) return;
          setState(() {
            allTopics = topics;
            groupedTopics = grouped;
            groupedFilteredTopics = grouped;
            _completedTopics.addAll(completed);
            _lastTopicSlug = lastTopic;
            _isLoading = false;
          });
          _updateCollectionPageSchema();
          _setBreadcrumbSchema();
                MetaService.setFaqSchema([
  {
    "question": "What is ${widget.category}?",
    "answer": "${widget.category} is a technology used for development."
  },
  {
    "question": "How to learn ${widget.category}?",
    "answer": "Start with basics and practice with real examples."
  }
]);

        })
      
        .catchError((e) {
          if (!mounted) return;
          final grouped = _groupTopicsSync(topics);
          setState(() {
            allTopics = topics;
            groupedTopics = grouped;
            groupedFilteredTopics = grouped;
            _completedTopics.addAll(completed);
            _lastTopicSlug = lastTopic;
            _isLoading = false;
          });
          _updateCollectionPageSchema();
          _setBreadcrumbSchema();
        });
  }

  // --------------------------------------------------------------
  // 2. Pagination
  // --------------------------------------------------------------
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });
    
    // Simulate loading more items (implement actual pagination from API)
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoadingMore = false;
      _hasMore = _currentPage < 5; // Adjust based on total items
    });
  }

  // --------------------------------------------------------------
  // 3. Grouping (isolated + sync fallback)
  // --------------------------------------------------------------
  static Map<String, List<TutorialTopic>> _groupTopicsIsolate(
    List<TutorialTopic> topics,
  ) {
    final map = <String, List<TutorialTopic>>{};
    for (final t in topics) {
      final normalizedCategory = t.category.toLowerCase();
      map.putIfAbsent(normalizedCategory, () => []).add(t);
    }
    return map;
  }

  Map<String, List<TutorialTopic>> _groupTopicsSync(
    List<TutorialTopic> topics,
  ) {
    final map = <String, List<TutorialTopic>>{};
    for (final t in topics) {
      final normalizedCategory = t.category.toLowerCase();
      map.putIfAbsent(normalizedCategory, () => []).add(t);
    }
    return map;
  }

  // --------------------------------------------------------------
  // 4. Combined Filtering (search + difficulty)
  // --------------------------------------------------------------
  void _applyFilters() {
    if (!mounted) return;
    final query = _searchQuery.trim().toLowerCase();
    final filteredBySearch = query.isEmpty
        ? allTopics
        : allTopics
            .where((t) => t.title.toLowerCase().contains(query))
            .toList();

    final filtered = _selectedDifficulty == 'All'
        ? filteredBySearch
        : filteredBySearch
            .where((t) => t.level == _selectedDifficulty)
            .toList();

    final grouped = _groupTopicsSync(filtered);

    setState(() {
      groupedFilteredTopics = grouped;
    });
    
    // ✅ Update meta for filtered view
    _updateFilteredMeta(query, _selectedDifficulty, filtered.length);
  }

  // --------------------------------------------------------------
  // 5. Search & Difficulty handlers
  // --------------------------------------------------------------
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
      });
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = "";
      _searchController.clear();
    });
    _applyFilters();
  }

  // --------------------------------------------------------------
  // 6. SharedPreferences helpers (Category-specific)
  // --------------------------------------------------------------
  Future<void> _saveLastTopic(String slug) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString('last_topic_${widget.category}', slug);
  }

  Future<void> _saveCompletedTopics() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setStringList('completed_${widget.category}', _completedTopics.toList());
  }

  // --------------------------------------------------------------
  // 7. Share Functionality
  // --------------------------------------------------------------
  void _shareTopicsPage() {
    final url = 'https://revochamp.site/tech/${widget.category}';
    final title = '${widget.category} Tutorials - Revochamp';
    
    if (kIsWeb) {
      html.window.navigator.share.call({
        'title': title,
        'text': 'Check out these ${widget.category} tutorials!',
        'url': url,
      });
    }
  }

  // --------------------------------------------------------------
  // 8. Helpers
  // --------------------------------------------------------------
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: PremiumTheme.richBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

  void _retryLoading() {
    setState(() {
      _isLoading = true;
    });
    _initAll();
  }

  double get _progress =>
      allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;
      
  int get _totalFilteredTopics =>
      groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  int _getGridCrossAxisCount(BuildContext context) {
    if (_config == null) {
      final width = MediaQuery.of(context).size.width;
      if (width >= 1200) return 4;
      if (width >= 800) return 3;
      if (width >= 500) return 2;
      return 1;
    }
    return _config!.grid.getCrossAxisCount(MediaQuery.of(context).size.width);
  }

  String _getLastUpdatedDate() {
    // if (allTopics.isEmpty) return 'January 2024';
    
    // // Assuming topics have a 'lastUpdated' field
    // final latest = allTopics.reduce((a, b) => 
    //   (a.lastUpdated ?? DateTime(2000)).isAfter(b.lastUpdated ?? DateTime(2000)) ? a : b);
    return _formatDate( DateTime.now());

    // if (allTopics.isEmpty) return 'January 2024';
    
    // // Assuming topics have a 'lastUpdated' field
    // final latest = allTopics.reduce((a, b) => 
    //   (a.lastUpdated ?? DateTime(2000)).isAfter(b.lastUpdated ?? DateTime(2000)) ? a : b);
    // return _formatDate(latest.lastUpdated ?? DateTime.now());

  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, String>> _getRelatedCategories() {
    final relations = {
      'dart': [
        {'name': 'Flutter Basics', 'slug': 'flutter-basics'},
        {'name': 'OOP Concepts', 'slug': 'oop'},
        {'name': 'Asynchronous Programming', 'slug': 'async-programming'},
      ],
      'flutter': [
        {'name': 'Widgets', 'slug': 'widgets'},
        {'name': 'State Management', 'slug': 'state-management'},
        {'name': 'Animations', 'slug': 'animations'},
      ],
      'widgets': [
        {'name': 'Flutter Basics', 'slug': 'flutter-basics'},
        {'name': 'Layouts', 'slug': 'layouts'},
        {'name': 'Navigation', 'slug': 'navigation'},
      ],
    };
    
    return relations[widget.category.toLowerCase()] ?? [];
  }

  // --------------------------------------------------------------
  // 9. UI Build
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getGridCrossAxisCount(context);
    final mobile = isMobile;
    final features = _config?.features ?? FeatureFlags.getDefault();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading || _isLoadingConfig
          ? _buildLoadingState()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(mobile),
                SliverToBoxAdapter(child: _buildBreadcrumbs(mobile)),
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Text(
      "Learn ${widget.category} with step-by-step tutorials, examples, and real-world projects. Covers beginner to advanced concepts.",
      style: TextStyle(fontSize: 14, color: Colors.black87),
    ),
  ),
),
                if (features.showHeroSection)
                  SliverToBoxAdapter(
                    child: (_config?.features.enableAnimations ?? true)
                        ? FadeTransition(
                            opacity: _heroAnimation,
                            child: _buildHeroSection(mobile),
                          )
                        : _buildHeroSection(mobile),
                  ),
                if (features.showProgressSection)
                  SliverToBoxAdapter(child: _buildProgressSection(mobile)),
                if (features.showStatsSection)
                  SliverToBoxAdapter(child: _buildStatsSection(mobile)),
                if (features.showContinueBanner &&
                    _lastTopicSlug != null &&
                    _lastTopicSlug!.isNotEmpty)
                  SliverToBoxAdapter(child: _buildContinueBanner(mobile)),
                if (features.showSearchFilters) ...[
                  SliverToBoxAdapter(child: _buildSearchSection(mobile)),
                  SliverToBoxAdapter(child: _buildDifficultyFilter(mobile)),
                ],
                if ((_searchQuery.isNotEmpty || _selectedDifficulty != 'All') &&
                    features.showSearchFilters)
                  SliverToBoxAdapter(child: _buildResultCount(mobile)),
                if (groupedFilteredTopics.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  ...groupedFilteredTopics.entries.expand((entry) {
                    final categoryName = entry.key;
                    final topicsInCategory = entry.value;
                    if (topicsInCategory.isEmpty) return <Widget>[];

                    // Paginate items
                    final paginatedTopics = topicsInCategory
                        .take(_currentPage * _itemsPerPage)
                        .toList();

                    return [
                      SliverToBoxAdapter(
                        child: _buildCategoryHeader(categoryName, mobile),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final topic = paginatedTopics[index];
                              final isCompleted = _completedTopics.contains(topic.slug);
                              return TopicCard(
                                topic: topic,
                                isCompleted: isCompleted,
                                onTap: () async {
                                  if (!_completedTopics.contains(topic.slug)) {
                                    if (mounted) {
                                      setState(() {
                                        _completedTopics.add(topic.slug);
                                      });
                                      await _saveCompletedTopics();
                                    }
                                  }
                                  if (!mounted) return;
                                  await _saveLastTopic(topic.slug);
                                  if (!mounted) return;
                                  if (context.mounted) {
                                    context.go('/${widget.category}/${topic.slug}');
                                  }
                                },
                              );
                            },
                            childCount: paginatedTopics.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: _config?.grid.childAspectRatio ?? 3.2,
                            crossAxisSpacing: _config?.grid.crossAxisSpacing ?? 12,
                            mainAxisSpacing: _config?.grid.mainAxisSpacing ?? 12,
                          ),
                        ),
                      ),
                    ];
                  }),
                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                SliverToBoxAdapter(child: _buildRelatedCategories()),
                SliverToBoxAdapter(child: _buildLastUpdated()),
                SliverToBoxAdapter(child: _buildSeoFooter(mobile)),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
      floatingActionButton: features.showFloatingButton && allTopics.length > 10
          ? FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              backgroundColor: PremiumTheme.richBlue,
              child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
            )
          : null,
    );
  }

  // --------------------------------------------------------------
  // 10. UI Components
  // --------------------------------------------------------------
  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: _buildLogo(),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: PremiumTheme.textMuted),
          onPressed: _shareTopicsPage,
          tooltip: 'Share this page',
        ),
        if (!isMobile) ...[
          TextButton(
            onPressed: () {
              if (context.mounted) context.go('/');
            },
            child: const Text("Home", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) context.go('/courses');
            },
            child: const Text("All Courses", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          const SizedBox(width: 20),
          OutlinedButton(
            onPressed: () => _showSnackBar("Login feature coming soon"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: PremiumTheme.lightGray, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Sign In", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _showSnackBar("Sign up feature coming soon"),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumTheme.richBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text("Get Started", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 24),
        ],
      ],
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
          child: const Center(child: Text("RL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 10),
        const Text("RevoLearn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
      ],
    );
  }

  Widget _buildBreadcrumbs(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: Text('Home', style: TextStyle(color: PremiumTheme.richBlue, fontSize: 13)),
          ),
          const Icon(Icons.chevron_right, size: 16, color: PremiumTheme.textLight),
          InkWell(
            onTap: () => context.go('/courses'),
            child: Text('Courses', style: TextStyle(color: PremiumTheme.richBlue, fontSize: 13)),
          ),
          const Icon(Icons.chevron_right, size: 16, color: PremiumTheme.textLight),
          Text(
            widget.category,
            style: TextStyle(color: PremiumTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
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
          Text('Loading topics...', style: TextStyle(color: PremiumTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    final hero = _config?.hero ?? HeroConfig.getDefault();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: isMobile ? 40 : 50),
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
            child: Text(hero.badge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(height: 30),
          Text(
            hero.title,
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
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
              hero.highlightedText,
              style: TextStyle(
                fontSize: isMobile ? 36 : 48,
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
              hero.description,
              style: TextStyle(
                fontSize: isMobile ? 15 : 16,
                color: PremiumTheme.textMuted,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hero.chips.isNotEmpty) ...[
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: hero.chips.map((chip) => _buildHeroChip(chip)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: PremiumTheme.lightGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PremiumTheme.textMuted)),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    final totalTopics = allTopics.length;
    final completedCount = _completedTopics.length;
    final totalHours = allTopics.fold<double>(0.0, (sum, topic) => sum + (topic.estimatedHours ?? 0.0));
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("$totalTopics", "Topics"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("$completedCount", "Completed"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("${totalHours.toStringAsFixed(0)}+", "Hours"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PremiumTheme.textDark)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildProgressSection(bool isMobile) {
    final pct = (_progress * 100).toInt();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Learning Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: PremiumTheme.elegantGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pct% • ${_completedTopics.length}/${allTopics.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: PremiumTheme.lightGray,
              color: PremiumTheme.richBlue,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _progress > 0.8
                ? "🎉 You're almost there! Keep pushing forward!"
                : _progress > 0.3
                ? "💪 Great progress! Keep learning, one topic at a time."
                : "🌟 Start your journey today. Every expert was once a beginner.",
            style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueBanner(bool isMobile) {
    final lastTopic = allTopics.firstWhere(
      (t) => t.slug == _lastTopicSlug,
      orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', estimatedHours: 0.0, category: '', level: ''),
    );
    if (lastTopic.slug.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PremiumTheme.success.withValues(alpha: 0.12), PremiumTheme.successBg.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.success.withValues(alpha: 0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
            boxShadow: [
              BoxShadow(color: const Color(0xFF11998E).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        ),
        title: Text('Continue: ${lastTopic.title}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
        subtitle: const Text('Tap to resume where you left off', style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted)),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTheme.success.withValues(alpha: 0.12)),
          child: const Icon(Icons.arrow_forward_rounded, size: 16, color: PremiumTheme.success),
        ),
        onTap: () {
          _saveLastTopic(lastTopic.slug);
          if (context.mounted) {
            context.go('/${widget.category}/${lastTopic.slug}');
          }
        },
      ),
    );
  }

  Widget _buildSearchSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
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
                  hintText: "Search topics...",
                  hintStyle: TextStyle(color: PremiumTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18, color: PremiumTheme.textLight),
                onPressed: _clearSearch,
              ),
            Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: PremiumTheme.richBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyFilter(bool isMobile) {
    final difficulties = _config?.difficulties ?? DifficultyConfig.getDefault();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: difficulties.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty.name;
            final color = difficulty.colorObj;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedDifficulty = difficulty.name);
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? color : PremiumTheme.lightGray, width: 1.5),
                    boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (difficulty.icon.isNotEmpty) ...[
                        Text(difficulty.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        difficulty.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : PremiumTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultCount(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
      child: Text(
        'Showing $_totalFilteredTopics result${_totalFilteredTopics != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCategoryHeader(String categoryName, bool isMobile) {
    final categoryConfig = _config?.categories[categoryName.toLowerCase()];
    final description = categoryConfig?.description ?? _getCategoryDescription(categoryName);
    final icon = categoryConfig?.icon ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 20, 32, isMobile ? 20 : 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon.isNotEmpty) ...[
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PremiumTheme.textDark, letterSpacing: -0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 13, color: PremiumTheme.textMuted, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              gradient: PremiumTheme.elegantGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDescription(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'dart basics':
        return 'Learn Dart syntax, variables, functions, and OOP concepts. Master the fundamentals of Dart programming language.';
      case 'widgets':
        return 'Explore Flutter widgets: Stateless, Stateful, and built-in components. Build beautiful UIs with Flutter\'s widget system.';
      case 'state management':
        return 'Manage app state with Provider, BLoC, and other patterns. Build scalable and maintainable Flutter applications.';
      case 'api integration':
        return 'Connect to REST APIs, handle JSON, and use HTTP requests. Learn to fetch and display data from backend services.';
      case 'advanced':
        return 'Deep dive into animations, custom painters, and performance optimization. Take your Flutter skills to the next level.';
      default:
        return 'Learn $categoryName concepts with practical examples and real-world applications.';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTheme.lightGray),
              child: const Center(child: Icon(Icons.search_off_rounded, size: 40, color: PremiumTheme.textLight)),
            ),
            const SizedBox(height: 20),
            const Text('No topics found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
            const SizedBox(height: 8),
            Text(
              'Try "Widgets", "State Management", or "API"',
              textAlign: TextAlign.center,
              style: TextStyle(color: PremiumTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedCategories() {
    final relatedCategories = _getRelatedCategories();
    if (relatedCategories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Explore More Topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: relatedCategories.map((category) {
              return ActionChip(
                label: Text(category['name']!),
                onPressed: () {
                  context.go('/tech/${category['slug']}');
                },
                backgroundColor: Colors.white,
                side: BorderSide(color: PremiumTheme.lightGray),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    final lastUpdated = _getLastUpdatedDate();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update, size: 12, color: PremiumTheme.textLight),
          const SizedBox(width: 4),
          Text(
            'Last updated: $lastUpdated',
            style: const TextStyle(fontSize: 11, color: PremiumTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildSeoFooter(bool isMobile) {
    final seo = _config?.seo ?? SEOConfig.getDefault();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray),
      ),
      child: Column(
        children: [
          Text(seo.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(seo.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
          const SizedBox(height: 12),
          Text(
            seo.description,
            style: TextStyle(fontSize: 13, color: PremiumTheme.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
          if (seo.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: seo.tags.map((tag) => _buildSeoTag(tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500)),
    );
  }
}

// // lib/screens/topics/topics_screen.dart
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../models/topic_screen_config.dart';
// import '../../models/tutorial_topic.dart';
// import '../../utils/json_parser.dart';
// import '../../core/theme.dart';
// import 'topic_card.dart';

// class TopicsScreen extends StatefulWidget {
//   final String category;

//   const TopicsScreen({super.key, required this.category});
  
//   // ✅ Per-category caching
//   static final Map<String, List<TutorialTopic>> _cachedTopics = {};
  
//   // ✅ Category-specific method
//   static List<TutorialTopic> getTopicsByCategory(String category) {
//     return _cachedTopics[category.toLowerCase()] ?? [];
//   }
  
//   static void clearCache() {
//     _cachedTopics.clear();
//   }

//   @override
//   State<TopicsScreen> createState() => _TopicsScreenState();
// }

// class _TopicsScreenState extends State<TopicsScreen>
//     with TickerProviderStateMixin {
//   // Data
//   List<TutorialTopic> allTopics = [];
//   Map<String, List<TutorialTopic>> groupedTopics = {};
//   Map<String, List<TutorialTopic>> groupedFilteredTopics = {};

//   // UI state
//   final TextEditingController _searchController = TextEditingController();
//   final Set<String> _completedTopics = {};
//   bool _isLoading = true;
//   String? _lastTopicSlug;
//   Timer? _debounce;
//   String _selectedDifficulty = 'All';
//   String _searchQuery = '';

//   // Dynamic configuration
//   ScreenConfig? _config;
//   bool _isLoadingConfig = true;

//   // Scroll controller for FAB
//   final ScrollController _scrollController = ScrollController();

//   // Cached SharedPreferences instance
//   SharedPreferences? _prefs;

//   // Animation
//   late AnimationController _heroController;
//   late Animation<double> _heroAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _loadConfiguration();
//     _initAll();
//     _setupAnimations();
//   }

//   // ---------------- API URL ----------------
//   String getBaseUrl() => 'https://json.revochamp.site/${widget.category}/topics.json';
//   String getConfigUrl() => 'https://json.revochamp.site/${widget.category}/config.json';

//   void _setupAnimations() {
//     _heroController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _heroAnimation = CurvedAnimation(
//       parent: _heroController,
//       curve: Curves.easeOutCubic,
//     );
//     if (_config?.features.enableAnimations ?? true) {
//       _heroController.forward();
//     } else {
//       _heroController.value = 1.0;
//     }
//   }

//   Future<void> _loadConfiguration() async {
//     try {
//       final response = await http.get(Uri.parse(getConfigUrl()));
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         if (mounted) {
//           setState(() {
//             _config = ScreenConfig.fromJson(jsonData);
//             _isLoadingConfig = false;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _config = ScreenConfig.getDefault();
//             _isLoadingConfig = false;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading config: $e');
//       if (mounted) {
//         setState(() {
//           _config = ScreenConfig.getDefault();
//           _isLoadingConfig = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _scrollController.dispose();
//     _heroController.dispose();
//     super.dispose();
//   }

//   // --------------------------------------------------------------
//   // 1. Initialisation
//   // --------------------------------------------------------------
//   Future<void> _initAll() async {
//     final normalizedCategory = widget.category.toLowerCase();
    
//     // Check cache first (category-specific)
//     if (TopicsScreen._cachedTopics.containsKey(normalizedCategory)) {
//       _applyData(
//         topics: TopicsScreen._cachedTopics[normalizedCategory]!,
//         completed: _completedTopics,
//         lastTopic: _lastTopicSlug,
//       );
//       return;
//     }

//     try {
//       _prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;

//       // Fetch data
//       final response = await http.get(Uri.parse(getBaseUrl()));

//       if (response.statusCode != 200) {
//         throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
//       }

//       // Parse in isolate
//       final topics = await compute(parseTopics, response.body);

//       if (topics.isEmpty) {
//         throw Exception('No topics found in the response');
//       }

//       // Update cache per category (with normalized key)
//       TopicsScreen._cachedTopics[normalizedCategory] = topics;

//       // Get saved progress with category-specific keys
//       final completedList = _prefs!.getStringList('completed_${widget.category}') ?? [];
//       final lastTopic = _prefs!.getString('last_topic_${widget.category}');

//       _applyData(
//         topics: topics,
//         completed: completedList,
//         lastTopic: lastTopic,
//       );
//     } catch (e) {
//       debugPrint('Error loading topics: $e');
//       if (!mounted) return;
//       _showErrorSnackbar('Failed to load topics: ${e.toString()}');
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _applyData({
//     required List<TutorialTopic> topics,
//     required Iterable<String> completed,
//     String? lastTopic,
//   }) {
//     compute(_groupTopicsIsolate, topics)
//         .then((grouped) {
//           if (!mounted) return;
//           setState(() {
//             allTopics = topics;
//             groupedTopics = grouped;
//             groupedFilteredTopics = grouped;
//             _completedTopics.addAll(completed);
//             _lastTopicSlug = lastTopic;
//             _isLoading = false;
//           });
//         })
//         .catchError((e) {
//           if (!mounted) return;
//           final grouped = _groupTopicsSync(topics);
//           setState(() {
//             allTopics = topics;
//             groupedTopics = grouped;
//             groupedFilteredTopics = grouped;
//             _completedTopics.addAll(completed);
//             _lastTopicSlug = lastTopic;
//             _isLoading = false;
//           });
//         });
//   }

//   // --------------------------------------------------------------
//   // 2. Grouping (isolated + sync fallback)
//   // --------------------------------------------------------------
//   static Map<String, List<TutorialTopic>> _groupTopicsIsolate(
//     List<TutorialTopic> topics,
//   ) {
//     final map = <String, List<TutorialTopic>>{};
//     for (final t in topics) {
//       final normalizedCategory = t.category.toLowerCase();
//       map.putIfAbsent(normalizedCategory, () => []).add(t);
//     }
//     return map;
//   }

//   Map<String, List<TutorialTopic>> _groupTopicsSync(
//     List<TutorialTopic> topics,
//   ) {
//     final map = <String, List<TutorialTopic>>{};
//     for (final t in topics) {
//       final normalizedCategory = t.category.toLowerCase();
//       map.putIfAbsent(normalizedCategory, () => []).add(t);
//     }
//     return map;
//   }

//   // --------------------------------------------------------------
//   // 3. Combined Filtering (search + difficulty)
//   // --------------------------------------------------------------
//   void _applyFilters() {
//     if (!mounted) return;
//     final query = _searchQuery.trim().toLowerCase();
//     final filteredBySearch = query.isEmpty
//         ? allTopics
//         : allTopics
//             .where((t) => t.title.toLowerCase().contains(query))
//             .toList();

//     final filtered = _selectedDifficulty == 'All'
//         ? filteredBySearch
//         : filteredBySearch
//             .where((t) => t.level == _selectedDifficulty)
//             .toList();

//     final grouped = _groupTopicsSync(filtered);

//     setState(() {
//       groupedFilteredTopics = grouped;
//     });
//   }

//   // --------------------------------------------------------------
//   // 4. Search & Difficulty handlers
//   // --------------------------------------------------------------
//   void _onSearchChanged(String query) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         _searchQuery = query;
//       });
//       _applyFilters();
//     });
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchQuery = "";
//       _searchController.clear();
//     });
//     _applyFilters();
//   }

//   // --------------------------------------------------------------
//   // 5. SharedPreferences helpers (Category-specific)
//   // --------------------------------------------------------------
//   Future<void> _saveLastTopic(String slug) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setString('last_topic_${widget.category}', slug);
//   }

//   Future<void> _saveCompletedTopics() async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setStringList('completed_${widget.category}', _completedTopics.toList());
//   }

//   // --------------------------------------------------------------
//   // 6. Helpers
//   // --------------------------------------------------------------
//   void _showErrorSnackbar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: PremiumTheme.richBlue,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: PremiumTheme.richBlue,
//         duration: const Duration(seconds: 2),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   double get _progress =>
//       allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;
      
//   int get _totalFilteredTopics =>
//       groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);

//   void _scrollToTop() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   bool get isMobile => MediaQuery.of(context).size.width < 600;

//   int _getGridCrossAxisCount(BuildContext context) {
//     if (_config == null) {
//       final width = MediaQuery.of(context).size.width;
//       if (width >= 1200) return 4;
//       if (width >= 800) return 3;
//       if (width >= 500) return 2;
//       return 1;
//     }
//     return _config!.grid.getCrossAxisCount(MediaQuery.of(context).size.width);
//   }

//   // --------------------------------------------------------------
//   // 7. UI Build
//   // --------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final crossAxisCount = _getGridCrossAxisCount(context);
//     final mobile = isMobile;
//     final features = _config?.features ?? FeatureFlags.getDefault();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _isLoading || _isLoadingConfig
//           ? _buildLoadingState()
//           : CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 _buildAppBar(mobile),
//                 if (features.showHeroSection)
//                   SliverToBoxAdapter(
//                     child: (_config?.features.enableAnimations ?? true)
//                         ? FadeTransition(
//                             opacity: _heroAnimation,
//                             child: _buildHeroSection(mobile),
//                           )
//                         : _buildHeroSection(mobile),
//                   ),
//                 if (features.showProgressSection)
//                   SliverToBoxAdapter(child: _buildProgressSection(mobile)),
//                 if (features.showStatsSection)
//                   SliverToBoxAdapter(child: _buildStatsSection(mobile)),
//                 if (features.showContinueBanner &&
//                     _lastTopicSlug != null &&
//                     _lastTopicSlug!.isNotEmpty)
//                   SliverToBoxAdapter(child: _buildContinueBanner(mobile)),
//                 if (features.showSearchFilters) ...[
//                   SliverToBoxAdapter(child: _buildSearchSection(mobile)),
//                   SliverToBoxAdapter(child: _buildDifficultyFilter(mobile)),
//                 ],
//                 if ((_searchQuery.isNotEmpty || _selectedDifficulty != 'All') &&
//                     features.showSearchFilters)
//                   SliverToBoxAdapter(child: _buildResultCount(mobile)),
//                 if (groupedFilteredTopics.isEmpty)
//                   SliverToBoxAdapter(child: _buildEmptyState())
//                 else
//                   ...groupedFilteredTopics.entries.expand((entry) {
//                     final categoryName = entry.key;
//                     final topicsInCategory = entry.value;
//                     if (topicsInCategory.isEmpty) return <Widget>[];

//                     return [
//                       SliverToBoxAdapter(
//                         child: _buildCategoryHeader(categoryName, mobile),
//                       ),
//                       SliverPadding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         sliver: SliverGrid(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final topic = topicsInCategory[index];
//                               final isCompleted = _completedTopics.contains(topic.slug);
//                               return TopicCard(
//                                 topic: topic,
//                                 isCompleted: isCompleted,
//                                 onTap: () async {
//                                   if (!_completedTopics.contains(topic.slug)) {
//                                     if (mounted) {
//                                       setState(() {
//                                         _completedTopics.add(topic.slug);
//                                       });
//                                       await _saveCompletedTopics();
//                                     }
//                                   }
//                                   if (!mounted) return;
//                                   await _saveLastTopic(topic.slug);
//                                   if (!mounted) return;
//                                   if (context.mounted) {
//                                     // ✅ FIXED: Remove /tech from navigation
//                                     // Use clean URL: /{category}/{slug}
//                                     context.go('/${widget.category}/${topic.slug}');
//                                   }
//                                 },
//                               );
//                             },
//                             childCount: topicsInCategory.length,
//                           ),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: crossAxisCount,
//                             childAspectRatio: _config?.grid.childAspectRatio ?? 3.2,
//                             crossAxisSpacing: _config?.grid.crossAxisSpacing ?? 12,
//                             mainAxisSpacing: _config?.grid.mainAxisSpacing ?? 12,
//                           ),
//                         ),
//                       ),
//                       const SliverToBoxAdapter(child: SizedBox(height: 16)),
//                     ];
//                   }),
//                 SliverToBoxAdapter(child: _buildSeoFooter(mobile)),
//                 const SliverToBoxAdapter(child: SizedBox(height: 40)),
//               ],
//             ),
//       floatingActionButton: features.showFloatingButton && allTopics.length > 10
//           ? FloatingActionButton(
//               mini: true,
//               onPressed: _scrollToTop,
//               backgroundColor: PremiumTheme.richBlue,
//               child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
//             )
//           : null,
//     );
//   }

//   // --------------------------------------------------------------
//   // 8. UI Components
//   // --------------------------------------------------------------
//   SliverAppBar _buildAppBar(bool isMobile) {
//     return SliverAppBar(
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: _buildLogo(),
//       centerTitle: false,
//       actions: [
//         if (!isMobile) ...[
//           TextButton(
//             onPressed: () {
//               if (context.mounted) context.go('/');
//             },
//             child: const Text("Home", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
//           ),
//           TextButton(
//             onPressed: () {
//               if (context.mounted) context.go('/courses');
//             },
//             child: const Text("All Courses", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
//           ),
//           const SizedBox(width: 20),
//           OutlinedButton(
//             onPressed: () => _showSnackBar("Login feature coming soon"),
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: PremiumTheme.lightGray, width: 1.5),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text("Sign In", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 13)),
//           ),
//           const SizedBox(width: 10),
//           ElevatedButton(
//             onPressed: () => _showSnackBar("Sign up feature coming soon"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: PremiumTheme.richBlue,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               elevation: 0,
//             ),
//             child: const Text("Get Started", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
//           ),
//           const SizedBox(width: 24),
//         ],
//       ],
//     );
//   }

//   Widget _buildLogo() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
//             ),
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: PremiumTheme.richBlue.withValues(alpha: 0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: const Center(child: Text("RL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
//         ),
//         const SizedBox(width: 10),
//         const Text("RevoLearn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
//       ],
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 48,
//             height: 48,
//             child: CircularProgressIndicator(
//               strokeWidth: 3,
//               valueColor: const AlwaysStoppedAnimation(PremiumTheme.richBlue),
//               backgroundColor: PremiumTheme.lightGray,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text('Loading topics...', style: TextStyle(color: PremiumTheme.textMuted, fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeroSection(bool isMobile) {
//     final hero = _config?.hero ?? HeroConfig.getDefault();

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: isMobile ? 40 : 50),
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
//             child: Text(hero.badge, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
//           ),
//           const SizedBox(height: 30),
//           Text(
//             hero.title,
//             style: TextStyle(
//               fontSize: isMobile ? 36 : 48,
//               fontWeight: FontWeight.w800,
//               color: PremiumTheme.textDark,
//               letterSpacing: -0.5,
//               height: 1.1,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
//             ).createShader(bounds),
//             child: Text(
//               hero.highlightedText,
//               style: TextStyle(
//                 fontSize: isMobile ? 36 : 48,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//                 height: 1.1,
//                 letterSpacing: -0.5,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             constraints: const BoxConstraints(maxWidth: 600),
//             child: Text(
//               hero.description,
//               style: TextStyle(
//                 fontSize: isMobile ? 15 : 16,
//                 color: PremiumTheme.textMuted,
//                 height: 1.6,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (hero.chips.isNotEmpty) ...[
//             const SizedBox(height: 30),
//             Wrap(
//               spacing: 16,
//               runSpacing: 12,
//               children: hero.chips.map((chip) => _buildHeroChip(chip)).toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildHeroChip(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       decoration: BoxDecoration(
//         color: PremiumTheme.lightGray,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray),
//       ),
//       child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PremiumTheme.textMuted)),
//     );
//   }

//   Widget _buildStatsSection(bool isMobile) {
//     final totalTopics = allTopics.length;
//     final completedCount = _completedTopics.length;
//     final totalHours = allTopics.fold<double>(0.0, (sum, topic) => sum + (topic.estimatedHours ?? 0.0));
    
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: PremiumTheme.softGray,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem("$totalTopics", "Topics"),
//           Container(width: 1, height: 30, color: PremiumTheme.lightGray),
//           _buildStatItem("$completedCount", "Completed"),
//           Container(width: 1, height: 30, color: PremiumTheme.lightGray),
//           _buildStatItem("${totalHours.toStringAsFixed(0)}+", "Hours"),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String value, String label) {
//     return Column(
//       children: [
//         Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PremiumTheme.textDark)),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(fontSize: 11, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//   Widget _buildProgressSection(bool isMobile) {
//     final pct = (_progress * 100).toInt();

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Your Learning Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                 decoration: BoxDecoration(
//                   gradient: PremiumTheme.elegantGradient,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '$pct% • ${_completedTopics.length}/${allTopics.length}',
//                   style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: LinearProgressIndicator(
//               value: _progress,
//               backgroundColor: PremiumTheme.lightGray,
//               color: PremiumTheme.richBlue,
//               minHeight: 8,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _progress > 0.8
//                 ? "🎉 You're almost there! Keep pushing forward!"
//                 : _progress > 0.3
//                 ? "💪 Great progress! Keep learning, one topic at a time."
//                 : "🌟 Start your journey today. Every expert was once a beginner.",
//             style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ FIXED: Continue banner navigation (remove /tech)
//   Widget _buildContinueBanner(bool isMobile) {
//     final lastTopic = allTopics.firstWhere(
//       (t) => t.slug == _lastTopicSlug,
//       orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', estimatedHours: 0.0, category: '', level: ''),
//     );
//     if (lastTopic.slug.isEmpty) return const SizedBox.shrink();

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [PremiumTheme.success.withValues(alpha: 0.12), PremiumTheme.successBg.withValues(alpha: 0.06)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: PremiumTheme.success.withValues(alpha: 0.25)),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
//             boxShadow: [
//               BoxShadow(color: const Color(0xFF11998E).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
//             ],
//           ),
//           child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
//         ),
//         title: Text('Continue: ${lastTopic.title}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
//         subtitle: const Text('Tap to resume where you left off', style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted)),
//         trailing: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTheme.success.withValues(alpha: 0.12)),
//           child: const Icon(Icons.arrow_forward_rounded, size: 16, color: PremiumTheme.success),
//         ),
//         onTap: () {
//           _saveLastTopic(lastTopic.slug);
//           if (context.mounted) {
//             // ✅ FIXED: Remove /tech from navigation
//             context.go('/${widget.category}/${lastTopic.slug}');
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildSearchSection(bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 16),
//       child: Container(
//         height: 52,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2)),
//           ],
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 16),
//             const Icon(Icons.search, color: PremiumTheme.textLight, size: 20),
//             const SizedBox(width: 10),
//             Expanded(
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: _onSearchChanged,
//                 decoration: const InputDecoration(
//                   hintText: "Search topics...",
//                   hintStyle: TextStyle(color: PremiumTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//             if (_searchQuery.isNotEmpty)
//               IconButton(
//                 icon: const Icon(Icons.clear, size: 18, color: PremiumTheme.textLight),
//                 onPressed: _clearSearch,
//               ),
//             Container(
//               margin: const EdgeInsets.all(6),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//               decoration: BoxDecoration(
//                 color: PremiumTheme.richBlue,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text("Search", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDifficultyFilter(bool isMobile) {
//     final difficulties = _config?.difficulties ?? DifficultyConfig.getDefault();

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: difficulties.map((difficulty) {
//             final isSelected = _selectedDifficulty == difficulty.name;
//             final color = difficulty.colorObj;
//             return Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() => _selectedDifficulty = difficulty.name);
//                   _applyFilters();
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
//                   decoration: BoxDecoration(
//                     color: isSelected ? color : Colors.transparent,
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(color: isSelected ? color : PremiumTheme.lightGray, width: 1.5),
//                     boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (difficulty.icon.isNotEmpty) ...[
//                         Text(difficulty.icon, style: const TextStyle(fontSize: 14)),
//                         const SizedBox(width: 6),
//                       ],
//                       Text(
//                         difficulty.name,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                           color: isSelected ? Colors.white : PremiumTheme.textMuted,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildResultCount(bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
//       child: Text(
//         'Showing $_totalFilteredTopics result${_totalFilteredTopics != 1 ? 's' : ''}',
//         style: const TextStyle(fontSize: 12, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500),
//       ),
//     );
//   }

//   Widget _buildCategoryHeader(String categoryName, bool isMobile) {
//     final categoryConfig = _config?.categories[categoryName.toLowerCase()];
//     final description = categoryConfig?.description ?? _getCategoryDescription(categoryName);
//     final icon = categoryConfig?.icon ?? '';

//     return Padding(
//       padding: EdgeInsets.fromLTRB(isMobile ? 20 : 20, 32, isMobile ? 20 : 20, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               if (icon.isNotEmpty) ...[
//                 Text(icon, style: const TextStyle(fontSize: 28)),
//                 const SizedBox(width: 12),
//               ],
//               Expanded(
//                 child: Text(
//                   categoryName,
//                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PremiumTheme.textDark, letterSpacing: -0.3),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(description, style: const TextStyle(fontSize: 13, color: PremiumTheme.textMuted, height: 1.4)),
//           const SizedBox(height: 12),
//           Container(
//             width: 50,
//             height: 3,
//             decoration: BoxDecoration(
//               gradient: PremiumTheme.elegantGradient,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getCategoryDescription(String categoryName) {
//     switch (categoryName.toLowerCase()) {
//       case 'dart basics':
//         return 'Learn Dart syntax, variables, functions, and OOP concepts.';
//       case 'widgets':
//         return 'Explore Flutter widgets: Stateless, Stateful, and built-in components.';
//       case 'state management':
//         return 'Manage app state with Provider, BLoC, and other patterns.';
//       case 'api integration':
//         return 'Connect to REST APIs, handle JSON, and use HTTP requests.';
//       case 'advanced':
//         return 'Deep dive into animations, custom painters, and performance optimization.';
//       default:
//         return 'Learn $categoryName concepts with practical examples.';
//     }
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(60),
//         child: Column(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTheme.lightGray),
//               child: const Center(child: Icon(Icons.search_off_rounded, size: 40, color: PremiumTheme.textLight)),
//             ),
//             const SizedBox(height: 20),
//             const Text('No topics found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
//             const SizedBox(height: 8),
//             Text(
//               'Try "Widgets", "State Management", or "API"',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: PremiumTheme.textMuted, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSeoFooter(bool isMobile) {
//     final seo = _config?.seo ?? SEOConfig.getDefault();

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 40),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: PremiumTheme.softGray,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: PremiumTheme.lightGray),
//       ),
//       child: Column(
//         children: [
//           Text(seo.emoji, style: const TextStyle(fontSize: 32)),
//           const SizedBox(height: 12),
//           Text(seo.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
//           const SizedBox(height: 12),
//           Text(
//             seo.description,
//             style: TextStyle(fontSize: 13, color: PremiumTheme.textMuted, height: 1.6),
//             textAlign: TextAlign.center,
//           ),
//           if (seo.tags.isNotEmpty) ...[
//             const SizedBox(height: 20),
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               alignment: WrapAlignment.center,
//               children: seo.tags.map((tag) => _buildSeoTag(tag)).toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSeoTag(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray),
//       ),
//       child: Text(text, style: const TextStyle(fontSize: 11, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500)),
//     );
//   }
// }
