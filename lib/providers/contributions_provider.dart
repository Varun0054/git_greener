import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contribution_day.dart';
import '../models/user_profile.dart';
import '../services/github_service.dart';
import 'auth_provider.dart';
import '../models/heatmap_stats.dart';

class ContributionsState {
  final UserProfile profile;
  final List<ContributionDay> days;
  final int currentStreak;
  final int totalContributions;
  final int longestStreak;

  ContributionsState({
    required this.profile,
    required this.days,
    required this.currentStreak,
    required this.totalContributions,
    this.longestStreak = 0,
  });

  HeatmapStats getStats() {
    if (days.isEmpty) {
      return HeatmapStats(
        totalContributions: 0,
        currentStreak: 0,
        longestStreak: 0,
        mostActiveDay: 'None',
        leastActiveDay: 'None',
        mostActiveMonth: 'None',
        avgCommitsPerDay: 0,
        topLanguage: 'None',
        zeroWeeks: 0,
        bestWeekCount: 0,
      );
    }

    final dayCounts = List.filled(7, 0);
    final monthCounts = List.filled(12, 0);
    for (var day in days) {
      dayCounts[day.date.weekday - 1] += day.contributionCount;
      monthCounts[day.date.month - 1] += day.contributionCount;
    }

    final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    int maxDayIdx = 0;
    int minDayIdx = 0;
    for (int i = 1; i < 7; i++) {
      if (dayCounts[i] > dayCounts[maxDayIdx]) maxDayIdx = i;
      if (dayCounts[i] < dayCounts[minDayIdx]) minDayIdx = i;
    }

    int maxMonthIdx = 0;
    for (int i = 1; i < 12; i++) {
      if (monthCounts[i] > monthCounts[maxMonthIdx]) maxMonthIdx = i;
    }

    // Rough calculation for zero weeks & best week
    int zeroWeeks = 0;
    int bestWeek = 0;
    for (int i = 0; i < days.length; i += 7) {
      int weekSum = 0;
      for (int k = 0; k < 7 && (i + k) < days.length; k++) {
        weekSum += days[i + k].contributionCount;
      }
      if (weekSum == 0) zeroWeeks++;
      if (weekSum > bestWeek) bestWeek = weekSum;
    }

    return HeatmapStats(
      totalContributions: totalContributions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      mostActiveDay: daysOfWeek[maxDayIdx],
      leastActiveDay: daysOfWeek[minDayIdx],
      mostActiveMonth: months[maxMonthIdx],
      avgCommitsPerDay: totalContributions / days.where((d) => d.contributionCount > 0).length.clamp(1, 999),
      topLanguage: 'Unknown', // Need repo data for this
      zeroWeeks: zeroWeeks,
      bestWeekCount: bestWeek,
    );
  }
}

final githubServiceProvider = Provider((ref) => GitHubService());

final contributionsProvider = FutureProvider<ContributionsState>((ref) async {
  final token = ref.watch(authProvider).value;
  if (token == null || token.isEmpty) {
    throw Exception('Not authenticated');
  }

  final githubService = ref.watch(githubServiceProvider);
  final data = await githubService.fetchProfileData(token);

  final profile = data['profile'] as UserProfile;
  final totalContributions = data['totalContributions'] as int;
  final List<ContributionDay> days = data['days'] as List<ContributionDay>;

  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  int maxStreak = 0;
  int currentWalkStreak = 0;
  for (var day in days) {
    if (day.contributionCount > 0) {
      currentWalkStreak++;
      if (currentWalkStreak > maxStreak) {
        maxStreak = currentWalkStreak;
      }
    } else {
      currentWalkStreak = 0;
    }
  }

  int activeStreak = 0;
  for (int i = days.length - 1; i >= 0; i--) {
    final day = days[i];
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    if (dayDate.isAfter(today)) continue; 

    if (dayDate == today && day.contributionCount == 0) {
      continue; 
    }

    if (day.contributionCount > 0) {
      activeStreak++;
    } else {
      break;
    }
  }

  return ContributionsState(
    profile: profile,
    totalContributions: totalContributions,
    days: days,
    currentStreak: activeStreak,
    longestStreak: maxStreak,
  );
});
