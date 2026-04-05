import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtutorial/screens/AdsenseAd.dart';
import 'package:techtutorial/screens/tutorial/content_widget.dart';

import '../../core/meta_service.dart';
import '../../models/content_item.dart';
import '../../models/quiz_question.dart';
import '../../models/tutorial_data.dart';
import '../../models/tutorial_topic.dart';
import 'editor_widget.dart';
import 'quiz_widgets.dart';
import 'package:http/http.dart' as http;

// ─── Design tokens ────────────────────────────────────────────────────────────
const _navy = Color(0xFF0A0F1E);
const _surface = Color(0xFF111827);
const _card = Color(0xFF1A2235);
const _accent = Color(0xFF3B82F6);
const _accentGlow = Color(0xFF60A5FA);
const _accentSoft = Color(0xFF1D3461);
const _success = Color(0xFF10B981);
const _border = Color(0xFF1E2D45);
const _textPrimary = Color(0xFFE2E8F0);
const _textSecondary = Color(0xFF94A3B8);
const _textMuted = Color(0xFF475569);

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

  TutorialData? _data;
  bool _isLoading = true;
  String? _error;

  List<QuizQuestionState> _quizStates = [];
  bool _quizSubmitted = false;
  int _score = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _codeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _sideMenuController = ScrollController();

  final List<GlobalKey> _headingKeys = [];
  double _scrollProgress = 0.0;
  int _currentSectionIndex = 0;

  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadTutorial();
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

  void _updateScrollProgress() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        setState(() {
          _scrollProgress = _scrollController.offset / max;
        });
      }
    }
  }

  void _updateActiveHeading() {
    if (!mounted) return;
    if (_headingKeys.isEmpty) return;
    int activeIndex = 0;
    for (int i = 0; i < _headingKeys.length; i++) {
      final key = _headingKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position > 0 && position < 200) {
            activeIndex = i;
            break;
          }
        }
      }
    }
    if (_currentSectionIndex != activeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentSectionIndex = activeIndex);
        }
      });
    }
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
        final response = await http.get(url);

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

      // if (kIsWeb) {
      //   final cleanUrl = '/${widget.args.category}/$slug';
      //   MetaService.setCanonical('https://revochamp.site/tech$cleanUrl');
      // }
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
        if (type == 'heading') {
          contentList.add(
            ContentItem(type: ContentType.heading, value: value as String),
          );
        } else if (type == 'text') {
          contentList.add(
            ContentItem(type: ContentType.text, value: value as String),
          );
        } else if (type == 'code') {
          contentList.add(
            ContentItem(
              type: ContentType.code,
              value: value as String,
              language: item['language'],
            ),
          );
        } else if (type == 'list') {
          final listValue = (value as List).join('\n');
          contentList.add(
            ContentItem(type: ContentType.list, value: listValue),
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
    _updateSeo();
    _updateStructuredData();

    if (kIsWeb) {
      _addHiddenH1(_data!.title);
      _injectFaqHtml();
      _injectInternalLinks();
      _injectContentHtml();

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

  void _injectInternalLinks() {
    if (!kIsWeb || _data == null) return;

    final div = html.DivElement()
      ..style.position = 'absolute'
      ..style.left = '-9999px';

    for (var slug in _data!.relatedSlugs) {
      final a = html.AnchorElement()
        ..href = '/${widget.args.category}/$slug'
        ..text = slug;
      div.append(a);
    }

    html.document.body?.append(div);
  }

  void _injectContentHtml() {
    if (!kIsWeb || _data == null) return;

    final div = html.DivElement()
      ..style.position = 'absolute'
      ..style.left = '-9999px';

    for (var item in _data!.content) {
      if (item.type == ContentType.text || item.type == ContentType.heading) {
        div.append(html.ParagraphElement()..text = item.value);
      }
    }

    html.document.body?.append(div);
  }

  void _injectFaqHtml() {
    if (!kIsWeb || _data == null || _data!.faq.isEmpty) return;

    final container = html.DivElement()
      ..style.position = 'absolute'
      ..style.left = '-9999px';

    for (var f in _data!.faq) {
      final q = html.HeadingElement.h2()..text = f['question'];
      final a = html.ParagraphElement()..text = f['answer'];
      container.append(q);
      container.append(a);
    }

    html.document.body?.append(container);
  }

  void _updateSeo() {
    if (!kIsWeb) return;

    String description =
        'Learn ${_data!.title} with this interactive ${widget.args.category} tutorial.';
    if (_data!.content.isNotEmpty) {
      final firstText = _data!.content.firstWhere(
        (item) => item.type == ContentType.text,
        orElse: () => ContentItem(type: ContentType.text, value: description),
      );
      description = firstText.value.substring(
        0,
        min(160, firstText.value.length),
      );
    }

    final metaTitle =
        _data!.meta?['title'] ??
        '${_data!.title} - ${widget.args.category.toUpperCase()} Tutorials';
    final metaDescription = _data!.meta?['description'] ?? description;
    final imageUrl =
        _data!.meta?['image'] ?? 'https://revochamp.site/banner.png';

    // Update main meta tags
    MetaService.updateMetaTags(
      title: metaTitle,
      description: metaDescription,
      slug: '${widget.args.category}/${widget.args.slug}',
      keywords: [widget.args.category, 'tutorial', _data!.title.toLowerCase()],
      isArticle: true,
      imageUrl: imageUrl,
    );

    // Add OG tags separately for social media
    MetaService.setOGTags(
      title: metaTitle,
      description: metaDescription,
      image: imageUrl,
    );

    // Add Twitter tags
    MetaService.setTwitterTags(
      title: metaTitle,
      description: metaDescription,
      image: imageUrl,
    );
  }

  void _updateStructuredData() {
    final baseUrl = 'https://revochamp.site/tech';
    // final pageId = '$baseUrl/${widget.args.category}/${widget.args.slug}';

final pageId = 'https://revochamp.site/tech/${widget.args.category}/${widget.args.slug}';
    final structuredData = {
      "@context": "https://schema.org",
      "@type": "TechArticle",
      "headline": _data!.title,
      "description": _getDescription(),
      "author": {
        "@type": "Person",
        "name": "${widget.args.category.toUpperCase()} Tutorials Team",
      },
      "datePublished": _data!.meta?['datePublished'] ?? "2025-01-01",
      "dateModified":
          _data!.meta?['dateModified'] ?? DateTime.now().toIso8601String(),
      "image": _data!.meta?['image'] ?? "$baseUrl/icon.png",
      "publisher": {
        "@type": "Organization",
        "name": "Revochamp",
        "logo": {"@type": "ImageObject", "url": "$baseUrl/logo.png"},
      },
      "mainEntityOfPage": {"@type": "WebPage", "@id": pageId},
    };

    if (_data!.faq.isNotEmpty) {
      final graph = [
        structuredData,
        {
          "@type": "FAQPage",
          "mainEntity": _data!.faq
              .map(
                (f) => {
                  "@type": "Question",
                  "name": f['question'],
                  "acceptedAnswer": {"@type": "Answer", "text": f['answer']},
                },
              )
              .toList(),
        },
      ];
      MetaService.setStructuredData({
        "@context": "https://schema.org",
        "@graph": graph,
      });
    } else {
      MetaService.setStructuredData(structuredData);
    }
  }

  String _getDescription() {
    if (_data!.content.isNotEmpty) {
      final textItem = _data!.content.firstWhere(
        (item) => item.type == ContentType.text,
        orElse: () => ContentItem(type: ContentType.text, value: ''),
      );
      final value = textItem.value;
      return value.substring(0, min(160, value.length));
    }
    return 'Interactive ${widget.args.category} tutorial about ${_data!.title}.';
  }

  void _submitQuiz() {
    if (_quizStates.any((state) => state.selectedAnswer == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: _card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
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

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_rounded, color: _success, size: 16),
            SizedBox(width: 8),
            Text('Copied to clipboard', style: TextStyle(color: _textPrimary)),
          ],
        ),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goToPrevious() {
    final topics = widget.args.allTopics;
    if (topics.isEmpty) {
      _showSnack('Loading topics... please wait');
      return;
    }
    final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);
    debugPrint(
      'Previous - Current index: $currentIndex, Category: ${widget.args.category}',
    );

    if (currentIndex > 0) {
      final previousSlug = topics[currentIndex - 1].slug;
      debugPrint('Navigating to: /${widget.args.category}/$previousSlug');
      context.go('/${widget.args.category}/$previousSlug');
    } else {
      _showSnack('This is the first tutorial');
    }
  }

  void _goToNext() {
    final topics = widget.args.allTopics;
    if (topics.isEmpty) {
      _showSnack('Loading topics... please wait');
      return;
    }
    final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);
    debugPrint(
      'Next - Current index: $currentIndex, Category: ${widget.args.category}',
    );

    if (currentIndex < topics.length - 1) {
      final nextSlug = topics[currentIndex + 1].slug;
      debugPrint('Navigating to: /${widget.args.category}/$nextSlug');
      context.go('/${widget.args.category}/$nextSlug');
    } else {
      _showSnack('You have completed all tutorials!');
    }
  }

  void _shareTutorial() {
    final url =
        'https://revochamp.site/tech/${widget.args.category}/${widget.args.slug}';
    final title = _data!.title;
    final text = 'Check out this tutorial: $title';

    if (kIsWeb) {
      // Try Web Share API first
      if (html.window.navigator.share != null) {
        html.window.navigator.share!({'title': title, 'text': text, 'url': url})
            .catchError((error) {
              _fallbackShare(url, title);
            });
      } else {
        _fallbackShare(url, title);
      }
    }
  }

  void _fallbackShare(String url, String title) {
    // Fallback: copy to clipboard
    Clipboard.setData(ClipboardData(text: url));
    _showSnack('Link copied to clipboard! Share it with others.');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _textPrimary)),
        backgroundColor: _card,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<ContentItem> get _headings =>
      _data?.content
          .where((item) => item.type == ContentType.heading)
          .toList() ??
      [];

  void _scrollToHeading(int index) {
    if (index < _headingKeys.length &&
        _headingKeys[index].currentContext != null) {
      Scrollable.ensureVisible(
        _headingKeys[index].currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_error != null) return _buildErrorScreen();

    final isDesktop = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: _navy,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFABs(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: _navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation(_accent),
                backgroundColor: _border,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading tutorial...',
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: _navy,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadTutorial();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          border: const Border(bottom: BorderSide(color: _border, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _AppBarButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/${widget.args.category}');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _data!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (_data!.difficulty.isNotEmpty ||
                                _data!.readTime.isNotEmpty)
                              Row(
                                children: [
                                  if (_data!.difficulty.isNotEmpty) ...[
                                    _AppBarChip(_data!.difficulty),
                                    const SizedBox(width: 6),
                                  ],
                                  if (_data!.readTime.isNotEmpty)
                                    Text(
                                      '· ${_data!.readTime}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: _textMuted,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _accentSoft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${(_scrollProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _accentGlow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _AppBarButton(
                        icon: Icons.share_rounded,
                        onTap: _shareTutorial,
                      ),
                      _AppBarButton(
                        icon: Icons.copy_rounded,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _data!.title));
                          _showSnack('Title copied');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              LinearProgressIndicator(
                value: _scrollProgress,
                minHeight: 2,
                backgroundColor: _border,
                valueColor: const AlwaysStoppedAnimation(_accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavFAB(
          heroTag: 'prev',
          icon: Icons.arrow_upward_rounded,
          onTap: _goToPrevious,
          tooltip: 'Previous',
        ),
        const SizedBox(height: 10),
        _NavFAB(
          heroTag: 'next',
          icon: Icons.arrow_downward_rounded,
          onTap: _goToNext,
          tooltip: 'Next',
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 270,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.list_rounded,
                          color: _accentGlow,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Contents',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: _border),
                Expanded(
                  child: ListView.builder(
                    controller: _sideMenuController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    itemCount: _headings.length,
                    itemBuilder: (context, index) {
                      final item = _headings[index];
                      final isActive = index == _currentSectionIndex;
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            _scrollToHeading(index);
                            setState(() => _currentSectionIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isActive
                                  ? _accentSoft
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 3,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: isActive ? _accent : _border,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.value,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isActive
                                          ? _accentGlow
                                          : _textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 1,
                        color: _border,
                        margin: const EdgeInsets.only(bottom: 10),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _scrollProgress,
                          minHeight: 4,
                          backgroundColor: _border,
                          valueColor: const AlwaysStoppedAnimation(_accent),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(_scrollProgress * 100).toInt()}% read',
                        style: const TextStyle(fontSize: 11, color: _textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: KeyedSubtree(
                  key: _contentKey,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      children: [
                        ..._buildContentItems(),
                        const SizedBox(height: 20),
                        _buildEditorSection(),
                        const SizedBox(height: 40),
                        if (_data!.quiz.isNotEmpty) _buildQuizSection(),
                        if (_data!.faq.isNotEmpty) _buildFaqSection(),
                        if (_data!.relatedSlugs.isNotEmpty)
                          _buildRelatedSection(),
                        const SizedBox(height: 30),
                        buildAdPlaceholder(height: 120, label: "Sponsored"),
                        _buildNavigationButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: KeyedSubtree(
            key: _contentKey,
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  if (_headings.isNotEmpty) _buildMobileToc(),
                  ..._buildContentItems(),
                  const SizedBox(height: 20),
                  _buildEditorSection(),
                  const SizedBox(height: 40),
                  if (_data!.quiz.isNotEmpty) _buildQuizSection(),
                  if (_data!.faq.isNotEmpty) _buildFaqSection(),
                  if (_data!.relatedSlugs.isNotEmpty) _buildRelatedSection(),
                  const SizedBox(height: 30),
                  buildAdPlaceholder(height: 120, label: "Sponsored"),
                  _buildNavigationButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileToc() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.list_rounded,
                  color: _accentGlow,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Contents',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _headings.asMap().entries.map((entry) {
              final idx = entry.key;
              final heading = entry.value;
              final hasValidKey = idx < _headingKeys.length;
              return GestureDetector(
                onTap: hasValidKey ? () => _scrollToHeading(idx) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    heading.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _accentGlow,
                      fontWeight: FontWeight.w500,
                    ),
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
    const adFrequency = 3;

    for (int i = 0; i < _data!.content.length; i++) {
      final item = _data!.content[i];
      if (item.type == ContentType.heading) {
        widgets.add(
          Container(
            key: headingIdx < _headingKeys.length
                ? _headingKeys[headingIdx]
                : null,
            child: ContentItemWidget(item: item, onCopy: _copyCode),
          ),
        );
        headingIdx++;
      } else {
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ContentItemWidget(item: item, onCopy: _copyCode),
            ),
          ),
        );
      }
      widgets.add(const SizedBox(height: 10));

      if (i > 0 &&
          i % adFrequency == 0 &&
          _data!.content[i].type != ContentType.heading &&
          _data!.content[i - 1].type != ContentType.heading) {
        widgets.add(buildAdPlaceholder(height: 120, label: 'Sponsored'));
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }

  Widget _buildEditorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Icons.edit_rounded, label: 'Try it Yourself'),
        const SizedBox(height: 14),
        EditorWidget(
          codeController: _codeController,
          defaultCode: _data!.defaultCode,
          onCopy: _copyCode,
          onRun: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Running code:\n${_codeController.text}')),
            );
          },
          onReset: () =>
              setState(() => _codeController.text = _data!.defaultCode),
        ),
      ],
    );
  }

  Widget _buildQuizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(icon: Icons.quiz_rounded, label: 'Test Your Knowledge'),
        if (!_quizSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              'Answer all ${_data!.quiz.length} question${_data!.quiz.length != 1 ? 's' : ''}',
              style: const TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ),
        for (int i = 0; i < _data!.quiz.length; i++)
          QuizCard(
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
        if (_quizSubmitted) ScoreCard(score: _score, total: _data!.quiz.length),
        const SizedBox(height: 16),
        QuizButtons(onSubmit: _submitQuiz, onReset: _resetQuiz),
        const SizedBox(height: 30),
        buildAdPlaceholder(height: 120, label: 'Sponsored'),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _SectionLabel(
          icon: Icons.help_outline_rounded,
          label: 'Frequently Asked Questions',
        ),
        const SizedBox(height: 14),
        ..._data!.faq.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: _accentGlow,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  item['question'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textPrimary,
                  ),
                ),
                iconColor: _textSecondary,
                collapsedIconColor: _textMuted,
                children: [
                  Text(
                    item['answer'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRelatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Container(height: 1, color: _border),
        const SizedBox(height: 20),
        _SectionLabel(icon: Icons.link_rounded, label: 'Related Topics'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _data!.relatedSlugs.map((slug) {
            return GestureDetector(
              onTap: () {
                context.go('/${widget.args.category}/$slug');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  slug
                      .replaceFirst('${widget.args.category}-', '')
                      .replaceAll('-', ' '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _accentGlow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _goToPrevious,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textPrimary,
              side: const BorderSide(color: _border),
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
            onPressed: _goToNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
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

  Widget buildAdPlaceholder({
    double height = 110,
    String label = 'Advertisement',
    bool isLoading = false,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Ad',
                style: TextStyle(fontSize: 10, color: _textMuted),
              ),
            ),
          ),
          AdsenseAd(adSlot: "1234567890"),
        ],
      ),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _accentGlow, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _textSecondary, size: 17),
      ),
    );
  }
}

class _AppBarChip extends StatelessWidget {
  final String label;
  const _AppBarChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _accentSoft,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: _accentGlow,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NavFAB extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isPrimary;

  const _NavFAB({
    required this.heroTag,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPrimary ? _accent : _card,
            shape: BoxShape.circle,
            border: Border.all(color: isPrimary ? _accent : _border),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? _accent.withValues(alpha: 0.3)
                    : Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
