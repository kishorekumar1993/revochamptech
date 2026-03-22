import 'dart:async';
import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/screens/about_page.dart';
import 'package:techtutorial/screens/contact_page.dart';
import 'package:techtutorial/screens/privacy-policy.dart';
import 'package:techtutorial/screens/terms.dart';
import 'package:techtutorial/screens/topics/topics_screen.dart';
import 'screens/tutorial/tutorial_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MetaService.setWebsiteSchema();
  usePathUrlStrategy(); // ✅ Remove #

  runApp(TutorialApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _removeStaticContent();
  });
}

void _removeStaticContent() {
  final splash = html.document.getElementById('splash');
  final seo = html.document.getElementById('seo-content');

  if (splash != null) {
    splash.style.opacity = '0';
    Future.delayed(const Duration(milliseconds: 300), () => splash.remove());
  }

  if (seo != null) {
    seo.style.display = 'none';
  }
}

class TutorialApp extends StatelessWidget {
  TutorialApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // ✅ DEEP LINK REDIRECT (/tech → clean URL)
    redirect: (context, state) {
      final uri = state.uri;
      final segments = uri.pathSegments;

      if (segments.isNotEmpty && segments[0] == 'tech') {
        final newPath = '/' + segments.skip(1).join('/');
        return newPath.isEmpty ? '/' : newPath;
      }

      return null;
    },

    routes: [
      // HOME
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const TopicsScreen(),
      ),

      // CATEGORY
      GoRoute(
        path: '/flutter',
        name: 'flutter',
        builder: (context, state) => const TopicsScreen(),
      ),
GoRoute(
  path: '/privacy-policy',
  name: 'privacy',
  builder: (context, state) => const PrivacyPolicyPage(),
),GoRoute(
  path: '/terms',
  builder: (context, state) => const TermsPage(),
),GoRoute(
  path: '/about',
  builder: (context, state) => const AboutPage(),
),GoRoute(
  path: '/contact',
  builder: (context, state) => const ContactPage(),
),
      // ✅ TUTORIAL PAGE (IMPORTANT)
      GoRoute(
        path: '/flutter/:slug',
        name: 'tutorial',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';

          return TutorialPage(
            key: ValueKey(slug), // 🔥 FIX: forces rebuild
            args: TutorialArguments(
              slug: slug,
              allTopics: TopicsScreen.cachedTopics,
            ),
          );
        },
      ),
    ],

    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('404 - Page Not Found')),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Tutorials',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }

  // ---------- THEME ----------
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primaryColor: const Color(0xFF1E3C72),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: brightness,
      ).copyWith(
        secondary: const Color(0xFF2A5298),
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        color: isDark ? Colors.grey[850] : Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
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
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
