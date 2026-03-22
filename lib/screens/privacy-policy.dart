import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  @override
  void initState() {
    super.initState();
    _setSEO(); // 🔥 SEO injection
  }

  // --------------------------------------------------
  // 🔥 SEO META TAGS (CRITICAL FOR ADSENSE + GOOGLE)
  // --------------------------------------------------
  void _setSEO() {
    // Title
    html.document.title = "Privacy Policy | Revochamp Flutter Tutorials";

    // Description
    _setMetaTag(
      name: "description",
      content:
          "Read the Privacy Policy of Revochamp - a Flutter tutorial platform providing coding guides, examples, and developer resources.",
    );

    // Keywords
    _setMetaTag(
      name: "keywords",
      content:
          "Flutter privacy policy, Revochamp, Flutter tutorials, developer learning platform",
    );

    // Open Graph (for sharing)
    _setMetaProperty(
      property: "og:title",
      content: "Privacy Policy | Revochamp",
    );

    _setMetaProperty(
      property: "og:description",
      content:
          "Privacy policy of Revochamp Flutter tutorial platform.",
    );

    _setMetaProperty(
      property: "og:type",
      content: "website",
    );

    // Canonical URL
    _setCanonical("https://revochamp.site/privacy-policy");

    // Structured Data (SEO BOOST)
    _addStructuredData();
  }

void _setMetaTag({required String name, required String content}) {
  final existing = html.document.head!
      .querySelector("meta[name='$name']");
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
        "@type": "WebPage",
        "name": "Privacy Policy - Revochamp",
        "url": "https://revochamp.site/privacy-policy",
        "description": "Privacy Policy for Revochamp Flutter tutorial platform."
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
        title: const Text("Privacy Policy"),
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
            "Privacy Policy 🔐",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "How we collect, use and protect your data",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CONTENT CARD
  // --------------------------------------------------
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // SEO readability
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
                  _title("Effective Date: March 22, 2026"),

                  _section("1. Introduction"),
                  _text(
                      "Revochamp is a Flutter tutorial platform providing coding guides, examples, and developer resources."),

                  _section("2. Information We Collect"),
                  _text(
                      "We collect basic usage data such as IP address, browser type, pages visited, and time spent."),

                  _section("3. How We Use Data"),
                  _text(
                      "To improve tutorials, enhance user experience, and analyze traffic."),

                  _section("4. Cookies"),
                  _text(
                      "We use cookies to improve performance and personalize experience."),

                  _section("5. Google AdSense"),
                  _text(
                      "We display ads via Google AdSense which may use cookies to show relevant ads."),

                  _section("6. Third-party Services"),
                  _text(
                      "We may use analytics and advertising tools for performance tracking."),

                  _section("7. Security"),
                  _text(
                      "We implement security measures, but no system is fully secure."),

                  _section("8. Contact"),
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

  Widget _title(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
}