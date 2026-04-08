// ==================== PRIVACY PAGE - SAME PATTERN AS ABOUT PAGE ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/widget/footer_card.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  void initState() {
    super.initState();

    MetaService.updateMetaTags(
      title: "Privacy Policy | RevoChamp Data Protection & Security",
      description:
          "Read RevoChamp privacy policy to understand how we collect, use, and protect your data securely.",
      slug: "privacy",
    );
    MetaService.setStructuredData({
      "@context": "https://schema.org",
      "@type": "WebPage",
      "name": "Privacy Policy",
      "description":
          "Read RevoChamp privacy policy to understand how we collect, use, and protect your data securely.",
      "url": "https://revochamp.site/tech/privacy",
      "inLanguage": "en",

      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "https://revochamp.site/tech/privacy",
      },

      "dateModified": "2026-01-01",

      "publisher": {"@type": "Organization", "name": "RevoChamp"},
    });
    MetaService.setBreadcrumbData(
      title: "Privacy Policy",
      slug: "privacy",
      parents: [
        {"name": "Home", "url": "https://revochamp.site/tech"},
      ],
    );
  }

  late bool isMobile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isMobile = MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    // final isMobile = MediaQuery.of(context).size.width < 600;

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
              },
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Your data & security",
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
                      "🔒 Your Privacy Matters",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Protecting your",
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
                      "data & privacy.",
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
                      "We are committed to protecting your personal information and being transparent about how we use it.",
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
                    "Last updated: January 2026",
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

          // Main Policy Sections
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
                  Text(
                    "Our Privacy Practices",
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 34,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "How we collect, use, and protect your information",
                    style: TextStyle(
                      fontSize: 16,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildPolicyGrid(isMobile),
                ],
              ),
            ),
          ),

          // Detailed Policy Sections
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 60,
              ),
              child: Column(
                children: [
                  _buildDataCollectionCard(isMobile),
                  const SizedBox(height: 40),
                  _buildDataUsageCard(isMobile),
                  const SizedBox(height: 40),
                  _buildDataSecurityCard(isMobile),
                  const SizedBox(height: 40),
                  _buildDataRightsCard(isMobile),
                ],
              ),
            ),
          ),

          // Contact Section
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
                    child: Text("📞", style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Questions About Your Privacy?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're here to help with any privacy concerns",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 3.0,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: const [
                          _ContactCard(
                            email: "privacy@RevoChamp.com",
                            icon: "🔒",
                            label: "Privacy Concerns",
                          ),
                          _ContactCard(
                            email: "data@RevoChamp.com",
                            icon: "📊",
                            label: "Data Requests",
                          ),
                          _ContactCard(
                            email: "support@RevoChamp.com",
                            icon: "💬",
                            label: "General Support",
                          ),
                          _ContactCard(
                            email: "security@RevoChamp.com",
                            icon: "🛡️",
                            label: "Security Issues",
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
            child: const Text("🔐", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Data is Safe",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We use bank-level encryption to protect your information at all times.",
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
            child: const Text("👁️", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Full Transparency",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We're clear about what data we collect and why we need it.",
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
            "You're in Control",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Access, update, or delete your personal data anytime.",
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

  Widget _buildPolicyGrid(bool isMobile) {
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
            _PolicyCard(
              emoji: "📋",
              title: "Information Collection",
              description:
                  "We collect only essential data to provide and improve our services",
            ),
            _PolicyCard(
              emoji: "🎯",
              title: "Usage of Data",
              description:
                  "Your information helps personalize your learning experience",
            ),
            _PolicyCard(
              emoji: "🛡️",
              title: "Data Protection",
              description:
                  "Industry-standard security measures protect your information",
            ),
            _PolicyCard(
              emoji: "✓",
              title: "Your Rights",
              description: "You have full control over your personal data",
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataCollectionCard(bool isMobile) {
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
                "Information We Collect",
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
            "Account Information: Name, email address, and profile details you provide during registration",
            isMobile,
          ),
          _buildBulletPoint(
            "Learning Data: Your course progress, quiz results, completion rates, and learning patterns",
            isMobile,
          ),
          _buildBulletPoint(
            "Device Information: Device type, operating system, browser type, and unique device identifiers",
            isMobile,
          ),
          _buildBulletPoint(
            "Usage Data: Pages visited, time spent on courses, features used, and interaction patterns",
            isMobile,
          ),
          _buildBulletPoint(
            "Analytics: Anonymous analytics data to help us improve our platform and user experience",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageCard(bool isMobile) {
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
                "How We Use Your Information",
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
            "To provide, maintain, and improve our educational services",
            isMobile,
          ),
          _buildBulletPoint(
            "To personalize your learning experience and course recommendations",
            isMobile,
          ),
          _buildBulletPoint(
            "To send important course updates, progress reports, and educational communications",
            isMobile,
          ),
          _buildBulletPoint(
            "To analyze usage patterns and optimize our platform performance",
            isMobile,
          ),
          _buildBulletPoint(
            "To comply with legal obligations and protect our users' rights",
            isMobile,
          ),
          _buildBulletPoint(
            "To prevent fraud and ensure platform security",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSecurityCard(bool isMobile) {
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
                "Data Security & Protection",
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
            "We implement industry-standard security measures including AES-256 encryption",
            isMobile,
          ),
          _buildBulletPoint(
            "All data is encrypted in transit using TLS 1.3 and at rest using secure storage",
            isMobile,
          ),
          _buildBulletPoint(
            "We conduct regular security audits, penetration testing, and vulnerability assessments",
            isMobile,
          ),
          _buildBulletPoint(
            "Access to personal data is strictly restricted to authorized personnel only",
            isMobile,
          ),
          _buildBulletPoint(
            "We fully comply with GDPR, CCPA, and other international privacy regulations",
            isMobile,
          ),
          _buildBulletPoint(
            "Regular backups ensure your data is never lost",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildDataRightsCard(bool isMobile) {
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
                child: const Text("✓", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Your Rights & Choices",
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
            "Right to Access: Request a complete copy of your personal data",
            isMobile,
          ),
          _buildBulletPoint(
            "Right to Rectify: Update or correct any inaccurate information",
            isMobile,
          ),
          _buildBulletPoint(
            "Right to Erasure: Request permanent deletion of your data",
            isMobile,
          ),
          _buildBulletPoint(
            "Right to Restrict: Limit how we use your data for specific purposes",
            isMobile,
          ),
          _buildBulletPoint(
            "Right to Portability: Export your data in a machine-readable format",
            isMobile,
          ),
          _buildBulletPoint(
            "Right to Object: Opt-out of certain data processing activities",
            isMobile,
          ),
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

// ==================== POLICY CARD COMPONENT ====================
class _PolicyCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _PolicyCard({
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

// ==================== CONTACT CARD COMPONENT ====================
class _ContactCard extends StatelessWidget {
  final String email;
  final String icon;
  final String label;

  const _ContactCard({
    required this.email,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
