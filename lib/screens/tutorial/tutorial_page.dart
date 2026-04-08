// ==================== ENHANCED TUTORIAL PAGE - PRODUCTION READY ====================
// Comprehensive improvements for SEO, design, layout, and functionality

import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:techtutorial/screens/tutorial/content_widget.dart';

import '../../core/meta_service.dart';
import '../../core/theme.dart';
import '../../models/content_item.dart';
import '../../models/quiz_question.dart';
import '../../models/tutorial_data.dart';
import '../../models/tutorial_topic.dart';
import 'editor_widget.dart';
import 'quiz_widgets.dart';
import 'package:http/http.dart' as http;

// ==================== ANALYTICS & TRACKING ====================
class TutorialAnalytics {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> trackTutorialView(
    String category,
    String slug,
    String title,
  ) async {
    await _analytics.logEvent(
      name: 'tutorial_viewed',
      parameters: {
        'tutorial_id': '$category/$slug',
        'title': title,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> trackSectionCompleted(
    String slug,
    String sectionTitle,
    int scrollProgress,
  ) async {
    await _analytics.logEvent(
      name: 'section_completed',
      parameters: {
        'tutorial_id': slug,
        'section': sectionTitle,
        'progress_percent': scrollProgress,
      },
    );
  }

  static Future<void> trackQuizSubmitted(
    String slug,
    int score,
    int total,
  ) async {
    await _analytics.logEvent(
      name: 'quiz_submitted',
      parameters: {
        'tutorial_id': slug,
        'score': score,
        'total': total,
        'percentage': (score / total * 100).toInt(),
      },
    );
  }

  static Future<void> trackCodeCopied(String slug, String language) async {
    await _analytics.logEvent(
      name: 'code_copied',
      parameters: {
        'tutorial_id': slug,
        'language': language,
      },
    );
  }
}

// ==================== USER PROGRESS TRACKING ====================
class UserProgressManager {
  static Future<void> saveProgress(
    String slug,
    int scrollProgress,
    List<int?> quizAnswers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(
      'progress_$slug',
      jsonEncode({
        'slug': slug,
        'scrollProgress': scrollProgress,
        'quizAnswers': quizAnswers,
        'lastAccessed': DateTime.now().toIso8601String(),
        'completed': scrollProgress >= 90,
      }),
    );
  }

  static Future<Map<String, dynamic>?> loadProgress(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('progress_$slug');
    return data != null ? jsonDecode(data) : null;
  }

  static Future<void> updateStudyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccess = prefs.getString('last_access');
    final today = DateTime.now().toString().split(' ')[0];
    
    if (lastAccess == null) {
      await prefs.setInt('current_streak', 1);
    } else if (lastAccess != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toString()
          .split(' ')[0];
      if (lastAccess == yesterday) {
        final streak = prefs.getInt('current_streak') ?? 0;
        await prefs.setInt('current_streak', streak + 1);
      } else {
        await prefs.setInt('current_streak', 1);
      }
    }
    
    await prefs.setString('last_access', today);
  }
}

// ==================== TUTORIAL ARGUMENTS ====================
class TutorialArguments {
  final String slug;
  final String category;
  final List<TutorialTopic> allTopics;

  TutorialArguments({
    required this.slug,
    required this.category,
    required this.allTopics,
  });
}

// ==================== MAIN TUTORIAL PAGE ====================
class TutorialPage extends StatefulWidget {
  final TutorialArguments args;
  const TutorialPage({super.key, required this.args});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>
    with SingleTickerProviderStateMixin {
  static final LinkedHashMap<String, TutorialData> _cache = LinkedHashMap();
  static const int _maxCacheSize = 20;

  String get tutorialsBaseUrl =>
      'https://json.revochamp.site/${widget.args.category}/';

  // Core data
  TutorialData? _data;
  bool _isLoading = true;
  String? _error;

  // Quiz state
  List<QuizQuestionState> _quizStates = [];
  bool _quizSubmitted = false;
  int _score = 0;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final TextEditingController _codeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _sideMenuController = ScrollController();

  // Tracking
  final List<GlobalKey> _headingKeys = [];
  double _scrollProgress = 0.0;
  int _currentSectionIndex = 0;
  bool _isFavorite = false;

  // Study stats
  int _studyStreak = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTutorial();
    _setupScrollListeners();
    _checkFavorite();
    _loadStudyStreak();
    _trackTutorialView();
    UserProgressManager.updateStudyStreak();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  void _setupScrollListeners() {
    _scrollController.addListener(_updateScrollProgress);
    _scrollController.addListener(_updateActiveHeading);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.removeListener(_updateActiveHeading);
    _scrollController.dispose();
    _sideMenuController.dispose();
    super.dispose();
  }

  // ==================== SCROLL TRACKING ====================
  void _updateScrollProgress() {
    if (!mounted || !_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final progress = _scrollController.offset / maxScroll;
    if ((_scrollProgress - progress).abs() > 0.01) {
      setState(() => _scrollProgress = progress);
      
      // Save progress periodically
      if (progress % 0.1 < 0.01) {
        UserProgressManager.saveProgress(
          widget.args.slug,
          (progress * 100).toInt(),
          _quizStates.map((s) => s.selectedAnswer).toList(),
        );
      }
    }
  }

  void _updateActiveHeading() {
    if (!mounted || _headingKeys.isEmpty) return;
    
    int activeIndex = 0;
    for (int i = 0; i < _headingKeys.length; i++) {
      final context = _headingKeys[i].currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position > 0 && position < 250) {
            activeIndex = i;
            break;
          }
        }
      }
    }
    
    if (_currentSectionIndex != activeIndex) {
      setState(() => _currentSectionIndex = activeIndex);
      TutorialAnalytics.trackSectionCompleted(
        widget.args.slug,
        _headings[activeIndex].value,
        (_scrollProgress * 100).toInt(),
      );
      
      _animateSidebarScroll(activeIndex);
    }
  }

  void _animateSidebarScroll(int index) {
    if (!_sideMenuController.hasClients) return;
    
    final double itemHeight = 48.0;
    final double targetOffset = (index * itemHeight) - 
        _sideMenuController.position.viewportDimension / 2;
    
    _sideMenuController.animateTo(
      targetOffset.clamp(0.0, _sideMenuController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ==================== FAVORITES & PREFERENCES ====================
  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains('${widget.args.category}/${widget.args.slug}');
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    final key = '${widget.args.category}/${widget.args.slug}';
    
    if (_isFavorite) {
      favorites.remove(key);
      _showSnackBar('Removed from favorites');
    } else {
      favorites.add(key);
      _showSnackBar('Added to favorites');
    }
    
    await prefs.setStringList('favorites', favorites);
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _loadStudyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studyStreak = prefs.getInt('current_streak') ?? 0;
    });
  }

  // ==================== TRACKING & SEO ====================
  void _trackTutorialView() {
    TutorialAnalytics.trackTutorialView(
      widget.args.category,
      widget.args.slug,
      _data?.title ?? '',
    );
  }

  Future<void> _loadTutorial() async {
    final slug = widget.args.slug;
    if (slug.isEmpty) {
      setState(() {
        _error = 'Invalid tutorial slug.';
        _isLoading = false;
      });
      return;
    }

    try {
      if (_cache.containsKey(slug)) {
        _data = _cache[slug];
      } else {
        final url = Uri.parse('$tutorialsBaseUrl$slug.json');
        debugPrint('Loading tutorial from: $url');
        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response('Timeout', 408),
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          _data = _parseTutorialData(json);
          _cache[slug] = _data!;
          if (_cache.length > _maxCacheSize) {
            _cache.remove(_cache.keys.first);
          }
        } else {
          setState(() {
            _error = 'Failed to load tutorial: HTTP ${response.statusCode}';
            _isLoading = false;
          });
          return;
        }
      }
      
      _initializeFromData();
      setState(() => _isLoading = false);
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = 'Failed to load tutorial: $e';
        _isLoading = false;
      });
    }
  }

  TutorialData _parseTutorialData(Map<String, dynamic> json) {
    final contentList = <ContentItem>[];
    try {
      for (var item in json['content'] ?? []) {
        final type = item['type'];
        final value = item['value'];
        
        switch (type) {
          case 'heading':
            contentList.add(
              ContentItem(type: ContentType.heading, value: value as String),
            );
          case 'subheading':
            contentList.add(
              ContentItem(type: ContentType.subheading, value: value as String),
            );
          case 'text':
            contentList.add(
              ContentItem(type: ContentType.text, value: value as String),
            );
          case 'code':
            contentList.add(
              ContentItem(
                type: ContentType.code,
                value: value as String,
                language: item['language'],
              ),
            );
          case 'list':
            final listItems = value is List
                ? value.map((e) => e.toString()).toList()
                : (value as String)
                    .split('\n')
                    .where((l) => l.trim().isNotEmpty)
                    .toList();
            contentList.add(
              ContentItem(type: ContentType.list, value: listItems),
            );
          case 'table':
            contentList.add(
              ContentItem(
                type: ContentType.table,
                value: '',
                tableData: item['value'] as Map<String, dynamic>?,
              ),
            );
          case 'callout':
            contentList.add(
              ContentItem(
                type: ContentType.callout,
                value: value as String,
                variant: item['variant'] as String? ?? 'info',
              ),
            );
        }
      }
    } catch (e) {
      debugPrint('Error parsing content: $e');
    }

    final quizList = <QuizQuestion>[];
    try {
      for (var q in json['quiz'] ?? []) {
        quizList.add(
          QuizQuestion(
            question: q['question'],
            options: List<String>.from(q['options']),
            answer: q['answer'],
            explanation: q['explanation'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error parsing quiz: $e');
    }

    return TutorialData(
      title: json['title'] ?? 'Untitled',
      subtitle: json['subtitle'] ?? '',
      difficulty: json['difficulty'] ?? '',
      readTime: json['readTime'] ?? '',
      meta: json['meta'],
      faq: (json['faq'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      content: contentList,
      quiz: quizList,
      defaultCode: json['tryEditor']?['defaultCode'] ?? '',
      relatedSlugs: (json['related'] as List?)?.cast<String>() ?? [],
    );
  }

  // ==================== CONSOLIDATED SEO INJECTION ====================
  void _injectFullContent() {
    if (!kIsWeb) return;

    // Remove any previously injected hidden SEO container
    html.document.querySelector('#seo-hidden-content')?.remove();

    final container = html.DivElement()
      ..id = 'seo-hidden-content'
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '-9999px'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.overflow = 'hidden';

    // H1 title
    container.append(html.HeadingElement.h1()..text = _data!.title);

    // All content sections (headings, text, code)
    for (final item in _data!.content) {
      if (item.type == ContentType.heading) {
        container.append(html.HeadingElement.h2()..text = item.value);
      } else if (item.type == ContentType.subheading) {
        container.append(html.HeadingElement.h3()..text = item.value);
      } else if (item.type == ContentType.text) {
        container.append(html.ParagraphElement()..text = item.value);
      } else if (item.type == ContentType.code) {
        final pre = html.PreElement()..text = item.value;
        container.append(pre);
      }
    }

    // FAQ content
    for (final faq in _data!.faq) {
      container.append(html.HeadingElement.h3()..text = faq['question'] ?? '');
      container.append(html.ParagraphElement()..text = faq['answer'] ?? '');
    }

    // Internal links (related tutorials)
    for (final slug in _data!.relatedSlugs) {
      final a = html.AnchorElement()
        ..href = '/${widget.args.category}/$slug'
        ..text = slug;
      container.append(a);
    }

    html.document.body?.append(container);
  }

  void _initializeFromData() {
    if (_data == null) return;
    
    _quizStates = List.generate(_data!.quiz.length, (_) => QuizQuestionState());
    _codeController.text = _data!.defaultCode;
    
    _headingKeys.clear();
    for (var i = 0; i < _data!.content.length; i++) {
      if (_data!.content[i].type == ContentType.heading) {
        _headingKeys.add(GlobalKey());
      }
    }
    
    // ✅ Enable all meta tags and structured data
    _updateComprehensiveSeo();
    _updateAdvancedStructuredData();
    
    // ✅ Single injection method
    _injectFullContent();
    
    if (kIsWeb) {
      _addHiddenH1(_data!.title);
      _setupBreadcrumbs();
    }
  }

  // ==================== ADVANCED SEO (META TAGS ENABLED) ====================
  void _updateComprehensiveSeo() {
    final baseUrl = 'https://revochamp.site/tech';
    final pageUrl = '$baseUrl/${widget.args.category}/${widget.args.slug}';
    final imageUrl = _data!.meta?['image'] ?? '$baseUrl/og-default.png';

    // Basic meta (title, description, keywords)
    MetaService.updateMetaTags(
      title: '${_data!.title} - Learn ${widget.args.category.toUpperCase()} | Revochamp',
      description: _generateSeoDescription(),
      slug: '${widget.args.category}/${widget.args.slug}',
      keywords: _generateKeywords(),
      isArticle: true,
      imageUrl: imageUrl,
    );

    // Open Graph
    MetaService.setOGTags(
      title: _data!.title,
      description: _generateSeoDescription(),
      image: imageUrl,
      url: pageUrl,
    );

    // Twitter Card
    MetaService.setTwitterTags(
      // card: 'summary_large_image',
      title: _data!.title,
      description: _generateSeoDescription(),
      image: imageUrl,
    );

    // Canonical URL
    MetaService.setCanonical(pageUrl);
    
    // Robots meta
    MetaService.setRobotsMeta('index, follow, max-image-preview:large');
  }

  void _updateAdvancedStructuredData() {
    final baseUrl = 'https://revochamp.site';
    final pageUrl = '$baseUrl/tech/${widget.args.category}/${widget.args.slug}';
    
    final schemaGraph = [
      // Article
      {
        "@context": "https://schema.org",
        "@type": "TechArticle",
        "@id": pageUrl,
        "headline": _data!.title,
        "description": _generateSeoDescription(),
        "image": {
          "@type": "ImageObject",
          "url": _data!.meta?['image'] ?? "$baseUrl/og-default.png",
        },
        "author": {
          "@type": "Organization",
          "name": "Revochamp",
          "url": baseUrl,
        },
        "datePublished": _data!.meta?['datePublished'] ?? DateTime.now().toIso8601String(),
        "dateModified": _data!.meta?['dateModified'] ?? DateTime.now().toIso8601String(),
        "articleBody": _extractArticleBody(),
        "learningResourceType": "Tutorial",
      },

      // Breadcrumb
      {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
          {
            "@type": "ListItem",
            "position": 1,
            "name": "Home",
            "item": baseUrl,
          },
          {
            "@type": "ListItem",
            "position": 2,
            "name": widget.args.category.toUpperCase(),
            "item": "$baseUrl/tech/${widget.args.category}",
          },
          {
            "@type": "ListItem",
            "position": 3,
            "name": _data!.title,
            "item": pageUrl,
          },
        ],
      },

      // FAQ if exists
      if (_data!.faq.isNotEmpty)
        {
          "@context": "https://schema.org",
          "@type": "FAQPage",
          "mainEntity": _data!.faq
              .map((f) => {
                "@type": "Question",
                "name": f['question'],
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text": f['answer'],
                },
              })
              .toList(),
        },
    ];

    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@graph": schemaGraph,
    });
  }

  String _generateSeoDescription() {
    if (_data!.content.isEmpty) {
      return 'Master ${_data!.title} with interactive examples and quizzes.';
    }
    
    final firstText = _data!.content
        .firstWhere((item) => item.type == ContentType.text,
            orElse: () => ContentItem(type: ContentType.text, value: ''))
        .value
        .replaceAll(RegExp(r'[*_#\[\]()]'), '');
    
    return firstText.substring(0, min(155, firstText.length)) + '...';
  }

  List<String> _generateKeywords() {
    return [
      _data!.title.toLowerCase(),
      widget.args.category,
      'tutorial',
      'learn',
      'interactive',
      ..._extractKeywordsFromContent(),
    ];
  }

  List<dynamic> _extractKeywordsFromContent() {
    return _data!.content
        .where((item) => item.type == ContentType.heading)
        .map((item) => item.value.toLowerCase())
        .take(5)
        .toList();
  }

  String _extractArticleBody() {
    return _data!.content
        .where((item) => item.type == ContentType.text)
        .map((item) => item.value)
        .join('\n\n')
        .substring(0, min(5000, _data!.content.length));
  }

  void _addHiddenH1(String text) {
    final existing = html.document.querySelector('h1.seo-hidden');
    existing?.remove();

    final h1 = html.HeadingElement.h1()
      ..text = text
      ..className = 'seo-hidden'
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '-9999px'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.overflow = 'hidden';

    html.document.body?.append(h1);
  }

  void _setupBreadcrumbs() {
    if (!kIsWeb) return;
    
    final parents = [
      {
        'name': '${widget.args.category.toUpperCase()} Tutorials',
        'url': 'https://revochamp.site/tech/${widget.args.category}',
      },
    ];
    
    MetaService.setBreadcrumbData(
      title: _data!.title,
      slug: '${widget.args.category}/${widget.args.slug}',
      parents: parents,
    );
  }

  // ==================== QUIZ FUNCTIONALITY ====================
  void _submitQuiz() {
    if (_quizStates.any((state) => state.selectedAnswer == null)) {
      _showSnackBar('Please answer all questions');
      return;
    }

    int score = 0;
    for (int i = 0; i < _data!.quiz.length; i++) {
      final isCorrect = _quizStates[i].selectedAnswer == _data!.quiz[i].answer;
      _quizStates[i].isCorrect = isCorrect;
      _quizStates[i].explanation = _data!.quiz[i].explanation;
      if (isCorrect) score++;
    }

    setState(() {
      _score = score;
      _quizSubmitted = true;
    });
    
    TutorialAnalytics.trackQuizSubmitted(widget.args.slug, score, _data!.quiz.length);
    _markCompleted();
  }

  Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completed_${widget.args.category}';
    final completed = prefs.getStringList(key) ?? [];
    if (!completed.contains(widget.args.slug)) {
      completed.add(widget.args.slug);
      await prefs.setStringList(key, completed);
    }
  }

  void _resetQuiz() {
    setState(() {
      _quizStates = List.generate(
        _data!.quiz.length,
        (_) => QuizQuestionState(),
      );
      _quizSubmitted = false;
      _score = 0;
    });
  }

  // ==================== CODE & COPY ====================
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('Copied to clipboard');
    TutorialAnalytics.trackCodeCopied(widget.args.slug, 'unknown');
  }

  // ==================== NAVIGATION ====================
  void _goToPrevious() {
    final topics = widget.args.allTopics;
    if (topics.isEmpty) {
      _showSnackBar('Loading topics... please wait');
      return;
    }
    final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);

    if (currentIndex > 0) {
      context.go('/${widget.args.category}/${topics[currentIndex - 1].slug}');
    } else {
      _showSnackBar('This is the first tutorial');
    }
  }

  void _goToNext() {
    final topics = widget.args.allTopics;
    if (topics.isEmpty) {
      _showSnackBar('Loading topics... please wait');
      return;
    }
    final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);

    if (currentIndex < topics.length - 1) {
      context.go('/${widget.args.category}/${topics[currentIndex + 1].slug}');
    } else {
      _showSnackBar('🎉 Congratulations! You completed all tutorials!');
    }
  }

  void _shareTutorial() {
    final url =
        'https://revochamp.site/tech/${widget.args.category}/${widget.args.slug}';
    final title = _data!.title;

    if (kIsWeb && html.window.navigator.share != null) {
      html.window.navigator.share!({'title': title, 'url': url})
          .catchError((_) => _fallbackShare(url));
    } else {
      _fallbackShare(url);
    }
  }

  void _fallbackShare(String url) {
    Clipboard.setData(ClipboardData(text: url));
    _showSnackBar('Link copied to clipboard!');
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

  List<ContentItem> get _headings {
    if (_data == null) return [];
    return _data!.content
        .where((item) => item.type == ContentType.heading)
        .toList();
  }

  void _scrollToHeading(int index) {
    if (index < _headingKeys.length && _headingKeys[index].currentContext != null) {
      Scrollable.ensureVisible(
        _headingKeys[index].currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentSectionIndex = index);
    }
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_error != null) return _buildErrorScreen();
    if (_data == null) return _buildErrorScreen();

    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _data?.title ?? 'Tutorial',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/${widget.args.category}');
          }
        },
      ),
      actions: [
        if (_studyStreak > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '$_studyStreak day streak',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: _shareTutorial,
          tooltip: 'Share',
        ),
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: LinearProgressIndicator(
          value: _scrollProgress,
          minHeight: 2,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation(PremiumTheme.richBlue),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading tutorial...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadTutorial();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftSidebar(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEnhancedHeroHeader(),
                  const SizedBox(height: 40),
                  ..._buildContentItems(),
                  const SizedBox(height: 50),
                  _buildEditorSection(),
                  const SizedBox(height: 50),
                  if (_data!.quiz.isNotEmpty) _buildQuizSection(),
                  if (_data!.faq.isNotEmpty) _buildFaqSection(),
                  const SizedBox(height: 40),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
        _buildRightSidebar(),
      ],
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: PremiumTheme.richBlue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Contents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: PremiumTheme.richBlue.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_headings.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumTheme.richBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _sideMenuController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _headings.length,
              itemBuilder: (context, index) {
                final item = _headings[index];
                final isActive = index == _currentSectionIndex;
                return _buildSidebarItem(item.value, index, isActive);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 12)),
                    Text(
                      '${(_scrollProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.richBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _scrollProgress,
                  backgroundColor: Colors.grey.shade200,
                  color: PremiumTheme.richBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Links',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PremiumTheme.textLight,
              ),
            ),
            const SizedBox(height: 16),
            ..._data!.relatedSlugs.take(4).map((slug) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => context.go('/${widget.args.category}/$slug'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_forward, size: 14, color: PremiumTheme.richBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          slug.replaceAll('-', ' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: PremiumTheme.richBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.go('/${widget.args.category}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.args.category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PremiumTheme.richBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _data!.title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (_data!.subtitle.isNotEmpty)
          Text(
            _data!.subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            if (_data!.difficulty.isNotEmpty)
              _buildMetaChip(
                icon: Icons.signal_cellular_alt,
                label: _data!.difficulty,
              ),
            if (_data!.readTime.isNotEmpty)
              _buildMetaChip(
                icon: Icons.access_time,
                label: _data!.readTime,
              ),
            _buildMetaChip(
              icon: Icons.quiz,
              label: '${_data!.quiz.length} Quizzes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, int index, bool isActive) {
    return InkWell(
      onTap: () => _scrollToHeading(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? PremiumTheme.richBlue.withValues(alpha:0.05) : null,
          border: Border(
            left: BorderSide(
              color: isActive ? PremiumTheme.richBlue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? PremiumTheme.richBlue : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedHeroHeader(),
          const SizedBox(height: 24),
          if (_headings.isNotEmpty) _buildMobileToc(),
          const SizedBox(height: 24),
          ..._buildContentItems(),
          const SizedBox(height: 24),
          _buildEditorSection(),
          const SizedBox(height: 32),
          if (_data!.quiz.isNotEmpty) _buildQuizSection(),
          if (_data!.faq.isNotEmpty) _buildFaqSection(),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildMobileToc() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In this tutorial',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _headings.asMap().entries.map((entry) {
              final idx = entry.key;
              final heading = entry.value;
              return GestureDetector(
                onTap: () => _scrollToHeading(idx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    heading.value,
                    style: TextStyle(fontSize: 12, color: PremiumTheme.richBlue),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentItems() {
    List<Widget> widgets = [];
    int headingIdx = 0;

    for (int i = 0; i < _data!.content.length; i++) {
      final item = _data!.content[i];
      
      if (item.type == ContentType.heading) {
        widgets.add(
          Container(
            key: headingIdx < _headingKeys.length ? _headingKeys[headingIdx] : null,
            margin: const EdgeInsets.only(top: 24, bottom: 12),
            child: ContentItemWidget(item: item, onCopy: _copyCode),
          ),
        );
        headingIdx++;
      } else {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ContentItemWidget(item: item, onCopy: _copyCode),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildEditorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.edit_note,
          title: 'Try it Yourself',
          subtitle: 'Experiment with the code below',
        ),
        const SizedBox(height: 20),
        EditorWidget(
          codeController: _codeController,
          defaultCode: _data!.defaultCode,
          onCopy: _copyCode,
          onRun: () => _showSnackBar('Running your code...'),
          onReset: () => setState(() => _codeController.text = _data!.defaultCode),
        ),
      ],
    );
  }

  Widget _buildQuizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.quiz,
          title: 'Test Your Knowledge',
          subtitle: '${_data!.quiz.length} questions',
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < _data!.quiz.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: QuizCard(
              index: i,
              total: _data!.quiz.length,
              question: _data!.quiz[i],
              state: _quizStates[i],
              submitted: _quizSubmitted,
              onAnswerSelected: (answerIndex) {
                if (!_quizSubmitted) {
                  setState(() => _quizStates[i].selectedAnswer = answerIndex);
                }
              },
            ),
          ),
        if (_quizSubmitted)
          ScoreCard(score: _score, total: _data!.quiz.length),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.richBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Submit Answers'),
              ),
            ),
            if (_quizSubmitted) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetQuiz,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.help,
          title: 'Frequently Asked Questions',
          subtitle: 'Common questions about this topic',
        ),
        const SizedBox(height: 20),
        ..._data!.faq.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ExpansionTile(
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: PremiumTheme.richBlue.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: PremiumTheme.richBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                item['question'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    item['answer'] ?? '',
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: PremiumTheme.richBlue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final topics = widget.args.allTopics;
    final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);
    final isFirst = currentIndex <= 0;
    final isLast = currentIndex >= topics.length - 1;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isFirst ? null : _goToPrevious,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLast ? null : _goToNext,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(isLast ? 'Completed' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLast ? Colors.green : PremiumTheme.richBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}