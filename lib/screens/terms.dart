// ==================== TERMS PAGE - SAME PATTERN AS ABOUT & PRIVACY PAGES ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/widget/footer_card.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  void initState() {
    super.initState();

    MetaService.updateMetaTags(
      title: "Terms of Service | RevoChamp User Agreement",
      description:
          "Review RevoChamp terms and conditions to understand your rights and responsibilities while using our platform.",
      slug: "terms",
    );

    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "WebPage",
      "name": "Terms of Service",
      "description":
          "Review RevoChamp terms and conditions to understand your rights and responsibilities.",
      "url": "https://revochamp.site/tech/terms",
      "keywords":
          "terms of service RevoChamp, user agreement, platform terms, legal conditions, learning platform rules",
      "dateModified": "2026-01-01",
      "inLanguage": "en",
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "https://revochamp.site/tech/terms",
      },
      "publisher": {"@type": "Organization", "name": "RevoChamp"},
    });

    MetaService.setBreadcrumbData(
      title: "Terms of Service",
      slug: "terms",
      parents: [
        {"name": "Home", "url": "https://revochamp.site/tech"},
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha:0.95),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: PremiumTheme.textDark,
              onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Terms of Service",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Legal terms & conditions",
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            centerTitle: false,

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: PremiumTheme.lightGray.withValues(alpha:0.6),
              ),
            ),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: isMobile ? 50 : 70,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumTheme.richBlue.withValues(alpha: 0.05),
                    Colors.white,
                    PremiumTheme.softGray.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumTheme.richBlue,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.richBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "⚖️ Legal Agreement",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Our commitment",
                    style: TextStyle(
                      fontSize: isMobile ? 36 : 52,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
                    ).createShader(bounds),
                    child: Text(
                      "to you.",
                      style: TextStyle(
                        fontSize: isMobile ? 36 : 52,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Text(
                      "Clear, fair terms that protect both you and our learning community.",
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: PremiumTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Effective: January 2026",
                    style: TextStyle(
                      fontSize: 13,
                      color: PremiumTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Key Principles Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 40,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        _buildPrincipleCard(isMobile),
                        const SizedBox(height: 24),
                        _buildPrincipleCard2(isMobile),
                        const SizedBox(height: 24),
                        _buildPrincipleCard3(isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPrincipleCard(isMobile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildPrincipleCard2(isMobile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildPrincipleCard3(isMobile)),
                      ],
                    ),
            ),
          ),

          // Key Terms Grid
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 60,
              ),
              color: PremiumTheme.softGray,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Key Terms",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "What you need to know",
                    style: TextStyle(
                      fontSize: 16,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTermsGrid(isMobile),
                ],
              ),
            ),
          ),

          // Detailed Terms Sections
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 60,
              ),
              child: Column(
                children: [
                  _buildUsageTermsCard(isMobile),
                  const SizedBox(height: 40),
                  _buildUserConductCard(isMobile),
                  const SizedBox(height: 40),
                  _buildIntellectualPropertyCard(isMobile),
                  const SizedBox(height: 40),
                  _buildDisclaimerCard(isMobile),
                ],
              ),
            ),
          ),

          // Additional Terms Section
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 20,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PremiumTheme.richBlue, Color(0xff1e3a8a)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.richBlue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("📜", style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Additional Terms",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Important information about your rights",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 4 : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3.5,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: const [
                          _AdditionalTermCard(
                            title: "Termination",
                            description:
                                "We may terminate accounts violating these terms",
                            icon: "⚠️",
                          ),
                          _AdditionalTermCard(
                            title: "Governing Law",
                            description:
                                "These terms are governed by applicable laws",
                            icon: "⚖️",
                          ),
                          _AdditionalTermCard(
                            title: "Changes to Terms",
                            description:
                                "We may update terms with reasonable notice",
                            icon: "🔄",
                          ),
                          _AdditionalTermCard(
                            title: "Contact Us",
                            description:
                                "Questions? Reach out to legal@RevoChamp.com",
                            icon: "📧",
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Acceptance CTA
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 80,
                vertical: 40,
              ),
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PremiumTheme.softGray, Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text("🤝", style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    "By using RevoChamp, you agree to these terms",
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We're committed to providing a safe, fair learning environment for everyone",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumTheme.richBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "I Accept & Continue →",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(child: Footer(isMobile: isMobile)),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("🛡️", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Fair & Transparent",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Clear terms that protect both learners and our platform.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard2(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PremiumTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("✓", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Rights",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Understand what you can expect from our service.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCard3(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PremiumTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("⚡", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Community Safety",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Guidelines that ensure a positive learning environment.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsGrid(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 1.8,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _TermCard(
              emoji: "📋",
              title: "Use License",
              description:
                  "Personal, non-commercial use of our learning materials",
            ),
            _TermCard(
              emoji: "🎯",
              title: "User Conduct",
              description: "Respectful behavior and community guidelines",
            ),
            _TermCard(
              emoji: "🛡️",
              title: "Intellectual Property",
              description: "Course content is protected by copyright",
            ),
            _TermCard(
              emoji: "⚖️",
              title: "Limitations",
              description: "Clear terms about liability and warranties",
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageTermsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PremiumTheme.richBlue.withValues(alpha: 0.05), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTheme.richBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("📋", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Use License & Access",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletPoint(
            "Personal, non-commercial use of course materials is permitted",
            isMobile,
          ),
          _buildBulletPoint(
            "One temporary download copy for personal viewing only",
            isMobile,
          ),
          _buildBulletPoint(
            "Cannot modify, copy, or distribute course content",
            isMobile,
          ),
          _buildBulletPoint(
            "No commercial use or public display of materials",
            isMobile,
          ),
          _buildBulletPoint(
            "Cannot decompile or reverse engineer any software",
            isMobile,
          ),
          _buildBulletPoint(
            "Must retain all copyright and proprietary notices",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildUserConductCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("🎯", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "User Conduct & Responsibilities",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletPoint(
            "Treat all community members with respect and professionalism",
            isMobile,
          ),
          _buildBulletPoint(
            "Do not harass or cause distress to other users",
            isMobile,
          ),
          _buildBulletPoint(
            "No transmission of obscene or offensive content",
            isMobile,
          ),
          _buildBulletPoint(
            "Do not disrupt normal platform operations",
            isMobile,
          ),
          _buildBulletPoint(
            "No unauthorized access attempts to our systems",
            isMobile,
          ),
          _buildBulletPoint("Report violations to our support team", isMobile),
        ],
      ),
    );
  }

  Widget _buildIntellectualPropertyCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PremiumTheme.richBlue.withValues(alpha: 0.05), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTheme.richBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("🛡️", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Intellectual Property",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletPoint(
            "All course materials are property of RevoChamp",
            isMobile,
          ),
          _buildBulletPoint(
            "Videos, lectures, quizzes are copyright protected",
            isMobile,
          ),
          _buildBulletPoint(
            "No reproduction or distribution without permission",
            isMobile,
          ),
          _buildBulletPoint(
            "Course content is for personal learning only",
            isMobile,
          ),
          _buildBulletPoint(
            "Trademarks and logos cannot be used without consent",
            isMobile,
          ),
          _buildBulletPoint(
            "User-generated content remains your property",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: PremiumTheme.softGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("⚠️", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Disclaimer & Limitations",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBulletPoint(
            "Materials provided 'as is' without warranties",
            isMobile,
          ),
          _buildBulletPoint(
            "No guarantee of accuracy or completeness",
            isMobile,
          ),
          _buildBulletPoint(
            "Not liable for indirect or consequential damages",
            isMobile,
          ),
          _buildBulletPoint(
            "Maximum liability limited to amount paid (if any)",
            isMobile,
          ),
          _buildBulletPoint(
            "Content may be updated without prior notice",
            isMobile,
          ),
          _buildBulletPoint("Use at your own discretion and risk", isMobile),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: PremiumTheme.richBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: PremiumTheme.textMuted,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TERM CARD COMPONENT ====================
class _TermCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _TermCard({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: PremiumTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: PremiumTheme.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ADDITIONAL TERM CARD COMPONENT ====================
class _AdditionalTermCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;

  const _AdditionalTermCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
