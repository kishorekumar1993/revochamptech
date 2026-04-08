import 'dart:async';
import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';

// DEFERRED IMPORTS (Lazy Loading for Performance)
import 'package:techtutorial/screens/home.dart' deferred as home;
import 'package:techtutorial/screens/about_page.dart' deferred as about;
import 'package:techtutorial/screens/contact_page.dart' deferred as contact;
import 'package:techtutorial/screens/course.dart' deferred as course;
import 'package:techtutorial/screens/mock_interview.dart' deferred as mock_interview;
import 'package:techtutorial/screens/mock_test/mock_test_screen.dart' deferred as mock_test;
import 'package:techtutorial/screens/privacy-policy.dart' deferred as privacy;
import 'package:techtutorial/screens/quiztopics/quiz_topics_screen.dart' deferred as quiz_topics;
import 'package:techtutorial/screens/terms.dart' deferred as terms;
import 'package:techtutorial/screens/topics/topics_screen.dart' deferred as topics;
import 'screens/tutorial/tutorial_page.dart' deferred as tutorial;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const TutorialApp());
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MetaService.setWebsiteSchema();
    if (kIsWeb) html.window.dispatchEvent(html.CustomEvent('flutter-first-frame'));
    _removeStaticContent();
  });
}

// --- SEO / Bot Helpers ---
bool? _cachedIsBot;
bool _isBot() {
  if (_cachedIsBot != null) return _cachedIsBot!;
  try {
    final ua = html.window.navigator.userAgent.toLowerCase();
    _cachedIsBot = ua.contains('bot') || 
                   ua.contains('crawler') || 
                   ua.contains('spider') ||
                   ua.contains('facebookexternalhit') ||
                   ua.contains('twitterbot') ||
                   ua.contains('linkedinbot');
  } catch (_) {
    _cachedIsBot = false;
  }
  return _cachedIsBot!;
}

void _removeStaticContent() {
  try {
    final splash = html.document.getElementById('splash');
    if (splash != null) {
      splash.style.opacity = '0';
      Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
    }
    final seo = html.document.getElementById('seo-content');
    if (seo != null && !_isBot()) {
      seo.style.display = 'none';
    }
  } catch (_) {
    // Ignore errors in non-web environments
  }
}

// ==================== DEFERRED LOADING WRAPPER (FIXED) ====================
class DeferredWrapper extends StatefulWidget {
  final Future<void> Function() loader;
  final Widget Function() builder;

  const DeferredWrapper({
    super.key,
    required this.loader,
    required this.builder,
  });

  @override
  State<DeferredWrapper> createState() => _DeferredWrapperState();
}

class _DeferredWrapperState extends State<DeferredWrapper> {
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDeferredLibrary();
  }

  Future<void> _loadDeferredLibrary() async {
    try {
      await widget.loader();
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading deferred library: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load page',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please refresh the page or try again later.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                  _loadDeferredLibrary();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.builder();
  }
}

// ==================== MAIN APP ====================
class TutorialApp extends StatelessWidget {
  const TutorialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tech Tutorials - Learn Programming for Free',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }

  GoRouter get _router => GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    routes: [
      // ========== STATIC ROUTES ==========
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => DeferredWrapper(
          loader: () => home.loadLibrary(),
          builder: () => home.HomePage(),
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (_, __) => DeferredWrapper(
          loader: () => about.loadLibrary(),
          builder: () => about.AboutPage(),
        ),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (_, __) => DeferredWrapper(
          loader: () => contact.loadLibrary(),
          builder: () => contact.ContactPage(),
        ),
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (_, __) => DeferredWrapper(
          loader: () => course.loadLibrary(),
          builder: () => course.CoursePage(),
        ),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (_, __) => DeferredWrapper(
          loader: () => privacy.loadLibrary(),
          builder: () => privacy.PrivacyPage(),
        ),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (_, __) => DeferredWrapper(
          loader: () => terms.loadLibrary(),
          builder: () => terms.TermsPage(),
        ),
      ),

      // ========== MOCK INTERVIEW ROUTES ==========
      GoRoute(
        path: '/mockinterview',
        name: 'mockinterview',
        builder: (_, __) => DeferredWrapper(
          loader: () => mock_interview.loadLibrary(),
          builder: () => mock_interview.MockInterviewPage(),
        ),
      ),
      GoRoute(
        path: '/interview/:category',
        name: 'mockinterview-topics',
        builder: (_, state) {
          final category = state.pathParameters['category']!;
          return DeferredWrapper(
            loader: () => quiz_topics.loadLibrary(),
            builder: () => quiz_topics.QuizTopicsScreen(category: category),
          );
        },
      ),
      GoRoute(
        path: '/interview/:category/:fileName',
        name: 'mock-test',
        builder: (_, state) {
          final category = state.pathParameters['category']!;
          final fileName = state.pathParameters['fileName']!;
          return DeferredWrapper(
            loader: () => mock_test.loadLibrary(),
            builder: () => mock_test.MockTestScreen(
              category: category,
              fileName: fileName,
            ),
          );
        },
      ),

      // ========== TUTORIAL ROUTES ==========
      GoRoute(
        path: '/:category',
        name: 'topics',
        builder: (_, state) {
          final category = state.pathParameters['category']!;
          return DeferredWrapper(
            loader: () => topics.loadLibrary(),
            builder: () => topics.TopicsScreen(category: category),
          );
        },
      ),
      GoRoute(
        path: '/:category/:slug',
        name: 'tutorial',
        builder: (_, state) {
          final category = state.pathParameters['category']!;
          final slug = state.pathParameters['slug']!;

          return DeferredWrapper(
            loader: () async {
              // Load both tutorial and topics libraries
              await tutorial.loadLibrary();
              await topics.loadLibrary();
            },
            builder: () => tutorial.TutorialPage(
              key: ValueKey('$category-$slug'),
              args: tutorial.TutorialArguments(
                slug: slug,
                category: category,
                allTopics: topics.TopicsScreen.getTopicsByCategory(category),
              ),
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" does not exist.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // ========== THEME ==========
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primaryColor: const Color(0xFF1E3C72),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: brightness,
      ).copyWith(secondary: const Color(0xFF2A5298)),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 2 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: isDark ? Colors.grey[850] : Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(width: 1),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:go_router/go_router.dart';
// import 'package:techtutorial/core/meta_service.dart';

// // DEFERRED IMPORTS (Lazy Loading for Performance)
// import 'package:techtutorial/screens/home.dart' deferred as home;
// import 'package:techtutorial/screens/about_page.dart' deferred as about;
// import 'package:techtutorial/screens/contact_page.dart' deferred as contact;
// import 'package:techtutorial/screens/course.dart' deferred as course;
// import 'package:techtutorial/screens/mock_interview.dart' deferred as mock_interview;
// import 'package:techtutorial/screens/mock_test/mock_test_screen.dart' deferred as mock_test;
// import 'package:techtutorial/screens/privacy-policy.dart' deferred as privacy;
// import 'package:techtutorial/screens/quiztopics/quiz_topics_screen.dart' deferred as quiz_topics;
// import 'package:techtutorial/screens/terms.dart' deferred as terms;
// import 'package:techtutorial/screens/topics/topics_screen.dart' deferred as topics;
// import 'screens/tutorial/tutorial_page.dart' deferred as tutorial;

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   usePathUrlStrategy();
//   runApp(const TutorialApp());
  
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     MetaService.setWebsiteSchema();
//     if (kIsWeb) html.window.dispatchEvent(html.CustomEvent('flutter-first-frame'));
//     _removeStaticContent();
//   });
// }

// // --- SEO / Bot Helpers ---
// bool? _cachedIsBot;
// bool _isBot() {
//   _cachedIsBot ??= html.window.navigator.userAgent.toLowerCase().contains('bot');
//   return _cachedIsBot!;
// }

// void _removeStaticContent() {
//   final splash = html.document.getElementById('splash');
//   if (splash != null) {
//     splash.style.opacity = '0';
//     Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
//   }
//   final seo = html.document.getElementById('seo-content');
//   if (seo != null && !_isBot()) {
//     seo.style.display = 'none';
//   }
// }

// // --- DEFERRED LOADING WRAPPER ---
// class DeferredWrapper extends StatelessWidget {
//   final Future<void> Function() loader;
//   final Widget Function() builder;

//   const DeferredWrapper({
//     super.key,
//     required this.loader,
//     required this.builder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: loader(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return builder();
//         }
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       },
//     );
//   }
// }

// // --- MAIN APP ---
// class TutorialApp extends StatelessWidget {
//   const TutorialApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Tech Tutorials',
//       debugShowCheckedModeBanner: false,
//       theme: _buildTheme(Brightness.light),
//       darkTheme: _buildTheme(Brightness.dark),
//       themeMode: ThemeMode.system,
//       routerConfig: _router,
//     );
//   }

//   GoRouter get _router => GoRouter(
//     initialLocation: '/',
//     debugLogDiagnostics: false,
//     routes: [
//       // ========== STATIC ROUTES (Order matters - specific first!) ==========
//       GoRoute(
//         path: '/',
//         name: 'home',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => home.loadLibrary(),
//           builder: () => home.HomePage(),
//         ),
//       ),
//       GoRoute(
//         path: '/about',
//         name: 'about',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => about.loadLibrary(),
//           builder: () => about.AboutPage(),
//         ),
//       ),
//       GoRoute(
//         path: '/contact',
//         name: 'contact',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => contact.loadLibrary(),
//           builder: () => contact.ContactPage(),
//         ),
//       ),
//       GoRoute(
//         path: '/courses',
//         name: 'courses',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => course.loadLibrary(),
//           builder: () => course.CoursePage(),
//         ),
//       ),
//       GoRoute(
//         path: '/privacy',
//         name: 'privacy',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => privacy.loadLibrary(),
//           builder: () => privacy.PrivacyPage(),
//         ),
//       ),
//       GoRoute(
//         path: '/terms',
//         name: 'terms',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => terms.loadLibrary(),
//           builder: () => terms.TermsPage(),
//         ),
//       ),

//       // ========== MOCK INTERVIEW ROUTES ==========
//       GoRoute(
//         path: '/mockinterview',
//         name: 'mockinterview',
//         builder: (_, __) => DeferredWrapper(
//           loader: () => mock_interview.loadLibrary(),
//           builder: () => mock_interview.MockInterviewPage(),
//         ),
//       ),
//       GoRoute(
//         path: '/mock-interview/:category',
//         name: 'mockinterview-topics',
//         builder: (_, state) {
//           final category = state.pathParameters['category']!;
//           return DeferredWrapper(
//             loader: () => quiz_topics.loadLibrary(),
//             builder: () => quiz_topics.QuizTopicsScreen(category: category),
//           );
//         },
//       ),
//       GoRoute(
//         path: '/mock-test/:category/:fileName',
//         name: 'mock-test',
//         builder: (_, state) {
//           final category = state.pathParameters['category']!;
//           final fileName = state.pathParameters['fileName']!;
//           return DeferredWrapper(
//             loader: () => mock_test.loadLibrary(),
//             builder: () => mock_test.MockTestScreen(
//               category: category,
//               fileName: fileName,
//             ),
//           );
//         },
//       ),

//       // ========== TUTORIAL ROUTES (With /tech/ prefix to avoid conflicts) ==========
//       GoRoute(
//         path: '/:category',
//         name: 'topics',
//         builder: (_, state) {
//           final category = state.pathParameters['category']!;
//           return DeferredWrapper(
//             loader: () => topics.loadLibrary(),
//             builder: () => topics.TopicsScreen(category: category),
//           );
//         },
//       ),
//       GoRoute(
//         path: '/:category/:slug',
//         name: 'tutorial',
//         builder: (_, state) {
//           final category = state.pathParameters['category']!;
//           final slug = state.pathParameters['slug']!;

//           return DeferredWrapper(
//             loader: () => tutorial.loadLibrary(),
//             builder: () => tutorial.TutorialPage(
//               key: ValueKey('$category-$slug'),
//               args: tutorial.TutorialArguments(
//                 slug: slug,
//                 category: category,
//                 allTopics: topics.TopicsScreen.getTopicsByCategory(category),
//               ),
//             ),
//           );
//         },
//       ),
//     ],
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               '404 - Page Not Found',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'The page "${state.uri}" does not exist.',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => context.go('/'),
//               child: const Text('Go to Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//   // ========== THEME ==========
//   ThemeData _buildTheme(Brightness brightness) {
//     final isDark = brightness == Brightness.dark;

//     return ThemeData(
//       brightness: brightness,
//       primaryColor: const Color(0xFF1E3C72),
//       colorScheme: ColorScheme.fromSwatch(
//         primarySwatch: Colors.blue,
//         brightness: brightness,
//       ).copyWith(secondary: const Color(0xFF2A5298)),
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       cardTheme: CardThemeData(
//         elevation: isDark ? 2 : 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         clipBehavior: Clip.antiAlias,
//         color: isDark ? Colors.grey[850] : Colors.white,
//         shadowColor: Colors.black.withValues(alpha: 0.1),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: const BorderSide(width: 1),
//         ),
//         filled: true,
//         fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
//       ),
//       textTheme: const TextTheme(
//         displayLarge: TextStyle(
//           fontSize: 28,
//           fontWeight: FontWeight.bold,
//           height: 1.3,
//         ),
//         displayMedium: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.w600,
//           height: 1.3,
//         ),
//         bodyLarge: TextStyle(fontSize: 16, height: 1.6),
//         bodyMedium: TextStyle(fontSize: 14, height: 1.5),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_web_plugins/url_strategy.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:techtutorial/core/meta_service.dart';
// // import 'package:techtutorial/screens/about_page.dart';
// // import 'package:techtutorial/screens/contact_page.dart';
// // import 'package:techtutorial/screens/course.dart';
// // import 'package:techtutorial/screens/home.dart';
// // import 'package:techtutorial/screens/mock_interview.dart';
// // import 'package:techtutorial/screens/mock_test/mock_test_screen.dart';
// // import 'package:techtutorial/screens/privacy-policy.dart';
// // import 'package:techtutorial/screens/quiztopics/quiz_topics_screen.dart';
// // import 'package:techtutorial/screens/terms.dart';
// // import 'package:techtutorial/screens/topics/topics_screen.dart';
// // import 'screens/tutorial/tutorial_page.dart';

// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   MetaService.setWebsiteSchema();
// //   usePathUrlStrategy(); // ✅ Remove #

// //   runApp(TutorialApp());
  
// //   if (kIsWeb) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       html.window.dispatchEvent(html.CustomEvent('flutter-first-frame'));
// //     });
// //   }
  
// //   WidgetsBinding.instance.addPostFrameCallback((_) {
// //     _removeStaticContent();
// //   });
// // }

// // void _removeStaticContent() {
// //   final splash = html.document.getElementById('splash');
// //   final seo = html.document.getElementById('seo-content');

// //   if (splash != null) {
// //     splash.style.opacity = '0';
// //     Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
// //   }

// //   if (seo != null && !_isBot()) {  // ✅ Now _isBot() is accessible
// //     seo.style.display = 'none';
// //   }
// // }

// // // ✅ Move this function outside
// // bool _isBot() {
// //   final ua = html.window.navigator.userAgent.toLowerCase();
// //   return ua.contains('googlebot') ||
// //       ua.contains('bingbot') ||
// //       ua.contains('yandex') ||
// //       ua.contains('duckduckbot') ||
// //       ua.contains('baiduspider') ||
// //       ua.contains('facebookexternalhit') ||
// //       ua.contains('twitterbot') ||
// //       ua.contains('linkedinbot');
// // }

// // class TutorialApp extends StatelessWidget {
// //   TutorialApp({super.key});

// //   GoRouter get _router => GoRouter(
// //     initialLocation: '/',
// //     debugLogDiagnostics: true,

// //     // ✅ FIXED: No redirect - keep /tech in URLs
// //     // Removed the redirect that was breaking navigation
    
// //     routes: [
// //       // HOME
// //       GoRoute(
// //         path: '/',
// //         name: 'home',
// //         builder: (context, state) => const HomePage(),
// //       ),

// //       // ABOUT
// //       GoRoute(
// //         path: '/about',
// //         name: 'about',
// //         builder: (context, state) => const AboutPage(),
// //       ),

// //       // CONTACT
// //       GoRoute(
// //         path: '/contact',
// //         name: 'contact',
// //         builder: (context, state) => const ContactPage(),
// //       ),

// //       // COURSES
// //       GoRoute(
// //         path: '/courses',
// //         name: 'courses',
// //         builder: (context, state) => const CoursePage(),
// //       ),

// //       // PRIVACY POLICY
// //       GoRoute(
// //         path: '/privacy',
// //         name: 'privacy',
// //         builder: (context, state) => const PrivacyPage(),
// //       ),

// //       // TERMS
// //       GoRoute(
// //         path: '/terms',
// //         name: 'terms',
// //         builder: (context, state) => const TermsPage(),
// //       ),
// //   GoRoute(
// //         path: '/mockinterview',
// //         name: 'mockinterview',
// //         builder: (context, state) => const MockInterviewPage(),
// //       ),

// // GoRoute(
// //         name: 'test',
// //         path: '/interview/:category/:fileName',
// //         builder: (context, state) {
// //           final category = state.pathParameters['category']!;
// //           final fileName = state.pathParameters['fileName']!;
// //           return MockTestScreen(
// //             category: category,
// //             fileName: fileName,
// //           );
// //         },
// //       ),
  
// //       // ✅ TOPICS SCREEN (Category View)
// //       GoRoute(
// //         path: '/interview/:category',
// //         name: 'mockinterview topics',
// //         builder: (context, state) {
// //           final category = state.pathParameters['category']!;
// //           return QuizTopicsScreen(category: category);
// //         },
// //       ),

// //     // ✅ TOPICS SCREEN (Category View)
// //       GoRoute(
// //         path: '/:category',
// //         name: 'topics',
// //         builder: (context, state) {
// //           final category = state.pathParameters['category']!;
// //           return TopicsScreen(category: category);
// //         },
// //       ),

// //       // ✅ TUTORIAL PAGE
// //       GoRoute(
// //         path: '/:category/:slug',
// //         name: 'tutorial',
// //         builder: (context, state) {
// //           final category = state.pathParameters['category']!;
// //           final slug = state.pathParameters['slug']!;

// //           return TutorialPage(
// //             key: ValueKey('$category-$slug'),
// //             args: TutorialArguments(
// //               slug: slug,
// //               category: category,
// //               allTopics: TopicsScreen.getTopicsByCategory(category),
// //             ),
// //           );

// //         },
// //       ),


// //     ],

// //     errorBuilder: (context, state) => Scaffold(
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.error_outline,
// //               size: 80,
// //               color: Colors.grey[400],
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               '404 - Page Not Found',
// //               style: TextStyle(
// //                 fontSize: 24,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'The page you are looking for does not exist.',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey[600],
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             ElevatedButton(
// //               onPressed: () {
// //                 context.go('/');
// //               },
// //               child: const Text('Go to Home'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     ),
// //   );

// //  @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp.router(
// //       title: 'Tech Tutorials',
// //       debugShowCheckedModeBanner: false,
// //       theme: _buildTheme(Brightness.light),
// //       darkTheme: _buildTheme(Brightness.dark),
// //       themeMode: ThemeMode.system,
// //       routerConfig: _router,
// //     );
// //   }

// //     // Helper method to format category from slug
// // String formatCategoryFromSlug(String slug) {
// //   // Convert slug back to readable category name
// //   return slug
// //       .split('-')
// //       .map((word) => word[0].toUpperCase() + word.substring(1))
// //       .join(' ');
// // }

 

// //   // ---------- THEME ----------
// //   ThemeData _buildTheme(Brightness brightness) {
// //     final isDark = brightness == Brightness.dark;

// //     return ThemeData(
// //       brightness: brightness,
// //       primaryColor: const Color(0xFF1E3C72),
// //       colorScheme: ColorScheme.fromSwatch(
// //         primarySwatch: Colors.blue,
// //         brightness: brightness,
// //       ).copyWith(secondary: const Color(0xFF2A5298)),
// //       appBarTheme: const AppBarTheme(
// //         elevation: 0,
// //         centerTitle: true,
// //         titleTextStyle: TextStyle(
// //           fontSize: 22,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.white,
// //         ),
// //       ),
// //       cardTheme: CardThemeData(
// //         elevation: isDark ? 2 : 4,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //         clipBehavior: Clip.antiAlias,
// //         color: isDark ? Colors.grey[850] : Colors.white,
// //         shadowColor: Colors.black.withValues(alpha: 0.1),
// //       ),
// //       inputDecorationTheme: InputDecorationTheme(
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(30),
// //           borderSide: const BorderSide(width: 1),
// //         ),
// //         filled: true,
// //         fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
// //       ),
// //       textTheme: const TextTheme(
// //         displayLarge: TextStyle(
// //           fontSize: 28,
// //           fontWeight: FontWeight.bold,
// //           height: 1.3,
// //         ),
// //         displayMedium: TextStyle(
// //           fontSize: 24,
// //           fontWeight: FontWeight.w600,
// //           height: 1.3,
// //         ),
// //         bodyLarge: TextStyle(fontSize: 16, height: 1.6),
// //         bodyMedium: TextStyle(fontSize: 14, height: 1.5),
// //       ),
// //       elevatedButtonTheme: ElevatedButtonThemeData(
// //         style: ElevatedButton.styleFrom(
// //           elevation: 2,
// //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(30),
// //           ),
// //         ),
// //       ),
// //       outlinedButtonTheme: OutlinedButtonThemeData(
// //         style: OutlinedButton.styleFrom(
// //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(30),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
