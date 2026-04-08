// ==================== ABOUT PAGE - FINAL IMPROVED DESIGN ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/widget/footer_card.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
 @override
void initState() {
  super.initState();

  const String aboutOgImage = 'https://revochamp.site/tech/about-og.png';

  MetaService.updateMetaTags(
    title: "About RevoChamp | Free Tech Learning Platform",
    description:
        "Learn about RevoChamp's mission, vision, and commitment to providing free, industry-ready tech education for everyone.",
    slug: "about",
    imageUrl: aboutOgImage,
    isArticle: false,
  );

  MetaService.setRobotsMeta('index, follow, max-image-preview:large');

  MetaService.setBreadcrumbData(
    title: "About",
    slug: "about",
    parents: [
      {"name": "Home", "url": "https://revochamp.site/tech"},
    ],
  );

  MetaService.setStructuredData({
    "@context": "https://schema.org",
    "@type": "AboutPage",
    "name": "About RevoChamp",
    "url": "https://revochamp.site/tech/about",
    "description":
        "Learn about RevoChamp mission, vision and free education platform.",
    "inLanguage": "en",
    "mainEntityOfPage": {
      "@type": "WebPage",
      "@id": "https://revochamp.site/tech/about"
    },
    "publisher": {
      "@type": "Organization",
      "name": "RevoChamp",
      "url": "https://revochamp.site",
      "logo": {
        "@type": "ImageObject",
        "url": "https://revochamp.site/tech/logo.png"
      },
      "foundingDate": "2023",
      "sameAs": [
        "https://twitter.com/revochamp",
        "https://www.facebook.com/revochamp",
        "https://www.linkedin.com/company/revochamp"
      ]
    }
  }, id: 'about-page-schema');
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
              },
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "About RevoChamp",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Our mission & vision",
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
                      "✨ Our Story",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Empowering learners",
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
                      "to build real-world skills.",
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
                      "Transform careers with free, industry-ready courses.",
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: PremiumTheme.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mission & Vision Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 40,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        _buildMissionCard(isMobile),
                        const SizedBox(height: 24),
                        _buildVisionCard(isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMissionCard(isMobile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildVisionCard(isMobile)),
                      ],
                    ),
            ),
          ),

          // Why Choose Us Section
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
                    "Why Choose RevoChamp?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "What makes us different",
                    style: TextStyle(
                      fontSize: 16,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildFeatureGrid(isMobile),
                ],
              ),
            ),
          ),

          // Our Story & Commitment
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 60,
              ),
              child: Column(
                children: [
                  _buildStoryCard(isMobile),
                  const SizedBox(height: 40),
                  _buildCommitmentCard(isMobile),
                ],
              ),
            ),
          ),

          // Stats Section
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
                    child: Text(
                      "Impact Numbers",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Trusted by learners worldwide",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        mainAxisSpacing: 30,
                        crossAxisSpacing: 20,
                        childAspectRatio:constraints.maxWidth > 600 ? 2.0:1.3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          _StatCard(
                            number: "100,000+",
                            label: "Learners",
                            icon: "👥",
                          ),
                          _StatCard(
                            number: "100+",
                            label: "Courses",
                            icon: "📚",
                          ),
                          _StatCard(
                            number: "50+",
                            label: "Experts",
                            icon: "👨‍🏫",
                          ),
                          _StatCard(number: "100%", label: "Free", icon: "🎁"),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Testimonial Section
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 80,
                vertical: 40,
              ),
              padding: EdgeInsets.all(isMobile ? 24 : 40),
              decoration: BoxDecoration(
                color: PremiumTheme.softGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text("❤️", style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 16),
                  Text(
                    "What Our Learners Say",
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTestimonial(isMobile),
                ],
              ),
            ),
          ),

          // Final CTA
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 80,
                vertical: 40,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 50,
                horizontal: isMobile ? 30 : 60,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xfff0f4f9), Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    "Start building your future today",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Join thousands of learners mastering in-demand tech skills for free",
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumTheme.richBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Start Learning Today →",
                      style: TextStyle(
                        fontSize: 15,
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

  Widget _buildMissionCard(bool isMobile) {
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
            child: const Text("🎯", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          const Text(
            "Our Mission",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We make world-class education accessible to all—equipping learners with practical, job-ready skills to succeed in a rapidly evolving digital world.",
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

  Widget _buildVisionCard(bool isMobile) {
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
            "Our Vision",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: PremiumTheme.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "A future where education is accessible to all, not limited by cost or location. We envision millions of learners transforming their lives through practical, real-world knowledge.",
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

  Widget _buildStoryCard(bool isMobile) {
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
                child: const Text("📖", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Our Story",
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
          Text(
            "RevoChamp was founded with a simple belief: quality education should not be limited by cost. Built by passionate developers and educators, the platform was created to bridge the gap between learning and real-world skills.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Today, RevoChamp has grown into a global learning platform, helping thousands of learners across 50+ countries gain practical skills, advance their careers, and unlock new opportunities.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentCard(bool isMobile) {
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
                child: const Text("💪", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Text(
                "Our Commitment",
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
          Text(
            "We are committed to delivering a learning experience you can trust:",
            style: TextStyle(
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.w700,
              color: PremiumTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _CommitmentItem(
                text: "✓ 100% Free Forever",
                color: PremiumTheme.success,
              ),
              _CommitmentItem(
                text: "✓ Industry-Relevant Content",
                color: PremiumTheme.richBlue,
              ),
              _CommitmentItem(
                text: "✓ Regular Updates",
                color: PremiumTheme.richBlue,
              ),
              _CommitmentItem(
                text: "✓ Expert Instructors",
                color: PremiumTheme.richBlue,
              ),
              _CommitmentItem(
                text: "✓ Practical Projects",
                color: PremiumTheme.richBlue,
              ),
              _CommitmentItem(
                text: "✓ Community Support",
                color: PremiumTheme.richBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isMobile) {
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
          childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 1.9,

          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _FeatureCard(
              emoji: "🎓",
              title: "Expert-Led Courses",
              description:
                  "Designed by industry professionals with real-world experience",
            ),
            _FeatureCard(
              emoji: "💰",
              title: "Always Free",
              description:
                  "Learn without subscriptions, hidden fees, or limitations",
            ),
            _FeatureCard(
              emoji: "🚀",
              title: "Job-Ready Skills",
              description:
                  "Build practical projects that prepare you for real careers",
            ),
            _FeatureCard(
              emoji: "📈",
              title: "Learn Anytime",
              description: "Access content anytime with lifetime availability",
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestimonial(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star,
                color: PremiumTheme.accentGold,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "I started with no coding background. RevoChamp helped me build real projects and gain confidence. Within months, I landed my first developer job.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textMuted,
              height: 1.6,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            "— Sarah Johnson",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PremiumTheme.textDark,
            ),
          ),
          const Text(
            "Frontend Developer",
            style: TextStyle(fontSize: 12, color: PremiumTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

// ==================== STAT CARD COMPONENT ====================
class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final String icon;

  const _StatCard({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==================== FEATURE CARD COMPONENT ====================
class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _FeatureCard({
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

// ==================== COMMITMENT ITEM COMPONENT ====================
class _CommitmentItem extends StatelessWidget {
  final String text;
  final Color color;

  const _CommitmentItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
