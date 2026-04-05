// lib/models/screen_config.dart
import 'package:flutter/material.dart';

class ScreenConfig {
  final HeroConfig hero;
  final Map<String, CategoryConfig> categories;
  final List<DifficultyConfig> difficulties;
  final SEOConfig seo;
  final GridConfig grid;
  final FeatureFlags features;

  ScreenConfig({
    required this.hero,
    required this.categories,
    required this.difficulties,
    required this.seo,
    required this.grid,
    required this.features,
  });

  factory ScreenConfig.fromJson(Map<String, dynamic> json) {
    return ScreenConfig(
      hero: HeroConfig.fromJson(json['hero'] ?? {}),
      categories: (json['categories'] as Map? ?? {})
          .map((key, value) => MapEntry(key, CategoryConfig.fromJson(value))),
      difficulties: (json['difficulties'] as List? ?? [])
          .map((d) => DifficultyConfig.fromJson(d))
          .toList(),
      seo: SEOConfig.fromJson(json['seo'] ?? {}),
      grid: GridConfig.fromJson(json['grid'] ?? {}),
      features: FeatureFlags.fromJson(json['features'] ?? {}),
    );
  }

  static ScreenConfig getDefault() {
    return ScreenConfig(
      hero: HeroConfig.getDefault(),
      categories: {},
      difficulties: DifficultyConfig.getDefault(),
      seo: SEOConfig.getDefault(),
      grid: GridConfig.getDefault(),
      features: FeatureFlags.getDefault(),
    );
  }
}

class HeroConfig {
  final String badge;
  final String title;
  final String highlightedText;
  final String description;
  final List<String> chips;

  HeroConfig({
    required this.badge,
    required this.title,
    required this.highlightedText,
    required this.description,
    required this.chips,
  });

  factory HeroConfig.fromJson(Map<String, dynamic> json) {
    return HeroConfig(
      badge: json['badge'] ?? '🎯 Learning Hub',
      title: json['title'] ?? 'Master',
      highlightedText: json['highlightedText'] ?? 'with confidence',
      description: json['description'] ?? 'Start your learning journey today.',
      chips: List<String>.from(json['chips'] ?? []),
    );
  }

  static HeroConfig getDefault() {
    return HeroConfig(
      badge: '🎯 Flutter Learning Hub',
      title: 'Master Flutter',
      highlightedText: 'with confidence',
      description:
          'Real examples, interactive quizzes, and production-ready code. Start your Flutter journey today.',
      chips: [
        '📱 Cross-platform',
        '⚡ Fast Development',
        '🎯 Real-world Projects',
        '📝 Practice Quizzes'
      ],
    );
  }
}

class CategoryConfig {
  final String description;
  final String icon;
  final String color;
  final int estimatedHours;

  CategoryConfig({
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedHours,
  });

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    return CategoryConfig(
      description: json['description'] ?? '',
      icon: json['icon'] ?? '📚',
      color: json['color'] ?? '#64748b',
      estimatedHours: json['estimatedHours'] ?? 0,
    );
  }
}

class DifficultyConfig {
  final String name;
  final String color;
  final String icon;

  DifficultyConfig({
    required this.name,
    required this.color,
    required this.icon,
  });

  factory DifficultyConfig.fromJson(Map<String, dynamic> json) {
    return DifficultyConfig(
      name: json['name'] ?? 'All',
      color: json['color'] ?? '#64748b',
      icon: json['icon'] ?? '🎯',
    );
  }

  static List<DifficultyConfig> getDefault() {
    return [
      DifficultyConfig(name: 'All', color: '#64748b', icon: '🎯'),
      DifficultyConfig(name: 'Beginner', color: '#11998E', icon: '🌱'),
      DifficultyConfig(name: 'Intermediate', color: '#1e40af', icon: '⚡'),
      DifficultyConfig(name: 'Advanced', color: '#FF416C', icon: '🚀'),
    ];
  }

  Color get colorObj => Color(int.parse('0xff${color.replaceFirst('#', '')}'));
}

class SEOConfig {
  final String emoji;
  final String title;
  final String description;
  final List<String> tags;

  SEOConfig({
    required this.emoji,
    required this.title,
    required this.description,
    required this.tags,
  });

  factory SEOConfig.fromJson(Map<String, dynamic> json) {
    return SEOConfig(
      emoji: json['emoji'] ?? '📚',
      title: json['title'] ?? 'About This Tutorial Series',
      description: json['description'] ??
          'Learn programming with our comprehensive tutorials.',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  static SEOConfig getDefault() {
    return SEOConfig(
      emoji: '📚',
      title: 'About This Tutorial Series',
      description:
          'Flutter is an open-source UI toolkit by Google used to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. In this tutorial, you will learn Flutter step-by-step with real-world examples, covering widgets, layouts, state management, API integration, and advanced concepts.',
      tags: [
        'Flutter Tutorial',
        'Dart Programming',
        'Mobile Development',
        'Cross-platform',
        'UI Framework'
      ],
    );
  }
}

class GridConfig {
  final Map<int, int> breakpoints;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  GridConfig({
    required this.breakpoints,
    required this.childAspectRatio,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
  });

  factory GridConfig.fromJson(Map<String, dynamic> json) {
    final breakpointsJson = json['breakpoints'] as Map? ?? {};
    final breakpoints = <int, int>{};
    breakpointsJson.forEach((key, value) {
      breakpoints[int.parse(key)] = value;
    });

    return GridConfig(
      breakpoints: breakpoints,
      childAspectRatio: (json['childAspectRatio'] ?? 3.2).toDouble(),
      crossAxisSpacing: (json['crossAxisSpacing'] ?? 12).toDouble(),
      mainAxisSpacing: (json['mainAxisSpacing'] ?? 12).toDouble(),
    );
  }

  static GridConfig getDefault() {
    return GridConfig(
      breakpoints: {1200: 4, 800: 3, 500: 2, 0: 1},
      childAspectRatio: 3.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    );
  }

  int getCrossAxisCount(double width) {
    final sortedKeys = breakpoints.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final key in sortedKeys) {
      if (width >= key) {
        return breakpoints[key]!;
      }
    }
    return breakpoints[0] ?? 2;
  }
}

class FeatureFlags {
  final bool showProgressSection;
  final bool showContinueBanner;
  final bool showSearchFilters;
  final bool showFloatingButton;
  final bool enableAnimations;
  final bool showHeroSection;
  final bool showStatsSection;
  final bool showCategorySection;

  FeatureFlags({
    required this.showProgressSection,
    required this.showContinueBanner,
    required this.showSearchFilters,
    required this.showFloatingButton,
    required this.enableAnimations,
    required this.showHeroSection,
    required this.showStatsSection,
    required this.showCategorySection,
  });

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      showProgressSection: json['showProgressSection'] ?? true,
      showContinueBanner: json['showContinueBanner'] ?? true,
      showSearchFilters: json['showSearchFilters'] ?? true,
      showFloatingButton: json['showFloatingButton'] ?? true,
      enableAnimations: json['enableAnimations'] ?? true,
      showHeroSection: json['showHeroSection'] ?? true,
      showStatsSection: json['showStatsSection'] ?? true,
      showCategorySection: json['showCategorySection'] ?? true,
    );
  }

  static FeatureFlags getDefault() {
    return FeatureFlags(
      showProgressSection: true,
      showContinueBanner: true,
      showSearchFilters: true,
      showFloatingButton: true,
      enableAnimations: true,
      showHeroSection: true,
      showStatsSection: true,
      showCategorySection: true,
    );
  }
}