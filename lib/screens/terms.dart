import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {

  @override
  void initState() {
    super.initState();
    _setSEO(); // 🔥 SEO
  }

  // --------------------------------------------------
  // SEO META TAGS
  // --------------------------------------------------
  void _setSEO() {
    html.document.title = "Terms & Conditions | Revochamp";

    _setMetaTag(
      name: "description",
      content:
          "Read the Terms and Conditions for using Revochamp Flutter tutorials, coding guides, and developer resources.",
    );

    _setMetaTag(
      name: "keywords",
      content:
          "terms and conditions, flutter tutorials, revochamp, developer platform",
    );

    _setMetaProperty(property: "og:title", content: "Terms & Conditions | Revochamp");
    _setMetaProperty(property: "og:type", content: "website");

    _setCanonical("https://revochamp.site/terms");

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
        "@type": "WebPage",
        "name": "Terms and Conditions - Revochamp",
        "url": "https://revochamp.site/terms",
        "description": "Terms and Conditions for using Revochamp Flutter tutorials."
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
        title: const Text("Terms & Conditions"),
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
            "Terms & Conditions 📜",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Rules and guidelines for using Revochamp",
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
                  _title("Effective Date: March 22, 2026"),

                  _section("1. Acceptance of Terms"),
                  _text("By accessing Revochamp, you agree to comply with these terms."),

                  _section("2. Use of Content"),
                  _text("All tutorials and content are for educational purposes only."),
                  _text("You may not copy, reproduce, or redistribute content without permission."),

                  _section("3. User Responsibility"),
                  _text("You agree to use the website responsibly and not misuse the platform."),

                  _section("4. Intellectual Property"),
                  _text("All content, design, and branding belong to Revochamp."),

                  _section("5. Disclaimer"),
                  _text("We provide content as-is without guarantees of accuracy or completeness."),

                  _section("6. Limitation of Liability"),
                  _text("We are not responsible for any damages resulting from use of the website."),

                  _section("7. External Links"),
                  _text("We are not responsible for third-party websites linked from our platform."),

                  _section("8. Changes to Terms"),
                  _text("We may update these terms at any time."),

                  _section("9. Contact"),
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