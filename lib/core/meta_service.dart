import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

class MetaService {
  static const String _baseUrl = 'https://revochamp.site/tech';

  static void updateMetaTags({
    required String title,
    required String description,
    String? imageUrl,
    String? slug,
  }) {
    if (!kIsWeb) return;
    html.document.title = title;
    _updateNameMeta('description', description);
    _updateNameMeta('keywords', 'flutter, tutorial, ${title.toLowerCase()}');
    _updatePropertyMeta('og:title', title);
    _updatePropertyMeta('og:description', description);
    _updatePropertyMeta('og:image', imageUrl ?? '$_baseUrl/default-og-image.png');
    _updatePropertyMeta('og:url', slug != null ? '$_baseUrl/flutter/$slug' : _baseUrl);
    _updatePropertyMeta('og:type', 'article');
    _updateNameMeta('twitter:card', 'summary_large_image');
    _updateNameMeta('twitter:title', title);
    _updateNameMeta('twitter:description', description);
    _updateNameMeta('twitter:image', imageUrl ?? '$_baseUrl/default-og-image.png');
    _updatePropertyMeta('og:site_name', 'Revochamp');
_updateNameMeta('application-name', 'Revochamp');
  }

  static void _updateNameMeta(String name, String content) {
    var tag = html.document.querySelector('meta[name="$name"]') as html.MetaElement?;
    if (tag == null) {
      tag = html.MetaElement()..name = name;
      html.document.head?.append(tag);
    }
    tag.content = content;
  }

  static void _updatePropertyMeta(String property, String content) {
    var tag = html.document.querySelector('meta[property="$property"]') as html.MetaElement?;
    if (tag == null) {
      tag = html.MetaElement()..setAttribute('property', property);
      html.document.head?.append(tag);
    }
    tag.setAttribute('content', content);
  }

  static void setStructuredData(Map<String, dynamic> data) {
    if (!kIsWeb) return;
    final existing = html.document.querySelector('script[type="application/ld+json"]');
    existing?.remove();
    final script = html.ScriptElement()
      ..type = 'application/ld+json'
      ..text = jsonEncode(data);
    html.document.head?.append(script);
  }
static void setWebsiteSchema() {
  if (!kIsWeb) return;

  final existing = html.document.querySelector('#website-schema');
  if (existing != null) return; // prevent duplicate

  final script = html.ScriptElement()
    ..id = 'website-schema'
    ..type = 'application/ld+json'
    ..text = jsonEncode({
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "Revochamp",
      "url": "https://revochamp.site/tech"
    });

  html.document.head?.append(script);
}

  static void setBreadcrumbData({
    required String title,
    required String slug,
    List<Map<String, String>>? parents,
  }) {
    final itemListElement = <Map<String, dynamic>>[];
    var position = 1;
    if (parents != null) {
      for (final parent in parents) {
        itemListElement.add({
          '@type': 'ListItem',
          'position': position++,
          'name': parent['name'],
          'item': parent['url'],
        });
      }
    }
    itemListElement.add({
      '@type': 'ListItem',
      'position': position,
      'name': title,
      'item': '$_baseUrl/flutter/$slug',
    });
    setStructuredData({
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': itemListElement,
    });
  }

  static void setCanonical(String url) {
    if (!kIsWeb) return;
    final existing = html.document.querySelector('link[rel="canonical"]');
    existing?.remove();
    final link = html.LinkElement()
      ..rel = 'canonical'
      ..href = url;
    html.document.head?.append(link);
  }

  @visibleForTesting
  static void clearAll() {
    if (!kIsWeb) return;
    final head = html.document.head;
    if (head != null) {
      head
          .querySelectorAll('meta[name], meta[property], script[type="application/ld+json"], link[rel="canonical"]')
          .forEach((element) => element.remove());
    }
  }
}

