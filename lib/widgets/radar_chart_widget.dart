import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<int, double> weekdayAvgs;

  const RadarChartWidget({super.key, required this.weekdayAvgs});

  @override
  Widget build(BuildContext context) {
    final List<double> values = [
      weekdayAvgs[1] ?? 0,
      weekdayAvgs[2] ?? 0,
      weekdayAvgs[3] ?? 0,
      weekdayAvgs[4] ?? 0,
      weekdayAvgs[5] ?? 0,
      weekdayAvgs[6] ?? 0,
      weekdayAvgs[7] ?? 0,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('🕸️ Day of Week Intensity', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
        ),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEDF0)),
          ),
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                  fillColor: const Color(0xFF2DA44E).withValues(alpha: 0.3),
                  borderColor: const Color(0xFF2DA44E),
                  borderWidth: 2,
                )
              ],
              getTitle: (index, angle) {
                final labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                if (index >= 0 && index < labels.length) {
                  return RadarChartTitle(text: labels[index.toInt()]);
                }
                return const RadarChartTitle(text: '');
              },
              radarBackgroundColor: Colors.transparent,
              gridBorderData: const BorderSide(color: Color(0xFFEBEDF0), width: 1),
              tickBorderData: const BorderSide(color: Color(0xFFEBEDF0), width: 1),
              tickCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
