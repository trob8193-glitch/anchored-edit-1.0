import 'package:flutter/material.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Training'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _TrainingTile(title: 'Dog Body Language', duration: '12 min'),
          _TrainingTile(title: 'Safe Leash Handling', duration: '18 min'),
          _TrainingTile(title: 'Incident Response Basics', duration: '15 min'),
        ],
      ),
    );
  }
}

class _TrainingTile extends StatelessWidget {
  const _TrainingTile({required this.title, required this.duration});

  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF212121),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(duration, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
      ),
    );
  }
}
