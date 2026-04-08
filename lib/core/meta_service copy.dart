// // ==================== meta_service.dart - FIXED VERSION ====================
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// class MetaService {
//   static const String _baseUrl = 'https://revochamp.site/tech';
//   static const String _defaultImage = '$_baseUrl/default-og-image.png';
//   static const String _siteName = 'Revochamp';
//   static const String _twitterHandle = '@revochamp';

//   // ============ VERIFICATION TAGS ============
//   static void setVerificationTags({
//     String? google,
//     String? bing,
//     String? yandex,
//     String? pinterest,
//     String? facebook,
//   }) {
//     if (!kIsWeb) return;
    
//     if (google != null) {
//       _updateMeta('google-site-verification', google, name: true);
//     }
//     if (bing != null) {
//       _updateMeta('msvalidate.01', bing, name: true);
//     }
//     if (yandex != null) {
//       _updateMeta('yandex-verification', yandex, name: true);
//     }
//     if (pinterest != null) {
//       _updateMeta('p:domain_verify', pinterest, name: true);
//     }
//     if (facebook != null) {
//       _updateMeta('facebook-domain-verification', facebook, name: true);
//     }
//   }

//   // ============ MAIN METHOD ============
//   static void updateMetaTags({
//     required String title,
//     required String description,
//     String? imageUrl,
//     String? slug,
//     String? author,
//     DateTime? publishedDate,
//     DateTime? modifiedDate,
//     List<String>? keywords,
//     bool isArticle = true,
//     bool noIndex = false,
//   }) {
//     if (!kIsWeb) return;

//     final fullUrl = slug != null
//         ? '$_baseUrl/$slug'
//         : html.window.location.href;

//     final finalImageUrl = imageUrl ?? _defaultImage;
//     final finalKeywords = keywords ?? ['flutter', 'tutorial', 'revochamp', 'programming', 'coding'];
    
//     html.document.title = title;
//     _updateMeta('description', description, name: true);
//     _updateMeta('keywords', finalKeywords.join(', '), name: true);
//     _updateMeta('author', author ?? _siteName, name: true);
//     _updateMeta('viewport', 'width=device-width, initial-scale=1.0, maximum-scale=5.0', name: true);
    
//     if (noIndex) {
//       _updateMeta('robots', 'noindex, nofollow', name: true);
//     } else {
//       _updateMeta('robots', 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1', name: true);
//     }
    
//     // Open Graph
//     _updateMeta('og:title', title, property: true);
//     _updateMeta('og:description', description, property: true);
//     _updateMeta('og:image', finalImageUrl, property: true);
//     _updateMeta('og:image:alt', title, property: true);
//     _updateMeta('og:image:width', '1200', property: true);
//     _updateMeta('og:image:height', '630', property: true);
//     _updateMeta('og:url', fullUrl, property: true);
//     _updateMeta('og:type', isArticle ? 'article' : 'website', property: true);
//     _updateMeta('og:site_name', _siteName, property: true);
//     _updateMeta('og:locale', 'en_US', property: true);
    
//     if (isArticle && publishedDate != null) {
//       _updateMeta('article:published_time', publishedDate.toIso8601String(), property: true);
//       if (modifiedDate != null) {
//         _updateMeta('article:modified_time', modifiedDate.toIso8601String(), property: true);
//       }
//       if (author != null) {
//         _updateMeta('article:author', author, property: true);
//       }
//       _updateMeta('article:section', 'Technology', property: true);
//     }
    
//     // Twitter
//     _updateMeta('twitter:card', 'summary_large_image', name: true);
//     _updateMeta('twitter:site', _twitterHandle, name: true);
//     _updateMeta('twitter:creator', _twitterHandle, name: true);
//     _updateMeta('twitter:title', title, name: true);
//     _updateMeta('twitter:description', description, name: true);
//     _updateMeta('twitter:image', finalImageUrl, name: true);
//     _updateMeta('twitter:image:alt', title, name: true);
    
//     setCanonical(fullUrl);
//   }
  
//   // ============ CORE METHODS ============
//   static void _updateMeta(String key, String content, {
//     bool name = false,
//     bool property = false,
//     bool rel = false,
//     String? hreflang,
//   }) {
//     String selector;
    
//     if (name) {
//       selector = 'meta[name="$key"]';
//     } else if (property) {
//       selector = 'meta[property="$key"]';
//     } else if (rel) {
//       selector = 'link[rel="$key"]';
//     } else {
//       return;
//     }
    
//     var element = html.document.querySelector(selector);
    
//     if (element == null) {
//       if (rel) {
//         element = html.LinkElement();
//         (element as html.LinkElement).rel = key;
//         if (hreflang != null) {
//           (element).hreflang = hreflang;
//         }
//       } else {
//         element = html.MetaElement();
//         if (name) {
//           (element as html.MetaElement).name = key;
//         } else if (property) {
//           (element as html.MetaElement).setAttribute('property', key);
//         }
//       }
//       html.document.head?.append(element);
//     }
    
//     if (rel) {
//       (element as html.LinkElement).href = content;
//     } else {
//       (element as html.MetaElement).content = content;
//     }
//   }

//   static void setStructuredData(Map<String, dynamic> data, {String? id}) {
//     if (!kIsWeb) return;
    
//     final selector = id != null 
//         ? 'script[type="application/ld+json"][id="$id"]'
//         : 'script[type="application/ld+json"]';
    
//     final existing = html.document.querySelector(selector);
//     existing?.remove();
    
//     final script = html.ScriptElement()
//       ..type = 'application/ld+json'
//       ..text = jsonEncode(data);
    
//     if (id != null) script.id = id;
    
//     html.document.head?.append(script);
//   }

//   static void setCanonical(String url) {
//     if (!kIsWeb) return;
    
//     var normalizedUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
//     var link = html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
//     if (link == null) {
//       link = html.LinkElement()..rel = 'canonical';
//       html.document.head?.append(link);
//     }
//     link.href = normalizedUrl;
//   }

//   // ============ SEO TAG METHODS ============
//   static void setOGTags({
//     required String title,
//     required String description,
//     required String image,
//   }) {
//     if (!kIsWeb) return;
    
//     _updateMeta('og:title', title, property: true);
//     _updateMeta('og:description', description, property: true);
//     _updateMeta('og:image', image, property: true);
//     _updateMeta('og:image:alt', title, property: true);
//     _updateMeta('og:image:width', '1200', property: true);
//     _updateMeta('og:image:height', '630', property: true);
//     _updateMeta('og:type', 'article', property: true);
//     _updateMeta('og:site_name', _siteName, property: true);
//   }
  
//   static void setTwitterTags({
//     required String title,
//     required String description,
//     required String image,
//   }) {
//     if (!kIsWeb) return;
    
//     _updateMeta('twitter:card', 'summary_large_image', name: true);
//     _updateMeta('twitter:site', _twitterHandle, name: true);
//     _updateMeta('twitter:creator', _twitterHandle, name: true);
//     _updateMeta('twitter:title', title, name: true);
//     _updateMeta('twitter:description', description, name: true);
//     _updateMeta('twitter:image', image, name: true);
//     _updateMeta('twitter:image:alt', title, name: true);
//   }

//   // ============ SCHEMA METHODS ============
//   static void setWebsiteSchema() {
//     if (!kIsWeb) return;
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "WebSite",
//       "name": _siteName,
//       "url": _baseUrl,
//       "potentialAction": {
//         "@type": "SearchAction",
//         "target": {
//           "@type": "EntryPoint",
//           "urlTemplate": "$_baseUrl/search?q={search_term_string}"
//         },
//         "query-input": "required name=search_term_string"
//       },
//       "sameAs": [
//         "https://twitter.com/revochamp",
//         "https://www.facebook.com/revochamp",
//         "https://www.linkedin.com/company/revochamp",
//       ]
//     }, id: 'website-schema');
//   }

//   static void setOrganizationSchema({
//     String? logoUrl,
//     String? description,
//   }) {
//     if (!kIsWeb) return;
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "Organization",
//       "name": _siteName,
//       "url": _baseUrl,
//       "logo": logoUrl ?? "$_baseUrl/logo.png",
//       "description": description ?? "Revochamp - Technology tutorials and insights",
//       "email": "contact@revochamp.site",
//       "sameAs": [
//         "https://twitter.com/revochamp",
//         "https://www.facebook.com/revochamp",
//       ]
//     }, id: 'organization-schema');
//   }

//   static void setCollectionPageSchema({
//     required String name,
//     required String description,
//     required String url,
//     List<Map<String, String>>? items,
//   }) {
//     if (!kIsWeb) return;
    
//     final itemListElement = <Map<String, dynamic>>[];
//     if (items != null) {
//       for (var i = 0; i < items.length; i++) {
//         itemListElement.add({
//           "@type": "ListItem",
//           "position": i + 1,
//           "name": items[i]['name'],
//           "url": items[i]['url'],
//         });
//       }
//     }
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "CollectionPage",
//       "name": name,
//       "description": description,
//       "url": url,
//       "mainEntity": {
//         "@type": "ItemList",
//         "itemListElement": itemListElement
//       }
//     }, id: 'collection-schema');
//   }

//   static void setBreadcrumbData({
//     required String title,
//     required String slug,
//     List<Map<String, String>>? parents,
//   }) {
//     final itemListElement = <Map<String, dynamic>>[];
//     var position = 1;
    
//     itemListElement.add({
//       '@type': 'ListItem',
//       'position': position++,
//       'name': 'Home',
//       'item': _baseUrl,
//     });
    
//     if (parents != null) {
//       for (final parent in parents) {
//         itemListElement.add({
//           '@type': 'ListItem',
//           'position': position++,
//           'name': parent['name'],
//           'item': parent['url'],
//         });
//       }
//     }
    
//     itemListElement.add({
//       '@type': 'ListItem',
//       'position': position,
//       'name': title,
//       'item': '$_baseUrl/$slug',
//     });
    
//     setStructuredData({
//       '@context': 'https://schema.org',
//       '@type': 'BreadcrumbList',
//       'itemListElement': itemListElement,
//     }, id: 'breadcrumb-schema');
//   }

//   static void setArticleSchema({
//     required String title,
//     required String description,
//     required String slug,
//     String? imageUrl,
//     String? author,
//     DateTime? publishedDate,
//     DateTime? modifiedDate,
//     List<String>? keywords,
//   }) {
//     final now = DateTime.now();
//     final publishDate = publishedDate ?? now;
//     final modifyDate = modifiedDate ?? now;
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "TechArticle",
//       "headline": title,
//       "description": description,
//       "image": imageUrl ?? _defaultImage,
//       "author": {
//         "@type": "Person",
//         "name": author ?? _siteName,
//         "url": "$_baseUrl/author/${author?.toLowerCase() ?? 'revochamp'}"
//       },
//       "publisher": {
//         "@type": "Organization",
//         "name": _siteName,
//         "logo": {
//           "@type": "ImageObject",
//           "url": "$_baseUrl/logo.png"
//         }
//       },
//       "datePublished": publishDate.toIso8601String(),
//       "dateModified": modifyDate.toIso8601String(),
//       "mainEntityOfPage": {
//         "@type": "WebPage",
//         "@id": "$_baseUrl/$slug"
//       },
//       "keywords": (keywords ?? ['flutter', 'tutorial']).join(', '),
//       "articleSection": "Technology",
//       "inLanguage": "en-US",
//     }, id: 'article-schema-$slug');
//   }

//   // ============ FIXED FAQ SCHEMA METHOD ============
//   static void setFAQSchema(List<Map<String, dynamic>> faqs) {
//     if (!kIsWeb) return;
    
//     final mainEntity = faqs.map((faq) => {
//       "@type": "Question",
//       "name": faq['question'] ?? faq['name'],
//       "acceptedAnswer": {
//         "@type": "Answer",
//         "text": faq['answer'] ?? faq['text'] ?? faq['acceptedAnswer']?['text']
//       }
//     }).toList();
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "FAQPage",
//       "mainEntity": mainEntity
//     }, id: 'faq-schema');
//   }

//   // Alternative FAQ method that accepts Map format directly
//   static void setFAQSchemaFromMap(List<Map<String, String>> faqs) {
//     if (!kIsWeb) return;
    
//     final mainEntity = faqs.map((faq) => {
//       "@type": "Question",
//       "name": faq['question'],
//       "acceptedAnswer": {
//         "@type": "Answer",
//         "text": faq['answer']
//       }
//     }).toList();
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "FAQPage",
//       "mainEntity": mainEntity
//     }, id: 'faq-schema');
//   }

//   static void setHowToSchema({
//     required String name,
//     required String description,
//     required List<Map<String, String>> steps,
//     String? imageUrl,
//     String? totalTime,
//   }) {
//     if (!kIsWeb) return;
    
//     final itemListElement = steps.asMap().entries.map((entry) {
//       final index = entry.key;
//       final step = entry.value;
//       return {
//         "@type": "HowToStep",
//         "position": index + 1,
//         "name": step['name'],
//         "text": step['description'],
//         "image": step['image'],
//       };
//     }).toList();
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "HowTo",
//       "name": name,
//       "description": description,
//       "image": imageUrl ?? _defaultImage,
//       "totalTime": totalTime,
//       "step": itemListElement
//     }, id: 'howto-schema');
//   }

//   static void setVideoSchema({
//     required String name,
//     required String description,
//     required String thumbnailUrl,
//     required String contentUrl,
//     required String embedUrl,
//     required Duration duration,
//     DateTime? uploadDate,
//   }) {
//     if (!kIsWeb) return;
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "VideoObject",
//       "name": name,
//       "description": description,
//       "thumbnailUrl": thumbnailUrl,
//       "contentUrl": contentUrl,
//       "embedUrl": embedUrl,
//       "uploadDate": (uploadDate ?? DateTime.now()).toIso8601String(),
//       "duration": duration.toString(),
//     }, id: 'video-schema');
//   }

//   static void setProductSchema({
//     required String name,
//     required String description,
//     required String image,
//     required double price,
//     required String currency,
//     required String availability,
//     String? sku,
//     String? brand,
//     double? rating,
//     int? reviewCount,
//   }) {
//     if (!kIsWeb) return;
    
//     setStructuredData({
//       "@context": "https://schema.org",
//       "@type": "Product",
//       "name": name,
//       "description": description,
//       "image": image,
//       "sku": sku,
//       "brand": {"@type": "Brand", "name": brand ?? _siteName},
//       "offers": {
//         "@type": "Offer",
//         "price": price,
//         "priceCurrency": currency,
//         "availability": availability,
//       },
//       if (rating != null && reviewCount != null)
//         "aggregateRating": {
//           "@type": "AggregateRating",
//           "ratingValue": rating,
//           "reviewCount": reviewCount,
//         },
//     }, id: 'product-schema');
//   }

//   static void setCourseSchema({
//     required String name,
//     required String description,
//     required String provider,
//     required String url,
//     String? image,
//     String? duration,
//     List<Map<String, String>>? hasCourseInstance,
//   }) {
//     if (!kIsWeb) return;
    
//     final schema = {
//       "@context": "https://schema.org",
//       "@type": "Course",
//       "name": name,
//       "description": description,
//       "provider": {
//         "@type": "Organization",
//         "name": provider,
//         "sameAs": url,
//       },
//     };
    
//     if (image != null) {
//       schema["image"] = image;
//     }
    
//     if (duration != null) {
//       schema["timeRequired"] = duration;
//     }
    
//     if (hasCourseInstance != null) {
//       schema["hasCourseInstance"] = hasCourseInstance;
//     }
    
//     setStructuredData(schema, id: 'course-schema');
//   }

//   static void setPersonSchema({
//     required String name,
//     String? description,
//     String? url,
//     String? image,
//     String? sameAs,
//   }) {
//     if (!kIsWeb) return;
    
//     final schema = {
//       "@context": "https://schema.org",
//       "@type": "Person",
//       "name": name,
//     };
    
//     if (description != null) schema["description"] = description;
//     if (url != null) schema["url"] = url;
//     if (image != null) schema["image"] = image;
//     if (sameAs != null) schema["sameAs"] = sameAs;
    
//     setStructuredData(schema, id: 'person-schema');
//   }

//   // ============ HELPER METHODS ============
//   static String getCurrentUrl() {
//     if (!kIsWeb) return _baseUrl;
//     return html.window.location.href;
//   }
  
//   static void setCustomMeta({
//     required String name,
//     required String content,
//   }) {
//     if (!kIsWeb) return;
//     _updateMeta(name, content, name: true);
//   }
  
//   static void setCustomProperty({
//     required String property,
//     required String content,
//   }) {
//     if (!kIsWeb) return;
//     _updateMeta(property, content, property: true);
//   }
  
//   static void removeMetaTag(String name, {bool isProperty = false}) {
//     if (!kIsWeb) return;
    
//     final selector = isProperty 
//         ? 'meta[property="$name"]' 
//         : 'meta[name="$name"]';
    
//     final tag = html.document.querySelector(selector);
//     tag?.remove();
//   }
  
//   static void updateStructuredDataById(String id, Map<String, dynamic> newData) {
//     if (!kIsWeb) return;
    
//     final script = html.document.querySelector('script[id="$id"]') as html.ScriptElement?;
//     if (script != null) {
//       script.text = jsonEncode(newData);
//     } else {
//       setStructuredData(newData, id: id);
//     }
//   }
  
//   static void setSocialMediaTags({
//     required String title,
//     required String description,
//     required String imageUrl,
//     required String url,
//   }) {
//     if (!kIsWeb) return;
    
//     _updateMeta('og:title', title, property: true);
//     _updateMeta('og:description', description, property: true);
//     _updateMeta('og:image', imageUrl, property: true);
//     _updateMeta('og:url', url, property: true);
//     _updateMeta('og:type', 'website', property: true);
    
//     _updateMeta('twitter:card', 'summary_large_image', name: true);
//     _updateMeta('twitter:title', title, name: true);
//     _updateMeta('twitter:description', description, name: true);
//     _updateMeta('twitter:image', imageUrl, name: true);
    
//     _updateMeta('image', imageUrl, name: true);
//   }
  
//   static void setArticleDates({
//     required DateTime publishedDate,
//     DateTime? modifiedDate,
//   }) {
//     if (!kIsWeb) return;
    
//     _updateMeta('article:published_time', publishedDate.toIso8601String(), property: true);
//     if (modifiedDate != null) {
//       _updateMeta('article:modified_time', modifiedDate.toIso8601String(), property: true);
//     }
//   }
  
//   static void setArticleAuthor({
//     required String name,
//     String? url,
//     String? image,
//   }) {
//     if (!kIsWeb) return;
    
//     _updateMeta('article:author', name, property: true);
//     _updateMeta('author', name, name: true);
//   }
  
//   static void setCanonicalWithParams(String baseUrl, Map<String, String>? params) {
//     if (!kIsWeb) return;
    
//     var canonicalUrl = baseUrl;
//     if (params != null && params.isNotEmpty) {
//       final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
//       canonicalUrl = '$baseUrl?$queryString';
//     }
    
//     setCanonical(canonicalUrl);
//   }
  
//   static void setNoIndex(bool noIndex) {
//     if (!kIsWeb) return;
    
//     if (noIndex) {
//       _updateMeta('robots', 'noindex, nofollow', name: true);
//     } else {
//       _updateMeta('robots', 'index, follow', name: true);
//     }
//   }
  
//   static void setAlternateLanguage(String url, String languageCode) {
//     if (!kIsWeb) return;
    
//     var link = html.document.querySelector('link[rel="alternate"][hreflang="$languageCode"]') as html.LinkElement?;
//     if (link == null) {
//       link = html.LinkElement()
//         ..rel = 'alternate'
//         ..hreflang = languageCode;
//       html.document.head?.append(link);
//     }
//     link.href = url;
//   }

//   // ============ DEBUG METHODS ============
//   static List<Map<String, String>> validateMetaTags() {
//     if (!kIsWeb) return [];
    
//     final results = <Map<String, String>>[];
//     final requiredTags = [
//       'description', 'og:title', 'og:description', 'og:image',
//       'twitter:title', 'twitter:description', 'twitter:image'
//     ];
    
//     for (final tag in requiredTags) {
//       final isProperty = tag.startsWith('og:') || tag.startsWith('twitter:');
//       final selector = isProperty 
//           ? 'meta[property="$tag"]' 
//           : 'meta[name="$tag"]';
      
//       final element = html.document.querySelector(selector);
//       results.add({
//         'tag': tag,
//         'present': element != null ? 'true' : 'false',
//         'content': element?.getAttribute('content') ?? '',
//       });
//     }
    
//     return results;
//   }

//   @visibleForTesting
//   static void clearAll() {
//     if (!kIsWeb) return;
//     final head = html.document.head;
//     if (head != null) {
//       head
//           .querySelectorAll(
//             'meta[name], meta[property], script[type="application/ld+json"], link[rel="canonical"], link[rel="alternate"]',
//           )
//           .forEach((element) => element.remove());
//     }
//   }
// }

// // ============ EXTENSION METHODS ============
// extension MetaServiceExtension on MetaService {
//   static void setPageMeta({
//     required String title,
//     required String description,
//     required String slug,
//     String? imageUrl,
//     String? author,
//     List<String>? keywords,
//     bool isArticle = true,
//   }) {
//     if (!kIsWeb) return;
    
//     MetaService.updateMetaTags(
//       title: title,
//       description: description,
//       slug: slug,
//       imageUrl: imageUrl,
//       author: author,
//       keywords: keywords,
//       isArticle: isArticle,
//     );
//   }
  
//   static void setBlogPostMeta({
//     required String title,
//     required String description,
//     required String slug,
//     required String author,
//     required DateTime publishedDate,
//     DateTime? modifiedDate,
//     String? imageUrl,
//     List<String>? tags,
//   }) {
//     if (!kIsWeb) return;
    
//     MetaService.updateMetaTags(
//       title: title,
//       description: description,
//       slug: slug,
//       author: author,
//       publishedDate: publishedDate,
//       modifiedDate: modifiedDate,
//       keywords: tags,
//       isArticle: true,
//     );
    
//     MetaService.setArticleSchema(
//       title: title,
//       description: description,
//       slug: slug,
//       author: author,
//       publishedDate: publishedDate,
//       modifiedDate: modifiedDate,
//       keywords: tags,
//       imageUrl: imageUrl,
//     );
//   }
  
//   static void setCategoryPageMeta({
//     required String category,
//     required String description,
//     required String slug,
//     int? itemCount,
//   }) {
//     if (!kIsWeb) return;
    
//     final title = itemCount != null 
//         ? "$category ($itemCount articles) - Revochamp"
//         : "$category - Revochamp";
    
//     final fullDescription = itemCount != null
//         ? "$description Currently $itemCount articles available."
//         : description;
    
//     MetaService.updateMetaTags(
//       title: title,
//       description: fullDescription,
//       slug: slug,
//       isArticle: false,
//     );
    
//     MetaService.setCollectionPageSchema(
//       name: category,
//       description: description,
//       url: 'https://revochamp.site/tech/$slug',
//     );
//   }
// }
// // import 'package:flutter/foundation.dart';
// // import 'meta_service.dart';

// // import 'dart:convert';

// // import 'package:flutter/foundation.dart';
// // import 'dart:html' if (dart.library.io) 'dart:html_stub.dart' as html;

// // class MetaService {
// //   static const String _baseUrl = 'https://revochamp.site/tech';
// //   static const String _defaultImage = '$_baseUrl/default-og-image.png';
// //   static const String _siteName = 'Revochamp';
// //   static const String _twitterHandle = '@revochamp';
// // // Add to lib/core/meta_service.dart

// // static void setVerificationTags({
// //   String? google,
// //   String? bing,
// //   String? yandex,
// //   String? pinterest,
// //   String? facebook,
// // }) {
// //   if (!kIsWeb) return;
  
// //   if (google != null) {
// //     _updateMeta('google-site-verification', google, name: true);
// //   }
// //   if (bing != null) {
// //     _updateMeta('msvalidate.01', bing, name: true);
// //   }
// //   if (yandex != null) {
// //     _updateMeta('yandex-verification', yandex, name: true);
// //   }
// //   if (pinterest != null) {
// //     _updateMeta('p:domain_verify', pinterest, name: true);
// //   }
// //   if (facebook != null) {
// //     _updateMeta('facebook-domain-verification', facebook, name: true);
// //   }
// // }
// //   // ============ MAIN METHOD ============
// //   static void updateMetaTags({
// //     required String title,
// //     required String description,
// //     String? imageUrl,
// //     String? slug,
// //     String? author,
// //     DateTime? publishedDate,
// //     DateTime? modifiedDate,
// //     List<String>? keywords,
// //     bool isArticle = true,
// //     bool noIndex = false,
// //   }) {
// //     if (!kIsWeb) return;

// //     final fullUrl = slug != null
// //         ? '$_baseUrl/$slug'
// //         : html.window.location.href;

// //     final finalImageUrl = imageUrl ?? _defaultImage;
// //     final finalKeywords = keywords ?? ['flutter', 'tutorial', 'revochamp'];
    
// //     html.document.title = title;
// //     _updateMeta('description', description, name: true);
// //     _updateMeta('keywords', finalKeywords.join(', '), name: true);
// //     _updateMeta('author', author ?? _siteName, name: true);
// //     _updateMeta('viewport', 'width=device-width, initial-scale=1.0, maximum-scale=5.0', name: true);
    
// //     if (noIndex) {
// //       _updateMeta('robots', 'noindex, nofollow', name: true);
// //     } else {
// //       _updateMeta('robots', 'index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1', name: true);
// //     }
    
// //     // Open Graph
// //     _updateMeta('og:title', title, property: true);
// //     _updateMeta('og:description', description, property: true);
// //     _updateMeta('og:image', finalImageUrl, property: true);
// //     _updateMeta('og:image:alt', title, property: true);
// //     _updateMeta('og:image:width', '1200', property: true);
// //     _updateMeta('og:image:height', '630', property: true);
// //     _updateMeta('og:url', fullUrl, property: true);
// //     _updateMeta('og:type', isArticle ? 'article' : 'website', property: true);
// //     _updateMeta('og:site_name', _siteName, property: true);
// //     _updateMeta('og:locale', 'en_US', property: true);
    
// //     if (isArticle && publishedDate != null) {
// //       _updateMeta('article:published_time', publishedDate.toIso8601String(), property: true);
// //       if (modifiedDate != null) {
// //         _updateMeta('article:modified_time', modifiedDate.toIso8601String(), property: true);
// //       }
// //       if (author != null) {
// //         _updateMeta('article:author', author, property: true);
// //       }
// //       _updateMeta('article:section', 'Technology', property: true);
// //     }
    
// //     // Twitter
// //     _updateMeta('twitter:card', 'summary_large_image', name: true);
// //     _updateMeta('twitter:site', _twitterHandle, name: true);
// //     _updateMeta('twitter:creator', _twitterHandle, name: true);
// //     _updateMeta('twitter:title', title, name: true);
// //     _updateMeta('twitter:description', description, name: true);
// //     _updateMeta('twitter:image', finalImageUrl, name: true);
// //     _updateMeta('twitter:image:alt', title, name: true);
    
// //     setCanonical(fullUrl);
// //   }
  
// //   // ============ CORE METHODS ============
// //   static void _updateMeta(String key, String content, {
// //     bool name = false,
// //     bool property = false,
// //     bool rel = false,
// //     String? hreflang,
// //   }) {
// //     String selector;
    
// //     if (name) {
// //       selector = 'meta[name="$key"]';
// //     } else if (property) {
// //       selector = 'meta[property="$key"]';
// //     } else if (rel) {
// //       selector = 'link[rel="$key"]';
// //     } else {
// //       return;
// //     }
    
// //     var element = html.document.querySelector(selector);
    
// //     if (element == null) {
// //       if (rel) {
// //         element = html.LinkElement();
// //         (element as html.LinkElement).rel = key;
// //         if (hreflang != null) {
// //           (element as html.LinkElement).hreflang = hreflang;
// //         }
// //       } else {
// //         element = html.MetaElement();
// //         if (name) {
// //           (element as html.MetaElement).name = key;
// //         } else if (property) {
// //           (element as html.MetaElement).setAttribute('property', key);
// //         }
// //       }
// //       html.document.head?.append(element);
// //     }
    
// //     if (rel) {
// //       (element as html.LinkElement).href = content;
// //     } else {
// //       (element as html.MetaElement).content = content;
// //     }
// //   }

// //   static void setStructuredData(Map<String, dynamic> data, {String? id}) {
// //     if (!kIsWeb) return;
    
// //     final selector = id != null 
// //         ? 'script[type="application/ld+json"][id="$id"]'
// //         : 'script[type="application/ld+json"]';
    
// //     final existing = html.document.querySelector(selector);
// //     existing?.remove();
    
// //     final script = html.ScriptElement()
// //       ..type = 'application/ld+json'
// //       ..text = jsonEncode(data);
    
// //     if (id != null) script.id = id;
    
// //     html.document.head?.append(script);
// //   }

// //   static void setCanonical(String url) {
// //     if (!kIsWeb) return;
    
// //     var normalizedUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
// //     var link = html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
// //     if (link == null) {
// //       link = html.LinkElement()..rel = 'canonical';
// //       html.document.head?.append(link);
// //     }
// //     link.href = normalizedUrl;
// //   }

// //   // ============ SEO TAG METHODS (Called by TutorialPage) ============
// //   static void setOGTags({
// //     required String title,
// //     required String description,
// //     required String image,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     _updateMeta('og:title', title, property: true);
// //     _updateMeta('og:description', description, property: true);
// //     _updateMeta('og:image', image, property: true);
// //     _updateMeta('og:image:alt', title, property: true);
// //     _updateMeta('og:image:width', '1200', property: true);
// //     _updateMeta('og:image:height', '630', property: true);
// //     _updateMeta('og:type', 'article', property: true);
// //     _updateMeta('og:site_name', _siteName, property: true);
// //   }
  
// //   static void setTwitterTags({
// //     required String title,
// //     required String description,
// //     required String image,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     _updateMeta('twitter:card', 'summary_large_image', name: true);
// //     _updateMeta('twitter:site', _twitterHandle, name: true);
// //     _updateMeta('twitter:creator', _twitterHandle, name: true);
// //     _updateMeta('twitter:title', title, name: true);
// //     _updateMeta('twitter:description', description, name: true);
// //     _updateMeta('twitter:image', image, name: true);
// //     _updateMeta('twitter:image:alt', title, name: true);
// //   }

// //   // ============ SCHEMA METHODS ============
// //   static void setWebsiteSchema() {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "WebSite",
// //       "name": _siteName,
// //       "url": _baseUrl,
// //       "potentialAction": {
// //         "@type": "SearchAction",
// //         "target": {
// //           "@type": "EntryPoint",
// //           "urlTemplate": "$_baseUrl/search?q={search_term_string}"
// //         },
// //         "query-input": "required name=search_term_string"
// //       },
// //       "sameAs": [
// //         "https://twitter.com/revochamp",
// //         "https://www.facebook.com/revochamp",
// //         "https://www.linkedin.com/company/revochamp",
// //       ]
// //     }, id: 'website-schema');
// //   }

// //   static void setOrganizationSchema({
// //     String? logoUrl,
// //     String? description,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "Organization",
// //       "name": _siteName,
// //       "url": _baseUrl,
// //       "logo": logoUrl ?? "$_baseUrl/logo.png",
// //       "description": description ?? "Revochamp - Technology tutorials and insights",
// //       "email": "contact@revochamp.site",
// //       "sameAs": [
// //         "https://twitter.com/revochamp",
// //         "https://www.facebook.com/revochamp",
// //       ]
// //     }, id: 'organization-schema');
// //   }

// //   static void setCollectionPageSchema({
// //     required String name,
// //     required String description,
// //     required String url,
// //     List<Map<String, String>>? items,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     final itemListElement = <Map<String, dynamic>>[];
// //     if (items != null) {
// //       for (var i = 0; i < items.length; i++) {
// //         itemListElement.add({
// //           "@type": "ListItem",
// //           "position": i + 1,
// //           "name": items[i]['name'],
// //           "url": items[i]['url'],
// //         });
// //       }
// //     }
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "CollectionPage",
// //       "name": name,
// //       "description": description,
// //       "url": url,
// //       "mainEntity": {
// //         "@type": "ItemList",
// //         "itemListElement": itemListElement
// //       }
// //     }, id: 'collection-schema');
// //   }

// //   static void setBreadcrumbData({
// //     required String title,
// //     required String slug,
// //     List<Map<String, String>>? parents,
// //   }) {
// //     final itemListElement = <Map<String, dynamic>>[];
// //     var position = 1;
    
// //     itemListElement.add({
// //       '@type': 'ListItem',
// //       'position': position++,
// //       'name': 'Home',
// //       'item': _baseUrl,
// //     });
    
// //     if (parents != null) {
// //       for (final parent in parents) {
// //         itemListElement.add({
// //           '@type': 'ListItem',
// //           'position': position++,
// //           'name': parent['name'],
// //           'item': parent['url'],
// //         });
// //       }
// //     }
    
// //     itemListElement.add({
// //       '@type': 'ListItem',
// //       'position': position,
// //       'name': title,
// //       'item': '$_baseUrl/$slug',
// //     });
    
// //     setStructuredData({
// //       '@context': 'https://schema.org',
// //       '@type': 'BreadcrumbList',
// //       'itemListElement': itemListElement,
// //     }, id: 'breadcrumb-schema');
// //   }

// //   static void setArticleSchema({
// //     required String title,
// //     required String description,
// //     required String slug,
// //     String? imageUrl,
// //     String? author,
// //     DateTime? publishedDate,
// //     DateTime? modifiedDate,
// //     List<String>? keywords,
// //   }) {
// //     final now = DateTime.now();
// //     final publishDate = publishedDate ?? now;
// //     final modifyDate = modifiedDate ?? now;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "TechArticle",
// //       "headline": title,
// //       "description": description,
// //       "image": imageUrl ?? _defaultImage,
// //       "author": {
// //         "@type": "Person",
// //         "name": author ?? _siteName,
// //         "url": "$_baseUrl/author/${author?.toLowerCase() ?? 'revochamp'}"
// //       },
// //       "publisher": {
// //         "@type": "Organization",
// //         "name": _siteName,
// //         "logo": {
// //           "@type": "ImageObject",
// //           "url": "$_baseUrl/logo.png"
// //         }
// //       },
// //       "datePublished": publishDate.toIso8601String(),
// //       "dateModified": modifyDate.toIso8601String(),
// //       "mainEntityOfPage": {
// //         "@type": "WebPage",
// //         "@id": "$_baseUrl/$slug"
// //       },
// //       "keywords": (keywords ?? ['flutter', 'tutorial']).join(', '),
// //       "articleSection": "Technology",
// //       "inLanguage": "en-US",
// //     }, id: 'article-schema-$slug');
// //   }

// //   static void setFaqSchema(List<Map<String, String>> faqs) {
// //     if (!kIsWeb) return;
    
// //     final mainEntity = faqs.map((faq) => {
// //       "@type": "Question",
// //       "name": faq['question'],
// //       "acceptedAnswer": {
// //         "@type": "Answer",
// //         "text": faq['answer']
// //       }
// //     }).toList();
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "FAQPage",
// //       "mainEntity": mainEntity
// //     }, id: 'faq-schema');
// //   }

// //   static void setHowToSchema({
// //     required String name,
// //     required String description,
// //     required List<Map<String, String>> steps,
// //     String? imageUrl,
// //     String? totalTime,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     final itemListElement = steps.asMap().entries.map((entry) {
// //       final index = entry.key;
// //       final step = entry.value;
// //       return {
// //         "@type": "HowToStep",
// //         "position": index + 1,
// //         "name": step['name'],
// //         "text": step['description'],
// //         "image": step['image'],
// //       };
// //     }).toList();
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "HowTo",
// //       "name": name,
// //       "description": description,
// //       "image": imageUrl ?? _defaultImage,
// //       "totalTime": totalTime,
// //       "step": itemListElement
// //     }, id: 'howto-schema');
// //   }

// //   static void setVideoSchema({
// //     required String name,
// //     required String description,
// //     required String thumbnailUrl,
// //     required String contentUrl,
// //     required String embedUrl,
// //     required Duration duration,
// //     DateTime? uploadDate,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "VideoObject",
// //       "name": name,
// //       "description": description,
// //       "thumbnailUrl": thumbnailUrl,
// //       "contentUrl": contentUrl,
// //       "embedUrl": embedUrl,
// //       "uploadDate": (uploadDate ?? DateTime.now()).toIso8601String(),
// //       "duration": duration.toString(),
// //     }, id: 'video-schema');
// //   }

// //   static void setProductSchema({
// //     required String name,
// //     required String description,
// //     required String image,
// //     required double price,
// //     required String currency,
// //     required String availability,
// //     String? sku,
// //     String? brand,
// //     double? rating,
// //     int? reviewCount,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "Product",
// //       "name": name,
// //       "description": description,
// //       "image": image,
// //       "sku": sku,
// //       "brand": {"@type": "Brand", "name": brand ?? _siteName},
// //       "offers": {
// //         "@type": "Offer",
// //         "price": price,
// //         "priceCurrency": currency,
// //         "availability": availability,
// //       },
// //       if (rating != null && reviewCount != null)
// //         "aggregateRating": {
// //           "@type": "AggregateRating",
// //           "ratingValue": rating,
// //           "reviewCount": reviewCount,
// //         },
// //     }, id: 'product-schema');
// //   }

// //   static void setCourseSchema({
// //     required String name,
// //     required String description,
// //     required String provider,
// //     required String url,
// //     String? image,
// //     String? duration,
// //     List<Map<String, String>>? hasCourseInstance,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "Course",
// //       "name": name,
// //       "description": description,
// //       "provider": {
// //         "@type": "Organization",
// //         "name": provider,
// //         "sameAs": url,
// //       },
// //       "image": ?image,
// //       "timeRequired": ?duration,
// //       "hasCourseInstance": ?hasCourseInstance,
// //     }, id: 'course-schema');
// //   }

// //   static void setPersonSchema({
// //     required String name,
// //     String? description,
// //     String? url,
// //     String? image,
// //     String? sameAs,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     setStructuredData({
// //       "@context": "https://schema.org",
// //       "@type": "Person",
// //       "name": name,
// //       "description": ?description,
// //       "url": ?url,
// //       "image": ?image,
// //       "sameAs": ?sameAs,
// //     }, id: 'person-schema');
// //   }

// //   // ============ HELPER METHODS ============
// //   static String getCurrentUrl() {
// //     if (!kIsWeb) return _baseUrl;
// //     return html.window.location.href;
// //   }
  
// //   static void setCustomMeta({
// //     required String name,
// //     required String content,
// //   }) {
// //     if (!kIsWeb) return;
// //     _updateMeta(name, content, name: true);
// //   }
  
// //   static void setCustomProperty({
// //     required String property,
// //     required String content,
// //   }) {
// //     if (!kIsWeb) return;
// //     _updateMeta(property, content, property: true);
// //   }
  
// //   static void removeMetaTag(String name, {bool isProperty = false}) {
// //     if (!kIsWeb) return;
    
// //     final selector = isProperty 
// //         ? 'meta[property="$name"]' 
// //         : 'meta[name="$name"]';
    
// //     final tag = html.document.querySelector(selector);
// //     tag?.remove();
// //   }
  
// //   static void updateStructuredDataById(String id, Map<String, dynamic> newData) {
// //     if (!kIsWeb) return;
    
// //     final script = html.document.querySelector('script[id="$id"]') as html.ScriptElement?;
// //     if (script != null) {
// //       script.text = jsonEncode(newData);
// //     } else {
// //       setStructuredData(newData, id: id);
// //     }
// //   }
  
// //   static void setSocialMediaTags({
// //     required String title,
// //     required String description,
// //     required String imageUrl,
// //     required String url,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     _updateMeta('og:title', title, property: true);
// //     _updateMeta('og:description', description, property: true);
// //     _updateMeta('og:image', imageUrl, property: true);
// //     _updateMeta('og:url', url, property: true);
// //     _updateMeta('og:type', 'website', property: true);
    
// //     _updateMeta('twitter:card', 'summary_large_image', name: true);
// //     _updateMeta('twitter:title', title, name: true);
// //     _updateMeta('twitter:description', description, name: true);
// //     _updateMeta('twitter:image', imageUrl, name: true);
    
// //     _updateMeta('image', imageUrl, name: true);
// //   }
  
// //   static void setArticleDates({
// //     required DateTime publishedDate,
// //     DateTime? modifiedDate,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     _updateMeta('article:published_time', publishedDate.toIso8601String(), property: true);
// //     if (modifiedDate != null) {
// //       _updateMeta('article:modified_time', modifiedDate.toIso8601String(), property: true);
// //     }
// //   }
  
// //   static void setArticleAuthor({
// //     required String name,
// //     String? url,
// //     String? image,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     _updateMeta('article:author', name, property: true);
// //     _updateMeta('author', name, name: true);
// //   }
  
// //   static void setCanonicalWithParams(String baseUrl, Map<String, String>? params) {
// //     if (!kIsWeb) return;
    
// //     var canonicalUrl = baseUrl;
// //     if (params != null && params.isNotEmpty) {
// //       final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
// //       canonicalUrl = '$baseUrl?$queryString';
// //     }
    
// //     setCanonical(canonicalUrl);
// //   }
  
// //   static void setNoIndex(bool noIndex) {
// //     if (!kIsWeb) return;
    
// //     if (noIndex) {
// //       _updateMeta('robots', 'noindex, nofollow', name: true);
// //     } else {
// //       _updateMeta('robots', 'index, follow', name: true);
// //     }
// //   }
  
// //   static void setAlternateLanguage(String url, String languageCode) {
// //     if (!kIsWeb) return;
    
// //     var link = html.document.querySelector('link[rel="alternate"][hreflang="$languageCode"]') as html.LinkElement?;
// //     if (link == null) {
// //       link = html.LinkElement()
// //         ..rel = 'alternate'
// //         ..hreflang = languageCode;
// //       html.document.head?.append(link);
// //     }
// //     link.href = url;
// //   }

// //   // ============ DEBUG METHODS ============
// //   static List<Map<String, String>> validateMetaTags() {
// //     if (!kIsWeb) return [];
    
// //     final results = <Map<String, String>>[];
// //     final requiredTags = [
// //       'description', 'og:title', 'og:description', 'og:image',
// //       'twitter:title', 'twitter:description', 'twitter:image'
// //     ];
    
// //     for (final tag in requiredTags) {
// //       final isProperty = tag.startsWith('og:') || tag.startsWith('twitter:');
// //       final selector = isProperty 
// //           ? 'meta[property="$tag"]' 
// //           : 'meta[name="$tag"]';
      
// //       final element = html.document.querySelector(selector);
// //       results.add({
// //         'tag': tag,
// //         'present': element != null ? 'true' : 'false',
// //         'content': element?.getAttribute('content') ?? '',
// //       });
// //     }
    
// //     return results;
// //   }

// //   @visibleForTesting
// //   static void clearAll() {
// //     if (!kIsWeb) return;
// //     final head = html.document.head;
// //     if (head != null) {
// //       head
// //           .querySelectorAll(
// //             'meta[name], meta[property], script[type="application/ld+json"], link[rel="canonical"], link[rel="alternate"]',
// //           )
// //           .forEach((element) => element.remove());
// //     }
// //   }
// // }

// // extension MetaServiceExtension on MetaService {
// //   static void setPageMeta({
// //     required String title,
// //     required String description,
// //     required String slug,
// //     String? imageUrl,
// //     String? author,
// //     List<String>? keywords,
// //     bool isArticle = true,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     MetaService.updateMetaTags(
// //       title: title,
// //       description: description,
// //       slug: slug,
// //       imageUrl: imageUrl,
// //       author: author,
// //       keywords: keywords,
// //       isArticle: isArticle,
// //     );
// //   }
  
// //   static void setBlogPostMeta({
// //     required String title,
// //     required String description,
// //     required String slug,
// //     required String author,
// //     required DateTime publishedDate,
// //     DateTime? modifiedDate,
// //     String? imageUrl,
// //     List<String>? tags,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     MetaService.updateMetaTags(
// //       title: title,
// //       description: description,
// //       slug: slug,
// //       author: author,
// //       publishedDate: publishedDate,
// //       modifiedDate: modifiedDate,
// //       keywords: tags,
// //       isArticle: true,
// //     );
    
// //     MetaService.setArticleSchema(
// //       title: title,
// //       description: description,
// //       slug: slug,
// //       author: author,
// //       publishedDate: publishedDate,
// //       modifiedDate: modifiedDate,
// //       keywords: tags,
// //       imageUrl: imageUrl,
// //     );
// //   }
  
// //   static void setCategoryPageMeta({
// //     required String category,
// //     required String description,
// //     required String slug,
// //     int? itemCount,
// //   }) {
// //     if (!kIsWeb) return;
    
// //     final title = itemCount != null 
// //         ? "$category ($itemCount articles) - Revochamp"
// //         : "$category - Revochamp";
    
// //     final fullDescription = itemCount != null
// //         ? "$description Currently $itemCount articles available."
// //         : description;
    
// //     MetaService.updateMetaTags(
// //       title: title,
// //       description: fullDescription,
// //       slug: slug,
// //       isArticle: false,
// //     );
    
// //     MetaService.setCollectionPageSchema(
// //       name: category,
// //       description: description,
// //       url: 'https://revochamp.site/tech/$slug',
// //     );
// //   }
// // }
