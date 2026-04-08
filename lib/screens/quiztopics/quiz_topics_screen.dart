// lib/screens/quiztopics/quiz_topics_screen.dart
import 'dart:async';
import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/screens/quiztopics/quiz_topic_card.dart';

import '../../models/topic_screen_config.dart';
import '../../models/tutorial_topic.dart';
import '../../utils/json_parser.dart';
import '../../core/theme.dart';

// ==================== SEO CONFIGURATION ====================
class QuizTopicSEOConfig {
  final String category;
  final int topicCount;
  final List<String> popularTopics;
  
  QuizTopicSEOConfig({
    required this.category,
    required this.topicCount,
    required this.popularTopics,
  });
  
  String get canonicalUrl => 'https://revochamp.site/mock-interview/${category.toLowerCase()}';
  String get ogImageUrl => 'https://revochamp.site/og-images/mock-interview/${category.toLowerCase()}.png';
  
  String get pageTitle => 
      '${_capitalize(category)} Mock Interview Tests | Practice Technical Interviews | RevoChamp';
  
  String get metaDescription => 
      'Prepare for ${_capitalize(category)} interviews with $topicCount+ mock tests. '
      'Practice ${popularTopics.take(3).join(', ')}, and more. '
      'Get instant AI feedback, detailed explanations, and FAANG-style questions. Free interview preparation.';
  
  List<String> get keywords => [
    category.toLowerCase(),
    '$category mock interview',
    '$category interview questions',
    '$category technical interview',
    'FAANG interview prep',
    'coding interview practice',
    ...popularTopics.map((t) => '$category $t'),
    'free mock interview',
    'interview simulator',
    'technical interview preparation',
  ];
  
  List<Map<String, String>> get faqs => [
    {
      "question": "What ${_capitalize(category)} mock interview tests are available?",
      "answer": "We offer $topicCount+ ${_capitalize(category)} mock interview tests covering ${popularTopics.take(5).join(', ')}. Each test simulates real technical interviews with timed questions, instant feedback, and detailed explanations."
    },
    {
      "question": "How do I prepare for a ${_capitalize(category)} technical interview?",
      "answer": "Start with beginner-friendly mock tests, review the explanations for each answer, and gradually move to advanced tests. Practice regularly, focus on understanding concepts rather than memorization, and use our AI feedback to identify weak areas."
    },
    {
      "question": "Are these ${_capitalize(category)} interview questions similar to FAANG interviews?",
      "answer": "Yes! Our questions are curated by FAANG interviewers and cover the exact topics, difficulty levels, and question patterns used by Google, Meta, Amazon, Apple, and Netflix. Each test includes real-world scenarios and edge cases."
    },
    {
      "question": "How long does each mock interview test take?",
      "answer": "Test durations vary from 15-60 minutes depending on the topic and difficulty level. We recommend completing tests in one sitting to simulate real interview conditions, but you can pause and resume anytime."
    },
    {
      "question": "Will I get a score and feedback after completing a test?",
      "answer": "Absolutely! After each test, you'll receive a comprehensive score report including percentage, points earned, accuracy rate, time taken, and detailed feedback on each question with explanations for correct and incorrect answers."
    },
    {
      "question": "Can I retake the mock interview tests?",
      "answer": "Yes! You can retake any test unlimited times. We recommend spacing out retakes to measure improvement and focusing on understanding the explanations before attempting again."
    },
    {
      "question": "Is this mock interview preparation free?",
      "answer": "Yes! All $topicCount+ ${_capitalize(category)} mock interview tests on RevoChamp are completely free. We believe in democratizing interview preparation and helping developers land their dream jobs."
    },
  ];
  
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class QuizTopicsScreen extends StatefulWidget {
  final String category;

  const QuizTopicsScreen({super.key, required this.category});
  
  // ============ CACHE MANAGEMENT ============
  static final Map<String, List<TutorialTopic>> _cachedTopics = {};
  static final Map<String, QuizTopicSEOConfig> _seoConfigCache = {};
  static bool _globalSEOSetup = false;
  
  static List<TutorialTopic> getTopicsByCategory(String category) {
    return _cachedTopics[category.toLowerCase()] ?? [];
  }
  
  static void clearCache() {
    _cachedTopics.clear();
    _seoConfigCache.clear();
  }

  @override
  State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
}

class _QuizTopicsScreenState extends State<QuizTopicsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  
  @override
  bool get wantKeepAlive => true;

  // Data
  List<TutorialTopic> allTopics = [];
  Map<String, List<TutorialTopic>> groupedTopics = {};
  Map<String, List<TutorialTopic>> groupedFilteredTopics = {};
  late QuizTopicSEOConfig _seoConfig;

  // UI state
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _completedTopics = {};
  bool _isLoading = true;
  String? _lastTopicSlug;
  Timer? _debounce;
  String _selectedDifficulty = 'All';
  String _searchQuery = '';

  ScreenConfig? _config;
  bool _isLoadingConfig = true;

  final ScrollController _scrollController = ScrollController();
  SharedPreferences? _prefs;

  late AnimationController _heroController;
  late Animation<double> _heroAnimation;

  // Pagination
  int _displayCount = 20;
  
  // Analytics
  int _pageLoadStartTime = 0;
  int _scrollDepth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageLoadStartTime = DateTime.now().millisecondsSinceEpoch;
    _seoConfig = QuizTopicSEOConfig(
      category: widget.category,
      topicCount: 0,
      popularTopics: [],
    );
    _setupGlobalSEO();
    _setupPageSEO();
    _loadConfiguration();
    _initAll();
    _setupAnimations();
    _scrollController.addListener(_onScrollWithTracking);
    _trackPageView();
  }

  // ==================== GLOBAL SEO SETUP ====================
  void _setupGlobalSEO() {
    if (!kIsWeb) return;
    if (QuizTopicsScreen._globalSEOSetup) return;
    
    _setDocumentLanguage();
    _addSitemapReference();
    _addPreconnectUrls();
    _setVerificationTags();
    
    QuizTopicsScreen._globalSEOSetup = true;
  }

  void _setDocumentLanguage() {
    if (!kIsWeb) return;
    html.document.documentElement?.lang = 'en';
  }

  void _addSitemapReference() {
    if (!kIsWeb) return;
    
    final existing = html.document.querySelector('link[rel="sitemap"]');
    if (existing != null) return;
    
    final sitemapLink = html.LinkElement()
      ..rel = 'sitemap'
      ..type = 'application/xml'
      ..href = 'https://revochamp.site/sitemap.xml';
    html.document.head?.append(sitemapLink);
  }

  void _addPreconnectUrls() {
    if (!kIsWeb) return;
    
    final urls = [
      'https://json.revochamp.site',
      'https://fonts.googleapis.com',
      'https://fonts.gstatic.com',
    ];
    
    for (final url in urls) {
      final existing = html.document.querySelector('link[rel="preconnect"][href="$url"]');
      if (existing != null) continue;
      
      final link = html.LinkElement()
        ..rel = 'preconnect'
        ..href = url;
      html.document.head?.append(link);
      
      final dnsLink = html.LinkElement()
        ..rel = 'dns-prefetch'
        ..href = url;
      html.document.head?.append(dnsLink);
    }
  }

  void _setVerificationTags() {
    if (!kIsWeb) return;
    
    MetaService.setVerificationTags(
      google: 'YOUR_GOOGLE_VERIFICATION_CODE',
      bing: 'YOUR_BING_VERIFICATION_CODE',
    );
  }

  // ==================== PAGE SEO SETUP ====================
  void _setupPageSEO() {
    if (!kIsWeb) return;
    
    _addH1Tag();
    _updateMetaTags();
  }

  void _addH1Tag() {
    if (!kIsWeb) return;
    
    final existing = html.document.querySelector('.seo-h1');
    existing?.remove();

    final h1 = html.HeadingElement.h1()
      ..text = '${_capitalize(widget.category)} Mock Interview Tests - Technical Interview Preparation'
      ..className = 'seo-h1'
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '-9999px'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.overflow = 'hidden';

    html.document.body?.append(h1);
  }

  void _updateMetaTags() {
    if (!kIsWeb) return;
    
    MetaService.updateMetaTags(
      title: _seoConfig.pageTitle,
      description: _seoConfig.metaDescription,
      slug: 'mock-interview/${widget.category.toLowerCase()}',
      imageUrl: _seoConfig.ogImageUrl,
      keywords: _seoConfig.keywords,
      isArticle: false,
      noIndex: false,
    );
    
    MetaService.setCanonical(_seoConfig.canonicalUrl);
    MetaService.setAlternateLanguage(_seoConfig.canonicalUrl, 'en');
  }

  void _updateSEOBasedOnData() {
    if (!kIsWeb) return;
    
    final popularTopics = allTopics
        .take(8)
        .map((t) => t.title)
        .toList();
    
    setState(() {
      _seoConfig = QuizTopicSEOConfig(
        category: widget.category,
        topicCount: allTopics.length,
        popularTopics: popularTopics,
      );
    });
    
    _updateMetaTags();
    _updateCollectionPageSchema();
    _setBreadcrumbSchema();
    _setFAQSchema();
    _setOrganizationSchema();
  }

  void _updateFilteredMeta(String searchQuery, String difficulty, int resultCount) {
    if (!kIsWeb) return;
    
    if (searchQuery.isNotEmpty) {
      MetaService.updateMetaTags(
        title: 'Search: $searchQuery - ${_capitalize(widget.category)} Mock Interview Tests',
        description: 'Found $resultCount mock interview tests matching "$searchQuery" in ${widget.category}. Practice with AI feedback and detailed explanations.',
        slug: 'mock-interview/${widget.category}',
        isArticle: false,
        noIndex: true,
      );
    } else if (difficulty != 'All') {
      MetaService.updateMetaTags(
        title: '$difficulty Level ${_capitalize(widget.category)} Mock Interview Tests',
        description: 'Practice $difficulty level ${widget.category} interview questions. Perfect for ${difficulty.toLowerCase()} developers preparing for technical interviews.',
        slug: 'mock-interview/${widget.category}',
        isArticle: false,
        noIndex: true,
      );
    } else {
      _updateMetaTags();
    }
    
    MetaService.setCanonical(_seoConfig.canonicalUrl);
  }

  // ==================== SCHEMA.ORG MARKUP ====================
  void _setOrganizationSchema() {
    if (!kIsWeb) return;
    
    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "RevoChamp",
      "url": "https://revochamp.site",
      "logo": "https://revochamp.site/logo.png",
      "description": "Free technical interview preparation and mock interview practice platform",
      "sameAs": [
        "https://twitter.com/revochamp",
        "https://www.linkedin.com/company/revochamp",
      ]
    }, id: 'organization-schema');
  }

  void _updateCollectionPageSchema() {
    if (!kIsWeb) return;
    
    final items = allTopics.take(20).map((topic) {
      return {
        'name': topic.title,
        'url': 'https://revochamp.site/mock-test/${widget.category.toLowerCase()}/${topic.slug}',
        'description': 'Practice ${topic.title} - Mock interview test with AI feedback',
      };
    }).toList();
    
    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "CollectionPage",
      "name": "${_capitalize(widget.category)} Mock Interview Tests",
      "headline": "Practice ${_capitalize(widget.category)} Technical Interviews",
      "description": _seoConfig.metaDescription,
      "url": _seoConfig.canonicalUrl,
      "inLanguage": "en",
      "isPartOf": {
        "@type": "WebSite",
        "name": "RevoChamp",
        "url": "https://revochamp.site"
      },
      "mainEntity": {
        "@type": "ItemList",
        "numberOfItems": allTopics.length,
        "itemListElement": items.asMap().entries.map((entry) => {
          "@type": "ListItem",
          "position": entry.key + 1,
          "item": {
            "@type": "Course",
            "name": entry.value['name'],
            "url": entry.value['url'],
            "description": entry.value['description'],
            "provider": {
              "@type": "Organization",
              "name": "RevoChamp"
            }
          }
        }).toList(),
      },
      "about": {
        "@type": "Thing",
        "name": "${widget.category} Interview Preparation",
        "description": "Technical interview practice for ${widget.category} roles"
      },
      "educationalLevel": ["Beginner", "Intermediate", "Advanced"],
      "teaches": widget.category,
    }, id: 'interview-collection-schema');
  }

  void _setBreadcrumbSchema() {
    if (!kIsWeb) return;
    
    MetaService.setBreadcrumbData(
      title: '${_capitalize(widget.category)} Mock Interview',
      slug: 'mock-interview/${widget.category.toLowerCase()}',
      parents: [
        {'name': 'Home', 'url': 'https://revochamp.site/'},
        {'name': 'Mock Interview', 'url': 'https://revochamp.site/mockinterview'},
      ],
    );
  }

  void _setFAQSchema() {
    if (!kIsWeb) return;
    
    MetaService.setFAQSchemaFromMap(_seoConfig.faqs);
  }

  // ==================== ANALYTICS ====================
  void _trackPageView() {
    if (kReleaseMode) {
      final loadTime = DateTime.now().millisecondsSinceEpoch - _pageLoadStartTime;
      debugPrint('📊 QuizTopicsScreen [${widget.category}] loaded in ${loadTime}ms with ${allTopics.length} topics');
    }
  }

  void _onScrollWithTracking() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    final currentPixels = position.pixels;
    
    final percentage = ((currentPixels / maxExtent) * 100).toInt();
    if (percentage > _scrollDepth) {
      _scrollDepth = percentage;
      if (kReleaseMode && percentage % 25 == 0) {
        debugPrint('📊 Scroll depth: $percentage%');
      }
    }
    
    if (currentPixels >= maxExtent - 300) {
      _loadMore();
    }
  }

  void _trackTopicClick(TutorialTopic topic) {
    if (kReleaseMode) {
      debugPrint('📊 Mock test clicked: ${topic.title}');
    }
  }

  // ==================== LIFECYCLE ====================
  @override
  void didUpdateWidget(covariant QuizTopicsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _pageLoadStartTime = DateTime.now().millisecondsSinceEpoch;
      _seoConfig = QuizTopicSEOConfig(
        category: widget.category,
        topicCount: 0,
        popularTopics: [],
      );
      _setupPageSEO();
      _resetAndReload();
    }
  }

  void _resetAndReload() {
    setState(() {
      _isLoading = true;
      allTopics = [];
      groupedTopics = {};
      groupedFilteredTopics = {};
      _completedTopics.clear();
      _searchQuery = '';
      _searchController.clear();
      _selectedDifficulty = 'All';
      _displayCount = 20;
    });
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScrollWithTracking);
    _scrollController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  // ==================== DATA LOADING ====================
  String getBaseUrl() => 'https://json.revochamp.site/mockinterview/${widget.category}/topics.json';
  String getConfigUrl() => 'https://json.revochamp.site/mockinterview/${widget.category}/config.json';

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    _heroController.forward();
  }

  Future<void> _loadConfiguration() async {
    try {
      final response = await http.get(Uri.parse(getConfigUrl()))
          .timeout(const Duration(seconds: 5));
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

  Future<void> _initAll() async {
    final normalizedCategory = widget.category.toLowerCase();
    
    if (QuizTopicsScreen._cachedTopics.containsKey(normalizedCategory)) {
      _applyData(
        topics: QuizTopicsScreen._cachedTopics[normalizedCategory]!,
        completed: _completedTopics,
        lastTopic: _lastTopicSlug,
      );
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final response = await http.get(Uri.parse(getBaseUrl()))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final topics = await compute(parseTopics, response.body);

      if (topics.isEmpty) {
        throw Exception('No topics found');
      }

      QuizTopicsScreen._cachedTopics[normalizedCategory] = topics;

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
      _showErrorSnackbar('Failed to load interview tests');
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
    final grouped = _groupTopicsSync(topics);
    
    if (mounted) {
      setState(() {
        allTopics = topics;
        groupedTopics = grouped;
        groupedFilteredTopics = grouped;
        _completedTopics.addAll(completed);
        _lastTopicSlug = lastTopic;
        _isLoading = false;
      });
      
      _updateSEOBasedOnData();
    }
  }

  // ==================== PAGINATION & FILTERS ====================
  void _loadMore() {
    if (!mounted) return;
    final totalItems = _getCurrentDisplayTopics().length;
    if (totalItems < _getTotalFilteredCount()) {
      setState(() {
        _displayCount += 20;
      });
      _addPaginationMeta();
    }
  }

  void _addPaginationMeta() {
    if (!kIsWeb) return;
    
    final currentPage = (_displayCount / 20).ceil();
    final totalPages = (_getTotalFilteredCount() / 20).ceil();
    
    html.document.querySelectorAll('link[rel="next"], link[rel="prev"]').forEach((e) => e.remove());
    
    if (currentPage < totalPages) {
      final nextLink = html.LinkElement()
        ..rel = 'next'
        ..href = '${_seoConfig.canonicalUrl}?page=${currentPage + 1}';
      html.document.head?.append(nextLink);
    }
    
    if (currentPage > 1) {
      final prevLink = html.LinkElement()
        ..rel = 'prev'
        ..href = currentPage == 2 ? _seoConfig.canonicalUrl : '${_seoConfig.canonicalUrl}?page=${currentPage - 1}';
      html.document.head?.append(prevLink);
    }
  }

  int _getTotalFilteredCount() {
    return groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);
  }

  List<TutorialTopic> _getCurrentDisplayTopics() {
    final allFiltered = groupedFilteredTopics.values.expand((list) => list).toList();
    return allFiltered.take(_displayCount).toList();
  }

  Map<String, List<TutorialTopic>> _groupTopicsSync(List<TutorialTopic> topics) {
    final map = <String, List<TutorialTopic>>{};
    for (final t in topics) {
      final category = t.category.isNotEmpty ? t.category : 'Mock Interview Tests';
      map.putIfAbsent(category, () => []).add(t);
    }
    // Sort topics within each category
    for (final key in map.keys) {
      map[key]!.sort((a, b) => a.title.compareTo(b.title));
    }
    return map;
  }

  void _applyFilters() {
    if (!mounted) return;
    final query = _searchQuery.trim().toLowerCase();
    final filteredBySearch = query.isEmpty
        ? allTopics
        : allTopics.where((t) => 
            t.title.toLowerCase().contains(query) ||
            t.category.toLowerCase().contains(query)
          ).toList();

    final filtered = _selectedDifficulty == 'All'
        ? filteredBySearch
        : filteredBySearch.where((t) => t.level == _selectedDifficulty).toList();

    final grouped = _groupTopicsSync(filtered);

    setState(() {
      groupedFilteredTopics = grouped;
      _displayCount = 20;
    });
    
    _updateFilteredMeta(query, _selectedDifficulty, filtered.length);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
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

  // ==================== PERSISTENCE ====================
  Future<void> _saveLastTopic(String slug) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString('last_topic_${widget.category}', slug);
  }

  Future<void> _saveCompletedTopics() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setStringList('completed_${widget.category}', _completedTopics.toList());
  }

  // ==================== SHARING & UTILITIES ====================
  void _shareTopicsPage() {
    final url = _seoConfig.canonicalUrl;
    final title = '${_capitalize(widget.category)} Mock Interview Tests - RevoChamp';
    
    if (kIsWeb) {
      html.window.navigator.share!({
        'title': title,
        'text': 'Practice ${widget.category} interviews with AI feedback!',
        'url': url,
      }).catchError((_) => _copyToClipboard(url));
    } else {
      _copyToClipboard(url);
    }
  }

  void _copyToClipboard(String text) {
    if (kIsWeb) {
      html.window.navigator.clipboard?.writeText(text);
    }
    _showSnackBar('📋 Link copied to clipboard!');
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
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

  double get _progress =>
      allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 4;
    if (width >= 1000) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getLastUpdatedDate() {
    return _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, String>> _getRelatedCategories() {
    final relations = {
      'frontend': [
        {'name': 'React Interview', 'slug': 'react'},
        {'name': 'JavaScript Interview', 'slug': 'javascript'},
        {'name': 'CSS Interview', 'slug': 'css'},
      ],
      'backend': [
        {'name': 'System Design', 'slug': 'system-design'},
        {'name': 'Database Interview', 'slug': 'database'},
        {'name': 'API Design', 'slug': 'api-design'},
      ],
    };
    
    return relations[widget.category.toLowerCase()] ?? [];
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final crossAxisCount = _getGridCrossAxisCount(context);
    final mobile = isMobile;
    final features = _config?.features ?? FeatureFlags.getDefault();
    final displayTopics = _getCurrentDisplayTopics();
    final hasMore = displayTopics.length < _getTotalFilteredCount();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading || _isLoadingConfig
          ? _buildSkeletonLoader(mobile)
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(mobile),
                SliverToBoxAdapter(child: _buildBreadcrumbs(mobile)),
                if (features.showHeroSection)
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _heroAnimation,
                      child: _buildHeroSection(mobile),
                    ),
                  ),
                if (features.showProgressSection && allTopics.isNotEmpty)
                  SliverToBoxAdapter(child: _buildProgressSection(mobile)),
                if (features.showStatsSection && allTopics.isNotEmpty)
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
                  ..._buildGroupedContent(crossAxisCount, mobile, displayTopics),
                if (hasMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
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
              backgroundColor: const Color(0xffea580c),
              child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSkeletonLoader(bool isMobile) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(isMobile),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(height: 40, width: 200),
                const SizedBox(height: 20),
                _buildSkeletonBox(height: 120),
                const SizedBox(height: 30),
                ...List.generate(3, (_) => _buildSkeletonBox(height: 80)),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  List<Widget> _buildGroupedContent(int crossAxisCount, bool mobile, List<TutorialTopic> displayTopics) {
    final Map<String, List<TutorialTopic>> groupedDisplay = {};
    for (final topic in displayTopics) {
      final category = topic.category.isNotEmpty ? topic.category : 'Mock Interview Tests';
      groupedDisplay.putIfAbsent(category, () => []).add(topic);
    }

    return groupedDisplay.entries.expand((entry) {
      final categoryName = entry.key;
      final topicsInCategory = entry.value;
      
      return [
        SliverToBoxAdapter(
          child: _buildCategoryHeader(categoryName, mobile),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final topic = topicsInCategory[index];
                final isCompleted = _completedTopics.contains(topic.slug);
                return QuizTopicCard(
                  topic: topic,
                  isCompleted: isCompleted,
                  onTap: () async {
                    _trackTopicClick(topic);
                    if (!_completedTopics.contains(topic.slug)) {
                      setState(() {
                        _completedTopics.add(topic.slug);
                      });
                      await _saveCompletedTopics();
                    }
                    await _saveLastTopic(topic.slug);
                    if (context.mounted) {
                      context.go('/mock-test/${widget.category}/${topic.slug}');
                    }
                  },
                );
              },
              childCount: topicsInCategory.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ];
    }).toList();
  }

  SliverAppBar _buildAppBar(bool isMobile) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
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
            onPressed: () => context.go('/'),
            child: const Text("Home", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          TextButton(
            onPressed: () => context.go('/mockinterview'),
            child: const Text("Mock Interview", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
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
              colors: [Color(0xffea580c), Color(0xff9a3412)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffea580c).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(child: Text("MI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 10),
        const Text("RevoChamp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
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
            onTap: () => context.go('/mockinterview'),
            child: Text('Mock Interview', style: TextStyle(color: PremiumTheme.richBlue, fontSize: 13)),
          ),
          const Icon(Icons.chevron_right, size: 16, color: PremiumTheme.textLight),
          Text(
            _capitalize(widget.category),
            style: TextStyle(color: PremiumTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
          ),
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
            const Color(0xffea580c).withValues(alpha: 0.05),
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
              color: const Color(0xffea580c),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffea580c).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '🎯 ${allTopics.length}+ Mock Tests Available',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Master ${_capitalize(widget.category)}',
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
              colors: [Color(0xffea580c), Color(0xff9a3412)],
            ).createShader(bounds),
            child: Text(
              'Technical Interviews',
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
              'Practice with ${allTopics.length}+ realistic ${widget.category} interview scenarios. Get instant AI feedback, detailed explanations, and track your progress. Prepare for FAANG interviews with confidence.',
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
    final avgTime = 30; // Average 30 minutes per test
    
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
          _buildStatItem("$totalTopics", "Tests"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("$completedCount", "Completed"),
          Container(width: 1, height: 30, color: PremiumTheme.lightGray),
          _buildStatItem("~$avgTime", "Min/Test"),
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
              const Text('Your Practice Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xffea580c), Color(0xff9a3412)]),
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
              color: const Color(0xffea580c),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _progress > 0.8
                ? "🎉 You're almost interview-ready! Keep practicing!"
                : _progress > 0.3
                ? "💪 Great progress! Continue building your confidence."
                : "🚀 Start practicing to ace your technical interviews!",
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
          colors: [const Color(0xffea580c).withValues(alpha: 0.12), Colors.orange.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffea580c).withValues(alpha: 0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xffea580c), Color(0xff9a3412)]),
            boxShadow: [
              BoxShadow(color: const Color(0xffea580c).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        ),
        title: Text('Continue: ${lastTopic.title}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: PremiumTheme.textDark)),
        subtitle: const Text('Resume your mock interview practice', style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted)),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffea580c).withValues(alpha: 0.12)),
          child: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xffea580c)),
        ),
        onTap: () {
          _saveLastTopic(lastTopic.slug);
          if (context.mounted) {
            context.go('/mock-test/${widget.category}/${lastTopic.slug}');
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
                decoration: InputDecoration(
                  hintText: "Search ${allTopics.length}+ interview tests...",
                  hintStyle: const TextStyle(color: PremiumTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
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
                color: const Color(0xffea580c),
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
          children: [
            _buildLevelChip('All Levels', _selectedDifficulty == 'All', () {
              setState(() => _selectedDifficulty = 'All');
              _applyFilters();
            }),
            const SizedBox(width: 10),
            ...difficulties.map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty.name;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildLevelChip(
                  difficulty.name,
                  isSelected,
                  () {
                    setState(() => _selectedDifficulty = difficulty.name);
                    _applyFilters();
                  },
                  icon: difficulty.icon,
                  color: difficulty.colorObj,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(String label, bool isSelected, VoidCallback onTap, {String? icon, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? const Color(0xffea580c)) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? (color ?? const Color(0xffea580c)) : PremiumTheme.lightGray,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (color ?? const Color(0xffea580c)).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : PremiumTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCount(bool isMobile) {
    final total = _getTotalFilteredCount();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
      child: Text(
        'Showing $total test${total != 1 ? 's' : ''}',
        style: const TextStyle(fontSize: 12, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCategoryHeader(String categoryName, bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 20, 32, isMobile ? 20 : 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: PremiumTheme.textDark, letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xffea580c), Color(0xff9a3412)]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
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
            const Text('No interview tests found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
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
          const Text('Explore More Interview Topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: relatedCategories.map((category) {
              return ActionChip(
                label: Text(category['name']!),
                onPressed: () {
                  context.go('/mock-interview/${category['slug']}');
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
          Text(
            seo.title.replaceAll('{category}', _capitalize(widget.category)),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            seo.description.replaceAll('{category}', widget.category),
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