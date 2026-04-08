// import 'dart:async';
// import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:go_router/go_router.dart';
// import 'package:techtutorial/core/meta_service.dart';
// import 'package:techtutorial/screens/about_page.dart';
// import 'package:techtutorial/screens/contact_page.dart';
// import 'package:techtutorial/screens/course.dart';
// import 'package:techtutorial/screens/home.dart';
// import 'package:techtutorial/screens/mock_interview.dart';
// import 'package:techtutorial/screens/mock_test/mock_test_screen.dart';
// import 'package:techtutorial/screens/privacy-policy.dart';
// import 'package:techtutorial/screens/quiztopics/quiz_topics_screen.dart';
// import 'package:techtutorial/screens/terms.dart';
// import 'package:techtutorial/screens/topics/topics_screen.dart';
// import 'screens/tutorial/tutorial_page.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   MetaService.setWebsiteSchema();
//   usePathUrlStrategy(); // ✅ Remove #

//   runApp(TutorialApp());
  
//   if (kIsWeb) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       html.window.dispatchEvent(html.CustomEvent('flutter-first-frame'));
//     });
//   }
  
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _removeStaticContent();
//   });
// }

// void _removeStaticContent() {
//   final splash = html.document.getElementById('splash');
//   final seo = html.document.getElementById('seo-content');

//   if (splash != null) {
//     splash.style.opacity = '0';
//     Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
//   }

//   if (seo != null && !_isBot()) {  // ✅ Now _isBot() is accessible
//     seo.style.display = 'none';
//   }
// }

// // ✅ Move this function outside
// bool _isBot() {
//   final ua = html.window.navigator.userAgent.toLowerCase();
//   return ua.contains('googlebot') ||
//       ua.contains('bingbot') ||
//       ua.contains('yandex') ||
//       ua.contains('duckduckbot') ||
//       ua.contains('baiduspider') ||
//       ua.contains('facebookexternalhit') ||
//       ua.contains('twitterbot') ||
//       ua.contains('linkedinbot');
// }

// class TutorialApp extends StatelessWidget {
//   TutorialApp({super.key});

//   GoRouter get _router => GoRouter(
//     initialLocation: '/',
//     debugLogDiagnostics: true,

//     // ✅ FIXED: No redirect - keep /tech in URLs
//     // Removed the redirect that was breaking navigation
    
//     routes: [
//       // HOME
//       GoRoute(
//         path: '/',
//         name: 'home',
//         builder: (context, state) => const HomePage(),
//       ),

//       // ABOUT
//       GoRoute(
//         path: '/about',
//         name: 'about',
//         builder: (context, state) => const AboutPage(),
//       ),

//       // CONTACT
//       GoRoute(
//         path: '/contact',
//         name: 'contact',
//         builder: (context, state) => const ContactPage(),
//       ),

//       // COURSES
//       GoRoute(
//         path: '/courses',
//         name: 'courses',
//         builder: (context, state) => const CoursePage(),
//       ),

//       // PRIVACY POLICY
//       GoRoute(
//         path: '/privacy',
//         name: 'privacy',
//         builder: (context, state) => const PrivacyPage(),
//       ),

//       // TERMS
//       GoRoute(
//         path: '/terms',
//         name: 'terms',
//         builder: (context, state) => const TermsPage(),
//       ),
//   GoRoute(
//         path: '/mockinterview',
//         name: 'mockinterview',
//         builder: (context, state) => const MockInterviewPage(),
//       ),

// GoRoute(
//         name: 'test',
//         path: '/interview/:category/:fileName',
//         builder: (context, state) {
//           final category = state.pathParameters['category']!;
//           final fileName = state.pathParameters['fileName']!;
//           return MockTestScreen(
//             category: category,
//             fileName: fileName,
//           );
//         },
//       ),
  
//       // ✅ TOPICS SCREEN (Category View)
//       GoRoute(
//         path: '/interview/:category',
//         name: 'mockinterview topics',
//         builder: (context, state) {
//           final category = state.pathParameters['category']!;
//           return QuizTopicsScreen(category: category);
//         },
//       ),

//     // ✅ TOPICS SCREEN (Category View)
//       GoRoute(
//         path: '/:category',
//         name: 'topics',
//         builder: (context, state) {
//           final category = state.pathParameters['category']!;
//           return TopicsScreen(category: category);
//         },
//       ),

//       // ✅ TUTORIAL PAGE
//       GoRoute(
//         path: '/:category/:slug',
//         name: 'tutorial',
//         builder: (context, state) {
//           final category = state.pathParameters['category']!;
//           final slug = state.pathParameters['slug']!;

//           return TutorialPage(
//             key: ValueKey('$category-$slug'),
//             args: TutorialArguments(
//               slug: slug,
//               category: category,
//               allTopics: TopicsScreen.getTopicsByCategory(category),
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
//             Icon(
//               Icons.error_outline,
//               size: 80,
//               color: Colors.grey[400],
//             ),
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
//               'The page you are looking for does not exist.',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 context.go('/');
//               },
//               child: const Text('Go to Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//  @override
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

//     // Helper method to format category from slug
// String formatCategoryFromSlug(String slug) {
//   // Convert slug back to readable category name
//   return slug
//       .split('-')
//       .map((word) => word[0].toUpperCase() + word.substring(1))
//       .join(' ');
// }

 

//   // ---------- THEME ----------
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
