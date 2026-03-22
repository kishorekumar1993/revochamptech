import 'package:flutter/material.dart';
import 'package:techtutorial/models/tutorial_topic.dart';

class TopicCard extends StatelessWidget {
  final TutorialTopic topic;
  final bool isCompleted;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF2A5298).withOpacity(0.1),
          child: Text(topic.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Interactive tutorial + quiz"),
        trailing: isCompleted
            ? const Icon(Icons.verified, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

