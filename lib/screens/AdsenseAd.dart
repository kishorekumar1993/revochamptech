import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class AdsenseAd extends StatefulWidget {
  final String adSlot;

  const AdsenseAd({super.key, required this.adSlot});

  @override
  State<AdsenseAd> createState() => _AdsenseAdState();
}

class _AdsenseAdState extends State<AdsenseAd> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    // Unique ID to avoid duplicate registration
    _viewId = 'ads-${widget.adSlot}-${DateTime.now().millisecondsSinceEpoch}';

    // Register the platform view factory once
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final container = html.DivElement();

      // Create <ins> element using generic tag creation (works in all SDK versions)
      final ins = html.Element.tag('ins')
        ..classes.add('adsbygoogle')
        ..style.display = 'block'
        ..setAttribute('data-ad-client', 'ca-pub-XXXXXXXXXXXX')
        ..setAttribute('data-ad-slot', widget.adSlot)
        ..setAttribute('data-ad-format', 'auto')
        ..setAttribute('data-full-width-responsive', 'true');

      container.append(ins);

      // Append a script that pushes the ad
      final script = html.ScriptElement();
      script.text = '(adsbygoogle = window.adsbygoogle || []).push({});';
      container.append(script);

      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}