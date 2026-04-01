import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/suggestion.dart';
import '../services/nemotron_service.dart';
import 'auth_provider.dart';
import 'contributions_provider.dart';

final nemotronServiceProvider = Provider((ref) => NemotronService());

final suggestionsProvider = FutureProvider<List<Suggestion>>((ref) async {
  final token = ref.watch(authProvider).value;
  if (token == null || token.isEmpty) {
    throw Exception('Not authenticated');
  }

  final githubService = ref.watch(githubServiceProvider);
  final nemotronService = ref.watch(nemotronServiceProvider);
  final openRouterKey = await ref.watch(openRouterKeyProvider.future);

  // Get recent repos
  final repos = await githubService.fetchRecentRepos(token);

  // Figure out days since last commit
  final contributionsState = await ref.watch(contributionsProvider.future);
  int daysSinceLastCommit = 0;
  int todayContributions = 0;
  int currentStreak = contributionsState.currentStreak;

  if (contributionsState.days.isNotEmpty) {
     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
     final todayDays = contributionsState.days.where(
       (d) => DateFormat('yyyy-MM-dd').format(d.date) == today
     );
     if (todayDays.isNotEmpty) {
       todayContributions = todayDays.first.contributionCount;
     }
  }

  for (int i = contributionsState.days.length - 1; i >= 0; i--) {
    if (contributionsState.days[i].contributionCount > 0) {
      final lastCommitDate = contributionsState.days[i].date;
      daysSinceLastCommit = DateTime.now().difference(lastCommitDate).inDays;
      break;
    }
  }

  return nemotronService.getSuggestions(
    repos: repos,
    todayContributions: todayContributions,
    currentStreak: currentStreak,
    daysSinceLastCommit: daysSinceLastCommit,
    openRouterKey: openRouterKey,
  );
});
