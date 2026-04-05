// import 'dart:async';
// import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:techtutorial/core/meta_service.dart';
// import 'package:techtutorial/screens/topics/topics_screen.dart';
// import 'screens/tutorial/tutorial_page.dart';
// import 'dart:async';
// import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:techtutorial/core/meta_service.dart';
// import 'package:techtutorial/screens/topics/topics_screen.dart';
// import 'screens/tutorial/tutorial_page.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   MetaService.setWebsiteSchema();
//   usePathUrlStrategy();

//   runApp(const TutorialApp());

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

//   if (seo != null) {
//     seo.style.display = 'none';
//   }
// }

// class TutorialApp extends StatelessWidget {
//   const TutorialApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,

//       // ✅ IMPORTANT FOR DIRECT URL LOAD
//       onGenerateInitialRoutes: (initialRoute) {
//         return [_handleRoute(initialRoute)];
//       },

//       onGenerateRoute: (settings) {
//         return _handleRoute(settings.name ?? '/');
//       },

//       onUnknownRoute: (_) => MaterialPageRoute(
//         builder: (_) => const TopicsScreen(),
//       ),
//     );
//   }

//   // ✅ CENTRAL ROUTE HANDLER
//   MaterialPageRoute _handleRoute(String route) {
//     final uri = Uri.parse(route);

//     // ✅ REMOVE /tech PREFIX
//     final segments = List<String>.from(uri.pathSegments);
//     if (segments.isNotEmpty && segments[0] == 'tech') {
//       segments.removeAt(0);
//     }

//     print("Final Segments: $segments");

//     // ✅ /flutter/:slug
//     if (segments.length >= 2 && segments[0] == 'flutter') {
//       final slug = segments[1];

//       return MaterialPageRoute(
//         builder: (_) => TutorialPage(
//           args: TutorialArguments(
//             slug: slug,
//             allTopics: TopicsScreen.cachedTopics,
//           ),
//         ),
//       );
//     }

//     // ✅ Default screen
//     return MaterialPageRoute(
//       builder: (_) => const TopicsScreen(),
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// // import 'package:flutter/material.dart';
// // import 'package:flutter_web_plugins/url_strategy.dart';
// // import 'package:techtutorial/core/meta_service.dart';
// // import 'package:techtutorial/screens/topics/topics_screen.dart';
// // import 'screens/tutorial/tutorial_page.dart';

// // void main() {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   MetaService.setWebsiteSchema();
// //   usePathUrlStrategy();

// //   runApp(const TutorialApp());

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

// //   if (seo != null) {
// //     seo.style.display = 'none';
// //   }
// // }

// // // ---------------------------- APP ----------------------------

// // class TutorialApp extends StatelessWidget {
// //   const TutorialApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Tutorials',
// //       debugShowCheckedModeBanner: false,
// //       theme: _buildTheme(Brightness.light),
// //       darkTheme: _buildTheme(Brightness.dark),
// //       themeMode: ThemeMode.system,

// //       // ✅ Initial deep link
// //       onGenerateInitialRoutes: (initialRoute) {
// //         return [_handleRoute(initialRoute)];
// //       },

// //       routes: {
// //         '/': (_) => const TopicsScreen(),
// //       },

// //       // ✅ Navigation
// //       onGenerateRoute: (settings) {
// //         return _handleRoute(settings.name ?? '/');
// //       },

// //       // ✅ Prevent crash (VERY IMPORTANT)
// //       onUnknownRoute: (settings) {
// //         return MaterialPageRoute(
// //           builder: (_) => const TopicsScreen(),
// //         );
// //       },
// //     );
// //   }

// //   // ---------------- ROUTER ----------------

// //   MaterialPageRoute _handleRoute(String route) {
// //     final uri = Uri.parse(route);
// //     final segments = uri.pathSegments;

// //     // ✅ /tech/flutter/:slug
// //     if (segments.length >= 3 &&
// //         segments[0] == 'tech' &&
// //         segments[1] == 'flutter' &&
// //         segments[2].isNotEmpty) {
// //       final slug = segments[2];

// //       return MaterialPageRoute(
// //         builder: (_) => 
// //         TutorialPage(
// //                 args: TutorialArguments(slug: slug, allTopics: const []),
// //               ),
// //         // TutorialPage(slug: slug),
// //       );
// //     }

// //     // ✅ Default
// //     return MaterialPageRoute(
// //       builder: (_) => const TopicsScreen(),
// //     );
// //   }

// //   // ---------------- THEME ----------------

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
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         clipBehavior: Clip.antiAlias,
// //         color: isDark ? Colors.grey[850] : Colors.white,
// //       ),
// //       inputDecorationTheme: InputDecorationTheme(
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(30),
// //         ),
// //         filled: true,
// //         fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
// //       ),
// //     );
// //   }
// // }


// // // import 'dart:async';
// // // import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_web_plugins/url_strategy.dart';
// // // import 'package:techtutorial/core/meta_service.dart';
// // // import 'package:techtutorial/screens/topics/topics_screen.dart';

// // // import 'screens/tutorial/tutorial_page.dart';

// // // void main() {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // // MetaService.setWebsiteSchema();
// // //   usePathUrlStrategy();

// // //   // Start the app immediately
// // //   runApp(const TutorialApp());
// // //   // After the first frame is painted, remove the splash & static SEO content
// // //   WidgetsBinding.instance.addPostFrameCallback((_) {
// // //     _removeStaticContent();
// // //   });
// // // }

// // // void _removeStaticContent() {
// // //   final splash = html.document.getElementById('splash');
// // //   final seo = html.document.getElementById('seo-content');
// // //   if (splash != null) {
// // //     splash.style.opacity = '0';
// // //     Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
// // //   }
// // //   if (seo != null) {
// // //     seo.style.display = 'none';
// // //   }
// // // }
// // // // ---------------------------- TutorialApp ----------------------------
// // // class TutorialApp extends StatelessWidget {
// // //   const TutorialApp({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: 'Flutter Tutorials',
// // //       debugShowCheckedModeBanner: false,
// // //       theme: _buildTheme(Brightness.light),
// // //       darkTheme: _buildTheme(Brightness.dark),
// // //       themeMode: ThemeMode.system,

// // //       onGenerateInitialRoutes: (initialRoute) {
// // //         if (initialRoute.startsWith('/tech/flutter/') &&
// // //             initialRoute.replaceFirst('/tech/flutter/', '').isNotEmpty) {
// // //           final slug = initialRoute.replaceFirst('/tech/flutter/', '');
// // //           return [
// // //             MaterialPageRoute(
// // //               builder: (context) => TutorialPage(
// // //                 args: TutorialArguments(slug: slug, allTopics: const []),
// // //               ),
// // //             ),
// // //           ];
// // //         }
// // //         return [
// // //           MaterialPageRoute(
// // //             builder: (context) => const TopicsScreen(),
// // //           ),
// // //         ];
// // //       },

// // //       routes: {
// // //         '/': (context) => const TopicsScreen(),
// // //       },

// // //       onGenerateRoute: (settings) {
// // //         if (settings.name != null &&
// // //             settings.name!.startsWith('/tech/flutter/') &&
// // //             settings.name!.replaceFirst('/tech/flutter/', '').isNotEmpty) {
// // //           final slug = settings.name!.replaceFirst('/tech/flutter/', '');
// // //           return MaterialPageRoute(
// // //             builder: (context) => TutorialPage(
// // //               args: TutorialArguments(slug: slug, allTopics: const []),
// // //             ),
// // //           );
// // //         }
// // //         return null;
// // //       },
// // //     );
// // //   }

// // //   ThemeData _buildTheme(Brightness brightness) {
// // //     final isDark = brightness == Brightness.dark;
// // //     return ThemeData(
// // //       brightness: brightness,
// // //       primaryColor: const Color(0xFF1E3C72),
// // //       colorScheme: ColorScheme.fromSwatch(
// // //         primarySwatch: Colors.blue,
// // //         brightness: brightness,
// // //       ).copyWith(secondary: const Color(0xFF2A5298)),
// // //       appBarTheme: const AppBarTheme(
// // //         elevation: 0,
// // //         centerTitle: true,
// // //         titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
// // //       ),
// // //       cardTheme: CardThemeData(
// // //         elevation: isDark ? 2 : 4,
// // //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// // //         clipBehavior: Clip.antiAlias,
// // //         color: isDark ? Colors.grey[850] : Colors.white,
// // //         shadowColor: Colors.black.withValues(alpha:0.1),
// // //       ),
// // //       inputDecorationTheme: InputDecorationTheme(
// // //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(width: 1)),
// // //         filled: true,
// // //         fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
// // //       ),
// // //       textTheme: const TextTheme(
// // //         displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
// // //         displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
// // //         bodyLarge: TextStyle(fontSize: 16, height: 1.6),
// // //         bodyMedium: TextStyle(fontSize: 14, height: 1.5),
// // //       ),
// // //     );
// // //   }
// // // }