// import 'dart:collection';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:techtutorial/screens/tutorial/content_widget.dart';

// import '../../core/meta_service.dart';
// import '../../core/theme.dart';
// import '../../models/content_item.dart';
// import '../../models/quiz_question.dart';
// import '../../models/tutorial_data.dart';
// import '../../models/tutorial_topic.dart';
// import 'editor_widget.dart';
// import 'quiz_widgets.dart';
// import 'package:http/http.dart' as http;

// class TutorialArguments {
//   final String slug;
//   final List<TutorialTopic> allTopics;
//   TutorialArguments({required this.slug, required this.allTopics});
// }

// // ---------------------------- TutorialPage ----------------------------

// class TutorialPage extends StatefulWidget {
//   final TutorialArguments args;
//   const TutorialPage({super.key, required this.args});

//   @override
//   State<TutorialPage> createState() => _TutorialPageState();
// }

// class _TutorialPageState extends State<TutorialPage>
//     with SingleTickerProviderStateMixin {
//   static final LinkedHashMap<String, TutorialData> _cache = LinkedHashMap();
//   static const int _maxCacheSize = 20;

//   TutorialData? _data;
//   bool _isLoading = true;
//   String? _error;

//   List<QuizQuestionState> _quizStates = [];
//   bool _quizSubmitted = false;
//   int _score = 0;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   final TextEditingController _codeController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   final List<GlobalKey> _headingKeys = [];
//   double _scrollProgress = 0.0;

//   final GlobalKey _contentKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//     _loadTutorial();

//     _scrollController.addListener(() {
//       if (_scrollController.hasClients) {
//         final max = _scrollController.position.maxScrollExtent;
//         if (max > 0) {
//           setState(() {
//             _scrollProgress = _scrollController.offset / max;
//           });
//         }
//       }
//     });
//   }

//   static const String tutorialsBaseUrl =
//       'https://json.revochamp.site/flutter/'; // Added

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _codeController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Updated _loadTutorial to fetch from API
//   Future<void> _loadTutorial() async {
//     final slug = widget.args.slug;
//     if (slug.isEmpty) {
//       setState(() {
//         _error = 'Invalid tutorial slug.';
//         _isLoading = false;
//       });
//       return;
//     }

//     try {
//       if (_cache.containsKey(slug)) {
//         _data = _cache[slug];
//       } else {
//         final url = Uri.parse('$tutorialsBaseUrl$slug.json');
//         final response = await http.get(url);
//         if (response.statusCode == 200) {
//           final json = jsonDecode(response.body);
//           _data = _parseTutorialData(json);
//           _cache[slug] = _data!;
//           if (_cache.length > _maxCacheSize) {
//             _cache.remove(_cache.keys.first);
//           }
//         } else {
//           setState(() {
//             _error = 'Failed to load tutorial: HTTP ${response.statusCode}';
//             _isLoading = false;
//           });
//           return;
//         }
//       }
//       _initializeFromData();
//       setState(() => _isLoading = false);
//       _animationController.forward();

//       if (kIsWeb) {
//         final cleanUrl = '/tech/flutter/$slug';
//         MetaService.setCanonical('https://revochamp.site$cleanUrl');
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to load tutorial: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   // Future<void> _loadTutorial() async {
//   //   final slug = widget.args.slug;
//   //   if (slug.isEmpty) {
//   //     setState(() {
//   //       _error = 'Invalid tutorial slug.';
//   //       _isLoading = false;
//   //     });
//   //     return;
//   //   }

//   //   try {
//   //     if (_cache.containsKey(slug)) {
//   //       _data = _cache[slug];
//   //     } else {
//   //       final jsonString = await rootBundle.loadString('assets/tutorials/$slug.json');
//   //       final json = jsonDecode(jsonString);
//   //       _data = _parseTutorialData(json);
//   //       _cache[slug] = _data!;
//   //       if (_cache.length > _maxCacheSize) {
//   //         _cache.remove(_cache.keys.first);
//   //       }
//   //     }
//   //     _initializeFromData();
//   //     setState(() => _isLoading = false);
//   //     _animationController.forward();

//   //     if (kIsWeb) {
//   //       final cleanUrl = '/flutter/$slug';
//   //       // html.window.history.pushState(null, _data!.title, cleanUrl);
//   //       MetaService.setCanonical('https://revochamp.site/tech$cleanUrl');
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       _error = 'Failed to load tutorial: $e';
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   TutorialData _parseTutorialData(Map<String, dynamic> json) {
//     final contentList = <ContentItem>[];
//     for (var item in json['content'] ?? []) {
//       final type = item['type'];
//       final value = item['value'];
//       if (type == 'heading') {
//         contentList.add(
//           ContentItem(type: ContentType.heading, value: value as String),
//         );
//       } else if (type == 'text') {
//         contentList.add(
//           ContentItem(type: ContentType.text, value: value as String),
//         );
//       } else if (type == 'code') {
//         contentList.add(
//           ContentItem(
//             type: ContentType.code,
//             value: value as String,
//             language: item['language'],
//           ),
//         );
//       } else if (type == 'list') {
//         final listValue = (value as List).join('\n');
//         contentList.add(ContentItem(type: ContentType.list, value: listValue));
//       }
//     }

//     final quizList = <QuizQuestion>[];
//     for (var q in json['quiz'] ?? []) {
//       quizList.add(
//         QuizQuestion(
//           question: q['question'],
//           options: List<String>.from(q['options']),
//           answer: q['answer'],
//           explanation: q['explanation'],
//         ),
//       );
//     }

//     return TutorialData(
//       title: json['title'] ?? 'Untitled',
//       subtitle: json['subtitle'] ?? '',
//       difficulty: json['difficulty'] ?? '',
//       readTime: json['readTime'] ?? '',
//       meta: json['meta'],
//       faq: List<Map<String, dynamic>>.from(json['faq'] ?? []),
//       content: contentList,
//       quiz: quizList,
//       defaultCode: json['tryEditor']?['defaultCode'] ?? '',
//       relatedSlugs: List<String>.from(json['related'] ?? []),
//     );
//   }

//   void _initializeFromData() {
//     if (_data == null) return;
//     _quizStates = List.generate(_data!.quiz.length, (_) => QuizQuestionState());
//     _codeController.text = _data!.defaultCode;
//     _headingKeys.clear();
//     for (var i = 0; i < _data!.content.length; i++) {
//       if (_data!.content[i].type == ContentType.heading) {
//         _headingKeys.add(GlobalKey());
//       }
//     }
//     _updateSeo();
//     _updateStructuredData();
//     if (kIsWeb) {
//       final parents = [
//         {
//           'name': 'Flutter Tutorials',
//           'url': 'https://revochamp.site/tech/flutter',
//         },
//       ];
//       MetaService.setBreadcrumbData(
//         title: _data!.title,
//         slug: widget.args.slug,
//         parents: parents,
//       );
//     }
//   }

//   void _updateSeo() {
//     if (!kIsWeb) return;
//     String description =
//         'Learn ${_data!.title} with this interactive Flutter tutorial.';
//     if (_data!.content.isNotEmpty) {
//       final firstText = _data!.content.firstWhere(
//         (item) => item.type == ContentType.text,
//         orElse: () => ContentItem(type: ContentType.text, value: description),
//       );
//       description = firstText.value.substring(
//         0,
//         min(160, firstText.value.length),
//       );
//     }
//     final metaTitle =
//         _data!.meta?['title'] ?? '${_data!.title} - Flutter Tutorials';
//     final metaDescription = _data!.meta?['description'] ?? description;
//     MetaService.updateMetaTags(
//       title: metaTitle,
//       description: metaDescription,
//       slug: widget.args.slug,
//     );
//   }

//   void _updateStructuredData() {
//     final baseUrl = 'https://revochamp.site/tech';
//     final pageId = '$baseUrl/flutter/${widget.args.slug}';
//     final structuredData = {
//       "@context": "https://schema.org",
//       "@type": "TechArticle",
//       "headline": _data!.title,
//       "description": _getDescription(),
//       "author": {"@type": "Person", "name": "Flutter Tutorials Team"},
//       "datePublished": "2025-01-01",
//       "image": "$baseUrl/icon.png",
//       "publisher": {
//         "@type": "Organization",
//         "name": "Your Organization",
//         "logo": {"@type": "ImageObject", "url": "$baseUrl/logo.png"},
//       },
//       "mainEntityOfPage": {"@type": "WebPage", "@id": pageId},
//     };

//     if (_data!.faq.isNotEmpty) {
//       final graph = [
//         structuredData,
//         {
//           "@type": "FAQPage",
//           "mainEntity": _data!.faq
//               .map(
//                 (f) => {
//                   "@type": "Question",
//                   "name": f['question'],
//                   "acceptedAnswer": {"@type": "Answer", "text": f['answer']},
//                 },
//               )
//               .toList(),
//         },
//       ];
//       MetaService.setStructuredData({
//         "@context": "https://schema.org",
//         "@graph": graph,
//       });
//     } else {
//       MetaService.setStructuredData(structuredData);
//     }
//   }

//   String _getDescription() {
//     if (_data!.content.isNotEmpty) {
//       final textItem = _data!.content.firstWhere(
//         (item) => item.type == ContentType.text,
//         orElse: () => ContentItem(type: ContentType.text, value: ''),
//       );
//       return textItem.value.substring(0, min(160, textItem.value.length));
//     }
//     return 'Interactive Flutter tutorial about ${_data!.title}.';
//   }

//   void _submitQuiz() {
//     if (_quizStates.any((state) => state.selectedAnswer == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please answer all questions')),
//       );
//       return;
//     }

//     int score = 0;
//     for (int i = 0; i < _data!.quiz.length; i++) {
//       final isCorrect = _quizStates[i].selectedAnswer == _data!.quiz[i].answer;
//       _quizStates[i].isCorrect = isCorrect;
//       _quizStates[i].explanation = _data!.quiz[i].explanation;
//       if (isCorrect) score++;
//     }

//     setState(() {
//       _score = score;
//       _quizSubmitted = true;
//     });

//     _markCompleted();
//   }

//   Future<void> _markCompleted() async {
//     final prefs = await SharedPreferences.getInstance();
//     final completed = prefs.getStringList('completed') ?? [];
//     if (!completed.contains(widget.args.slug)) {
//       completed.add(widget.args.slug);
//       await prefs.setStringList('completed', completed);
//     }
//   }

//   void _resetQuiz() {
//     setState(() {
//       _quizStates = List.generate(
//         _data!.quiz.length,
//         (_) => QuizQuestionState(),
//       );
//       _quizSubmitted = false;
//       _score = 0;
//     });
//   }

//   void _copyCode(String code) {
//     Clipboard.setData(ClipboardData(text: code));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Code copied to clipboard'),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }

//   void _goToPrevious() {
//     final topics = widget.args.allTopics;
//     if (topics.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Loading topics... please wait')),
//       );
//       return;
//     }
//     final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);
//     if (currentIndex > 0) {
//       final prevSlug = topics[currentIndex - 1].slug;
//       // ✅ Use /flutter/$prevSlug
//       // Navigator.pushReplacementNamed(context, '/flutter/$prevSlug');
// context.go('/tech/flutter/$prevSlug');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('This is the first tutorial')),
//       );
//     }
//   }

//   int _currentSectionIndex = 0;
//   void _goToNext() {
//     final topics = widget.args.allTopics;
//     if (topics.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Loading topics... please wait')),
//       );
//       return;
//     }
//     final currentIndex = topics.indexWhere((t) => t.slug == widget.args.slug);
//     if (currentIndex < topics.length - 1) {
//       final nextSlug = topics[currentIndex + 1].slug;
//       // ✅ Use /flutter/$nextSlug
//       // Navigator.pushReplacementNamed(context, '/flutter/$nextSlug');
// context.go('/tech/flutter/$nextSlug');
//       } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You have completed all tutorials!')),
//       );
//     }
//   }

//   List<ContentItem> get _headings =>
//       _data?.content
//           .where((item) => item.type == ContentType.heading)
//           .toList() ??
//       [];

//   void _scrollToHeading(int index) {
//     if (index < _headingKeys.length &&
//         _headingKeys[index].currentContext != null) {
//       Scrollable.ensureVisible(
//         _headingKeys[index].currentContext!,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   // ---------- UI Building ----------
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (_error != null) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text(_error!, style: const TextStyle(color: Colors.red)),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() => _isLoading = true);
//                   _loadTutorial();
//                 },
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final theme = Theme.of(context);
//     final isDesktop = MediaQuery.of(context).size.width > 1000;

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Semantics(
//       //     header: true,
//       //     child: Text(_data!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
//       //   ),
//       //   flexibleSpace: Container(decoration: BoxDecoration(gradient: primaryGradient)),
//       //   bottom: PreferredSize(
//       //     preferredSize: const Size.fromHeight(4),
//       //     child: LinearProgressIndicator(
//       //       value: _scrollProgress,
//       //       backgroundColor: Colors.transparent,
//       //       color: Colors.white,
//       //       minHeight: 3,
//       //     ),
//       //   ),
//       // ),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: primaryGradient,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // 🔹 TOP BAR
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: SizedBox(
//                     height: 56,
//                     child: Row(
//                       children: [
//                         // Back
//                         IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),

//                         // Title (ellipsis safe)
//                         Expanded(
//                           child: Text(
//                             _data!.title,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),

//                         // Actions
//                         IconButton(
//                           icon: const Icon(Icons.share, color: Colors.white70),
//                           onPressed: () {
//                             // TODO: Share logic
//                           },
//                         ),

//                         IconButton(
//                           icon: const Icon(Icons.copy, color: Colors.white70),
//                           onPressed: () {
//                             Clipboard.setData(
//                               ClipboardData(text: _data!.title),
//                             );
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Title copied')),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // 🔹 PROGRESS BAR (SMOOTH + ROUNDED)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: LinearProgressIndicator(
//                       value: _scrollProgress,
//                       minHeight: 4,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 6),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: "prev",
//             onPressed: _goToPrevious,
//             mini: true,
//             child: const Icon(Icons.arrow_back),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: "next",
//             onPressed: _goToNext,
//             mini: true,
//             child: const Icon(Icons.arrow_forward),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.brightness == Brightness.dark
//                   ? Colors.grey[900]!
//                   : const Color(0xFFF8FAFC),
//               theme.brightness == Brightness.dark
//                   ? Colors.grey[850]!
//                   : const Color(0xFFEFF3F8),
//             ],
//           ),
//         ),
//         child: isDesktop
//             ? Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Sidebar TOC
//                   SizedBox(
//                     width: 280,
//                     child: Container(
//                       margin: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.85),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 12,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // 🔹 HEADER
//                           const Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.menu_book, color: Color(0xFF1E3C72)),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   "Contents",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF1E3C72),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                           Divider(height: 1),

//                           // 🔹 LIST
//                           Expanded(
//                             child: ListView.builder(
//                               controller: ScrollController(),
//                               padding: const EdgeInsets.all(8),
//                               itemCount: _headings.length,
//                               itemBuilder: (context, index) {
//                                 final item = _headings[index];
//                                 final isActive = index == _currentSectionIndex;

//                                 return MouseRegion(
//                                   cursor: SystemMouseCursors.click,
//                                   child: InkWell(
//                                     borderRadius: BorderRadius.circular(12),
//                                     onTap: () {
//                                       _scrollToHeading(index);
//                                       setState(
//                                         () => _currentSectionIndex = index,
//                                       );
//                                     },
//                                     child: AnimatedContainer(
//                                       duration: const Duration(
//                                         milliseconds: 200,
//                                       ),
//                                       margin: const EdgeInsets.symmetric(
//                                         vertical: 4,
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 10,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: isActive
//                                             ? const Color(
//                                                 0xFF2A5298,
//                                               ).withOpacity(0.12)
//                                             : Colors.transparent,
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           // 🔹 ACTIVE BAR
//                                           AnimatedContainer(
//                                             duration: const Duration(
//                                               milliseconds: 200,
//                                             ),
//                                             width: 3,
//                                             height: 20,
//                                             margin: const EdgeInsets.only(
//                                               right: 10,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: isActive
//                                                   ? const Color(0xFF2A5298)
//                                                   : Colors.transparent,
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                           ),

//                                           // 🔹 TEXT
//                                           Expanded(
//                                             child: Text(
//                                               item.value,
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: isActive
//                                                     ? FontWeight.w600
//                                                     : FontWeight.w400,
//                                                 color: isActive
//                                                     ? const Color(0xFF1E3C72)
//                                                     : Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),

//                           // 🔹 PROGRESS FOOTER
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             child: LinearProgressIndicator(
//                               value: _scrollProgress,
//                               minHeight: 4,
//                               backgroundColor: Colors.grey.shade300,
//                               valueColor: const AlwaysStoppedAnimation(
//                                 Color(0xFF2A5298),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 1200),
//                         child: FadeTransition(
//                           opacity: _fadeAnimation,
//                           child: KeyedSubtree(
//                             key: _contentKey,
//                             child: Scrollbar(
//                               controller: _scrollController,
//                               child: ListView(
//                                 controller: _scrollController,
//                                 padding: const EdgeInsets.all(20),
//                                 children: [
                                
//                                   // Inline TOC is hidden on desktop; we use sidebar instead
//                                   if (!isDesktop && _headings.isNotEmpty) ...[
//                                     Text(
//                                       '📑 Contents',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: const Color(0xFF1E3C72),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Wrap(
//                                       spacing: 8,
//                                       runSpacing: 4,
//                                       children: _headings.asMap().entries.map((
//                                         entry,
//                                       ) {
//                                         final idx = entry.key;
//                                         final heading = entry.value;
//                                         final bool hasValidKey =
//                                             idx < _headingKeys.length;
//                                         return ActionChip(
//                                           label: Text(heading.value),
//                                           onPressed: hasValidKey
//                                               ? () => _scrollToHeading(idx)
//                                               : null,
//                                           backgroundColor: const Color(
//                                             0xFF2A5298,
//                                           ).withOpacity(0.1),
//                                         );
//                                       }).toList(),
//                                     ),
//                                     const SizedBox(height: 20),
//                                   ],

//                                   ..._buildContentWidgets(theme),

//                                   const SizedBox(height: 20),
//                                   Text(
//                                     '✏️ Try it Yourself',
//                                     style: TextStyle(
//                                       fontSize: 28,
//                                       fontWeight: FontWeight.bold,
//                                       color: const Color(0xFF1E3C72),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   EditorWidget(
//                                     codeController: _codeController,
//                                     defaultCode: _data!.defaultCode,
//                                     onCopy: _copyCode,
//                                     onRun: () {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'Running code:\n${_codeController.text}',
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     onReset: () => setState(
//                                       () => _codeController.text =
//                                           _data!.defaultCode,
//                                     ),
//                                   ),

//                                   const SizedBox(height: 40),

//                                   if (_data!.quiz.isNotEmpty) ...[
//                                     Text(
//                                       '📝 Test Your Knowledge',
//                                       style: TextStyle(
//                                         fontSize: 28,
//                                         fontWeight: FontWeight.bold,
//                                         color: const Color(0xFF1E3C72),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     if (!_quizSubmitted)
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           bottom: 8,
//                                         ),
//                                         child: Text(
//                                           'Answer all ${_data!.quiz.length} questions',
//                                           style: theme.textTheme.bodyLarge
//                                               ?.copyWith(
//                                                 color: Colors.grey[600],
//                                               ),
//                                         ),
//                                       ),
//                                     for (int i = 0; i < _data!.quiz.length; i++)
//                                       QuizCard(
//                                         index: i,
//                                         total: _data!.quiz.length,
//                                         question: _data!.quiz[i],
//                                         state: _quizStates[i],
//                                         submitted: _quizSubmitted,
//                                         onAnswerSelected: (answerIndex) {
//                                           if (!_quizSubmitted) {
//                                             setState(
//                                               () =>
//                                                   _quizStates[i]
//                                                           .selectedAnswer =
//                                                       answerIndex,
//                                             );
//                                           }
//                                         },
//                                       ),
//                                     if (_quizSubmitted)
//                                       ScoreCard(
//                                         score: _score,
//                                         total: _data!.quiz.length,
//                                       ),
//                                     const SizedBox(height: 16),
//                                     QuizButtons(
//                                       onSubmit: _submitQuiz,
//                                       onReset: _resetQuiz,
//                                     ),

//                                     const SizedBox(height: 30),
//                                     // _buildAdPlaceholder(),
//                                     buildAdPlaceholder(
//   height: 120,
//   label: "Sponsored",
// ),
//                                   ],

//                                   if (_data!.faq.isNotEmpty) _buildFaqSection(),

//                                   if (_data!.relatedSlugs.isNotEmpty) ...[
//                                     const Divider(height: 40, thickness: 2),
//                                      // ✅ CALL HERE
//           RelatedSlugsWrap(
//             slugs: _data?.relatedSlugs ?? [],
//           ),
//                                     // Text(
//                                     //   '🔗 Related Topics',
//                                     //   style: TextStyle(
//                                     //     fontSize: 24,
//                                     //     fontWeight: FontWeight.bold,
//                                     //     color: const Color(0xFF1E3C72),
//                                     //   ),
//                                     // ),
//                                     // const SizedBox(height: 16),
//                                     // Wrap(
//                                     //   spacing: 8,
//                                     //   runSpacing: 8,
//                                     //   children: _data!.relatedSlugs.map((slug) {
//                                     //     return ActionChip(
//                                     //       label: Text(
//                                     //         slug
//                                     //             .replaceFirst('flutter-', '')
//                                     //             .replaceFirst('-', ' '),
//                                     //       ),
//                                     //       onPressed: () {
//                                     //         // ✅ Use /flutter/$slug
//                                     //         Navigator.pushReplacementNamed(
//                                     //           context,
//                                     //           '/flutter/$slug',
//                                     //         );
//                                     //       },
//                                     //       backgroundColor: const Color(
//                                     //         0xFF2A5298,
//                                     //       ).withOpacity(0.1),
//                                     //       side: const BorderSide(
//                                     //         color: Color(0xFF2A5298),
//                                     //       ),
//                                     //     );
//                                     //   }).toList(),
//                                     // ),
                          
                          
//                                   ],

//                                   const SizedBox(height: 30),
//                                   // _buildAdPlaceholder(),
//                                   buildAdPlaceholder(
//   height: 120,
//   label: "Sponsored",
// ),

//                                   NavigationButtons(
//                                     onPrevious: _goToPrevious,
//                                     onNext: _goToNext,
//                                   ),
//                                   const SizedBox(height: 20),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : // Mobile layout (no sidebar)
//               Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 900),
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: KeyedSubtree(
//                       key: _contentKey,
//                       child: Scrollbar(
//                         controller: _scrollController,
//                         child: ListView(
//                           controller: _scrollController,
//                           padding: const EdgeInsets.all(20),
//                           children: [
//                             // _buildTutorialHero(),
//                             // const SizedBox(height: 20),
//                             if (_headings.isNotEmpty) ...[
//                               Text(
//                                 '📑 Contents',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF1E3C72),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Wrap(
//                                 spacing: 8,
//                                 runSpacing: 4,
//                                 children: _headings.asMap().entries.map((
//                                   entry,
//                                 ) {
//                                   final idx = entry.key;
//                                   final heading = entry.value;
//                                   final bool hasValidKey =
//                                       idx < _headingKeys.length;
//                                   return ActionChip(
//                                     label: Text(heading.value),
//                                     onPressed: hasValidKey
//                                         ? () => _scrollToHeading(idx)
//                                         : null,
//                                     backgroundColor: const Color(
//                                       0xFF2A5298,
//                                     ).withOpacity(0.1),
//                                   );
//                                 }).toList(),
//                               ),
//                               const SizedBox(height: 20),
//                             ],

//                             ..._buildContentWidgets(theme),

//                             const SizedBox(height: 20),
//                             Text(
//                               '✏️ Try it Yourself',
//                               style: TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF1E3C72),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             EditorWidget(
//                               codeController: _codeController,
//                               defaultCode: _data!.defaultCode,
//                               onCopy: _copyCode,
//                               onRun: () {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       'Running code:\n${_codeController.text}',
//                                     ),
//                                   ),
//                                 );
//                               },
//                               onReset: () => setState(
//                                 () => _codeController.text = _data!.defaultCode,
//                               ),
//                             ),

//                             const SizedBox(height: 40),

//                             if (_data!.quiz.isNotEmpty) ...[
//                               Text(
//                                 '📝 Test Your Knowledge',
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF1E3C72),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               if (!_quizSubmitted)
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 8),
//                                   child: Text(
//                                     'Answer all ${_data!.quiz.length} questions',
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ),
//                               for (int i = 0; i < _data!.quiz.length; i++)
//                                 QuizCard(
//                                   index: i,
//                                   total: _data!.quiz.length,
//                                   question: _data!.quiz[i],
//                                   state: _quizStates[i],
//                                   submitted: _quizSubmitted,
//                                   onAnswerSelected: (answerIndex) {
//                                     if (!_quizSubmitted) {
//                                       setState(
//                                         () => _quizStates[i].selectedAnswer =
//                                             answerIndex,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               if (_quizSubmitted)
//                                 ScoreCard(
//                                   score: _score,
//                                   total: _data!.quiz.length,
//                                 ),
//                               const SizedBox(height: 16),
//                               QuizButtons(
//                                 onSubmit: _submitQuiz,
//                                 onReset: _resetQuiz,
//                               ),

//                               const SizedBox(height: 30),
//                               // _buildAdPlaceholder(),
//                               buildAdPlaceholder(
//   height: 120,
//   label: "Sponsored",
// ),
//                             ],

//                             if (_data!.faq.isNotEmpty) _buildFaqSection(),

//                             if (_data!.relatedSlugs.isNotEmpty) ...[
//                               const Divider(height: 40, thickness: 2),
//                               Text(
//                                 '🔗 Related Topics',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF1E3C72),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Wrap(
//                                 spacing: 8,
//                                 runSpacing: 8,
//                                 children: _data!.relatedSlugs.map((slug) {
//                                   return ActionChip(
//                                     label: Text(
//                                       slug
//                                           .replaceFirst('flutter-', '')
//                                           .replaceFirst('-', ' '),
//                                     ),
//                                     onPressed: () {
//                                       // ✅ Use /flutter/$slug
//                                       // Navigator.pushReplacementNamed(
//                                       //   context,
//                                       //   '/flutter/$slug',
//                                       // );

// context.go('/tech/flutter/$slug');
//                                     },
//                                     backgroundColor: const Color(
//                                       0xFF2A5298,
//                                     ).withOpacity(0.1),
//                                     side: const BorderSide(
//                                       color: Color(0xFF2A5298),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ],

//                             const SizedBox(height: 30),
//                             // _buildAdPlaceholder(),
// buildAdPlaceholder(
//   height: 120,
//   label: "Sponsored",
// ),
//                             NavigationButtons(
//                               onPrevious: _goToPrevious,
//                               onNext: _goToNext,
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   List<Widget> _buildContentWidgets(ThemeData theme) {
//     List<Widget> widgets = [];
//     int headingIdx = 0;
//     int adCounter = 0;
//     const adFrequency = 3;

//     for (int i = 0; i < _data!.content.length; i++) {
//       if (_data!.content[i].type == ContentType.heading) {
//         widgets.add(
//           Container(
//             key: headingIdx < _headingKeys.length
//                 ? _headingKeys[headingIdx]
//                 : null,
//             child: ContentItemWidget(
//               item: _data!.content[i],
//               onCopy: _copyCode,
//             ),
//           ),
//         );
//         headingIdx++;
//       } else {
//         widgets.add(
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: theme.cardColor,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(6),
//               child: ContentItemWidget(
//                 item: _data!.content[i],
//                 onCopy: _copyCode,
//               ),
//             ),
//           ),
//         );
//       }
//       widgets.add(const SizedBox(height: 12));

//       // Insert ad after every N items, but not too early and not near headings
//       if (i > 0 &&
//           i % adFrequency == 0 &&
//           _data!.content[i].type != ContentType.heading) {
//         widgets.add(
//           buildAdPlaceholder(
//   height: 120,
//   label: "Sponsored",
// ),
//           // _buildAdPlaceholder()
          
//           );
//         widgets.add(const SizedBox(height: 20));
//         adCounter++;
//       }
//     }
//     return widgets;
//   }

//   Widget _buildFaqSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 30),
//         const Text(
//           'Frequently Asked Questions',
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1E3C72),
//           ),
//         ),
//         const SizedBox(height: 16),

//         ..._data!.faq.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.grey.shade50],
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.06),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Theme(
//               data: Theme.of(
//                 context,
//               ).copyWith(dividerColor: Colors.transparent),
//               child: ExpansionTile(
//                 tilePadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 leading: CircleAvatar(
//                   backgroundColor: const Color(0xFF2A5298).withOpacity(0.1),
//                   child: Text(
//                     '${index + 1}',
//                     style: const TextStyle(color: Color(0xFF2A5298)),
//                   ),
//                 ),
//                 title: Text(
//                   item['question'] ?? '',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 children: [
//                   Text(
//                     item['answer'] ?? '',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }

// Widget buildAdPlaceholder({
//   double height = 110,
//   String label = 'Advertisement',
//   bool isLoading = false,
// }) {
//   return Container(
//     height: height,
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Colors.grey.shade200,
//           Colors.grey.shade100,
//         ],
//       ),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.grey.shade300),
//     ),
//     child: Stack(
//       children: [
//         // 🔹 Ad Label (Top Right)
//         Positioned(
//           top: 8,
//           right: 10,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               "Ad",
//               style: TextStyle(fontSize: 10, color: Colors.black54),
//             ),
//           ),
//         ),

//         // 🔹 Center Content
//         Center(
//           child: isLoading
//               ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.campaign_outlined,
//                       color: Colors.grey.shade500,
//                       size: 28,
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       label,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ],
//     ),
//   );
// }
// }

// // ---------------------------- Related Slugs Wrap ----------------------------
// class RelatedSlugsWrap extends StatelessWidget {
//   final List<String> slugs;

//   const RelatedSlugsWrap({
//     super.key,
//     required this.slugs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (slugs.isEmpty) return const SizedBox.shrink();

//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: slugs.map((slug) {
//         return _SlugChip(slug: slug);
//       }).toList(),
//     );
//   }
// }

// // ---------------------------- Slug Chip ----------------------------
// class _SlugChip extends StatelessWidget {
//   final String slug;

//   const _SlugChip({required this.slug});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return ActionChip(
//       elevation: 0,
//       pressElevation: 2,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

//       label: Text(
//         _formatSlug(slug),
//         style: theme.textTheme.labelMedium?.copyWith(
//           fontWeight: FontWeight.w600,
//         ),
//       ),

//       avatar: const Icon(
//         Icons.tag,
//         size: 16,
//         color: Color(0xFF2A5298),
//       ),

//       backgroundColor: const Color(0xFF2A5298).withOpacity(0.08),

//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         side: const BorderSide(
//           color: Color(0xFF2A5298),
//           width: 1,
//         ),
//       ),

//       onPressed: () => _navigate(context, slug),
//     );
//   }

//   // ---------------------------- Navigation ----------------------------
//   void _navigate(BuildContext context, String slug) {
//     // Navigator.pushReplacementNamed(
//     //   context,
//     //   '/flutter/$slug',
//     // );
//     context.go('/tech/flutter/$slug');
//   }

//   // ---------------------------- Slug Formatter ----------------------------
//   String _formatSlug(String slug) {
//     return slug
//         .replaceFirst('flutter-', '')
//         .split('-')
//         .map((word) =>
//             word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
//         .join(' ');
//   }
// }
