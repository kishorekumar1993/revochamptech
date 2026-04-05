import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techtutorial/models/course_model.dart';

class CourseService {
  static const String url =
      'https://json.revochamp.site/tech/category.json'; // your API

  static Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List list = data['courses'];

      return list.map((e) => Course.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }
}
