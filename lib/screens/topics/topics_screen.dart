import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtutorial/screens/tutorial/tutorial_page.dart';

import '../../core/theme.dart';
import '../../models/tutorial_topic.dart';
import '../../utils/json_parser.dart';
import 'topic_card.dart';




class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  static final List<TutorialTopic> _cachedTopics = [];
  static List<TutorialTopic> get cachedTopics => _cachedTopics;
  static const String baseUrl = 'https://json.revochamp.site/flutter/topics.json';

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
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

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // 1. Initialisation
  // --------------------------------------------------------------
  Future<void> _initAll() async {
    if (TopicsScreen._cachedTopics.isNotEmpty) {
      _applyData(
        topics: TopicsScreen._cachedTopics,
        completed: _completedTopics,
        lastTopic: _lastTopicSlug,
      );
      return;
    }

    try {
      _prefs = await SharedPreferences.getInstance();

      final response = await http.get(Uri.parse(TopicsScreen.baseUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final topics = await compute(parseTopics, response.body);

      TopicsScreen._cachedTopics.clear();
      TopicsScreen._cachedTopics.addAll(topics);

      _applyData(
        topics: topics,
        completed: _prefs!.getStringList('completed') ?? [],
        lastTopic: _prefs!.getString('last_topic'),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to load topics: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyData({
    required List<TutorialTopic> topics,
    required Iterable<String> completed,
    String? lastTopic,
  }) {
    compute(_groupTopicsIsolate, topics).then((grouped) {
      setState(() {
        allTopics = topics;
        groupedTopics = grouped;
        groupedFilteredTopics = grouped;
        _completedTopics.addAll(completed);
        _lastTopicSlug = lastTopic;
        _isLoading = false;
      });
    }).catchError((e) {
      final grouped = _groupTopicsSync(topics);
      setState(() {
        allTopics = topics;
        groupedTopics = grouped;
        groupedFilteredTopics = grouped;
        _completedTopics.addAll(completed);
        _lastTopicSlug = lastTopic;
        _isLoading = false;
      });
    });
  }

  // --------------------------------------------------------------
  // 2. Grouping (isolated + sync fallback)
  // --------------------------------------------------------------
  static Map<String, List<TutorialTopic>> _groupTopicsIsolate(List<TutorialTopic> topics) {
    final map = <String, List<TutorialTopic>>{};
    for (final t in topics) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  Map<String, List<TutorialTopic>> _groupTopicsSync(List<TutorialTopic> topics) {
    final map = <String, List<TutorialTopic>>{};
    for (final t in topics) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  // --------------------------------------------------------------
  // 3. Debounced search
  // --------------------------------------------------------------
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final filtered = allTopics
          .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      final grouped = await compute(_groupTopicsIsolate, filtered);

      setState(() {
        groupedFilteredTopics = grouped;
      });
    });
  }

  // --------------------------------------------------------------
  // 4. SharedPreferences helpers
  // --------------------------------------------------------------
  Future<void> _saveLastTopic(String slug) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString('last_topic', slug);
  }

  // --------------------------------------------------------------
  // 5. Helpers
  // --------------------------------------------------------------
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  double get _progress => allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;

  void _scrollToTop() {
    final scrollable = Scrollable.of(context);
    scrollable.position.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 1;
  }

  // --------------------------------------------------------------
  // 6. UI Build
  // --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = _getGridCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Tutorials'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: primaryGradient)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.brightness == Brightness.dark ? Colors.grey[900]! : const Color(0xFFF8FAFC),
              theme.brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFEFF3F8),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHero()),
                  SliverToBoxAdapter(child: _buildProgressBar()),
                  if (_lastTopicSlug != null && _lastTopicSlug!.isNotEmpty)
                    SliverToBoxAdapter(child: _buildContinueBanner()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search topics...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  ...groupedFilteredTopics.entries.expand((entry) {
                    final category = entry.key;
                    final topicsInCategory = entry.value;
                    if (topicsInCategory.isEmpty) return <Widget>[];

                    return [
                      SliverToBoxAdapter(
                        child: _buildCategoryHeader(category),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final topic = topicsInCategory[index];
                              final isCompleted = _completedTopics.contains(topic.slug);
                              return TopicCard(
                                topic: topic,
                                isCompleted: isCompleted,
                                onTap: () {
                                  _saveLastTopic(topic.slug);
                                  // GoRouter navigation
                                  // context.pushNamed(
                                  //   'tutorial',
                                  //   pathParameters: {'slug': topic.slug},
                                  // );
context.go('/flutter/${topic.slug}');                                },
                              );
                            },
                            childCount: topicsInCategory.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio:
                                MediaQuery.of(context).size.width > 700 ? 2.8 : 3.2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ];
                  }),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
      ),
      floatingActionButton: allTopics.length > 10
          ? FloatingActionButton(
              mini: true,
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Master Flutter 🚀",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Learn step-by-step with examples, quizzes & live editor",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 18),
              ),
              Text(
                '${_completedTopics.length}/${allTopics.length} topics',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A5298),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF2A5298),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueBanner() {
    final lastTopic = allTopics.firstWhere(
      (t) => t.slug == _lastTopicSlug,
      orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', category: ''),
    );
    if (lastTopic.slug.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        color: const Color(0xFF2A5298).withOpacity(0.1),
        child: ListTile(
          leading: const Icon(Icons.play_circle_fill, color: Color(0xFF2A5298), size: 36),
          title: Text('Continue: ${lastTopic.title}'),
          subtitle: const Text('Tap to resume'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            _saveLastTopic(lastTopic.slug);
            // context.pushNamed(
            //   'tutorial',
            //   pathParameters: {'slug': lastTopic.slug},
            // );
            context.go('/${lastTopic.category}/${lastTopic.slug}');
          },
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, bottom: 8),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3C72),
        ),
      ),
    );
  }
}

// // ---------------------------- TopicsScreen (Optimized with Grid Layout) ----------------------------
// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:techtutorial/screens/tutorial/tutorial_page.dart';

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
//   Map<String, List<TutorialTopic>> groupedTopics = {}; // full data grouped
//   Map<String, List<TutorialTopic>> groupedFilteredTopics = {}; // search results grouped

//   // UI state
//   final TextEditingController _searchController = TextEditingController();
//   final Set<String> _completedTopics = {};
//   bool _isLoading = true;
//   String? _lastTopicSlug;
//   Timer? _debounce;

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
//     super.dispose();
//   }

//   // --------------------------------------------------------------
//   // 1. Single initialisation
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
//         groupedFilteredTopics = grouped; // initially same as full
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
//   // 3. Debounced search with isolated grouping
//   // --------------------------------------------------------------
//   void _onSearchChanged(String query) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () async {
//       final filtered = allTopics
//           .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
//           .toList();

//       final grouped = await compute(_groupTopicsIsolate, filtered);

//       setState(() {
//         groupedFilteredTopics = grouped;
//       });
//     });
//   }

//   // --------------------------------------------------------------
//   // 4. SharedPreferences helpers (cached instance)
//   // --------------------------------------------------------------
//   Future<void> _saveLastTopic(String slug) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     await _prefs?.setString('last_topic', slug);
//   }

//   // --------------------------------------------------------------
//   // 5. Helpers
//   // --------------------------------------------------------------
//   void _showErrorSnackbar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   double get _progress => allTopics.isEmpty ? 0 : _completedTopics.length / allTopics.length;

//   void _scrollToTop() {
//     final scrollable = Scrollable.of(context);
//     scrollable.position.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   // Helper to determine grid columns based on screen width
//   int _getGridCrossAxisCount(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width >= 1200) return 4;
//     if (width >= 800) return 3;
//     return 1;
//   }

//   // --------------------------------------------------------------
//   // 6. UI Build (CustomScrollView with Grid)
//   // --------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final crossAxisCount = _getGridCrossAxisCount(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Flutter Tutorials'),
//         flexibleSpace: Container(decoration: BoxDecoration(gradient: primaryGradient)),
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
//                 slivers: [
//                   SliverToBoxAdapter(child: _buildHero()),
//                   SliverToBoxAdapter(child: _buildProgressBar()),
//                   if (_lastTopicSlug != null && _lastTopicSlug!.isNotEmpty)
//                     SliverToBoxAdapter(child: _buildContinueBanner()),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search topics...',
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         onChanged: _onSearchChanged,
//                       ),
//                     ),
//                   ),
//                   // Build slivers for each category
//                   ...groupedFilteredTopics.entries.expand((entry) {
//                     final category = entry.key;
//                     final topicsInCategory = entry.value;
//                     if (topicsInCategory.isEmpty) return <Widget>[];

//                     return [
//                       SliverToBoxAdapter(
//                         child: _buildCategoryHeader(category),
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
//                                 onTap: () {
//                                   _saveLastTopic(topic.slug);
//                                   // Navigator.pushNamed(
//                                   //   context,
//                                   //   '/tech/flutter/${topic.slug}',
//                                   // );

// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => TutorialPage(
//       args: TutorialArguments(
//         slug: topic.slug,
//         allTopics: allTopics,
//       ),
//     ),
//   ),
// );                                },
//                               );
//                             },
//                             childCount: topicsInCategory.length,
//                           ),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: crossAxisCount,
//                             childAspectRatio:MediaQuery.of(context).size.width >700? 2.8:3.2, // Adjust as needed for card shape
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                           ),
//                         ),
//                       ),
//                       const SliverToBoxAdapter(child: SizedBox(height: 16)),
//                     ];
//                   }),
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

//   Widget _buildHero() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: primaryGradient,
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
//       ),
//       child: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Master Flutter 🚀",
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             "Learn step-by-step with examples, quizzes & live editor",
//             style: TextStyle(color: Colors.white70, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

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
//         ],
//       ),
//     );
//   }

//   Widget _buildContinueBanner() {
//     final lastTopic = allTopics.firstWhere(
//       (t) => t.slug == _lastTopicSlug,
//       orElse: () => allTopics.isNotEmpty ? allTopics.first : TutorialTopic(slug: '', title: '', emoji: '', category: ''),
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
//             // Navigator.pushNamed(
//             //   context,
//             //   '/tech/flutter/${lastTopic.slug}',
//             // );
//             Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => TutorialPage(
//       args: TutorialArguments(
//         slug: lastTopic.slug,
//         allTopics: allTopics,
//       ),
//     ),
//   ),
// );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryHeader(String category) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 24, left: 20, bottom: 8),
//       child: Text(
//         category,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF1E3C72),
//         ),
//       ),
//     );
//   }
// }