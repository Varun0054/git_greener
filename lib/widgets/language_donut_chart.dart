import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LanguageDonutChart extends StatelessWidget {
  final Map<String, int> languageData;

  const LanguageDonutChart({super.key, required this.languageData});

  Color _colorForLanguage(String lang) {
    return switch (lang.toLowerCase()) {
      'dart'       => const Color(0xFF00B4AB),
      'python'     => const Color(0xFF3572A5),
      'javascript' => const Color(0xFFF1E05A),
      'typescript' => const Color(0xFF2B7489),
      'java'       => const Color(0xFFB07219),
      'kotlin'     => const Color(0xFFA97BFF),
      'swift'      => const Color(0xFFFF5733),
      'html'       => const Color(0xFFE34C26),
      'css'        => const Color(0xFF563D7C),
      'go'         => const Color(0xFF00ADD8),
      'rust'       => const Color(0xFFDEA584),
      _            => const Color(0xFF636C76),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (languageData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('🍩 Tech Stack Breakdown', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEDF0)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    sections: languageData.entries.map((e) {
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: '',
                        color: _colorForLanguage(e.key),
                        radius: 40,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: languageData.entries.map((e) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: _colorForLanguage(e.key)),
                      const SizedBox(width: 4),
                      Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
