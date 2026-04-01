class HeatmapStats {
  final int totalContributions;
  final int currentStreak;
  final int longestStreak;
  final String mostActiveDay;
  final String leastActiveDay;
  final String mostActiveMonth;
  final double avgCommitsPerDay;
  final String topLanguage;
  final int zeroWeeks;
  final int bestWeekCount;

  HeatmapStats({
    required this.totalContributions,
    required this.currentStreak,
    required this.longestStreak,
    required this.mostActiveDay,
    required this.leastActiveDay,
    required this.mostActiveMonth,
    required this.avgCommitsPerDay,
    required this.topLanguage,
    required this.zeroWeeks,
    required this.bestWeekCount,
  });
}
