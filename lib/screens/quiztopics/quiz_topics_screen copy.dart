// // lib/screens/topics/topics_screen.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:techtutorial/core/meta_service.dart';
// import 'package:techtutorial/screens/quiztopics/quiz_topic_card.dart';

// import '../../models/topic_screen_config.dart';
// import '../../models/tutorial_topic.dart';
// import '../../utils/json_parser.dart';
// import '../../core/theme.dart';

// class QuizTopicsScreen extends StatefulWidget {
//   final String category;

//   const QuizTopicsScreen({super.key, required this.category});
  
//   static final Map<String, List<TutorialTopic>> _cachedTopics = {};
  
//   static List<TutorialTopic> getTopicsByCategory(String category) {
//     return _cachedTopics[category.toLowerCase()] ?? [];
//   }
  
//   static void clearCache() {
//     _cachedTopics.clear();
//   }

//   @override
//   State<QuizTopicsScreen> createState() => _QuizTopicsScreenState();
// }

// class _QuizTopicsScreenState extends State<QuizTopicsScreen>
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
//   @override
//   bool get wantKeepAlive => true;

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

//   ScreenConfig? _config;
//   bool _isLoadingConfig = true;

//   final ScrollController _scrollController = ScrollController();
//   SharedPreferences? _prefs;

//   late AnimationController _heroController;
//   late Animation<double> _heroAnimation;

//   // Pagination
//   int _displayCount = 20;
//   final int _loadMoreThreshold = 10;

//   @override
//   void initState() {
//     super.initState();
//     _updateSEOMetaTags();
//     _loadConfiguration();
//     if (kIsWeb) {
//       _addH1("${widget.category} Tutorials");
//     }
//     _initAll();
//     _setupAnimations();
//     _scrollController.addListener(_onScroll);
//   }

//   void _addH1(String text) {
//     final existing = html.document.querySelector('.seo-h1');
//     existing?.remove();

//     final h1 = html.HeadingElement.h1()
//       ..text = text
//       ..className = 'seo-h1'
//       ..style.position = 'absolute'
//       ..style.left = '-9999px'
//       ..style.top = '-9999px'
//       ..style.width = '1px'
//       ..style.height = '1px'
//       ..style.overflow = 'hidden';

//     html.document.body?.append(h1);
//   }

//   @override
//   void didUpdateWidget(covariant QuizTopicsScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.category != widget.category) {
//       _updateSEOMetaTags();
//       if (kIsWeb) {
//         _addH1("${widget.category} Tutorials");
//       }
//       _resetAndReload();
//     }
//   }

//   void _resetAndReload() {
//     setState(() {
//       _isLoading = true;
//       allTopics = [];
//       groupedTopics = {};
//       groupedFilteredTopics = {};
//       _completedTopics.clear();
//       _searchQuery = '';
//       _searchController.clear();
//       _selectedDifficulty = 'All';
//       _displayCount = 20;
//     });
//     _initAll();
//   }

//   void _updateSEOMetaTags() {
//     if (!kIsWeb) return;
    
//     final categoryName = widget.category;
//     final capitalizedCategory = categoryName[0].toUpperCase() + categoryName.substring(1);
    
//     MetaService.updateMetaTags(
//       title: "$capitalizedCategory Tutorials - Revochamp",
//       description: "Learn $capitalizedCategory with step-by-step tutorials, practical examples, and best practices. Master ${capitalizedCategory.toLowerCase()} from beginner to advanced. Free tutorials with hands-on examples.",
//       slug: "tech/$categoryName",
//       keywords: [categoryName, "tutorial", "learn $categoryName", "$categoryName guide", "programming", "$categoryName examples"],
//       isArticle: false,
//     );
//   }

//   void _updateFilteredMeta(String searchQuery, String difficulty, int resultCount) {
//     if (!kIsWeb) return;
    
//     if (searchQuery.isNotEmpty) {
//       MetaService.updateMetaTags(
//         title: "Search: $searchQuery - ${widget.category} Tutorials",
//         description: "Found $resultCount results for '$searchQuery' in ${widget.category}. Learn ${widget.category} with our comprehensive tutorials.",
//         slug: "tech/${widget.category}?q=$searchQuery",
//         isArticle: false,
//         noIndex: true,
//       );
//     } else if (difficulty != 'All') {
//       MetaService.updateMetaTags(
//         title: "$difficulty Level ${widget.category} Tutorials",
//         description: "Browse $difficulty level ${widget.category} tutorials. Perfect for ${difficulty.toLowerCase()} developers looking to enhance their skills.",
//         slug: "tech/${widget.category}/difficulty/${difficulty.toLowerCase()}",
//         isArticle: false,
//       );
//     } else {
//       _updateSEOMetaTags();
//     }
//   }

//   String getBaseUrl() => 'https://json.revochamp.site/mockinterview/${widget.category}/topics.json';
//   String getConfigUrl() => 'https://json.revochamp.site/mockinterview/${widget.category}/config.json';

//   void _setupAnimations() {
//     _heroController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _heroAnimation = CurvedAnimation(
//       parent: _heroController,
//       curve: Curves.easeOutCubic,
//     );
//     _heroController.forward();
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
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _heroController.dispose();
//     super.dispose();
//   }

//   Future<void> _initAll() async {
//     final normalizedCategory = widget.category.toLowerCase();
    
//     if (QuizTopicsScreen._cachedTopics.containsKey(normalizedCategory)) {
//       _applyData(
//         topics: QuizTopicsScreen._cachedTopics[normalizedCategory]!,
//         completed: _completedTopics,
//         lastTopic: _lastTopicSlug,
//       );
//       return;
//     }

//     try {
//       _prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;

//       final response = await http.get(Uri.parse(getBaseUrl()));

//       if (response.statusCode != 200) {
//         throw Exception('HTTP ${response.statusCode}');
//       }

//       final topics = await compute(parseTopics, response.body);

//       if (topics.isEmpty) {
//         throw Exception('No topics found');
//       }

//       QuizTopicsScreen._cachedTopics[normalizedCategory] = topics;

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
//       _showErrorSnackbar('Failed to load topics');
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
//     final grouped = _groupTopicsSync(topics);
    
//     if (mounted) {
//       setState(() {
//         allTopics = topics;
//         groupedTopics = grouped;
//         groupedFilteredTopics = grouped;
//         _completedTopics.addAll(completed);
//         _lastTopicSlug = lastTopic;
//         _isLoading = false;
//       });
//       _updateCollectionPageSchema();
//       _setBreadcrumbSchema();
//       _setFaqSchema();
//     }
//   }

//   void _setFaqSchema() {
//     if (!kIsWeb) return;
    
//     // MetaService.setFaqSchema([
//     //   {
//     //     "question": "What is ${widget.category}?",
//     //     "answer": "${widget.category} is a technology used for modern application development."
//     //   },
//     //   {
//     //     "question": "How to learn ${widget.category} effectively?",
//     //     "answer": "Start with fundamentals, practice with hands-on examples, build real projects, and join developer communities."
//     //   },
//     //   {
//     //     "question": "Is ${widget.category} good for beginners?",
//     //     "answer": "Yes, ${widget.category} has excellent learning resources and a supportive community for beginners."
//     //   }
//     // ]);
  
//   }

//   void _updateCollectionPageSchema() {
//     if (!kIsWeb) return;
    
//     final items = allTopics.take(20).map((topic) {
//       return {
//         'name': topic.title,
//         'url': 'https://revochamp.site/tech/${widget.category}/${topic.slug}',
//       };
//     }).toList();
    
//     MetaService.setCollectionPageSchema(
//       name: "${widget.category} Tutorials",
//       description: "Complete collection of ${widget.category} tutorials with practical examples",
//       url: "https://revochamp.site/tech/${widget.category}",
//       items: items,
//     );
//   }

//   void _setBreadcrumbSchema() {
//     if (!kIsWeb) return;
    
//     MetaService.setBreadcrumbData(
//       title: widget.category,
//       slug: "tech/${widget.category}",
//       parents: [
//         {'name': 'Home', 'url': 'https://revochamp.site/'},
//         {'name': 'Courses', 'url': 'https://revochamp.site/tech/courses'},
//       ],
//     );
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >= 
//         _scrollController.position.maxScrollExtent - 300) {
//       _loadMore();
//     }
//   }

//   void _loadMore() {
//     if (!mounted) return;
//     final totalItems = _getCurrentDisplayTopics().length;
//     if (totalItems < _getTotalFilteredCount()) {
//       setState(() {
//         _displayCount += 20;
//       });
//     }
//   }

//   int _getTotalFilteredCount() {
//     return groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);
//   }

//   List<TutorialTopic> _getCurrentDisplayTopics() {
//     final allFiltered = groupedFilteredTopics.values.expand((list) => list).toList();
//     return allFiltered.take(_displayCount).toList();
//   }

//   Map<String, List<TutorialTopic>> _groupTopicsSync(List<TutorialTopic> topics) {
//     final map = <String, List<TutorialTopic>>{};
//     for (final t in topics) {
//       final category = t.category.isNotEmpty ? t.category : 'General';
//       map.putIfAbsent(category, () => []).add(t);
//     }
//     return map;
//   }

//   void _applyFilters() {
//     if (!mounted) return;
//     final query = _searchQuery.trim().toLowerCase();
//     final filteredBySearch = query.isEmpty
//         ? allTopics
//         : allTopics.where((t) => t.title.toLowerCase().contains(query)).toList();

//     final filtered = _selectedDifficulty == 'All'
//         ? filteredBySearch
//         : filteredBySearch.where((t) => t.level == _selectedDifficulty).toList();

//     final grouped = _groupTopicsSync(filtered);

//     setState(() {
//       groupedFilteredTopics = grouped;
//       _displayCount = 20;
//     });
    
//     _updateFilteredMeta(query, _selectedDifficulty, filtered.length);
//   }

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

//   Future<void> _saveLastTopic(String slug) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setString('last_topic_${widget.category}', slug);
//   }

//   Future<void> _saveCompletedTopics() async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setStringList('completed_${widget.category}', _completedTopics.toList());
//   }

//   void _shareTopicsPage() {
//     final url = 'https://revochamp.site/tech/${widget.category}';
//     final title = '${widget.category} Tutorials - Revochamp';
    
//     if (kIsWeb && html.window.navigator.share != null) {
//       html.window.navigator.share!({
//         'title': title,
//         'text': 'Check out these ${widget.category} tutorials!',
//         'url': url,
//       }).catchError((_) => _copyToClipboard(url));
//     } else {
//       _copyToClipboard(url);
//     }
//   }

//   void _copyToClipboard(String text) {
//     // html.window.navigator.clipboard.writeText(text);
//     _showSnackBar('Link copied to clipboard!');
//   }

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
//     final width = MediaQuery.of(context).size.width;
//     if (width >= 1400) return 4;
//     if (width >= 1000) return 3;
//     if (width >= 600) return 2;
//     return 1;
//   }

//   String _getLastUpdatedDate() {
//     return _formatDate(DateTime.now());
//   }

//   String _formatDate(DateTime date) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return '${months[date.month - 1]} ${date.year}';
//   }

//   List<Map<String, String>> _getRelatedCategories() {
//     final relations = {
//       'dart': [
//         {'name': 'Flutter Basics', 'slug': 'flutter-basics'},
//         {'name': 'OOP Concepts', 'slug': 'oop'},
//         {'name': 'Async Programming', 'slug': 'async-programming'},
//       ],
//       'flutter': [
//         {'name': 'Widgets', 'slug': 'widgets'},
//         {'name': 'State Management', 'slug': 'state-management'},
//         {'name': 'Animations', 'slug': 'animations'},
//       ],
//     };
    
//     return relations[widget.category.toLowerCase()] ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
    
//     final crossAxisCount = _getGridCrossAxisCount(context);
//     final mobile = isMobile;
//     final features = _config?.features ?? FeatureFlags.getDefault();
//     final displayTopics = _getCurrentDisplayTopics();
//     final hasMore = displayTopics.length < _getTotalFilteredCount();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _isLoading || _isLoadingConfig
//           ? _buildLoadingState()
//           : CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 _buildAppBar(mobile),
//                 SliverToBoxAdapter(child: _buildBreadcrumbs(mobile)),
//                 // SliverToBoxAdapter(
//                 //   child: Padding(
//                 //     padding: const EdgeInsets.symmetric(horizontal: 20),
//                 //     child: Text(
//                 //       "Learn ${widget.category} with step-by-step tutorials, examples, and real-world projects. Covers beginner to advanced concepts.",
//                 //       style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
//                 //     ),
//                 //   ),
//                 // ),
//                 if (features.showHeroSection)
//                   SliverToBoxAdapter(
//                     child: FadeTransition(
//                       opacity: _heroAnimation,
//                       child: _buildHeroSection(mobile),
//                     ),
//                   ),
//                 if (features.showProgressSection && allTopics.isNotEmpty)
//                   SliverToBoxAdapter(child: _buildProgressSection(mobile)),
//                 if (features.showStatsSection && allTopics.isNotEmpty)
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
//                   ..._buildGroupedContent(crossAxisCount, mobile, displayTopics),
//                 if (hasMore)
//                   const SliverToBoxAdapter(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//                   ),
//                 SliverToBoxAdapter(child: _buildRelatedCategories()),
//                 SliverToBoxAdapter(child: _buildLastUpdated()),
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

//   List<Widget> _buildGroupedContent(int crossAxisCount, bool mobile, List<TutorialTopic> displayTopics) {
//     final Map<String, List<TutorialTopic>> groupedDisplay = {};
//     for (final topic in displayTopics) {
//       final category = topic.category.isNotEmpty ? topic.category : 'General';
//       groupedDisplay.putIfAbsent(category, () => []).add(topic);
//     }

//     return groupedDisplay.entries.expand((entry) {
//       final categoryName = entry.key;
//       final topicsInCategory = entry.value;
      
//       return [
//         SliverToBoxAdapter(
//           child: _buildCategoryHeader(categoryName, mobile),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           sliver: SliverGrid(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 final topic = topicsInCategory[index];
//                 final isCompleted = _completedTopics.contains(topic.slug);
//                 return QuizTopicCard(
//                   topic: topic,
//                   isCompleted: isCompleted,
//                   onTap: () async {
//                               // context.go('/interview/${topic.slug}');
                  
//                     if (!_completedTopics.contains(topic.slug)) {
//                       setState(() {
//                         _completedTopics.add(topic.slug);
//                       });
//                       await _saveCompletedTopics();
//                     }
//                     await _saveLastTopic(topic.slug);
//                     if (context.mounted) {
//                       context.go('/interview/${widget.category}/${topic.slug}');
//                     }
//                   },
//                 );
//               },
//               childCount: topicsInCategory.length,
//             ),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               childAspectRatio: 3.5,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//           ),
//         ),
//         const SliverToBoxAdapter(child: SizedBox(height: 8)),
//       ];
//     }).toList();
//   }

//   SliverAppBar _buildAppBar(bool isMobile) {
//     return SliverAppBar(
//       pinned: true,
//       backgroundColor: Colors.white,
//       elevation: 0,
//       title: _buildLogo(),
//       centerTitle: false,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.share, color: PremiumTheme.textMuted),
//           onPressed: _shareTopicsPage,
//           tooltip: 'Share this page',
//         ),
//         if (!isMobile) ...[
//           TextButton(
//             onPressed: () => context.go('/'),
//             child: const Text("Home", style: TextStyle(color: PremiumTheme.textMuted, fontWeight: FontWeight.w500, fontSize: 14)),
//           ),
//           TextButton(
//             onPressed: () => context.go('/courses'),
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
//         const Text("RevoChamp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: PremiumTheme.textDark)),
//       ],
//     );
//   }

//   Widget _buildBreadcrumbs(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 12),
//       child: Row(
//         children: [
//           InkWell(
//             onTap: () => context.go('/'),
//             child: Text('Home', style: TextStyle(color: PremiumTheme.richBlue, fontSize: 13)),
//           ),
//           const Icon(Icons.chevron_right, size: 16, color: PremiumTheme.textLight),
//           InkWell(
//             onTap: () => context.go('/courses'),
//             child: Text('Courses', style: TextStyle(color: PremiumTheme.richBlue, fontSize: 13)),
//           ),
//           const Icon(Icons.chevron_right, size: 16, color: PremiumTheme.textLight),
//           Text(
//             widget.category,
//             style: TextStyle(color: PremiumTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
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
//             context.go('/interview/${widget.category}/${lastTopic.slug}');
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
//     final total = _getTotalFilteredCount();
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 8),
//       child: Text(
//         'Showing $total result${total != 1 ? 's' : ''}',
//         style: const TextStyle(fontSize: 12, color: PremiumTheme.textMuted, fontWeight: FontWeight.w500),
//       ),
//     );
//   }

//   Widget _buildCategoryHeader(String categoryName, bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(isMobile ? 20 : 20, 32, isMobile ? 20 : 20, 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             categoryName,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: PremiumTheme.textDark, letterSpacing: -0.3),
//           ),
//           const SizedBox(height: 8),
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
//               'Try adjusting your search or filter',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: PremiumTheme.textMuted, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRelatedCategories() {
//     final relatedCategories = _getRelatedCategories();
//     if (relatedCategories.isEmpty) return const SizedBox.shrink();
    
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: PremiumTheme.softGray,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Explore More Topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: relatedCategories.map((category) {
//               return ActionChip(
//                 label: Text(category['name']!),
//                 onPressed: () {
//                   context.go('/${category['slug']}');
//                 },
//                 backgroundColor: Colors.white,
//                 side: BorderSide(color: PremiumTheme.lightGray),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLastUpdated() {
//     final lastUpdated = _getLastUpdatedDate();
    
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.update, size: 12, color: PremiumTheme.textLight),
//           const SizedBox(width: 4),
//           Text(
//             'Last updated: $lastUpdated',
//             style: const TextStyle(fontSize: 11, color: PremiumTheme.textLight),
//           ),
//         ],
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
