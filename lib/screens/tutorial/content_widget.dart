import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:techtutorial/models/content_item.dart';

class ContentItemWidget extends StatelessWidget {
  final ContentItem item;
  final Function(String) onCopy;

  const ContentItemWidget({
    super.key,
    required this.item,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ContentType.heading:
        return _buildHeading(context);

      case ContentType.text:
      case ContentType.list:
        return _buildText(context);

      case ContentType.code:
        return _buildCode();
    }
  }

  // 🔹 HEADING (Premium Section Style)
  Widget _buildHeading(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ),

            // 🔥 Anchor icon (pro docs feature)
            Icon(Icons.link, size: 16, color: Colors.grey.shade400),
          ],
        ),

        const SizedBox(height: 8),

        // subtle divider (better than thick bar)
        Container(
          height: 1.2,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A5298),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // 🔹 TEXT (Readable Layout)
Widget _buildText(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: MarkdownBody(
      data: item.value,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 15.5,
          height: 1.75,
          color: Color(0xFF334155),
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        listBullet: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
} 

 // 🔹 CODE (VS CODE STYLE BLOCK)
  Widget _buildCode() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: HighlightView(
              item.value,
              language: item.language ?? 'dart',
              theme: {
                'root': const TextStyle(
                  backgroundColor: Color(0xFF0D1117),
                  color: Colors.white,
                ),
                'keyword': const TextStyle(color: Color(0xFF79C0FF)),
                'string': const TextStyle(color: Color(0xFFA5D6FF)),
                'comment': const TextStyle(color: Color(0xFF8B949E)),
                'number': const TextStyle(color: Color(0xFF79C0FF)),
              },
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),

          // 🔹 HEADER BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Mac dots
                  Row(
                    children: const [
                      _Dot(color: Colors.red),
                      SizedBox(width: 6),
                      _Dot(color: Colors.yellow),
                      SizedBox(width: 6),
                      _Dot(color: Colors.green),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    (item.language ?? 'DART').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 10),

                  InkWell(
                    onTap: () => onCopy(item.value),
                    child: const Icon(Icons.copy,
                        size: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

// 🔹 Small colored dots (Mac style)
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
