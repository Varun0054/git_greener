import 'package:flutter/material.dart';

class CalendarMiniHeatmap extends StatelessWidget {
  final List<ContributionDay> days;

  const CalendarMiniHeatmap({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    // Take last 90 days
    final rollingDays = days.length > 90 ? days.sublist(days.length - 90) : days;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('📅 Recent Activity (90 Days)', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEDF0)),
          ),
          child: CustomPaint(
            size: const Size(double.infinity, 120),
            painter: HeatmapPainter(rollingDays),
          ),
        ),
      ],
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final List<ContributionDay> days;

  HeatmapPainter(this.days);

  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 14.0;
    const double gap = 3.0;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // We have 90 days. Roughly 13 weeks.
    // 7 rows (days) x n columns (weeks)
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final col = i ~/ 7;
      final row = i % 7;

      paint.color = _getColor(day.contributionCount);
      
      final rect = Rect.fromLTWH(
        col * (cellSize + gap),
        row * (cellSize + gap),
        cellSize,
        cellSize,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)), 
        paint
      );
    }
  }

  Color _getColor(int count) {
    if (count == 0) return const Color(0xFFEBEDF0);
    if (count <= 3) return const Color(0xFF9BE9A8);
    if (count <= 6) return const Color(0xFF40C463);
    if (count <= 9) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Minimal model definition for widget-only use if needed, but normally imported
class ContributionDay {
  final DateTime date;
  final int contributionCount;
  ContributionDay({required this.date, required this.contributionCount});
}
