// // lib/screens/mock_test_screen.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // ============================================================
// // DATA MODELS
// // ============================================================

// class Question {
//   final String id;
//   final String text;
//   final List<String> options;
//   final int correctAnswerIndex;
//   final String explanation;
//   final String difficulty;
//   final int points;
//   final List<String> hints;
//   final String topic;

//   const Question({
//     required this.id,
//     required this.text,
//     required this.options,
//     required this.correctAnswerIndex,
//     required this.explanation,
//     required this.difficulty,
//     required this.points,
//     required this.hints,
//     required this.topic,
//   });

//   factory Question.fromJson(Map<String, dynamic> json) {
//     return Question(
//       id: json['id'] as String,
//       text: json['text'] as String,
//       options: List<String>.from(json['options']),
//       correctAnswerIndex: json['correctAnswerIndex'] as int,
//       explanation: json['explanation'] as String,
//       difficulty: json['difficulty'] as String,
//       points: json['points'] as int,
//       hints: json['hints'] != null ? List<String>.from(json['hints']) : [],
//       topic: json['topic'] as String,
//     );
//   }
// }

// class TestSession {
//   final String id;
//   final String title;
//   final String description;
//   final String category;
//   final int passingScore;
//   final int timeLimitMinutes;
//   final List<Question> questions;
//   final Map<String, Question> questionMap;

//   TestSession({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.passingScore,
//     required this.timeLimitMinutes,
//     required this.questions,
//   }) : questionMap = {
//           for (var q in questions) q.id: q,
//         };

//   int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);

//   factory TestSession.fromJson(Map<String, dynamic> json) {
//     final questionsList = (json['questions'] as List)
//         .map((e) => Question.fromJson(e))
//         .toList();

//     return TestSession(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       description: json['description'] as String,
//       category: json['category'] as String,
//       passingScore: json['passingScore'] as int,
//       timeLimitMinutes: json['timeLimitMinutes'] as int,
//       questions: questionsList,
//     );
//   }
// }

// class UserAnswer {
//   final String questionId;
//   final int selectedOptionIndex;
//   final bool isCorrect;
//   final DateTime answeredAt;
//   final bool usedHint;

//   const UserAnswer({
//     required this.questionId,
//     required this.selectedOptionIndex,
//     required this.isCorrect,
//     required this.answeredAt,
//     this.usedHint = false,
//   });
// }

// class TestStatistics {
//   final int totalQuestions;
//   final int answered;
//   final int correct;
//   final int incorrect;
//   final int unattempted;
//   final int totalPoints;
//   final int earnedPoints;
//   final double accuracy;
//   final int hintsUsed;
//   final double percentage;
//   final bool passed;
//   final Duration timeTaken;
//   final double attemptRate;

//   const TestStatistics({
//     required this.totalQuestions,
//     required this.answered,
//     required this.correct,
//     required this.incorrect,
//     required this.unattempted,
//     required this.totalPoints,
//     required this.earnedPoints,
//     required this.accuracy,
//     required this.hintsUsed,
//     required this.percentage,
//     required this.passed,
//     required this.timeTaken,
//     required this.attemptRate,
//   });
// }

// // ============================================================
// // TEST SERVICE (UPDATED FOR API)
// // ============================================================

// class TestService {
//   // Base URL
//   static const String baseUrl = 'https://json.revochamp.site/mockinterview';
  
//   // Load test from API with category and filename
//   Future<TestSession> loadTest({
//     required String category,
//     required String fileName,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/$category/$fileName.json');
//       print('📚 Loading test from: $url'); // Debug log
      
//       final response = await http.get(url);
      
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         return TestSession.fromJson(jsonData);
//       } else {
//         throw Exception('HTTP ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to load test: $e');
//     }
//   }

//   TestStatistics calculateStatistics({
//     required TestSession session,
//     required Map<String, UserAnswer> answers,
//     required int hintsUsed,
//     required Duration timeTaken,
//   }) {
//     final totalQuestions = session.questions.length;
//     final answered = answers.length;
//     final correct = answers.values.where((a) => a.isCorrect).length;
//     final incorrect = answered - correct;
//     final unattempted = totalQuestions - answered;
    
//     final earnedPoints = answers.values.fold<int>(0, (sum, answer) {
//       if (answer.isCorrect) {
//         final question = session.questionMap[answer.questionId];
//         return sum + (question?.points ?? 0);
//       }
//       return sum;
//     });
    
//     final accuracy = answered > 0 ? (correct / answered) * 100 : 0;
//     final percentage = session.totalPoints > 0
//         ? (earnedPoints / session.totalPoints) * 100
//         : 0;
//     final passed = percentage >= session.passingScore;
//     final attemptRate = (answered / totalQuestions) * 100;
    
//     return TestStatistics(
//       totalQuestions: totalQuestions,
//       answered: answered,
//       correct: correct,
//       incorrect: incorrect,
//       unattempted: unattempted,
//       totalPoints: session.totalPoints,
//       earnedPoints: earnedPoints,
//       accuracy: accuracy.toDouble(),
//       hintsUsed: hintsUsed,
//       percentage: percentage.toDouble(),
//       passed: passed,
//       timeTaken: timeTaken,
//       attemptRate: attemptRate,
//     );
//   }
// }


// // ============================================================
// // TEST INTRO SCREEN
// // ============================================================

// class TestIntroScreen extends StatelessWidget {
//   final TestSession session;

//   const TestIntroScreen({super.key, required this.session});

//   static const primaryColor = Color(0xFF6366F1);

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth < 600;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           _buildHeader(context, isMobile),

//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(isMobile ? 16 : 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildStatsRow(isMobile),
//                   const SizedBox(height: 20),
//                   _buildPassingScore(),
//                   const SizedBox(height: 20),
//                   _buildDifficultySection(isMobile),
//                   const SizedBox(height: 20),
//                   _buildTopics(),
//                   const SizedBox(height: 20),
//                   _buildFeatures(isMobile),
//                   const SizedBox(height: 24),
//                   _buildStartButton(context, isMobile),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, bool isMobile) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: isMobile ? 220 : 320,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [primaryColor, const Color(0xFF818CF8)],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(32),
//           bottomRight: Radius.circular(32),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: primaryColor.withValues(alpha:0.25),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           )
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 20 : 32, vertical: 20),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   _iconButton(Icons.arrow_back_ios, () {
//                     Navigator.pop(context);
//                   }),
//                   const Spacer(),
//                   _categoryChip(),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 400),
//                 width: isMobile ? 70 : 90,
//                 height: isMobile ? 70 : 90,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha:0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.assignment_turned_in,
//                     size: 35, color: Colors.white),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 session.title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: isMobile ? 22 : 28,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 session.description,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.white.withValues(alpha:0.9),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "~${session.timeLimitMinutes} mins to complete",
//                 style: const TextStyle(color: Colors.white70, fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _iconButton(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha:0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }

//   Widget _categoryChip() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha:0.2),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Text(
//         session.category.toUpperCase(),
//         style: const TextStyle(color: Colors.white, fontSize: 11),
//       ),
//     );
//   }

//   Widget _buildStatsRow(bool isMobile) {
//     return Row(
//       children: [
//         Expanded(
//             child: _statCard(Icons.quiz, '${session.questions.length}', 'Questions')),
//         const SizedBox(width: 10),
//         Expanded(
//             child: _statCard(Icons.timer, '${session.timeLimitMinutes}', 'Minutes')),
//         const SizedBox(width: 10),
//         Expanded(
//             child: _statCard(Icons.stars, '${session.totalPoints}', 'Points')),
//       ],
//     );
//   }

//   Widget _statCard(IconData icon, String value, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: primaryColor),
//           const SizedBox(height: 6),
//           Text(value,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 18)),
//           Text(label, style: TextStyle(color: Colors.grey.shade600)),
//         ],
//       ),
//     );
//   }

//   Widget _buildPassingScore() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: primaryColor.withValues(alpha:0.05),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.emoji_events, color: primaryColor),
//           const SizedBox(width: 10),
//           Text(
//             "Passing Score: ${session.passingScore}%",
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: primaryColor),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildDifficultySection(bool isMobile) {
//     final total = session.questions.length;
//     final beginner =
//         session.questions.where((q) => q.difficulty == 'beginner').length;
//     final intermediate =
//         session.questions.where((q) => q.difficulty == 'intermediate').length;
//     final advanced =
//         session.questions.where((q) => q.difficulty == 'advanced').length;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Difficulty Distribution",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               flex: beginner,
//               child: Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(4),
//                     bottomLeft: Radius.circular(beginner > 0 && intermediate == 0 && advanced == 0 ? 4 : 0),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: intermediate,
//               child: Container(
//                 height: 8,
//                 color: Colors.orange,
//               ),
//             ),
//             Expanded(
//               flex: advanced,
//               child: Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(advanced > 0 ? 4 : 0),
//                     bottomRight: Radius.circular(advanced > 0 ? 4 : 0),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildDifficultyLegend('Beginner', beginner, Colors.green),
//             _buildDifficultyLegend('Intermediate', intermediate, Colors.orange),
//             _buildDifficultyLegend('Advanced', advanced, Colors.red),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDifficultyLegend(String label, int count, Color color) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           '$label ($count)',
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.grey.shade600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopics() {
//     final topics = session.questions.map((e) => e.topic).toSet().toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Topics Covered",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: topics.map((topic) {
//             return Chip(
//               label: Text(topic),
//               backgroundColor: const Color(0xFF6366F1).withValues(alpha:0.1),
//               labelStyle: TextStyle(
//                 color: const Color(0xFF6366F1),
//                 fontWeight: FontWeight.w600,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatures(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Features",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 10),
//         _feature("Timed Challenge"),
//         _feature("Free Navigation"),
//         _feature("Smart Hints"),
//       ],
//     );
//   }

//   Widget _feature(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           const Icon(Icons.check_circle, size: 16, color: primaryColor),
//           const SizedBox(width: 8),
//           Text(text),
//         ],
//       ),
//     );
//   }

//   Widget _buildStartButton(BuildContext context, bool isMobile) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => _MockTestQuizScreen(session: session),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [primaryColor, Color(0xFF818CF8)],
//           ),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: const Center(
//           child: Text(
//             "Start Test Now →",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // QUIZ SCREEN
// // ============================================================

// class _MockTestQuizScreen extends StatefulWidget {
//   final TestSession session;

//   const _MockTestQuizScreen({required this.session});

//   @override
//   State<_MockTestQuizScreen> createState() => _MockTestQuizScreenState();
// }

// class _MockTestQuizScreenState extends State<_MockTestQuizScreen> {
//   final TestService _testService = TestService();
  
//   late TestSession _testSession;
  
//   final Map<String, UserAnswer> _userAnswers = {};
//   final Set<String> _hintUsedQuestions = {};
//   int _currentQuestionIndex = 0;
//   late DateTime _testStartTime;
  
//   bool _showExplanation = false;
//   int? _selectedOptionForCurrent;
//   bool _showHint = false;
  
//   Timer? _timer;
//   Duration _timeRemaining = const Duration(minutes: 45);
//   bool _isTimeUp = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _testSession = widget.session;
//     _testStartTime = DateTime.now();
//     _timeRemaining = Duration(minutes: _testSession.timeLimitMinutes);
//     _startTimer();
//   }
  
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
  
//   void _restoreCurrentAnswerState() {
//     final question = _testSession.questions[_currentQuestionIndex];
//     final existingAnswer = _userAnswers[question.id];
    
//     setState(() {
//       if (existingAnswer != null) {
//         _selectedOptionForCurrent = existingAnswer.selectedOptionIndex;
//         _showExplanation = true;
//         _showHint = existingAnswer.usedHint;
//       } else {
//         _selectedOptionForCurrent = null;
//         _showExplanation = false;
//         _showHint = false;
//       }
//     });
//   }
  
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isTimeUp) return;
      
//       if (_timeRemaining.inSeconds <= 0) {
//         timer.cancel();
//         _isTimeUp = true;
//         _submitTest();
//       } else {
//         setState(() {
//           _timeRemaining -= const Duration(seconds: 1);
//         });
//       }
//     });
//   }

//   void _selectOption(int optionIndex) {
//     if (_isTimeUp) return;
//     if (_showExplanation) return;
    
//     final question = _testSession.questions[_currentQuestionIndex];
//     final isCorrect = optionIndex == question.correctAnswerIndex;
    
//     setState(() {
//       _userAnswers[question.id] = UserAnswer(
//         questionId: question.id,
//         selectedOptionIndex: optionIndex,
//         isCorrect: isCorrect,
//         answeredAt: DateTime.now(),
//         usedHint: _showHint,
//       );
      
//       if (_showHint) {
//         _hintUsedQuestions.add(question.id);
//       }
      
//       _showExplanation = true;
//       _selectedOptionForCurrent = optionIndex;
//     });
//   }

//   void _nextQuestion() {
//     if (_currentQuestionIndex < _testSession.questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//       });
//       _restoreCurrentAnswerState();
//     }
//   }

//   void _previousQuestion() {
//     if (_currentQuestionIndex > 0) {
//       setState(() {
//         _currentQuestionIndex--;
//       });
//       _restoreCurrentAnswerState();
//     }
//   }

//   void _submitTest() {
//     _timer?.cancel();
    
//     final timeTaken = DateTime.now().difference(_testStartTime);
//     final statistics = _testService.calculateStatistics(
//       session: _testSession,
//       answers: _userAnswers,
//       hintsUsed: _hintUsedQuestions.length,
//       timeTaken: timeTaken,
//     );

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ResultsScreen(
//           stats: statistics,
//           session: _testSession,
//           userAnswers: _userAnswers,
//           onRetake: () {
//             Navigator.pop(context);
//             _resetTest();
//           },
//         ),
//       ),
//     );
//   }

//   void _resetTest() {
//     setState(() {
//       _userAnswers.clear();
//       _hintUsedQuestions.clear();
//       _currentQuestionIndex = 0;
//       _showExplanation = false;
//       _selectedOptionForCurrent = null;
//       _showHint = false;
//       _testStartTime = DateTime.now();
//       _timeRemaining = Duration(minutes: _testSession.timeLimitMinutes);
//       _isTimeUp = false;
//     });
//     _startTimer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth < 600;
    
//     final question = _testSession.questions[_currentQuestionIndex];
//     final hasAnswer = _userAnswers.containsKey(question.id);
//     final progress = ((_currentQuestionIndex + 1) / _testSession.questions.length);
//     final isLastQuestion = _currentQuestionIndex == _testSession.questions.length - 1;
//     final allQuestionsAnswered = _userAnswers.length == _testSession.questions.length;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FF),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D44)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           _testSession.title,
//           style:TextStyle(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF2D2D44),
//           ),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _timeRemaining.inMinutes < 5 ? Colors.red.shade50 : const Color(0xFF6C63FF).withValues(alpha:0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.timer,
//                   size: isMobile ? 16 : 18,
//                   color: _timeRemaining.inMinutes < 5 ? Colors.red.shade700 : const Color(0xFF6C63FF),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   _formatTime(_timeRemaining),
//                   style: TextStyle(
//                     fontSize: isMobile ? 12 : 14,
//                     fontWeight: FontWeight.w600,
//                     color: _timeRemaining.inMinutes < 5 ? Colors.red.shade700 : const Color(0xFF6C63FF),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(4),
//           child: LinearProgressIndicator(
//             value: progress,
//             backgroundColor: Colors.grey.shade100,
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
//             minHeight: 4,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
//             color: Colors.white,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStatChip(
//                   icon: Icons.quiz,
//                   label: '${_currentQuestionIndex + 1}/${_testSession.questions.length}',
//                   isMobile: isMobile,
//                 ),
//                 _buildStatChip(
//                   icon: Icons.check_circle,
//                   label: '${_userAnswers.length} Answered',
//                   isMobile: isMobile,
//                 ),
//                 _buildStatChip(
//                   icon: Icons.check,
//                   label: '${_userAnswers.values.where((a) => a.isCorrect).length} Correct',
//                   isMobile: isMobile,
//                 ),
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(isMobile ? 16 : 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildQuestionCard(question, isMobile),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Select your answer:',
//                     style:TextStyle(
//                       fontSize: isMobile ? 13 : 14,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...List.generate(question.options.length, (index) {
//                     final isSelected = _selectedOptionForCurrent == index;
//                     final isCorrect = index == question.correctAnswerIndex;
                    
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: _buildOptionCard(
//                         option: question.options[index],
//                         letter: String.fromCharCode(65 + index),
//                         isSelected: isSelected,
//                         isCorrect: isCorrect,
//                         showResult: _showExplanation && hasAnswer,
//                         onTap: () => _selectOption(index),
//                         isEnabled: !_showExplanation && !hasAnswer && !_isTimeUp,
//                         isMobile: isMobile,
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 16),
//                   if (question.hints.isNotEmpty && !_showExplanation && !hasAnswer && !_isTimeUp)
//                     _buildHintSection(question.hints[0], isMobile),
//                   if (_showExplanation && hasAnswer)
//                     _buildExplanationCard(
//                       isCorrect: _userAnswers[question.id]!.isCorrect,
//                       explanation: question.explanation,
//                       selectedLetter: String.fromCharCode(65 + _selectedOptionForCurrent!),
//                       selectedText: question.options[_selectedOptionForCurrent!],
//                       correctLetter: String.fromCharCode(65 + question.correctAnswerIndex),
//                       correctText: question.options[question.correctAnswerIndex],
//                       pointsEarned: _userAnswers[question.id]!.isCorrect ? question.points : 0,
//                       isMobile: isMobile,
//                     ),
//                   const SizedBox(height: 24),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             side: BorderSide(
//                               color: _currentQuestionIndex > 0
//                                   ? const Color(0xFF6C63FF)
//                                   : Colors.grey.shade300,
//                             ),
//                           ),
//                           child: Text('Previous', style:TextStyle(fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: _showExplanation
//                               ? (isLastQuestion
//                                   ? (allQuestionsAnswered || _isTimeUp ? _submitTest : null)
//                                   : _nextQuestion)
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF6C63FF),
//                             padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           child: Text(
//                             isLastQuestion ? 'Submit' : 'Next',
//                             style:TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (!allQuestionsAnswered && isLastQuestion && _showExplanation && !_isTimeUp)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.orange.shade200),
//                         ),
//                         child: Text(
//                           'Please answer all questions before submitting',
//                           textAlign: TextAlign.center,
//                           style:TextStyle(
//                             fontSize: isMobile ? 11 : 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.orange.shade700,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatChip({required IconData icon, required String label, required bool isMobile}) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 5 : 6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: isMobile ? 14 : 16, color: Colors.grey.shade600),
//           const SizedBox(width: 6),
//           Text(label, style:TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionCard(Question question, bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getDifficultyColor(question.difficulty).withValues(alpha:0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   question.difficulty.toUpperCase(),
//                   style:TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _getDifficultyColor(question.difficulty)),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
//                 child: Row(
//                   children: [
//                     Icon(Icons.star, size: 12, color: Colors.amber.shade700),
//                     const SizedBox(width: 4),
//                     Text('${question.points} pts', style:TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.amber.shade700)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(question.text, style:TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w600, height: 1.4, color: const Color(0xFF2D2D44))),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
//             child: Text(question.topic, style:TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade700)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOptionCard({
//     required String option,
//     required String letter,
//     required bool isSelected,
//     required bool isCorrect,
//     required bool showResult,
//     required VoidCallback onTap,
//     required bool isEnabled,
//     required bool isMobile,
//   }) {
//     Color backgroundColor = Colors.white;
//     Color borderColor = Colors.grey.shade200;
//     Color letterBgColor = Colors.grey.shade100;
//     Color letterTextColor = Colors.grey.shade600;
    
//     if (showResult) {
//       if (isCorrect) {
//         backgroundColor = Colors.green.shade50;
//         borderColor = Colors.green;
//         letterBgColor = Colors.green;
//         letterTextColor = Colors.white;
//       } else if (isSelected && !isCorrect) {
//         backgroundColor = Colors.red.shade50;
//         borderColor = Colors.red;
//         letterBgColor = Colors.red;
//         letterTextColor = Colors.white;
//       }
//     } else if (isSelected) {
//       backgroundColor = const Color(0xFF6C63FF).withValues(alpha: 0.08);
//       borderColor = const Color(0xFF6C63FF);
//       letterBgColor = const Color(0xFF6C63FF);
//       letterTextColor = Colors.white;
//     }
    
//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: borderColor, width: 1.5),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: isEnabled ? onTap : null,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 12 : 16),
//             child: Row(
//               children: [
//                 Container(
//                   width: isMobile ? 36 : 40,
//                   height: isMobile ? 36 : 40,
//                   decoration: BoxDecoration(color: letterBgColor, borderRadius: BorderRadius.circular(12)),
//                   child: Center(child: Text(letter, style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 14 : 16, color: letterTextColor))),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(option, style:TextStyle(fontSize: isMobile ? 13 : 15, fontWeight: FontWeight.w500, color: const Color(0xFF2D2D44), height: 1.4))),
//                 if (showResult) Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: isMobile ? 20 : 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHintSection(String hint, bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 12 : 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.orange.shade50]),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.amber.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.lightbulb, size: isMobile ? 18 : 20, color: Colors.amber.shade700),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Hint Available', style:TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w700, color: Colors.amber.shade900)),
//                 if (_showHint) ...[
//                   const SizedBox(height: 4),
//                   Text(hint, style:TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.amber.shade800, height: 1.4)),
//                 ],
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: _showHint ? null : () => setState(() => _showHint = true),
//             style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
//             child: Text(_showHint ? 'Shown' : 'Reveal', style:TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 13, color: _showHint ? Colors.grey.shade400 : Colors.amber.shade700)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExplanationCard({
//     required bool isCorrect,
//     required String explanation,
//     required String selectedLetter,
//     required String selectedText,
//     required String correctLetter,
//     required String correctText,
//     required int pointsEarned,
//     required bool isMobile,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 16 : 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: isCorrect ? [Colors.green.shade50, Colors.teal.shade50] : [Colors.red.shade50, Colors.orange.shade50]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: isCorrect ? Colors.green.shade300 : Colors.red.shade300, width: 1.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(color: isCorrect ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(10)),
//                 child: Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white, size: isMobile ? 18 : 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(child: Text(isCorrect ? 'Correct!' : 'Incorrect', style:TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w700, color: isCorrect ? Colors.green.shade700 : Colors.red.shade700))),
//               if (pointsEarned > 0)
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF45a049)]), borderRadius: BorderRadius.circular(8)),
//                   child: Row(children: [const Icon(Icons.add, color: Colors.white, size: 14), const SizedBox(width: 4), Text('$pointsEarned', style:TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isMobile ? 12 : 14))]),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (!isCorrect) ...[
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.6), borderRadius: BorderRadius.circular(10)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Your answer:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12, color: Colors.red.shade700)),
//                   const SizedBox(height: 4),
//                   Text('$selectedLetter. $selectedText', style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44))),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.6), borderRadius: BorderRadius.circular(10)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(isCorrect ? 'Explanation:' : 'Correct answer:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12, color: Colors.green.shade700)),
//                 const SizedBox(height: 6),
//                 if (!isCorrect) ...[
//                   Text('$correctLetter. $correctText', style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44), fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 12),
//                   Text('Explanation:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12)),
//                   const SizedBox(height: 6),
//                 ],
//                 Text(explanation, style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44), height: 1.5)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getDifficultyColor(String difficulty) {
//     switch (difficulty.toLowerCase()) {
//       case 'beginner': return Colors.green;
//       case 'intermediate': return Colors.orange;
//       case 'advanced': return Colors.red;
//       default: return Colors.blue;
//     }
//   }

//   String _formatTime(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }
// }

// // ============================================================
// // RESULTS SCREEN
// // ============================================================

// class ResultsScreen extends StatefulWidget {
//   final TestStatistics stats;
//   final TestSession session;
//   final Map<String, UserAnswer> userAnswers;
//   final VoidCallback onRetake;

//   const ResultsScreen({
//     super.key,
//     required this.stats,
//     required this.session,
//     required this.userAnswers,
//     required this.onRetake,
//   });

//   @override
//   State<ResultsScreen> createState() => _ResultsScreenState();
// }

// class _ResultsScreenState extends State<ResultsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = screenWidth < 600;
//     final isTablet = screenWidth >= 600 && screenWidth < 900;
    
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FF),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Text('Test Results', style:TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D44))),
//         leading: IconButton(icon: const Icon(Icons.close, color: Color(0xFF2D2D44)), onPressed: () => Navigator.of(context).pop()),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(isMobile ? 16 : 24),
//         child: Column(
//           children: [
//             _buildScoreCard(isMobile),
//             const SizedBox(height: 24),
//             _buildStatisticsGrid(isMobile, isTablet),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: widget.onRetake,
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retake Test'),
//                     style: OutlinedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.done),
//                     label: const Text('Exit'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6C63FF),
//                       padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             _buildDetailedReview(isMobile),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScoreCard(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 24 : 32),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: widget.stats.passed ? [const Color(0xFF4CAF50), const Color(0xFF45a049)] : [const Color(0xFFFF9800), const Color(0xFFFF6F00)],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [BoxShadow(color: (widget.stats.passed ? Colors.green : Colors.orange).withValues(alpha:0.3), blurRadius: 30, offset: const Offset(0, 10))],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
//             child: Icon(widget.stats.passed ? Icons.emoji_events : Icons.school, size: isMobile ? 48 : 56, color: Colors.white),
//           ),
//           const SizedBox(height: 20),
//           Text('${widget.stats.percentage.toStringAsFixed(1)}%', style:TextStyle(fontSize: isMobile ? 48 : 64, fontWeight: FontWeight.w900, color: Colors.white)),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.25), borderRadius: BorderRadius.circular(12)),
//             child: Text(widget.stats.passed ? 'PASSED' : 'NEEDS IMPROVEMENT', style:TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 12 : 14, color: Colors.white, letterSpacing: 1.2)),
//           ),
//           const SizedBox(height: 16),
//           Text('${widget.stats.earnedPoints} / ${widget.stats.totalPoints} points', style:TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white70, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 12),
//           Text('Time taken: ${_formatDuration(widget.stats.timeTaken)}', style:TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.white70)),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsGrid(bool isMobile, bool isTablet) {
//     final stats = [
//       {'title': 'Questions', 'value': widget.stats.totalQuestions.toString(), 'icon': Icons.quiz, 'color': Colors.blue},
//       {'title': 'Answered', 'value': widget.stats.answered.toString(), 'icon': Icons.check_circle, 'color': Colors.teal},
//       {'title': 'Correct', 'value': widget.stats.correct.toString(), 'icon': Icons.verified, 'color': Colors.green},
//       {'title': 'Incorrect', 'value': widget.stats.incorrect.toString(), 'icon': Icons.close, 'color': Colors.red},
//       {'title': 'Accuracy', 'value': '${widget.stats.accuracy.toStringAsFixed(0)}%', 'icon': Icons.trending_up, 'color': Colors.orange},
//       {'title': 'Attempt Rate', 'value': '${widget.stats.attemptRate.toStringAsFixed(0)}%', 'icon': Icons.analytics, 'color': Colors.purple},
//       {'title': 'Hints Used', 'value': widget.stats.hintsUsed.toString(), 'icon': Icons.lightbulb, 'color': Colors.amber},
//     ];
    
//     int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         final stat = stats[index];
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10, offset: const Offset(0, 2))]),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (stat['color'] as Color).withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)), child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24)),
//               const SizedBox(height: 8),
//               Text(stat['value'] as String, style:TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w800, color: stat['color'] as Color)),
//               const SizedBox(height: 4),
//               Text(stat['title'] as String, style:TextStyle(fontSize: isMobile ? 10 : 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailedReview(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Detailed Review', style:TextStyle(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D44))),
//         const SizedBox(height: 16),
//         ...List.generate(widget.session.questions.length, (index) {
//           final question = widget.session.questions[index];
//           final answer = widget.userAnswers[question.id];
//           final isCorrect = answer?.isCorrect ?? false;
//           final isAnswered = answer != null;
          
//           return Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
//             child: ExpansionTile(
//               leading: CircleAvatar(backgroundColor: isAnswered ? (isCorrect ? Colors.green : Colors.red) : Colors.grey, radius: isMobile ? 14 : 16, child: Text('${index + 1}', style:TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isMobile ? 12 : 14))),
//               title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis, style:TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44))),
//               subtitle: Text(isAnswered ? (isCorrect ? '✓ Correct' : '✗ Incorrect') : 'Not answered', style:TextStyle(color: isAnswered ? (isCorrect ? Colors.green : Colors.red) : Colors.grey, fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12)),
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (isAnswered && !isCorrect)
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.only(bottom: 12),
//                           decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Your Answer:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12, color: Colors.red.shade700)),
//                               const SizedBox(height: 4),
//                               Text('${String.fromCharCode(65 + answer!.selectedOptionIndex)}. ${question.options[answer.selectedOptionIndex]}', style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44))),
//                             ],
//                           ),
//                         ),
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Correct Answer:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12, color: Colors.green.shade700)),
//                             const SizedBox(height: 4),
//                             Text('${String.fromCharCode(65 + question.correctAnswerIndex)}. ${question.options[question.correctAnswerIndex]}', style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44), fontWeight: FontWeight.w600)),
//                             const SizedBox(height: 12),
//                             Text('Explanation:', style:TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 11 : 12, color: Colors.green.shade700)),
//                             const SizedBox(height: 4),
//                             Text(question.explanation, style:TextStyle(fontSize: isMobile ? 13 : 14, color: const Color(0xFF2D2D44), height: 1.5)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes;
//     final seconds = duration.inSeconds.remainder(60);
//     if (minutes > 0) return '$minutes min ${seconds}s';
//     return '${seconds}s';
//   }
// }

// // ============================================================
// // MAIN ENTRY POINT (UPDATED FOR API)
// // ============================================================

// class MockTestScreen extends StatelessWidget {
//   final String category;
//   final String fileName;

//   const MockTestScreen({
//     super.key, 
//     required this.category,
//     required this.fileName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<TestSession>(
//       future: TestService().loadTest(category: category, fileName: fileName),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF))),
//                   const SizedBox(height: 24),
//                   Text('Loading Test...', style:TextStyle(fontSize: 16, color: Colors.grey.shade600)),
//                 ],
//               ),
//             ),
//           );
//         }
        
//         if (snapshot.hasError) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             body: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
//                     const SizedBox(height: 24),
//                     Text('Failed to Load Test', style:TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
//                     const SizedBox(height: 12),
//                     Text(snapshot.error.toString(), textAlign: TextAlign.center, style:TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
        
//         return TestIntroScreen(session: snapshot.data!);
//       },
//     );
//   }
// }