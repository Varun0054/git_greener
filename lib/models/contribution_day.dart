import 'package:flutter/material.dart';

class ContributionDay {
  final DateTime date;
  final int contributionCount;
  final Color color;

  const ContributionDay({
    required this.date,
    required this.contributionCount,
    required this.color,
  });

  factory ContributionDay.fromJson(Map<String, dynamic> json) {
    return ContributionDay(
      date: DateTime.parse(json['date'] as String),
      contributionCount: json['contributionCount'] as int? ?? 0,
      color: _parseColor(json['color'] as String?),
    );
  }

  static Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return const Color(0xFFEBEDF0);
    }
    final hexCode = colorHex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return const Color(0xFFEBEDF0);
  }
}
