import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import '../../core/theme.dart'; // assuming this exports primaryGradient etc.

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusMessage = FocusNode();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // --------------------------------------------------
  // SEO (Web only)
  // --------------------------------------------------
  @override
  void initState() {
    super.initState();
    _setSEO();
  }

  void _setSEO() {
    html.document.title = "Contact Us | Revochamp";
    _setMetaTag(
      name: "description",
      content:
          "Contact Revochamp for Flutter tutorials, support, or collaboration inquiries.",
    );
    _setCanonical("https://revochamp.site/contact");
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

  void _setCanonical(String url) {
    // Remove any existing canonical link to avoid duplicates
    final existing = html.document.head!.querySelector("link[rel='canonical']");
    existing?.remove();
    final link = html.LinkElement()
      ..rel = "canonical"
      ..href = url;
    html.document.head!.append(link);
  }

  // --------------------------------------------------
  // FORM SUBMIT (Real API call)
  // --------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = jsonEncode({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'message': messageController.text.trim(),
      });

      // Replace with your actual endpoint
      const apiUrl = '/api/contact';

      final request = await html.HttpRequest.request(
        apiUrl,
        method: 'POST',
        sendData: data,
        requestHeaders: {
          'Content-Type': 'application/json',
          // Add any other headers (e.g., CSRF token) here
        },
      );

      if (request.status == 200 || request.status == 201) {
        // Success
        _clearForm();
        _showSnackBar('Message sent successfully!', isError: false);
      } else {
        // Server responded with an error
        throw Exception('Server responded with ${request.status}');
      }
    } catch (e) {
      // Network error or other failure
      setState(() {
        errorMessage = 'Failed to send message. Please try again later.';
      });
      _showSnackBar(errorMessage!, isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    messageController.clear();
    _formKey.currentState?.reset(); // clears validation errors
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
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
              isDark ? Colors.grey[900]! : const Color(0xFFF8FAFC),
              isDark ? Colors.grey[850]! : const Color(0xFFEFF3F8),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _hero()),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(child: _mainContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Us 📩",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Have questions or feedback? Reach out to us.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _mainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: use two columns if screen width > 800
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _contactInfoCard()),
              const SizedBox(width: 24),
              Expanded(child: _formCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _contactInfoCard(),
              const SizedBox(height: 24),
              _formCard(),
            ],
          );
        }
      },
    );
  }

  Widget _contactInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get in touch",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.email, "support@revochamp.site", isEmail: true),
            const SizedBox(height: 12),
            _infoRow(Icons.phone, "+1 (555) 123-4567"),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, "123 Flutter Ave, Silicon Valley, CA"),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Social Media",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _socialIcon(Icons.chat, "Discord", onTap: () {}),
                const SizedBox(width: 16),
                _socialIcon(Icons.code, "GitHub", onTap: () {}),
                const SizedBox(width: 16),
                _socialIcon(Icons.camera_alt, "Instagram", onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool isEmail = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: isEmail
                ? () {
                    // Copy email to clipboard
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isEmail ? Colors.blue : null,
                decoration: isEmail ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: Colors.blueGrey),
      ),
    );
  }

Widget _formCard() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _input(
              controller: nameController,
              label: "Name",
              icon: Icons.person,
              focusNode: _focusName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name is required";
                }
                if (value.length < 2) {
                  return "Name must be at least 2 characters";
                }
                return null;
              },
              onSubmitted: () => FocusScope.of(context).requestFocus(_focusEmail),
            ),
            const SizedBox(height: 16),
            _input(
              controller: emailController,
              label: "Email",
              icon: Icons.email,
              focusNode: _focusEmail,
              isEmail: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                final pattern = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );
                if (!pattern.hasMatch(value)) {
                  return "Enter a valid email address";
                }
                return null;
              },
              onSubmitted: () => FocusScope.of(context).requestFocus(_focusMessage),
            ),
            const SizedBox(height: 16),
            _input(
              controller: messageController,
              label: "Message",
              icon: Icons.message,
              focusNode: _focusMessage,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Message is required";
                }
                if (value.length < 10) {
                  return "Message must be at least 10 characters";
                }
                return null;
              },
              // No onSubmitted for multiline field
            ),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send Message"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _input({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required FocusNode focusNode,
  bool isEmail = false,
  int maxLines = 1,
  String? Function(String?)? validator,
  VoidCallback? onSubmitted, // optional callback for single-line fields
}) {
  return TextFormField(
    controller: controller,
    focusNode: focusNode,
    maxLines: maxLines,
    keyboardType: maxLines > 1
        ? TextInputType.multiline
        : (isEmail ? TextInputType.emailAddress : TextInputType.text),
    textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    onFieldSubmitted: maxLines == 1 ? (_) => onSubmitted?.call() : null,
  );
}
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    _focusName.dispose();
    _focusEmail.dispose();
    _focusMessage.dispose();
    super.dispose();
  }
}