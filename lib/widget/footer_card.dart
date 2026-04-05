import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:techtutorial/core/theme.dart';

void navigateToAbout(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => const AboutPage()),
  // );
  context.go('/about');
}

void navigateToContact(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => const ContactPage()),
  // );

  context.go('/contact');
}

void navigateToPrivacy(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => const PrivacyPage()),
  // );
  context.go('/privacy');
}

void navigateToTerms(BuildContext context) {
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(builder: (context) => const TermsPage()),
  // );
  context.go('/terms');
}



// Alternative: Top Banner (non-intrusive)
void showSnackBar(String message, BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: -100.0, end: 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(offset: Offset(0, value), child: child);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: PremiumTheme.richBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// Widget buildFooter(bool isMobile, BuildContext context) {
Widget buildFooter(BuildContext context, bool isMobile) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 50, horizontal: isMobile ? 24 : 80),
    color: PremiumTheme.darkNavy,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                Text(
                  "Making education accessible\nto everyone, everywhere.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterColumn("Explore", [
                    {"title": "Courses", "onTap": () {}},
                    {"title": "About", "onTap": () => navigateToAbout(context)},
                    {
                      "title": "Contact",
                      "onTap": () => navigateToContact(context),
                    },
                  ]),
                  const SizedBox(width: 60),
                  _buildFooterColumn("Legal", [
                    {
                      "title": "Privacy",
                      "onTap": () => navigateToPrivacy(context),
                    },
                    {"title": "Terms", "onTap": () => navigateToTerms(context)},
                    {
                      "title": "Cookies",
                      "onTap": () =>
                          showSnackBar("Cookie settings coming soon", context),
                    },
                  ]),
                  const SizedBox(width: 60),
                  _buildFooterColumn("Connect", [
                    {
                      "title": "Twitter",
                      "onTap": () =>
                          showSnackBar("Twitter coming soon", context),
                    },
                    {
                      "title": "LinkedIn",
                      "onTap": () =>
                          showSnackBar("LinkedIn coming soon", context),
                    },
                    {
                      "title": "GitHub",
                      "onTap": () =>
                          showSnackBar("GitHub coming soon", context),
                    },
                  ]),
                ],
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink("Courses", () {}),
              _buildFooterLink("About", () => navigateToAbout(context)),
              _buildFooterLink("Contact", () => navigateToContact(context)),
              _buildFooterLink("Privacy", () => navigateToPrivacy(context)),
              _buildFooterLink("Terms", () => navigateToTerms(context)),
            ],
          ),
        ],
        const SizedBox(height: 50),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "© 2026 RevoLearn. All rights reserved.",
              style: TextStyle(
                color: Color(0xff94a3b8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "❤️ Made with passion",
              style: TextStyle(
                color: Color(0xff94a3b8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFooterColumn(String title, List<Map<String, dynamic>> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 16),
      ...items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: item['onTap'] as VoidCallback,
            child: Text(
              item['title'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildLogo() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PremiumTheme.richBlue, Color(0xff1e40af)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "RL",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        "RevoLearn",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ],
  );
}

Widget _buildFooterLink(String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xffa1aec3),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class Footer extends StatelessWidget {
  final bool isMobile;

  const Footer({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return buildFooter(context, isMobile);
  }
}
