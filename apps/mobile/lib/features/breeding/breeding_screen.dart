import 'package:flutter/material.dart';

class BreedingScreen extends StatelessWidget {
  const BreedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Breeding'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _BreedingCard(
            title: 'Program Status',
            lines: ['2 active pairings', '1 pending health clearance', 'Next review in 5 days'],
          ),
          _BreedingCard(
            title: 'Required Records',
            lines: ['Genetic panel uploaded', 'Vaccination records current', 'Microchip IDs verified'],
          ),
        ],
      ),
    );
  }
}

class _BreedingCard extends StatelessWidget {
  const _BreedingCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF212121),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(line, style: const TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
