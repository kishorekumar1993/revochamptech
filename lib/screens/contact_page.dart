// ==================== CONTACT PAGE - FULLY SEO OPTIMIZED ====================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/meta_service.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/widget/footer_card.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  // Custom OG image for contact page
  static const String _contactOgImage =
      'https://revochamp.site/tech/contact-og.png';

  @override
  void initState() {
    super.initState();

    // ✅ Meta tags with custom social image
    MetaService.updateMetaTags(
      title: "Contact RevoChamp | Support, Help & Enquiries",
      description:
          "Contact RevoChamp for support, queries, and feedback. Get help with courses, technical issues, and learning guidance.",
      slug: "contact",
      imageUrl: _contactOgImage,
      isArticle: false, // Contact page is not an article
    );

    // ✅ Breadcrumb schema
    MetaService.setBreadcrumbData(
      title: "Contact",
      slug: "contact",
      parents: [
        {"name": "Home", "url": "https://revochamp.site/tech"},
      ],
    );

    // ✅ Combined structured data (ContactPage + FAQPage + ContactPoint)
    MetaService.setStructuredData(
      {
        "@context": "https://schema.org",
        "@graph": [
          {
            "@type": "ContactPage",
            "@id": "https://revochamp.site/tech/contact",
            "name": "Contact RevoChamp",
            "url": "https://revochamp.site/tech/contact",
            "description": "Official contact page for RevoChamp support and help",
            "inLanguage": "en",
            "mainEntityOfPage": {
              "@type": "WebPage",
              "@id": "https://revochamp.site/tech/contact"
            },
            "publisher": {
              "@type": "Organization",
              "name": "RevoChamp",
              "url": "https://revochamp.site",
              "contactPoint": {
                "@type": "ContactPoint",
                "contactType": "customer support",
                "email": "support@revochamp.site",
                "url": "https://revochamp.site/tech/contact",
                "availableLanguage": ["English"]
              }
            }
          },
          // ✅ FAQPage schema – now matches visible content on page
          {
            "@type": "FAQPage",
            "mainEntity": [
              {
                "@type": "Question",
                "name": "How can I contact support?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text":
                      "You can contact our support team via email at support@revochamp.site or by using the contact form on this page."
                }
              },
              {
                "@type": "Question",
                "name": "How long does it take to get a response?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text":
                      "We typically respond to all inquiries within 24 hours on business days (Monday–Friday)."
                }
              },
              {
                "@type": "Question",
                "name": "What are your support hours?",
                "acceptedAnswer": {
                  "@type": "Answer",
                  "text":
                      "Our support team is available Monday–Friday from 9:00 AM to 6:00 PM, and Saturday from 10:00 AM to 4:00 PM."
                }
              }
            ]
          }
        ]
      },
      id: 'contact-page-schema',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Color(0xffef4444),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Replace with actual API call (e.g., Formspree, Firebase, custom backend)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Message sent! We'll get back to you soon."),
          backgroundColor: PremiumTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    });
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
            backgroundColor: Colors.white.withValues(alpha: 0.95),
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
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "We’re here to help",
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
                color: PremiumTheme.lightGray.withValues(alpha: 0.6),
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
                      "💬 Get in Touch",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "We'd love to",
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
                      "hear from you.",
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
                      "Have questions, feedback, or suggestions? Reach out to us — we're here to help!",
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

          // Quick Contact Cards
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 40,
              ),
              child: isMobile
                  ? Column(
                      children: [
                        _buildQuickContactCard(isMobile),
                        const SizedBox(height: 20),
                        _buildQuickContactCard2(isMobile),
                        const SizedBox(height: 20),
                        _buildQuickContactCard3(isMobile),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildQuickContactCard(isMobile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildQuickContactCard2(isMobile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildQuickContactCard3(isMobile)),
                      ],
                    ),
            ),
          ),

          // Contact Methods Grid
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
                    "Connect With Us",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: PremiumTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Multiple ways to reach our team",
                    style: TextStyle(
                      fontSize: 16,
                      color: PremiumTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildContactGrid(isMobile),
                ],
              ),
            ),
          ),

          // Contact Form Section
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
                vertical: 60,
              ),
              child: Column(children: [_buildContactFormCard(isMobile)]),
            ),
          ),

          // Support Hours Section
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
                    child: Text("⏰", style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Support Hours",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're here to help when you need us",
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
                          _SupportHourCard(
                            day: "Monday - Friday",
                            hours: "9:00 AM - 6:00 PM",
                            icon: "💼",
                          ),
                          _SupportHourCard(
                            day: "Saturday",
                            hours: "10:00 AM - 4:00 PM",
                            icon: "🌤️",
                          ),
                          _SupportHourCard(
                            day: "Sunday",
                            hours: "Closed",
                            icon: "😴",
                          ),
                          _SupportHourCard(
                            day: "Response Time",
                            hours: "Within 24 hours",
                            icon: "⚡",
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

          // ✅ Real FAQ Section (now matches structured data)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 80,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Semantics(
                        label: "Question mark icon",
                        child: const Text("❓", style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Frequently Asked Questions",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: PremiumTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFaqItem(
                    question: "How can I contact support?",
                    answer:
                        "You can contact our support team via email at support@revochamp.site or by using the contact form above.",
                  ),
                  _buildFaqItem(
                    question: "How long does it take to get a response?",
                    answer:
                        "We typically respond to all inquiries within 24 hours on business days (Monday–Friday).",
                  ),
                  _buildFaqItem(
                    question: "What are your support hours?",
                    answer:
                        "Our support team is available Monday–Friday from 9:00 AM to 6:00 PM, and Saturday from 10:00 AM to 4:00 PM.",
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

  // ✅ FAQ item widget
  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PremiumTheme.lightGray),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textDark,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: PremiumTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactCard(bool isMobile) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Semantics(
              label: "Email icon",
              child: const Icon(
                Icons.email,
                color: PremiumTheme.richBlue,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Email Us",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "support@revochamp.site",
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: PremiumTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactCard2(bool isMobile) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Semantics(
              label: "Chat icon",
              child: const Icon(
                Icons.chat,
                color: PremiumTheme.success,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Live Chat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Available during business hours",
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: PremiumTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactCard3(bool isMobile) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PremiumTheme.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Semantics(
              label: "Social media icon",
              child: Icon(Icons.share, color: PremiumTheme.warning, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Social Media",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: PremiumTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "@RevoChamp",
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: PremiumTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactGrid(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount =
            constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 2.0,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _ContactMethodCard(
              emoji: "📧",
              title: "Email Support",
              description: "24/7 email support for all inquiries",
            ),
            _ContactMethodCard(
              emoji: "💬",
              title: "Live Chat",
              description: "Real-time assistance during business hours",
            ),
            _ContactMethodCard(
              emoji: "📞",
              title: "Phone Support",
              description: "Priority support for urgent matters",
            ),
            _ContactMethodCard(
              emoji: "🌐",
              title: "Community Forum",
              description: "Connect with other learners",
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactFormCard(bool isMobile) {
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
                child: Semantics(
                  label: "Message icon",
                  child: const Text("📝", style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Send us a Message",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PremiumTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormField("Full Name", _nameController, "John Doe", isMobile),
          const SizedBox(height: 20),
          _buildFormField(
            "Email Address",
            _emailController,
            "john@example.com",
            isMobile,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            "Subject",
            _subjectController,
            "How can we help?",
            isMobile,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            "Message",
            _messageController,
            "Your message here...",
            isMobile,
            maxLines: 6,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.richBlue,
                disabledBackgroundColor:
                    PremiumTheme.richBlue.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Send Message →",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint,
    bool isMobile, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: PremiumTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: PremiumTheme.textLight,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: PremiumTheme.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: PremiumTheme.lightGray,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: PremiumTheme.richBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: PremiumTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== CONTACT METHOD CARD COMPONENT ====================
class _ContactMethodCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _ContactMethodCard({
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
          Semantics(
            label: title,
            child: Text(emoji, style: const TextStyle(fontSize: 36)),
          ),
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

// ==================== SUPPORT HOUR CARD COMPONENT ====================
class _SupportHourCard extends StatelessWidget {
  final String day;
  final String hours;
  final String icon;

  const _SupportHourCard({
    required this.day,
    required this.hours,
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
          Semantics(
            label: day,
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  hours,
                  style: TextStyle(
                    fontSize: 13,
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
// // ==================== CONTACT PAGE - SAME PATTERN AS OTHER PAGES ====================
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:techtutorial/core/meta_service.dart';
// import 'package:techtutorial/core/theme.dart';
// import 'package:techtutorial/widget/footer_card.dart';

// class ContactPage extends StatefulWidget {
//   const ContactPage({super.key});

//   @override
//   State<ContactPage> createState() => _ContactPageState();
// }

// class _ContactPageState extends State<ContactPage> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _subjectController = TextEditingController();
//   final _messageController = TextEditingController();
//   bool _isSubmitting = false;


// @override
// void initState() {
//   super.initState();

//   MetaService.updateMetaTags(
//     title: "Contact RevoChamp | Support, Help & Enquiries",
//     description:
//         "Contact RevoChamp for support, queries, and feedback. Get help with courses, technical issues, and learning guidance.",
//     slug: "contact",
//   );

// MetaService.setStructuredData({
//   "@context": "https://schema.org",
//   "@type": "ContactPage",
//   "name": "Contact RevoChamp",
//   "url": "https://revochamp.site/tech/contact",
//   "description": "Official contact page for RevoChamp support and help",
//   "inLanguage": "en",

//   "mainEntityOfPage": {
//     "@type": "WebPage",
//     "@id": "https://revochamp.site/tech/contact"
//   },

//   "publisher": {
//     "@type": "Organization",
//     "name": "RevoChamp"
//   }
// });
// MetaService.setBreadcrumbData(
//   title: "Contact",
//   slug: "contact",
//   parents: [
//     {"name": "Home", "url": "https://revochamp.site/tech"},
//   ],
// );

// MetaService.setStructuredData({
//   "@context": "https://schema.org",
//   "@type": "FAQPage",
//   "mainEntity": [
//     {
//       "@type": "Question",
//       "name": "How can I contact support?",
//       "acceptedAnswer": {
//         "@type": "Answer",
//         "text": "You can contact us via email or contact form."
//       }
//     },
//     {
//       "@type": "Question",
//       "name": "How long does it take to get a response?",
//       "acceptedAnswer": {
//         "@type": "Answer",
//         "text": "We typically respond within 24 hours."
//       }
//     }
//   ]
// });
// }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _subjectController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _submitForm() {
//     if (_nameController.text.isEmpty ||
//         _emailController.text.isEmpty ||
//         _subjectController.text.isEmpty ||
//         _messageController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please fill all fields"),
//           backgroundColor: Color(0xffef4444),
//           behavior: SnackBarBehavior.floating,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     // Simulate form submission
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() => _isSubmitting = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("✅ Message sent! We'll get back to you soon."),
//           backgroundColor: PremiumTheme.success,
//           behavior: SnackBarBehavior.floating,
//           duration: Duration(seconds: 3),
//         ),
//       );
//       _nameController.clear();
//       _emailController.clear();
//       _subjectController.clear();
//       _messageController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           // App Bar
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.white.withValues(alpha:0.95),
//             elevation: 0,
//             scrolledUnderElevation: 0,
//             surfaceTintColor: Colors.transparent,

//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, size: 18),
//               color: PremiumTheme.textDark,
//               onPressed: () {
//                 if (context.canPop()) {
//                   context.pop();
//                 } else {
//                   context.go('/');
//                 }
//               },
//             ),

//             title: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   "Contact Us",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: PremiumTheme.textDark,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   "We’re here to help",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: PremiumTheme.textMuted,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),

//             centerTitle: false,

//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(1),
//               child: Container(
//                 height: 1,
//                 color: PremiumTheme.lightGray.withValues(alpha:0.6),
//               ),
//             ),
//           ),
//           // Hero Section
//           SliverToBoxAdapter(
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 24 : 80,
//                 vertical: isMobile ? 50 : 70,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     PremiumTheme.richBlue.withValues(alpha: 0.05),
//                     Colors.white,
//                     PremiumTheme.softGray.withValues(alpha: 0.5),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: PremiumTheme.richBlue,
//                       borderRadius: BorderRadius.circular(50),
//                       boxShadow: [
//                         BoxShadow(
//                           color: PremiumTheme.richBlue.withValues(alpha: 0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Text(
//                       "💬 Get in Touch",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     "We'd love to",
//                     style: TextStyle(
//                       fontSize: isMobile ? 36 : 52,
//                       fontWeight: FontWeight.w800,
//                       color: PremiumTheme.textDark,
//                       letterSpacing: -0.5,
//                       height: 1.1,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ShaderMask(
//                     shaderCallback: (bounds) => const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
//                     ).createShader(bounds),
//                     child: Text(
//                       "hear from you.",
//                       style: TextStyle(
//                         fontSize: isMobile ? 36 : 52,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white,
//                         height: 1.1,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     constraints: const BoxConstraints(maxWidth: 600),
//                     child: Text(
//                       "Have questions, feedback, or suggestions? Reach out to us - we're here to help!",
//                       style: TextStyle(
//                         fontSize: isMobile ? 15 : 17,
//                         color: PremiumTheme.textMuted,
//                         height: 1.6,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Quick Contact Cards
//           SliverToBoxAdapter(
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 24 : 80,
//                 vertical: 40,
//               ),
//               child: isMobile
//                   ? Column(
//                       children: [
//                         _buildQuickContactCard(isMobile),
//                         const SizedBox(height: 20),
//                         _buildQuickContactCard2(isMobile),
//                         const SizedBox(height: 20),
//                         _buildQuickContactCard3(isMobile),
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         Expanded(child: _buildQuickContactCard(isMobile)),
//                         const SizedBox(width: 24),
//                         Expanded(child: _buildQuickContactCard2(isMobile)),
//                         const SizedBox(width: 24),
//                         Expanded(child: _buildQuickContactCard3(isMobile)),
//                       ],
//                     ),
//             ),
//           ),

//           // Contact Methods Grid
//           SliverToBoxAdapter(
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 24 : 80,
//                 vertical: 60,
//               ),
//               color: PremiumTheme.softGray,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Connect With Us",
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.w800,
//                       color: PremiumTheme.textDark,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Multiple ways to reach our team",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: PremiumTheme.textMuted,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 48),
//                   _buildContactGrid(isMobile),
//                 ],
//               ),
//             ),
//           ),

//           // Contact Form Section
//           SliverToBoxAdapter(
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 24 : 80,
//                 vertical: 60,
//               ),
//               child: Column(children: [_buildContactFormCard(isMobile)]),
//             ),
//           ),

//           // Support Hours Section
//           SliverToBoxAdapter(
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 20 : 20,
//                 vertical: 20,
//               ),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [PremiumTheme.richBlue, Color(0xff1e3a8a)],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: PremiumTheme.richBlue.withValues(alpha: 0.3),
//                     blurRadius: 24,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.only(top: 40),
//                     child: Text("⏰", style: TextStyle(fontSize: 48)),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Support Hours",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "We're here to help when you need us",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.white.withValues(alpha: 0.8),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       int crossAxisCount = constraints.maxWidth > 600 ? 4 : 1;
//                       return GridView.count(
//                         crossAxisCount: crossAxisCount,
//                         shrinkWrap: true,
//                         mainAxisSpacing: 16,
//                         crossAxisSpacing: 16,
//                         childAspectRatio: 3.5,
//                         physics: const NeverScrollableScrollPhysics(),
//                         padding: const EdgeInsets.all(24),
//                         children: const [
//                           _SupportHourCard(
//                             day: "Monday - Friday",
//                             hours: "9:00 AM - 6:00 PM",
//                             icon: "💼",
//                           ),
//                           _SupportHourCard(
//                             day: "Saturday",
//                             hours: "10:00 AM - 4:00 PM",
//                             icon: "🌤️",
//                           ),
//                           _SupportHourCard(
//                             day: "Sunday",
//                             hours: "Closed",
//                             icon: "😴",
//                           ),
//                           _SupportHourCard(
//                             day: "Response Time",
//                             hours: "Within 24 hours",
//                             icon: "⚡",
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),

//           // FAQ CTA
//           SliverToBoxAdapter(
//             child: Container(
//               margin: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 20 : 80,
//                 vertical: 40,
//               ),
//               padding: EdgeInsets.all(isMobile ? 24 : 32),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [PremiumTheme.softGray, Colors.white],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//               ),
//               child: Column(
//                 children: [
//                   const Text("❓", style: TextStyle(fontSize: 48)),
//                   const SizedBox(height: 16),
//                   Text(
//                     "Frequently Asked Questions",
//                     style: TextStyle(
//                       fontSize: isMobile ? 20 : 24,
//                       fontWeight: FontWeight.w800,
//                       color: PremiumTheme.textDark,
//                       letterSpacing: -0.3,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Find quick answers to common questions in our FAQ section",
//                     style: TextStyle(
//                       fontSize: isMobile ? 13 : 14,
//                       color: PremiumTheme.textMuted,
//                       fontWeight: FontWeight.w500,
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   OutlinedButton(
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("📚 FAQ page coming soon!"),
//                           behavior: SnackBarBehavior.floating,
//                           backgroundColor: PremiumTheme.richBlue,
//                           duration: Duration(seconds: 2),
//                         ),
//                       );
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         color: PremiumTheme.richBlue,
//                         width: 1.5,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       "View FAQs →",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: PremiumTheme.richBlue,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Footer
//           SliverToBoxAdapter(child: Footer(isMobile: isMobile)),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickContactCard(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 28),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: PremiumTheme.richBlue.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.email,
//               color: PremiumTheme.richBlue,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Email Us",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: PremiumTheme.textDark,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "support@RevoChamp.com",
//                   style: TextStyle(
//                     fontSize: isMobile ? 13 : 14,
//                     color: PremiumTheme.textMuted,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickContactCard2(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 28),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: PremiumTheme.success.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.chat,
//               color: PremiumTheme.success,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Live Chat",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: PremiumTheme.textDark,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Available during business hours",
//                   style: TextStyle(
//                     fontSize: isMobile ? 13 : 14,
//                     color: PremiumTheme.textMuted,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickContactCard3(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 28),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: PremiumTheme.warning.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(Icons.home, color: PremiumTheme.warning, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Social Media",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: PremiumTheme.textDark,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "@RevoChamp",
//                   style: TextStyle(
//                     fontSize: isMobile ? 13 : 14,
//                     color: PremiumTheme.textMuted,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactGrid(bool isMobile) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         int crossAxisCount = constraints.maxWidth > 900
//             ? 4
//             : (constraints.maxWidth > 600 ? 2 : 1);
//         return GridView.count(
//           crossAxisCount: crossAxisCount,
//           shrinkWrap: true,
//           mainAxisSpacing: 24,
//           crossAxisSpacing: 24,
//           childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 2.0,
//           physics: const NeverScrollableScrollPhysics(),
//           children: const [
//             _ContactMethodCard(
//               emoji: "📧",
//               title: "Email Support",
//               description: "24/7 email support for all inquiries",
//             ),
//             _ContactMethodCard(
//               emoji: "💬",
//               title: "Live Chat",
//               description: "Real-time assistance during business hours",
//             ),
//             _ContactMethodCard(
//               emoji: "📞",
//               title: "Phone Support",
//               description: "Priority support for urgent matters",
//             ),
//             _ContactMethodCard(
//               emoji: "🌐",
//               title: "Community Forum",
//               description: "Connect with other learners",
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildContactFormCard(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 24 : 32),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [PremiumTheme.richBlue.withValues(alpha: 0.05), Colors.white],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: PremiumTheme.richBlue.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text("📝", style: TextStyle(fontSize: 24)),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 "Send us a Message",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: PremiumTheme.textDark,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           _buildFormField("Full Name", _nameController, "John Doe", isMobile),
//           const SizedBox(height: 20),
//           _buildFormField(
//             "Email Address",
//             _emailController,
//             "john@example.com",
//             isMobile,
//           ),
//           const SizedBox(height: 20),
//           _buildFormField(
//             "Subject",
//             _subjectController,
//             "How can we help?",
//             isMobile,
//           ),
//           const SizedBox(height: 20),
//           _buildFormField(
//             "Message",
//             _messageController,
//             "Your message here...",
//             isMobile,
//             maxLines: 6,
//           ),
//           const SizedBox(height: 28),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isSubmitting ? null : _submitForm,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: PremiumTheme.richBlue,
//                 disabledBackgroundColor: PremiumTheme.richBlue.withValues(
//                   alpha: 0.5,
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 elevation: 0,
//               ),
//               child: _isSubmitting
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       "Send Message →",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormField(
//     String label,
//     TextEditingController controller,
//     String hint,
//     bool isMobile, {
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: PremiumTheme.textDark,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(
//               color: PremiumTheme.textLight,
//               fontSize: 14,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: PremiumTheme.lightGray),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: PremiumTheme.lightGray,
//                 width: 1.5,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: PremiumTheme.richBlue,
//                 width: 1.5,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//           ),
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 15,
//             color: PremiumTheme.textDark,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ==================== CONTACT METHOD CARD COMPONENT ====================
// class _ContactMethodCard extends StatelessWidget {
//   final String emoji;
//   final String title;
//   final String description;

//   const _ContactMethodCard({
//     required this.emoji,
//     required this.title,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: PremiumTheme.lightGray, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(emoji, style: const TextStyle(fontSize: 36)),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: PremiumTheme.textDark,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 13,
//               color: PremiumTheme.textMuted,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ==================== SUPPORT HOUR CARD COMPONENT ====================
// class _SupportHourCard extends StatelessWidget {
//   final String day;
//   final String hours;
//   final String icon;

//   const _SupportHourCard({
//     required this.day,
//     required this.hours,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.white.withValues(alpha: 0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 28)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   hours,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white.withValues(alpha: 0.8),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
