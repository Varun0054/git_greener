import '../models/suggestion.dart';
import '../models/github_repo.dart';

class SuggestionEngine {
  List<Suggestion> generate({
    required List<GitHubRepo> repos,
    required int todayContributions,
    required int currentStreak,
    required int daysSinceLastCommit,
  }) {
    final result = <Suggestion>[];
    final usedRepos = <String>{};
    final ruleTypeCounts = <SuggestionType, int>{};

    // Rule caps per type — enforces variety
    const typeCaps = {
      SuggestionType.addReadme: 2,
      SuggestionType.fixOpenIssue: 2,
      SuggestionType.reviveOldRepo: 1,
      SuggestionType.pushLocalChanges: 1,
      SuggestionType.updateDescription: 1,
      SuggestionType.addTests: 1,
      SuggestionType.dailyCommit: 1,
    };

    // Step 1 — Rule 2: Streak at risk (only repos.first, highest priority)
    if (repos.isNotEmpty && currentStreak >= 3 && todayContributions == 0) {
      final r = repos.first;
      result.add(
        Suggestion(
          owner: r.owner,
          repoName: r.name,
          message:
              "Your $currentStreak-day streak is on the line! Push anything to ${r.name} to keep it alive 🔥",
          reason: "Streak at risk",
          type: SuggestionType.dailyCommit,
        ),
      );
      usedRepos.add(r.name);
      ruleTypeCounts[SuggestionType.dailyCommit] = 1;
    }
    // Step 2 — Rule 1: No commit today (only repos.first, mutually exclusive with Rule 2)
    else if (repos.isNotEmpty && todayContributions == 0) {
      final r = repos.first;
      result.add(
        Suggestion(
          owner: r.owner,
          repoName: r.name,
          message:
              "Make a small improvement to ${r.name} — even a comment or doc fix counts!",
          reason: "No commit yet today",
          type: SuggestionType.dailyCommit,
        ),
      );
      usedRepos.add(r.name);
      ruleTypeCounts[SuggestionType.dailyCommit] = 1;
    }

    // Step 3 — Apply rules across repos in priority order, one rule per repo
    // Ordered by priority; first matching rule wins for each repo
    for (final repo in repos) {
      if (result.length >= 5) break;
      if (usedRepos.contains(repo.name)) continue;
      if (repo.isFork) continue;

      final daysSincePush = DateTime.now().difference(repo.pushedAt).inDays;

      // Try each rule in priority order — pick first that fits cap
      final suggestion =
          _tryRule3MissingReadme(repo, ruleTypeCounts, typeCaps) ??
          _tryRule7OpenIssues(repo, ruleTypeCounts, typeCaps) ??
          _tryRule5InactiveOld(repo, daysSincePush, ruleTypeCounts, typeCaps) ??
          _tryRule6InactiveRecent(
            repo,
            daysSincePush,
            ruleTypeCounts,
            typeCaps,
          ) ??
          _tryRule4NoDescription(repo, ruleTypeCounts, typeCaps) ??
          _tryRule8NoTests(repo, ruleTypeCounts, typeCaps);

      if (suggestion != null) {
        result.add(suggestion);
        usedRepos.add(repo.name);
        ruleTypeCounts[suggestion.type] =
            (ruleTypeCounts[suggestion.type] ?? 0) + 1;
      }
    }

    // Step 4 — Fallback if empty
    if (result.isEmpty) {
      final fallbackRepo = repos.isNotEmpty ? repos.first.name : 'your project';
      final fallbackOwner = repos.isNotEmpty ? repos.first.owner : '';
      result.add(
        Suggestion(
          owner: fallbackOwner,
          repoName: fallbackRepo,
          message:
              "Great job staying active! Try adding documentation or comments to any repo today.",
          reason: "All good!",
          type: SuggestionType.dailyCommit,
        ),
      );
    }

    return result;
  }

  bool _underCap(
    SuggestionType type,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    return (counts[type] ?? 0) < (caps[type] ?? 1);
  }

  Suggestion? _tryRule3MissingReadme(
    GitHubRepo repo,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.addReadme, counts, caps)) return null;
    if (repo.hasReadme) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "Add a README.md to '${repo.name}' — it takes 5 minutes and makes your profile look polished",
      reason: "Missing README",
      type: SuggestionType.addReadme,
    );
  }

  Suggestion? _tryRule7OpenIssues(
    GitHubRepo repo,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.fixOpenIssue, counts, caps)) return null;
    if (repo.openIssuesCount <= 0) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "Fix one of the ${repo.openIssuesCount} open issues in '${repo.name}' — close an issue = a commit + progress!",
      reason: "${repo.openIssuesCount} open issues",
      type: SuggestionType.fixOpenIssue,
    );
  }

  Suggestion? _tryRule5InactiveOld(
    GitHubRepo repo,
    int daysSincePush,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.reviveOldRepo, counts, caps)) return null;
    if (daysSincePush <= 30) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "Revive '${repo.name}' — it hasn't been touched in $daysSincePush days. Even a small refactor or cleanup commit helps",
      reason: "Inactive 30+ days",
      type: SuggestionType.reviveOldRepo,
    );
  }

  Suggestion? _tryRule6InactiveRecent(
    GitHubRepo repo,
    int daysSincePush,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.pushLocalChanges, counts, caps)) return null;
    if (daysSincePush < 7 || daysSincePush > 30) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "It's been a week since you touched '${repo.name}'. Push those local changes or add a small feature",
      reason: "Inactive this week",
      type: SuggestionType.pushLocalChanges,
    );
  }

  Suggestion? _tryRule4NoDescription(
    GitHubRepo repo,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.updateDescription, counts, caps)) return null;
    if (repo.description != null && repo.description!.isNotEmpty) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "Add a one-line description to '${repo.name}' on GitHub — helps people (and you) know what it's for",
      reason: "No description",
      type: SuggestionType.updateDescription,
    );
  }

  Suggestion? _tryRule8NoTests(
    GitHubRepo repo,
    Map<SuggestionType, int> counts,
    Map<SuggestionType, int> caps,
  ) {
    if (!_underCap(SuggestionType.addTests, counts, caps)) return null;
    if (repo.language != 'Dart') return null;
    if (repo.name.toLowerCase().contains('test')) return null;
    return Suggestion(
      owner: repo.owner,
      repoName: repo.name,
      message:
          "Add a simple widget test to '${repo.name}' — Flutter makes it easy with flutter_test",
      reason: "No tests found",
      type: SuggestionType.addTests,
    );
  }
}
