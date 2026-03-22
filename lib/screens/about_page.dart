import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();
    _setSEO();
  }

  // --------------------------------------------------
  // SEO
  // --------------------------------------------------
  void _setSEO() {
    html.document.title = "About Revochamp | Flutter Learning Platform";

    _setMetaTag(
      name: "description",
      content:
          "Revochamp is a modern Flutter learning platform providing tutorials, coding examples, and developer resources for beginners and professionals.",
    );

    _setMetaTag(
      name: "keywords",
      content:
          "Flutter tutorials, learn Flutter, Dart tutorials, mobile development, Revochamp",
    );

    _setMetaProperty(property: "og:title", content: "About Revochamp");
    _setMetaProperty(
        property: "og:description",
        content: "Learn Flutter with structured tutorials and real examples.");

    _setCanonical("https://revochamp.site/about");

    _addStructuredData();
  }

  void _setMetaTag({required String name, required String content}) {
    final existing = html.document.head!.querySelector("meta[name='$name']");
    if (existing != null) {
      existing.setAttribute("content", content);
    } else {
      final meta = html.MetaElement()
        ..name = name
        ..content = content;
      html.document.head!.append(meta);
    }
  }

  void _setMetaProperty({required String property, required String content}) {
    final meta = html.MetaElement()
      ..setAttribute("property", property)
      ..content = content;
    html.document.head!.append(meta);
  }

  void _setCanonical(String url) {
    final link = html.LinkElement()
      ..rel = "canonical"
      ..href = url;
    html.document.head!.append(link);
  }

  void _addStructuredData() {
    final script = html.ScriptElement()
      ..type = "application/ld+json"
      ..text = '''
      {
        "@context": "https://schema.org",
        "@type": "Organization",
        "name": "Revochamp",
        "url": "https://revochamp.site",
        "description": "Flutter tutorials, examples, and developer learning platform."
      }
      ''';

    html.document.head!.append(script);
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: primaryGradient),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.brightness == Brightness.dark
                  ? Colors.grey[900]!
                  : const Color(0xFFF8FAFC),
              theme.brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : const Color(0xFFEFF3F8),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _hero()),
            SliverToBoxAdapter(child: _content()),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HERO
  // --------------------------------------------------
  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Revochamp 🚀",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "A modern platform to master Flutter development",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CONTENT
  // --------------------------------------------------
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section("What is Revochamp?"),
                  _text(
                      "Revochamp is a Flutter-focused learning platform designed to help developers learn, build, and master mobile and web applications using Flutter and Dart."),

                  _section("What We Provide"),
                  _text("• Step-by-step Flutter tutorials"),
                  _text("• Real-world coding examples"),
                  _text("• Structured learning paths"),
                  _text("• Developer-friendly explanations"),

                  _section("Who is it for?"),
                  _text("• Beginners starting Flutter"),
                  _text("• Intermediate developers improving skills"),
                  _text("• Professionals building production apps"),

                  _section("Our Mission"),
                  _text(
                      "Our mission is to simplify Flutter learning by providing clear, structured, and practical content that helps developers grow faster."),

                  _section("Why Revochamp?"),
                  _text(
                      "We focus on practical learning, clean UI, and real use cases instead of just theory."),

                  _section("Contact"),
                  _text("support@revochamp.site"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------
  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _text(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text, style: const TextStyle(height: 1.6)),
      );
}