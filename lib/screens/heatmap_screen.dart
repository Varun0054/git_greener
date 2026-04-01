import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contributions_provider.dart';
import '../providers/suggestions_provider.dart';
import '../widgets/calendar_mini_heatmap.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/language_donut_chart.dart';
import '../widgets/ai_summary_card.dart';

class HeatmapScreen extends ConsumerWidget {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsProvider);
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Analytics 📊'),
      ),
      body: contributionsAsync.when(
        data: (data) {
          final stats = data.getStats();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AiSummaryCard(stats: stats),
              const SizedBox(height: 24),
              
              // Stats Cards Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCard(value: '${stats.totalContributions}', label: 'Total'),
                  _StatCard(value: '${stats.currentStreak}', label: 'Streak'),
                  _StatCard(value: '${stats.longestStreak}', label: 'Best'),
                  _StatCard(value: stats.mostActiveDay.substring(0, 3), label: 'Top Day'),
                ],
              ),
              const SizedBox(height: 24),

              CalendarMiniHeatmap(days: data.days.map((e) => ContributionDay(date: e.date, contributionCount: e.contributionCount)).toList()),
              const SizedBox(height: 32),

              RadarChartWidget(weekdayAvgs: _calculateWeekdayAvgs(data.days)),
              const SizedBox(height: 32),

              suggestionsAsync.maybeWhen(
                data: (repos) => LanguageDonutChart(languageData: _calculateLanguageData(repos.map((s) => s.repoName).toList())),
                orElse: () => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Map<int, double> _calculateWeekdayAvgs(List<dynamic> days) {
    final totals = <int, int>{};
    final counts = <int, int>{};
    for (var day in days) {
      final wd = day.date.weekday;
      totals[wd] = (totals[wd] ?? 0) + (day.contributionCount as int);
      counts[wd] = (counts[wd] ?? 0) + 1;
    }
    return {
      for (var wd in totals.keys)
        wd: counts[wd]! > 0 ? totals[wd]! / counts[wd]! : 0.0
    };
  }

  Map<String, int> _calculateLanguageData(List<String> repoNames) {
    return {'Dart': 5, 'Python': 2, 'TypeScript': 1}; 
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 4,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEDF0)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2DA44E))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF636C76))),
        ],
      ),
    );
  }
}
