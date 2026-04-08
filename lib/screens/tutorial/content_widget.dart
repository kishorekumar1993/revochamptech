import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:techtutorial/core/theme.dart';
import 'package:techtutorial/models/content_item.dart';

// ─── Design tokens matching HomePage PremiumTheme ─────────────────────────
const _accent = PremiumTheme.richBlue;
const _accentGlow = Color(0xFF3B82F6);
const _accentSoft = Color(0xFFEFF6FF);
const _textPrimary = PremiumTheme.textDark;
const _textSecondary = PremiumTheme.textMuted;
const _textLight = PremiumTheme.textLight;
const _border = PremiumTheme.lightGray;
const _codeBg = Color(0xFFF8FAFC);
const _codeBorder = Color(0xFFE2E8F0);
const _codeHeaderBg = Color(0xFFF1F5F9);
const _headingColor = PremiumTheme.textDark;

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
        return _buildHeading();
      case ContentType.subheading:
        return _buildSubheading();
      case ContentType.text:
        return _buildText();
      case ContentType.list:
        return _buildList();
      case ContentType.code:
        return _buildCode();
      case ContentType.table:
        return _buildTable();
      case ContentType.callout:
        return _buildCallout();
    }
  }

  // ─── Main Heading ────────────────────────────────────────────────────────
  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accent, Color(0xff1e40af)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _headingColor,
                letterSpacing: -0.4,
                height: 1.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.link_rounded,
              size: 14,
              color: _accent.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Subheading ──────────────────────────────────────────────────────────
  Widget _buildSubheading() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _headingColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Text Content ────────────────────────────────────────────────────────
  Widget _buildText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.5),
      ),
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
            color: _accent,
          ),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: _accent,
            backgroundColor: Color(0xFFF1F5F9),
          ),
          codeblockDecoration: BoxDecoration(
            color: _codeBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _codeBorder),
          ),
          blockquoteDecoration: BoxDecoration(
            color: _accentSoft,
            border: const Border(left: BorderSide(color: _accent, width: 3)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          blockquote: const TextStyle(
            color: _accent,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          listBullet: const TextStyle(
            fontSize: 15,
            color: _accent,
            fontWeight: FontWeight.bold,
          ),
          listIndent: 20,
          a: const TextStyle(
            color: _accent,
            decoration: TextDecoration.underline,
          ),
          h1: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _headingColor,
            letterSpacing: -0.3,
          ),
          h2: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _headingColor,
            letterSpacing: -0.2,
          ),
          h3: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
          h4: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          tableHead: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
          tableBody: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
      ),
    );
  }

  // ─── List Widget ─────────────────────────────────────────────────────────
 // ─── List Widget ─────────────────────────────────────────────────────────
Widget _buildList() {
  List<String> items = [];
  
  try {
    if (item.value is List) {
      // Convert each item to string to handle dynamic types
      items = (item.value as List).map((e) => e.toString()).toList();
    } else if (item.value is String) {
      items = (item.value as String).split('\n').where((l) => l.trim().isNotEmpty).toList();
    }
  } catch (e) {
    debugPrint('Error parsing list: $e');
    items = [];
  }

  if (items.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((listItem) {
        final isCheckbox = listItem.trim().startsWith('- [ ]') || listItem.trim().startsWith('- [x]');
        final isBullet = listItem.trim().startsWith('- ') || listItem.trim().startsWith('* ');
        final isNumbered = RegExp(r'^\d+\.').hasMatch(listItem.trim());
        
        String displayText = listItem;
        bool isChecked = false;
        
        if (isCheckbox) {
          isChecked = listItem.trim().contains('[x]');
          displayText = listItem.replaceFirst(RegExp(r'- \[[ x]\]'), '').trim();
        } else if (isBullet) {
          displayText = listItem.replaceFirst(RegExp(r'^[-*] '), '').trim();
        } else if (isNumbered) {
          displayText = listItem.replaceFirst(RegExp(r'^\d+\. '), '').trim();
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCheckbox)
                Icon(
                  isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  size: 20,
                  color: isChecked ? _accent : _textLight,
                )
              else if (isBullet)
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
              else if (isNumbered)
                Container(
                  width: 24,
                  margin: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${listItem.trim().split('.')[0]}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _accent,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              Expanded(
                child: _buildMarkdownText(displayText),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
  Widget _buildMarkdownText(String text) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: _textSecondary,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        a: const TextStyle(
          color: _accent,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // ─── Table Widget ────────────────────────────────────────────────────────
// ─── Table Widget ────────────────────────────────────────────────────────
Widget _buildTable() {
  try {
    final tableData = item.tableData;
    if (tableData == null || tableData.isEmpty) {
      return _buildEmptyTable();
    }

    // Properly cast headers with type conversion
    final headersRaw = tableData['headers'];
    final headers = headersRaw is List 
        ? headersRaw.map((e) => e.toString()).toList() 
        : <String>[];
    
    // Properly cast rows with type conversion
    final rowsRaw = tableData['rows'];
    List<List<String>> rows = [];
    if (rowsRaw is List) {
      rows = rowsRaw.map((row) {
        if (row is List) {
          return row.map((cell) => cell.toString()).toList();
        }
        return <String>[];
      }).toList();
    }

    if (headers.isEmpty && rows.isEmpty) {
      return _buildEmptyTable();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => _accentSoft,
            ),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _textPrimary,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
            columnSpacing: 24,
            horizontalMargin: 16,
            dividerThickness: 1,
            border: TableBorder(
              horizontalInside: BorderSide(color: _border.withValues(alpha: 0.5)),
              verticalInside: BorderSide(color: _border.withValues(alpha: 0.5)),
              bottom: BorderSide(color: _border),
              top: BorderSide(color: _border),
              left: BorderSide(color: _border),
              right: BorderSide(color: _border),
            ),
            columns: headers.map((header) {
              return DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _buildMarkdownText(header),
                ),
              );
            }).toList(),
            rows: rows.map((row) {
              return DataRow(
                cells: row.map((cell) {
                  return DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _buildMarkdownText(cell),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error building table: $e');
    return _buildEmptyTable();
  }
} 

 Widget _buildEmptyTable() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.table_chart, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Table data not available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Callout Widget (Info, Tip, Warning, etc.) ───────────────────────────
  Widget _buildCallout() {
    final variant = item.variant ?? 'info';
    
    Color backgroundColor;
    Color borderColor;
    IconData icon;
    Color iconColor;
    
    switch (variant.toLowerCase()) {
      case 'tip':
        backgroundColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF10B981);
        icon = Icons.lightbulb_rounded;
        iconColor = const Color(0xFF059669);
        break;
      case 'warning':
        backgroundColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        iconColor = const Color(0xFFD97706);
        break;
      case 'danger':
      case 'error':
        backgroundColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        iconColor = const Color(0xFFDC2626);
        break;
      case 'info':
      default:
        backgroundColor = _accentSoft;
        borderColor = _accent;
        icon = Icons.info_rounded;
        iconColor = _accent;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMarkdownText(item.value),
          ),
        ],
      ),
    );
  }

  // ─── Code Block ──────────────────────────────────────────────────────────
  Widget _buildCode() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _codeHeaderBg,
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  const _MacDots(),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_accent, Color(0xff1e40af)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (item.language ?? 'html').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _CopyButton(onTap: () => onCopy(item.value)),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: HighlightView(
                  item.value,
                  language: item.language ?? 'html',
                  theme: _getLightTheme(),
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.5,
                    height: 1.65,
                    color: _textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getLightTheme() {
    return {
      'root': const TextStyle(
        backgroundColor: Colors.white,
        color: _textPrimary,
      ),
      'keyword': const TextStyle(color: Color(0xFF7C3AED)),
      'built_in': const TextStyle(color: Color(0xFFEA580C)),
      'type': const TextStyle(color: Color(0xFFEA580C)),
      'literal': const TextStyle(color: Color(0xFF7C3AED)),
      'number': const TextStyle(color: Color(0xFFDC2626)),
      'regexp': const TextStyle(color: Color(0xFF059669)),
      'string': const TextStyle(color: Color(0xFF2563EB)),
      'symbol': const TextStyle(color: Color(0xFF059669)),
      'class': const TextStyle(color: Color(0xFFEA580C)),
      'function': const TextStyle(color: Color(0xFF7C3AED)),
      'title': const TextStyle(color: Color(0xFF7C3AED)),
      'params': const TextStyle(color: _textPrimary),
      'comment': const TextStyle(
        color: Color(0xFF94A3B8),
        fontStyle: FontStyle.italic,
      ),
      'doctag': const TextStyle(color: Color(0xFF7C3AED)),
      'meta': const TextStyle(color: Color(0xFF94A3B8)),
      'variable': const TextStyle(color: Color(0xFFEA580C)),
      'attr': const TextStyle(color: Color(0xFF7C3AED)),
      'tag': const TextStyle(color: Color(0xFF059669)),
      'name': const TextStyle(color: Color(0xFF059669)),
      'selector-id': const TextStyle(color: Color(0xFFEA580C)),
      'selector-class': const TextStyle(color: Color(0xFFEA580C)),
      'selector-attr': const TextStyle(color: Color(0xFF7C3AED)),
      'selector-pseudo': const TextStyle(color: Color(0xFF7C3AED)),
      'link': const TextStyle(color: _accent),
      'attribute': const TextStyle(color: Color(0xFFEA580C)),
      'addition': const TextStyle(
        color: Color(0xFF059669),
        backgroundColor: Color(0xFFECFDF5),
      ),
      'deletion': const TextStyle(
        color: Color(0xFFDC2626),
        backgroundColor: Color(0xFFFEF2F2),
      ),
    };
  }
}

// ─── Mac Dots ──────────────────────────────────────────────────────────────
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
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 3,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

// ─── Copy Button ───────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _copied
                ? const Color(0xFFD1FAE5)
                : _hovered
                    ? _accentSoft
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _copied
                  ? const Color(0xFF10B981)
                  : _hovered
                      ? _accent
                      : _border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 14,
                color: _copied ? const Color(0xFF059669) : _textLight,
              ),
              const SizedBox(width: 6),
              Text(
                _copied ? 'Copied!' : 'Copy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _copied ? const Color(0xFF059669) : _textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
