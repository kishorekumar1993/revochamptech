// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../core/theme.dart';
// import '../../models/tutorial_topic.dart';
// import '../../utils/json_parser.dart';
// import 'topic_card.dart';

// class TopicsScreen extends StatefulWidget {
//   const TopicsScreen({super.key});

//   static final List<TutorialTopic> _cachedTopics = [];
//   static List<TutorialTopic> get cachedTopics => _cachedTopics;
//   static const String baseUrl = 'https://json.revochamp.site/flutter/topics.json';

//   @override
//   State<TopicsScreen> createState() => _TopicsScreenState();
// }

// class _TopicsScreenState extends State<TopicsScreen> {
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

//   // Scroll controller for FAB
//   final ScrollController _scrollController = ScrollController();

//   // Cached SharedPreferences instance
//   SharedPreferences? _prefs;

//   @override
//   void initState() {
//     super.initState();
//     _initAll();
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // --------------------------------------------------------------
//   // 1. Initialisation
//   // --------------------------------------------------------------
//   Future<void> _initAll() async {
//     if (TopicsScreen._cachedTopics.isNotEmpty) {
//       _applyData(
//         topics: TopicsScreen._cachedTopics,
//         completed: _completedTopics,
//         lastTopic: _lastTopicSlug,
//       );
//       return;
//     }

//     try {
//       _prefs = await SharedPreferences.getInstance();

//       final response = await http.get(Uri.parse(TopicsScreen.baseUrl));
//       if (response.statusCode != 200) {
//         throw Exception('HTTP ${response.statusCode}');
//       }
//       final topics = await compute(parseTopics, response.body);

//       TopicsScreen._cachedTopics.clear();
//       TopicsScreen._cachedTopics.addAll(topics);

//       _applyData(
//         topics: topics,
//         completed: _prefs!.getStringList('completed') ?? [],
//         lastTopic: _prefs!.getString('last_topic'),
//       );
//     } catch (e) {
//       _showErrorSnackbar('Failed to load topics: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   void _applyData({
//     required List<TutorialTopic> topics,
//     required Iterable<String> completed,
//     String? lastTopic,
//   }) {
//     compute(_groupTopicsIsolate, topics).then((grouped) {
//       setState(() {
//         allTopics = topics;
//         groupedTopics = grouped;
//         groupedFilteredTopics = grouped;
//         _completedTopics.addAll(completed);
//         _lastTopicSlug = lastTopic;
//         _isLoading = false;
//       });
//     }).catchError((e) {
//       final grouped = _groupTopicsSync(topics);
//       setState(() {
//         allTopics = topics;
//         groupedTopics = grouped;
//         groupedFilteredTopics = grouped;
//         _completedTopics.addAll(completed);
//         _lastTopicSlug = lastTopic;
//         _isLoading = false;
//       });
//     });
//   }

//   // --------------------------------------------------------------
//   // 2. Grouping (isolated + sync fallback)
//   // --------------------------------------------------------------
//   static Map<String, List<TutorialTopic>> _groupTopicsIsolate(List<TutorialTopic> topics) {
//     final map = <String, List<TutorialTopic>>{};
//     for (final t in topics) {
//       map.putIfAbsent(t.category, () => []).add(t);
//     }
//     return map;
//   }

//   Map<String, List<TutorialTopic>> _groupTopicsSync(List<TutorialTopic> topics) {
//     final map = <String, List<TutorialTopic>>{};
//     for (final t in topics) {
//       map.putIfAbsent(t.category, () => []).add(t);
//     }
//     return map;
//   }

//   // --------------------------------------------------------------
//   // 3. Combined Filtering (search + difficulty)
//   // --------------------------------------------------------------
//   void _applyFilters() {
//     // 1. Filter by search query
//     final query = _searchQuery.trim().toLowerCase();
//     final filteredBySearch = query.isEmpty
//         ? allTopics
//         : allTopics.where((t) => t.title.toLowerCase().contains(query)).toList();

//     // 2. Filter by difficulty (if not 'All')
//     final filtered = _selectedDifficulty == 'All'
//         ? filteredBySearch
//         : filteredBySearch.where((t) => t.level == _selectedDifficulty).toList();

//     // 3. Group the final list
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

//   // --------------------------------------------------------------
//   // 5. SharedPreferences helpers
//   // --------------------------------------------------------------
//   Future<void> _saveLastTopic(String slug) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setString('last_topic', slug);
//   }

//   // --------------------------------------------------------------
//   // 6. Helpers
//   // --------------------------------------------------------------
//   void _showErrorSnackbar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   double get _progress => allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;
//   int get _totalFilteredTopics => groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);

//   void _scrollToTop() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   int _getGridCrossAxisCount(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width >= 1200) return 4;
//     if (width >= 800) return 3;
//     return 1;
//   }

//   // --------------------------------------------------------------
//   // 7. UI Build (OPTIMIZED ORDER)
//   // --------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final crossAxisCount = _getGridCrossAxisCount(context);

//     return Scaffold(
//       appBar: buildSmartAppBar(
//         context,
//         progress: _progress,
//         lastTopic: _lastTopicSlug,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.brightness == Brightness.dark ? Colors.grey[900]! : const Color(0xFFF8FAFC),
//               theme.brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFEFF3F8),
//             ],
//           ),
//         ),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : CustomScrollView(
//                 controller: _scrollController, // ← Attach controller
//                 slivers: [
//                   // 1. Breadcrumb (SEO)
//                   SliverToBoxAdapter(child: _buildBreadcrumb()),

//                   // 2. Hero (value + CTA)
//                   SliverToBoxAdapter(child: _buildHero()),

//                   // 3. Start Here (onboarding for new users)
//                   SliverToBoxAdapter(child: _buildStartHere()),

//                   // 4. Continue Learning (returning users)
//                   if (_lastTopicSlug != null && _lastTopicSlug!.isNotEmpty)
//                     SliverToBoxAdapter(child: _buildContinueBanner()),

//                   // 5. Progress Bar (motivation)
//                   SliverToBoxAdapter(child: _buildProgressBar()),

//                   // 6. Features + Trust (what we offer, credibility)
//                   // SliverToBoxAdapter(child: _buildFeatureRow()),
//                   // SliverToBoxAdapter(child: _buildTrustSignals()),

//                   // 7. Search + Result Count + Difficulty Filter
//                   SliverToBoxAdapter(child: _buildSearchField()),
//                   SliverToBoxAdapter(child: _buildResultCount()),
//                   SliverToBoxAdapter(child: _buildDifficultyFilter()),

//                   // 8. Learning Path (visual guide)
//                   // SliverToBoxAdapter(child: _buildLearningPath()),

//                   // 9. Popular Topics (social proof / discovery)
//                   // SliverToBoxAdapter(child: _buildPopularTopics()),

//                   // 10. Topics Grid / Empty State
//                   if (groupedFilteredTopics.isEmpty)
//                     SliverToBoxAdapter(child: _buildEmptyState())
//                   else
//                     ...groupedFilteredTopics.entries.expand((entry) {
//                       final category = entry.key;
//                       final topicsInCategory = entry.value;
//                       if (topicsInCategory.isEmpty) return <Widget>[];

//                       return [
//                         SliverToBoxAdapter(
//                           child: _buildCategoryHeader(category, _getCategoryDescription(category)),
//                         ),
//                         SliverPadding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           sliver: SliverGrid(
//                             delegate: SliverChildBuilderDelegate(
//                               (context, index) {
//                                 final topic = topicsInCategory[index];
//                                 final isCompleted = _completedTopics.contains(topic.slug);
//                                 return TopicCard(
//                                   topic: topic,
//                                   isCompleted: isCompleted,
//                                   onTap: () async {
//                                     // Mark as completed
//                                     if (!_completedTopics.contains(topic.slug)) {
//                                       setState(() {
//                                         _completedTopics.add(topic.slug);
//                                       });
//                                       final prefs = await SharedPreferences.getInstance();
//                                       await prefs.setStringList('completed', _completedTopics.toList());
//                                     }

//                                     _saveLastTopic(topic.slug);
//                                     context.go('/flutter/${topic.slug}');
//                                   },
//                                 );
//                               },
//                               childCount: topicsInCategory.length,
//                             ),
//                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: crossAxisCount,
//                               childAspectRatio:
//                                   MediaQuery.of(context).size.width > 700 ? 2.8 : 3.2,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                             ),
//                           ),
//                         ),
//                         const SliverToBoxAdapter(child: SizedBox(height: 16)),
//                       ];
//                     }),

//                   // 11. SEO Paragraph (long text for Google)
//                   SliverToBoxAdapter(child: _buildSeoParagraph()),

//                   const SliverToBoxAdapter(child: SizedBox(height: 20)),
//                 ],
//               ),
//       ),
//       floatingActionButton: allTopics.length > 10
//           ? FloatingActionButton(
//               mini: true,
//               onPressed: _scrollToTop,
//               child: const Icon(Icons.arrow_upward),
//             )
//           : null,
//     );
//   }

//   // ---------- Breadcrumb ----------
//   Widget _buildBreadcrumb() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Row(
//         children: [
//           Text(
//             "Home",
//             style: TextStyle(color: Colors.grey[600], fontSize: 12),
//           ),
//           const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
//           Text(
//             "Flutter Topics",
//             style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------- Hero Section (with CTA) ----------
//   Widget _buildHero() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: primaryGradient,
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Master Flutter 🚀",
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Learn Flutter with real examples, quizzes, and production-ready code.",
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               _heroBullet("✔ Beginner to Advanced"),
//               const SizedBox(width: 16),
//               _heroBullet("✔ Real-world examples"),
//               const SizedBox(width: 16),
//               _heroBullet("✔ Practice quizzes"),
//             ],
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               final firstCategory = groupedTopics.keys.firstOrNull;
//               if (firstCategory != null) {
//                 final firstTopic = groupedTopics[firstCategory]?.firstOrNull;
//                 if (firstTopic != null) {
//                   context.go('/flutter/${firstTopic.slug}');
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: const Color(0xFF1E3C72),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: const Text("Start Learning Flutter Now 🚀", style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _heroBullet(String text) {
//     return Text(
//       text,
//       style: const TextStyle(color: Colors.white70, fontSize: 12),
//     );
//   }

//   // ---------- Feature Row ----------
//   Widget _buildFeatureRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _featureItem(Icons.code, "Code Examples"),
//           _featureItem(Icons.quiz, "Quizzes"),
//           _featureItem(Icons.play_circle, "Live Practice"),
//         ],
//       ),
//     );
//   }

//   Widget _featureItem(IconData icon, String label) {
//     return Column(
//       children: [
//         Icon(icon, size: 32, color: const Color(0xFF2A5298)),
//         const SizedBox(height: 8),
//         Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//   // ---------- Trust Signals ----------
//   Widget _buildTrustSignals() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children:  [
//           _trustItem("100+", "Flutter Topics"),
//           _trustItem("Real-world", "Examples"),
//           _trustItem("Weekly", "Updates"),
//         ],
//       ),
//     );
//   }

//   static Widget _trustItem(String number, String label) {
//     return Column(
//       children: [
//         Text(
//           number,
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A5298)),
//         ),
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }

//   // ---------- Progress Bar ----------
//   Widget _buildProgressBar() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Your Progress',
//                 style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
//               ),
//               Text(
//                 '${_completedTopics.length}/${allTopics.length} topics',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2A5298),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: _progress,
//             backgroundColor: Colors.grey[300],
//             color: const Color(0xFF2A5298),
//             minHeight: 8,
//             borderRadius: BorderRadius.circular(4),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _progress > 0.8
//                 ? "Keep going! You're doing great 🚀"
//                 : "Keep learning, one step at a time!",
//             style: const TextStyle(fontSize: 12, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------- Continue Banner ----------
//   Widget _buildContinueBanner() {
//     final lastTopic = allTopics.firstWhere(
//       (t) => t.slug == _lastTopicSlug,
//       orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', category: '',level: ""),
//     );
//     if (lastTopic.slug.isEmpty) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: Card(
//         color: const Color(0xFF2A5298).withOpacity(0.1),
//         child: ListTile(
//           leading: const Icon(Icons.play_circle_fill, color: Color(0xFF2A5298), size: 36),
//           title: Text('Continue: ${lastTopic.title}'),
//           subtitle: const Text('Tap to resume'),
//           trailing: const Icon(Icons.arrow_forward),
//           onTap: () {
//             _saveLastTopic(lastTopic.slug);
//             context.go('/${lastTopic.category}/${lastTopic.slug}');
//           },
//         ),
//       ),
//     );
//   }

//   // ---------- Start Here Section ----------
//   Widget _buildStartHere() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [const Color(0xFF2A5298).withOpacity(0.1), const Color(0xFF2A5298).withOpacity(0.05)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.bolt, color: Color(0xFF2A5298), size: 28),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "New to Flutter? Start here 👇",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "We recommend beginning with Dart Basics and then moving to Widgets.",
//                   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------- Search Field (with clear button) ----------
//   Widget _buildSearchField() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search topics...',
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: _searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     _searchController.clear();
//                     setState(() {
//                       _searchQuery = '';
//                     });
//                     _applyFilters();
//                   },
//                 )
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         onChanged: _onSearchChanged,
//       ),
//     );
//   }

//   // ---------- Result Count ----------
//   Widget _buildResultCount() {
//     // Show only if either search or filter is active
//     if (_searchQuery.isEmpty && _selectedDifficulty == 'All') return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
//       child: Text(
//         "Showing $_totalFilteredTopics result${_totalFilteredTopics != 1 ? 's' : ''}",
//         style: const TextStyle(fontSize: 12, color: Colors.grey),
//       ),
//     );
//   }

//   // ---------- Difficulty Filter (working) ----------
//   Widget _buildDifficultyFilter() {
//     final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: difficulties.map((level) {
//             final isSelected = _selectedDifficulty == level;
//             return Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: FilterChip(
//                 label: Text(level),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   setState(() {
//                     _selectedDifficulty = level;
//                   });
//                   _applyFilters();
//                 },
//                 backgroundColor: Colors.grey[200],
//                 selectedColor: const Color(0xFF2A5298),
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.white : Colors.grey[800],
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   side: isSelected
//                       ? BorderSide.none
//                       : BorderSide(color: Colors.grey[300]!),
//                 ),
//                 elevation: isSelected ? 2 : 0,
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   // ---------- Learning Path ----------
//   Widget _buildLearningPath() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "📚 Learning Path",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           _step("1. Dart Basics"),
//           _step("2. Flutter Widgets"),
//           _step("3. State Management"),
//           _step("4. API Integration"),
//           _step("5. Advanced Concepts"),
//         ],
//       ),
//     );
//   }

//   Widget _step(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           const Icon(Icons.check_circle, size: 16, color: Color(0xFF2A5298)),
//           const SizedBox(width: 8),
//           Text(text, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   // ---------- Popular Topics ----------
//   Widget _buildPopularTopics() {
//     final popular = allTopics.take(5).toList();
//     if (popular.isEmpty) return const SizedBox.shrink();

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "🔥 Popular Topics",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           ...popular.map((topic) => ListTile(
//                 leading: const Icon(Icons.star, color: Colors.amber, size: 20),
//                 title: Text(topic.title),
//                 subtitle: Text(_getTopicDescription(topic)),
//                 dense: true,
//                 onTap: () {
//                   _saveLastTopic(topic.slug);
//                   context.go('/flutter/${topic.slug}');
//                 },
//               )),
//         ],
//       ),
//     );
//   }

//   // ---------- Category Header with Description ----------
//   Widget _buildCategoryHeader(String category, String description) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 24, left: 20, bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             category,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1E3C72),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             description,
//             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper: category description
//   String _getCategoryDescription(String category) {
//     switch (category.toLowerCase()) {
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
//         return 'Learn $category concepts with practical examples.';
//     }
//   }

//   // Helper: topic description (fallback if model doesn't have it)
//   String _getTopicDescription(TutorialTopic topic) {
//     // If your TutorialTopic model has a description field, use it.
//     return 'Learn ${topic.title} with step-by-step examples and quizzes.';
//   }

//   // ---------- Empty State ----------
//   Widget _buildEmptyState() {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(40),
//         child: Column(
//           children: [
//             Icon(Icons.search_off, size: 48, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No topics found 😔',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Try searching for "Flutter", "Widgets", or "State Management"',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------- SEO Paragraph ----------
//   Widget _buildSeoParagraph() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Text(
//         "Flutter is an open-source UI toolkit by Google used to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. In this tutorial, you will learn Flutter step-by-step with real-world examples, covering widgets, layouts, state management, API integration, and advanced concepts. Whether you are a beginner or an experienced developer, this comprehensive Flutter tutorial will help you master the framework and build production-ready apps. Start your Flutter journey today with our curated topics, interactive quizzes, and live code editor.",
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey[600],
//           height: 1.5,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// // ---------- AppBar ----------
// AppBar buildSmartAppBar(
//   BuildContext context, {
//   required double progress,
//   required String? lastTopic,
// }) {
//   return AppBar(
//     elevation: 0,
//     toolbarHeight: 65,
//     backgroundColor: const Color(0xFF1E3C72),
//     title: Row(
//       children: [
//         const Icon(Icons.school, color: Colors.white),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Revochamp",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 lastTopic != null ? "Continue Learning" : "Flutter Tutorials",
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//     actions: [
//       if (lastTopic != null)
//         IconButton(
//           icon: const Icon(Icons.play_arrow),
//           tooltip: "Continue",
//           onPressed: () {
//             GoRouter.of(context).go('/flutter/$lastTopic');
//           },
//         ),
//       IconButton(
//         icon: const Icon(Icons.search),
//         onPressed: () {
//           // open search
//         },
//       ),
//       Padding(
//         padding: const EdgeInsets.only(right: 12),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               "${(progress * 100).toInt()}%",
//               style: const TextStyle(
//                 fontSize: 11,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

// // import 'dart:async';

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../../core/theme.dart';
// // import '../../models/tutorial_topic.dart';
// // import '../../utils/json_parser.dart';
// // import 'topic_card.dart';

// // class TopicsScreen extends StatefulWidget {
// //   const TopicsScreen({super.key});

// //   static final List<TutorialTopic> _cachedTopics = [];
// //   static List<TutorialTopic> get cachedTopics => _cachedTopics;
// //   static const String baseUrl = 'https://json.revochamp.site/flutter/topics.json';

// //   @override
// //   State<TopicsScreen> createState() => _TopicsScreenState();
// // }

// // class _TopicsScreenState extends State<TopicsScreen> {
// //   // Data
// //   List<TutorialTopic> allTopics = [];
// //   Map<String, List<TutorialTopic>> groupedTopics = {};
// //   Map<String, List<TutorialTopic>> groupedFilteredTopics = {};

// //   // UI state
// //   final TextEditingController _searchController = TextEditingController();
// //   final Set<String> _completedTopics = {};
// //   bool _isLoading = true;
// //   String? _lastTopicSlug;
// //   Timer? _debounce;
// //   String _selectedDifficulty = 'All';
// //   String _searchQuery = '';          // holds current search query

// //   // Cached SharedPreferences instance
// //   SharedPreferences? _prefs;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initAll();
// //   }

// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   // --------------------------------------------------------------
// //   // 1. Initialisation
// //   // --------------------------------------------------------------
// //   Future<void> _initAll() async {
// //     if (TopicsScreen._cachedTopics.isNotEmpty) {
// //       _applyData(
// //         topics: TopicsScreen._cachedTopics,
// //         completed: _completedTopics,
// //         lastTopic: _lastTopicSlug,
// //       );
// //       return;
// //     }

// //     try {
// //       _prefs = await SharedPreferences.getInstance();

// //       final response = await http.get(Uri.parse(TopicsScreen.baseUrl));
// //       if (response.statusCode != 200) {
// //         throw Exception('HTTP ${response.statusCode}');
// //       }
// //       final topics = await compute(parseTopics, response.body);

// //       TopicsScreen._cachedTopics.clear();
// //       TopicsScreen._cachedTopics.addAll(topics);

// //       _applyData(
// //         topics: topics,
// //         completed: _prefs!.getStringList('completed') ?? [],
// //         lastTopic: _prefs!.getString('last_topic'),
// //       );
// //     } catch (e) {
// //       _showErrorSnackbar('Failed to load topics: $e');
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   void _applyData({
// //     required List<TutorialTopic> topics,
// //     required Iterable<String> completed,
// //     String? lastTopic,
// //   }) {
// //     compute(_groupTopicsIsolate, topics).then((grouped) {
// //       setState(() {
// //         allTopics = topics;
// //         groupedTopics = grouped;
// //         groupedFilteredTopics = grouped;
// //         _completedTopics.addAll(completed);
// //         _lastTopicSlug = lastTopic;
// //         _isLoading = false;
// //       });
// //     }).catchError((e) {
// //       final grouped = _groupTopicsSync(topics);
// //       setState(() {
// //         allTopics = topics;
// //         groupedTopics = grouped;
// //         groupedFilteredTopics = grouped;
// //         _completedTopics.addAll(completed);
// //         _lastTopicSlug = lastTopic;
// //         _isLoading = false;
// //       });
// //     });
// //   }

// //   // --------------------------------------------------------------
// //   // 2. Grouping (isolated + sync fallback)
// //   // --------------------------------------------------------------
// //   static Map<String, List<TutorialTopic>> _groupTopicsIsolate(List<TutorialTopic> topics) {
// //     final map = <String, List<TutorialTopic>>{};
// //     for (final t in topics) {
// //       map.putIfAbsent(t.category, () => []).add(t);
// //     }
// //     return map;
// //   }

// //   Map<String, List<TutorialTopic>> _groupTopicsSync(List<TutorialTopic> topics) {
// //     final map = <String, List<TutorialTopic>>{};
// //     for (final t in topics) {
// //       map.putIfAbsent(t.category, () => []).add(t);
// //     }
// //     return map;
// //   }

// //   // --------------------------------------------------------------
// //   // 3. Combined Filtering (search + difficulty)
// //   // --------------------------------------------------------------
// //   void _applyFilters() {
// //     // 1. Filter by search query
// //     final query = _searchQuery.trim().toLowerCase();
// //     final filteredBySearch = query.isEmpty
// //         ? allTopics
// //         : allTopics.where((t) => t.title.toLowerCase().contains(query)).toList();

// //     // 2. Filter by difficulty (if not 'All')
// //     final filtered = _selectedDifficulty == 'All'
// //         ? filteredBySearch
// //         : filteredBySearch.where((t) => t.level == _selectedDifficulty).toList();

// //     // 3. Group the final list
// //     final grouped = _groupTopicsSync(filtered);

// //     setState(() {
// //       groupedFilteredTopics = grouped;
// //     });
// //   }

// //   // --------------------------------------------------------------
// //   // 4. Search & Difficulty handlers
// //   // --------------------------------------------------------------
// //   void _onSearchChanged(String query) {
// //     _debounce?.cancel();
// //     _debounce = Timer(const Duration(milliseconds: 300), () {
// //       setState(() {
// //         _searchQuery = query;
// //       });
// //       _applyFilters();
// //     });
// //   }

// //   // --------------------------------------------------------------
// //   // 5. SharedPreferences helpers
// //   // --------------------------------------------------------------
// //   Future<void> _saveLastTopic(String slug) async {
// //     _prefs ??= await SharedPreferences.getInstance();
// //     await _prefs?.setString('last_topic', slug);
// //   }

// //   // --------------------------------------------------------------
// //   // 6. Helpers
// //   // --------------------------------------------------------------
// //   void _showErrorSnackbar(String message) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message)),
// //     );
// //   }

// //   double get _progress => allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;
// //   int get _totalFilteredTopics => groupedFilteredTopics.values.fold(0, (sum, list) => sum + list.length);

// //   void _scrollToTop() {
// //     final scrollable = Scrollable.of(context);
// //     scrollable.position.animateTo(
// //       0,
// //       duration: const Duration(milliseconds: 300),
// //       curve: Curves.easeOut,
// //     );
// //   }

// //   int _getGridCrossAxisCount(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //     if (width >= 1200) return 4;
// //     if (width >= 800) return 3;
// //     return 1;
// //   }

// //   // --------------------------------------------------------------
// //   // 7. UI Build (OPTIMIZED ORDER)
// //   // --------------------------------------------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final crossAxisCount = _getGridCrossAxisCount(context);

// //     return Scaffold(
// //       appBar: buildSmartAppBar(
// //         context,
// //         progress: _progress,
// //         lastTopic: _lastTopicSlug,
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [
// //               theme.brightness == Brightness.dark ? Colors.grey[900]! : const Color(0xFFF8FAFC),
// //               theme.brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFEFF3F8),
// //             ],
// //           ),
// //         ),
// //         child: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : CustomScrollView(
// //                 slivers: [
// //                   // 1. Breadcrumb (SEO)
// //                   // SliverToBoxAdapter(child: _buildBreadcrumb()),

// //                   // 2. Hero (value + CTA)
// //                   SliverToBoxAdapter(child: _buildHero()),

// //                   // 3. Start Here (onboarding for new users)
// //                   // SliverToBoxAdapter(child: _buildStartHere()),

// //                   // 4. Continue Learning (returning users)
// //                   if (_lastTopicSlug != null && _lastTopicSlug!.isNotEmpty)
// //                     SliverToBoxAdapter(child: _buildContinueBanner()),

// //                   // 5. Progress Bar (motivation)
// //                   SliverToBoxAdapter(child: _buildProgressBar()),

// //                   // 6. Features + Trust (what we offer, credibility)
// //                   // SliverToBoxAdapter(child: _buildFeatureRow()),
// //                   // SliverToBoxAdapter(child: _buildTrustSignals()),

// //                   // 7. Search + Result Count + Difficulty Filter
// //                   SliverToBoxAdapter(child: _buildSearchField()),
// //                   SliverToBoxAdapter(child: _buildResultCount()),
// //                   SliverToBoxAdapter(child: _buildDifficultyFilter()),

// //                   // 8. Learning Path (visual guide)
// //                   // SliverToBoxAdapter(child: _buildLearningPath()),

// //                   // 9. Popular Topics (social proof / discovery)
// //                   // SliverToBoxAdapter(child: _buildPopularTopics()),

// //                   // 10. Topics Grid / Empty State
// //                   if (groupedFilteredTopics.isEmpty)
// //                     SliverToBoxAdapter(child: _buildEmptyState())
// //                   else
// //                     ...groupedFilteredTopics.entries.expand((entry) {
// //                       final category = entry.key;
// //                       final topicsInCategory = entry.value;
// //                       if (topicsInCategory.isEmpty) return <Widget>[];

// //                       return [
// //                         SliverToBoxAdapter(
// //                           child: _buildCategoryHeader(category, _getCategoryDescription(category)),
// //                         ),
// //                         SliverPadding(
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           sliver: SliverGrid(
// //                             delegate: SliverChildBuilderDelegate(
// //                               (context, index) {
// //                                 final topic = topicsInCategory[index];
// //                                 final isCompleted = _completedTopics.contains(topic.slug);
// //                                 return TopicCard(
// //                                   topic: topic,
// //                                   isCompleted: isCompleted,
// //                                   onTap: () async {
// //                                     // Mark as completed
// //                                     if (!_completedTopics.contains(topic.slug)) {
// //                                       setState(() {
// //                                         _completedTopics.add(topic.slug);
// //                                       });
// //                                       final prefs = await SharedPreferences.getInstance();
// //                                       await prefs.setStringList('completed', _completedTopics.toList());
// //                                     }

// //                                     _saveLastTopic(topic.slug);
// //                                     context.go('/flutter/${topic.slug}');
// //                                   },
// //                                 );
// //                               },
// //                               childCount: topicsInCategory.length,
// //                             ),
// //                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                               crossAxisCount: crossAxisCount,
// //                               childAspectRatio:
// //                                   MediaQuery.of(context).size.width > 700 ? 2.8 : 3.2,
// //                               crossAxisSpacing: 12,
// //                               mainAxisSpacing: 12,
// //                             ),
// //                           ),
// //                         ),
// //                         const SliverToBoxAdapter(child: SizedBox(height: 16)),
// //                       ];
// //                     }),

// //                   // 11. SEO Paragraph (long text for Google)
// //                   SliverToBoxAdapter(child: _buildSeoParagraph()),

// //                   const SliverToBoxAdapter(child: SizedBox(height: 20)),
// //                 ],
// //               ),
// //       ),
// //       floatingActionButton: allTopics.length > 10
// //           ? FloatingActionButton(
// //               mini: true,
// //               onPressed: _scrollToTop,
// //               child: const Icon(Icons.arrow_upward),
// //             )
// //           : null,
// //     );
// //   }

// //   // ---------- Breadcrumb ----------
// //   Widget _buildBreadcrumb() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //       child: Row(
// //         children: [
// //           Text(
// //             "Home",
// //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
// //           ),
// //           const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
// //           Text(
// //             "Flutter Topics",
// //             style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------- Hero Section (with CTA) ----------
// //   Widget _buildHero() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         gradient: primaryGradient,
// //         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "Master Flutter 🚀",
// //             style: TextStyle(
// //               fontSize: 28,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.white,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           const Text(
// //             "Learn Flutter with real examples, quizzes, and production-ready code.",
// //             style: TextStyle(color: Colors.white70, fontSize: 16),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               _heroBullet("✔ Beginner to Advanced"),
// //               const SizedBox(width: 16),
// //               _heroBullet("✔ Real-world examples"),
// //               const SizedBox(width: 16),
// //               _heroBullet("✔ Practice quizzes"),
// //             ],
// //           ),
// //           const SizedBox(height: 24),
// //           ElevatedButton(
// //             onPressed: () {
// //               final firstCategory = groupedTopics.keys.firstOrNull;
// //               if (firstCategory != null) {
// //                 final firstTopic = groupedTopics[firstCategory]?.firstOrNull;
// //                 if (firstTopic != null) {
// //                   context.go('/flutter/${firstTopic.slug}');
// //                 }
// //               }
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: Colors.white,
// //               foregroundColor: const Color(0xFF1E3C72),
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(30),
// //               ),
// //             ),
// //             child: const Text("Start Learning Flutter Now 🚀", style: TextStyle(fontWeight: FontWeight.bold)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _heroBullet(String text) {
// //     return Text(
// //       text,
// //       style: const TextStyle(color: Colors.white70, fontSize: 12),
// //     );
// //   }

// //   // ---------- Feature Row ----------
// //   Widget _buildFeatureRow() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           _featureItem(Icons.code, "Code Examples"),
// //           _featureItem(Icons.quiz, "Quizzes"),
// //           _featureItem(Icons.play_circle, "Live Practice"),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _featureItem(IconData icon, String label) {
// //     return Column(
// //       children: [
// //         Icon(icon, size: 32, color: const Color(0xFF2A5298)),
// //         const SizedBox(height: 8),
// //         Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
// //       ],
// //     );
// //   }

// //   // ---------- Trust Signals ----------
// //   Widget _buildTrustSignals() {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             spreadRadius: 2,
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children:  [
// //           _trustItem("100+", "Flutter Topics"),
// //           _trustItem("Real-world", "Examples"),
// //           _trustItem("Weekly", "Updates"),
// //         ],
// //       ),
// //     );
// //   }

// //   static Widget _trustItem(String number, String label) {
// //     return Column(
// //       children: [
// //         Text(
// //           number,
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A5298)),
// //         ),
// //         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
// //       ],
// //     );
// //   }

// //   // ---------- Progress Bar ----------
// //   Widget _buildProgressBar() {
// //     return Padding(
// //       padding: const EdgeInsets.all(20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'Your Progress',
// //                 style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
// //               ),
// //               Text(
// //                 '${_completedTopics.length}/${allTopics.length} topics',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w600,
// //                   color: Color(0xFF2A5298),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           LinearProgressIndicator(
// //             value: _progress,
// //             backgroundColor: Colors.grey[300],
// //             color: const Color(0xFF2A5298),
// //             minHeight: 8,
// //             borderRadius: BorderRadius.circular(4),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             _progress > 0.8
// //                 ? "Keep going! You're doing great 🚀"
// //                 : "Keep learning, one step at a time!",
// //             style: const TextStyle(fontSize: 12, color: Colors.grey),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------- Continue Banner ----------
// //   Widget _buildContinueBanner() {
// //     final lastTopic = allTopics.firstWhere(
// //       (t) => t.slug == _lastTopicSlug,
// //       orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', category: '',level: ""),
// //     );
// //     if (lastTopic.slug.isEmpty) return const SizedBox.shrink();

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //       child: Card(
// //         color: const Color(0xFF2A5298).withOpacity(0.1),
// //         child: ListTile(
// //           leading: const Icon(Icons.play_circle_fill, color: Color(0xFF2A5298), size: 36),
// //           title: Text('Continue: ${lastTopic.title}'),
// //           subtitle: const Text('Tap to resume'),
// //           trailing: const Icon(Icons.arrow_forward),
// //           onTap: () {
// //             _saveLastTopic(lastTopic.slug);
// //             context.go('/${lastTopic.category}/${lastTopic.slug}');
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------- Start Here Section ----------
// //   Widget _buildStartHere() {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [const Color(0xFF2A5298).withOpacity(0.1), const Color(0xFF2A5298).withOpacity(0.05)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(16),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.bolt, color: Color(0xFF2A5298), size: 28),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   "New to Flutter? Start here 👇",
// //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   "We recommend beginning with Dart Basics and then moving to Widgets.",
// //                   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------- Search Field (with clear button) ----------
// //   Widget _buildSearchField() {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
// //       child: TextField(
// //         controller: _searchController,
// //         decoration: InputDecoration(
// //           hintText: 'Search topics...',
// //           prefixIcon: const Icon(Icons.search),
// //           suffixIcon: _searchController.text.isNotEmpty
// //               ? IconButton(
// //                   icon: const Icon(Icons.clear),
// //                   onPressed: () {
// //                     _searchController.clear();
// //                     setState(() {
// //                       _searchQuery = '';
// //                     });
// //                     _applyFilters();
// //                   },
// //                 )
// //               : null,
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(30),
// //           ),
// //         ),
// //         onChanged: _onSearchChanged,
// //       ),
// //     );
// //   }

// //   // ---------- Result Count ----------
// //   Widget _buildResultCount() {
// //     // Show only if either search or filter is active
// //     if (_searchQuery.isEmpty && _selectedDifficulty == 'All') return const SizedBox.shrink();
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
// //       child: Text(
// //         "Showing $_totalFilteredTopics result${_totalFilteredTopics != 1 ? 's' : ''}",
// //         style: const TextStyle(fontSize: 12, color: Colors.grey),
// //       ),
// //     );
// //   }

// //   // ---------- Difficulty Filter (working) ----------
// //   Widget _buildDifficultyFilter() {
// //     final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: Row(
// //           children: difficulties.map((level) {
// //             final isSelected = _selectedDifficulty == level;
// //             return Padding(
// //               padding: const EdgeInsets.only(right: 12),
// //               child: FilterChip(
// //                 label: Text(level),
// //                 selected: isSelected,
// //                 onSelected: (selected) {
// //                   setState(() {
// //                     _selectedDifficulty = level;
// //                   });
// //                   _applyFilters();
// //                 },
// //                 backgroundColor: Colors.grey[200],
// //                 selectedColor: const Color(0xFF2A5298),
// //                 labelStyle: TextStyle(
// //                   color: isSelected ? Colors.white : Colors.grey[800],
// //                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
// //                 ),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(30),
// //                   side: isSelected
// //                       ? BorderSide.none
// //                       : BorderSide(color: Colors.grey[300]!),
// //                 ),
// //                 elevation: isSelected ? 2 : 0,
// //               ),
// //             );
// //           }).toList(),
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------- Learning Path ----------
// //   Widget _buildLearningPath() {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             spreadRadius: 2,
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "📚 Learning Path",
// //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 12),
// //           _step("1. Dart Basics"),
// //           _step("2. Flutter Widgets"),
// //           _step("3. State Management"),
// //           _step("4. API Integration"),
// //           _step("5. Advanced Concepts"),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _step(String text) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.check_circle, size: 16, color: Color(0xFF2A5298)),
// //           const SizedBox(width: 8),
// //           Text(text, style: const TextStyle(fontSize: 14)),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------- Popular Topics ----------
// //   Widget _buildPopularTopics() {
// //     final popular = allTopics.take(5).toList();
// //     if (popular.isEmpty) return const SizedBox.shrink();

// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             spreadRadius: 2,
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "🔥 Popular Topics",
// //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 12),
// //           ...popular.map((topic) => ListTile(
// //                 leading: const Icon(Icons.star, color: Colors.amber, size: 20),
// //                 title: Text(topic.title),
// //                 subtitle: Text(_getTopicDescription(topic)),
// //                 dense: true,
// //                 onTap: () {
// //                   _saveLastTopic(topic.slug);
// //                   context.go('/flutter/${topic.slug}');
// //                 },
// //               )),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------- Category Header with Description ----------
// //   Widget _buildCategoryHeader(String category, String description) {
// //     return Padding(
// //       padding: const EdgeInsets.only(top: 24, left: 20, bottom: 8),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             category,
// //             style: const TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Color(0xFF1E3C72),
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             description,
// //             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Helper: category description
// //   String _getCategoryDescription(String category) {
// //     switch (category.toLowerCase()) {
// //       case 'dart basics':
// //         return 'Learn Dart syntax, variables, functions, and OOP concepts.';
// //       case 'widgets':
// //         return 'Explore Flutter widgets: Stateless, Stateful, and built-in components.';
// //       case 'state management':
// //         return 'Manage app state with Provider, BLoC, and other patterns.';
// //       case 'api integration':
// //         return 'Connect to REST APIs, handle JSON, and use HTTP requests.';
// //       case 'advanced':
// //         return 'Deep dive into animations, custom painters, and performance optimization.';
// //       default:
// //         return 'Learn $category concepts with practical examples.';
// //     }
// //   }

// //   // Helper: topic description (fallback if model doesn't have it)
// //   String _getTopicDescription(TutorialTopic topic) {
// //     // If your TutorialTopic model has a description field, use it.
// //     return 'Learn ${topic.title} with step-by-step examples and quizzes.';
// //   }

// //   // ---------- Empty State ----------
// //   Widget _buildEmptyState() {
// //     return const Center(
// //       child: Padding(
// //         padding: EdgeInsets.all(40),
// //         child: Column(
// //           children: [
// //             Icon(Icons.search_off, size: 48, color: Colors.grey),
// //             SizedBox(height: 16),
// //             Text(
// //               'No topics found 😔',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               'Try searching for "Flutter", "Widgets", or "State Management"',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------- SEO Paragraph ----------
// //   Widget _buildSeoParagraph() {
// //     return Padding(
// //       padding: const EdgeInsets.all(20),
// //       child: Text(
// //         "Flutter is an open-source UI toolkit by Google used to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. In this tutorial, you will learn Flutter step-by-step with real-world examples, covering widgets, layouts, state management, API integration, and advanced concepts. Whether you are a beginner or an experienced developer, this comprehensive Flutter tutorial will help you master the framework and build production-ready apps. Start your Flutter journey today with our curated topics, interactive quizzes, and live code editor.",
// //         style: TextStyle(
// //           fontSize: 12,
// //           color: Colors.grey[600],
// //           height: 1.5,
// //         ),
// //         textAlign: TextAlign.center,
// //       ),
// //     );
// //   }
// // }

// // // ---------- AppBar ----------
// // AppBar buildSmartAppBar(
// //   BuildContext context, {
// //   required double progress,
// //   required String? lastTopic,
// // }) {
// //   return AppBar(
// //     elevation: 0,
// //     toolbarHeight: 65,
// //     backgroundColor: const Color(0xFF1E3C72),
// //     title: Row(
// //       children: [
// //         const Icon(Icons.school, color: Colors.white),
// //         const SizedBox(width: 10),
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 "Revochamp",
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               Text(
// //                 lastTopic != null ? "Continue Learning" : "Flutter Tutorials",
// //                 style: const TextStyle(
// //                   fontSize: 11,
// //                   color: Colors.white70,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     ),
// //     actions: [
// //       if (lastTopic != null)
// //         IconButton(
// //           icon: const Icon(Icons.play_arrow),
// //           tooltip: "Continue",
// //           onPressed: () {
// //             GoRouter.of(context).go('/flutter/$lastTopic');
// //           },
// //         ),
// //       IconButton(
// //         icon: const Icon(Icons.search),
// //         onPressed: () {
// //           // open search
// //         },
// //       ),
// //       Padding(
// //         padding: const EdgeInsets.only(right: 12),
// //         child: Center(
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.15),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(
// //               "${(progress * 100).toInt()}%",
// //               style: const TextStyle(
// //                 fontSize: 11,
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     ],
// //   );
// // }
