import 'dart:convert';
import '../models/tutorial_topic.dart';

List<TutorialTopic> parseTopics(String jsonString) {
  final List list = jsonDecode(jsonString);
  return list.map((e) => TutorialTopic.fromJson(e)).toList();
}