import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:techtutorial/models/content_item.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const _editorBg = Color(0xFF0D1117);
const _editorHeader = Color(0xFF161B22);
const _editorBorder = Color(0xFF21262D);
const _accent = Color(0xFF3B82F6);
const _accentGlow = Color(0xFF60A5FA);
const _accentSoft = Color(0xFF1D3461);
const _textPrimary = Color(0xFFE2E8F0);
const _textSecondary = Color(0xFF94A3B8);
const _textMuted = Color(0xFF8B949E);
const _headingColor = Color(0xFFF1F5F9);

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

  // ─── Heading ─────────────────────────────────────────────────────────────
  Widget _buildHeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left accent mark
              Container(
                width: 4,
                height: 28,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_accent, _accentGlow],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha:0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _headingColor,
                    letterSpacing: -0.4,
                    height: 1.3,
                  ),
                ),
              ),
              // Anchor icon
              Icon(Icons.tag_rounded, size: 15, color: _textMuted.withValues(alpha:0.5)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Text / List ─────────────────────────────────────────────────────────
  Widget _buildText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: MarkdownBody(
        data: item.value,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 15,
            height: 1.8,
            color: _textSecondary,
            letterSpacing: 0.1,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
          em: const TextStyle(
            fontStyle: FontStyle.italic,
            color: _accentGlow,
          ),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: _accentGlow,
            backgroundColor: Color(0xFF1A2235),
          ),
          codeblockDecoration: BoxDecoration(
            color: _editorBg,
            borderRadius: BorderRadius.circular(8),
          ),
          blockquoteDecoration: BoxDecoration(
            color: _accentSoft.withValues(alpha:0.4),
            border: const Border(left: BorderSide(color: _accent, width: 3)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          blockquote: const TextStyle(
            color: _accentGlow,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          listBullet: const TextStyle(
            fontSize: 15,
            color: _accentGlow,
            fontWeight: FontWeight.bold,
          ),
          listIndent: 20,
          a: const TextStyle(
            color: _accentGlow,
            decoration: TextDecoration.underline,
            decorationColor: _accentSoft,
          ),
          h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _headingColor),
          h2: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: _headingColor),
          h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary),
        ),
      ),
    );
  }

  // ─── Code Block ──────────────────────────────────────────────────────────
  Widget _buildCode() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _editorBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _editorBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                color: _editorHeader,
                border: Border(bottom: BorderSide(color: _editorBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const _MacDots(),
                  const SizedBox(width: 12),
                  // Language badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      (item.language ?? 'dart').toUpperCase(),
                      style: const TextStyle(
                        color: _accentGlow,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _CopyButton(onTap: () => onCopy(item.value)),
                ],
              ),
            ),
            // Code
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16), // 👈 increase top padding
                child: HighlightView(
                   item.value,
                   language: item.language ?? 'dart',
                   theme: {
                     'root': const TextStyle(
                       backgroundColor: _editorBg,
                       color: _textPrimary,
                     ),
                     'keyword': const TextStyle(color: Color(0xFF79C0FF)),
                     'built_in': const TextStyle(color: Color(0xFFFFA657)),
                     'type': const TextStyle(color: Color(0xFFFFA657)),
                     'literal': const TextStyle(color: Color(0xFF79C0FF)),
                     'number': const TextStyle(color: Color(0xFFFF7B72)),
                     'regexp': const TextStyle(color: Color(0xFF7EE787)),
                     'string': const TextStyle(color: Color(0xFFA5D6FF)),
                     'subst': const TextStyle(color: _textPrimary),
                     'symbol': const TextStyle(color: Color(0xFF7EE787)),
                     'class': const TextStyle(color: Color(0xFFFFA657)),
                     'function': const TextStyle(color: Color(0xFFD2A8FF)),
                     'title': const TextStyle(color: Color(0xFFD2A8FF)),
                     'params': const TextStyle(color: _textPrimary),
                     'comment': const TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
                     'doctag': const TextStyle(color: Color(0xFF79C0FF)),
                     'meta': const TextStyle(color: Color(0xFF8B949E)),
                     'variable': const TextStyle(color: Color(0xFFFFA657)),
                     'attr': const TextStyle(color: Color(0xFF79C0FF)),
                     'tag': const TextStyle(color: Color(0xFF7EE787)),
                     'name': const TextStyle(color: Color(0xFF7EE787)),
                     'selector-id': const TextStyle(color: Color(0xFFFFA657)),
                     'selector-class': const TextStyle(color: Color(0xFFFFA657)),
                     'selector-attr': const TextStyle(color: Color(0xFF79C0FF)),
                     'selector-pseudo': const TextStyle(color: Color(0xFF79C0FF)),
                     'link': const TextStyle(color: _accentGlow),
                     'attribute': const TextStyle(color: Color(0xFFFFA657)),
                     'addition': const TextStyle(color: Color(0xFFA8FF97), backgroundColor: Color(0xFF0D261A)),
                     'deletion': const TextStyle(color: Color(0xFFFF7B72), backgroundColor: Color(0xFF2D0B0B)),
                   },
                   textStyle: const TextStyle(
                     fontFamily: 'monospace',
                     fontSize: 13.5,
                     height: 1.65,
                   ),
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mac Dots ─────────────────────────────────────────────────────────────────
class _MacDots extends StatelessWidget {
  const _MacDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _Dot(color: Color(0xFFFF5F56)),
        SizedBox(width: 6),
        _Dot(color: Color(0xFFFFBD2E)),
        SizedBox(width: 6),
        _Dot(color: Color(0xFF27C93F)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha:0.3), blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }
}

// ─── Copy Button ──────────────────────────────────────────────────────────────
class _CopyButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CopyButton({required this.onTap});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  bool _hovered = false;

  void _handleTap() async {
    widget.onTap();
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _copied
                ? const Color(0xFF0D2B22)
                : _hovered
                    ? const Color(0xFF21262D)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _copied
                  ? const Color(0xFF10B981).withValues(alpha:0.4)
                  : _hovered
                      ? _editorBorder
                      : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 13,
                color: _copied ? const Color(0xFF10B981) : _textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                _copied ? 'Copied!' : 'Copy',
                style: TextStyle(
                  fontSize: 11,
                  color: _copied ? const Color(0xFF10B981) : _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_highlight/flutter_highlight.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:techtutorial/models/content_item.dart';

// class ContentItemWidget extends StatelessWidget {
//   final ContentItem item;
//   final Function(String) onCopy;

//   const ContentItemWidget({
//     super.key,
//     required this.item,
//     required this.onCopy,
//   });

//   @override
//   Widget build(BuildContext context) {
//     switch (item.type) {
//       case ContentType.heading:
//         return _buildHeading(context);

//       case ContentType.text:
//       case ContentType.list:
//         return _buildText(context);

//       case ContentType.code:
//         return _buildCode();
//     }
//   }

//   // 🔹 HEADING (Premium Section Style)
//   Widget _buildHeading(BuildContext context) {
//   return Padding(
//     padding: const EdgeInsets.only(top: 32, bottom: 14),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 item.value,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF0F172A),
//                   letterSpacing: -0.2,
//                 ),
//               ),
//             ),

//             // 🔥 Anchor icon (pro docs feature)
//             Icon(Icons.link, size: 16, color: Colors.grey.shade400),
//           ],
//         ),

//         const SizedBox(height: 8),

//         // subtle divider (better than thick bar)
//         Container(
//           height: 1.2,
//           width: 60,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 const Color(0xFF2A5298),
//                 Colors.transparent,
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   // 🔹 TEXT (Readable Layout)
// Widget _buildText(BuildContext context) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     padding: const EdgeInsets.symmetric(horizontal: 6),
//     child: MarkdownBody(
//       data: item.value,
//       styleSheet: MarkdownStyleSheet(
//         p: const TextStyle(
//           fontSize: 15.5,
//           height: 1.75,
//           color: Color(0xFF334155),
//         ),
//         strong: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         listBullet: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// } 

//  // 🔹 CODE (VS CODE STYLE BLOCK)
//   Widget _buildCode() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0D1117),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.2),
//             blurRadius: 12,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
//             child: HighlightView(
//               item.value,
//               language: item.language ?? 'dart',
//               theme: {
//                 'root': const TextStyle(
//                   backgroundColor: Color(0xFF0D1117),
//                   color: Colors.white,
//                 ),
//                 'keyword': const TextStyle(color: Color(0xFF79C0FF)),
//                 'string': const TextStyle(color: Color(0xFFA5D6FF)),
//                 'comment': const TextStyle(color: Color(0xFF8B949E)),
//                 'number': const TextStyle(color: Color(0xFF79C0FF)),
//               },
//               textStyle: const TextStyle(
//                 fontFamily: 'monospace',
//                 fontSize: 14,
//                 height: 1.6,
//               ),
//             ),
//           ),


//           // 🔹 HEADER BAR
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF161B22),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   // Mac dots
//                   Row(
//                     children: const [
//                       _Dot(color: Colors.red),
//                       SizedBox(width: 6),
//                       _Dot(color: Colors.yellow),
//                       SizedBox(width: 6),
//                       _Dot(color: Colors.green),
//                     ],
//                   ),

//                   const Spacer(),

//                   Text(
//                     (item.language ?? 'DART').toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   const SizedBox(width: 10),

//                   InkWell(
//                     onTap: () => onCopy(item.value),
//                     child: const Icon(Icons.copy,
//                         size: 16, color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


// }

// // 🔹 Small colored dots (Mac style)
// class _Dot extends StatelessWidget {
//   final Color color;
//   const _Dot({required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 10,
//       height: 10,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     );
//   }
// }
