import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final String value;

  const StreakCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF636C76), fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Color(0xFF1F2328), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
