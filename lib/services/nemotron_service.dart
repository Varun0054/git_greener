import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/suggestion.dart';
import '../models/github_repo.dart';
import '../models/heatmap_stats.dart';
import 'suggestion_engine.dart';

class NemotronService {
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'nvidia/nemotron-3-super-120b-a12b:free';

  final SuggestionEngine _ruleEngine = SuggestionEngine();

  String buildSuggestionsPrompt(List<GitHubRepo> repos, int streak, int todayCommits) {
    final repoLines = repos.take(8).map((r) {
      final daysAgo = DateTime.now().difference(r.pushedAt).inDays;
      return '- ${r.name} | ${r.language ?? 'Unknown'} | pushed ${daysAgo}d ago'
          ' | ${r.openIssuesCount} issues | README: ${r.hasReadme}';
    }).join('\n');

    return '''
You are a coding productivity coach. Based ONLY on this GitHub metadata, suggest 4 specific actionable commits the developer can make today to keep their contribution graph active.

STRICT RULES:
- Never ask for or reference any code
- Never reference file contents or commit history
- Base suggestions only on the metadata below
- Each suggestion must be short (1 sentence max)
- Format: JSON array of objects with "repo" and "message" fields only

Developer stats:
- Current streak: $streak days
- Commits today: $todayCommits
- Days since last commit: ${todayCommits == 0 ? DateTime.now().hour ~/ 24 + 1 : 0}

Repos (name | language | last pushed | open issues | has README):
$repoLines

Respond ONLY with a valid JSON array. Example:
[
  {"repo": "my-app", "message": "Add input validation to the login form"},
  {"repo": "portfolio", "message": "Add a README with project description"}
]
''';
  }

  String buildHeatmapSummaryPrompt(HeatmapStats stats) {
    return '''
You are a developer productivity analyst. Write a short, friendly 3-sentence summary 
of this developer's GitHub activity patterns. Be encouraging and specific.
No code. Numbers only.

Activity data:
- Total contributions this year: ${stats.totalContributions}
- Current streak: ${stats.currentStreak} days
- Longest streak: ${stats.longestStreak} days
- Most active day of week: ${stats.mostActiveDay}
- Most active month: ${stats.mostActiveMonth}
- Average commits per active day: ${stats.avgCommitsPerDay}
- Most used language: ${stats.topLanguage}
- Least active day: ${stats.leastActiveDay}
- Weeks with zero activity: ${stats.zeroWeeks}
- Best week (commit count): ${stats.bestWeekCount}

Write exactly 3 sentences. Be specific with the numbers. End with one motivational line.
''';
  }

  Future<String> _callNemotron(String prompt, String apiKey) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'github-greener-app',
        'X-Title': 'GitHub Greener',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit reached. Try again in a moment.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid OpenRouter API key.');
    } else {
      throw Exception('AI unavailable (${response.statusCode})');
    }
  }

  List<Suggestion> parseSuggestions(String rawJson) {
    try {
      final clean = rawJson
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> list = jsonDecode(clean);
      return list.map((item) => Suggestion(
        owner: '', // AI doesn't provide owner, usually not needed for suggestion list display
        repoName: item['repo'] ?? 'General',
        message: item['message'] ?? '',
        reason: 'AI Suggested',
        type: SuggestionType.aiGenerated,
      )).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Suggestion>> getSuggestions({
    required List<GitHubRepo> repos,
    required int currentStreak,
    required int todayContributions,
    required int daysSinceLastCommit,
    required String? openRouterKey,
  }) async {
    if (openRouterKey == null || openRouterKey.isEmpty) {
      return _ruleEngine.generate(
        repos: repos,
        todayContributions: todayContributions,
        currentStreak: currentStreak,
        daysSinceLastCommit: daysSinceLastCommit,
      );
    }

    try {
      final prompt = buildSuggestionsPrompt(repos, currentStreak, todayContributions);
      final raw = await _callNemotron(prompt, openRouterKey);
      final suggestions = parseSuggestions(raw);
      if (suggestions.isNotEmpty) return suggestions;
      return _ruleEngine.generate(
        repos: repos,
        todayContributions: todayContributions,
        currentStreak: currentStreak,
        daysSinceLastCommit: daysSinceLastCommit,
      );
    } catch (_) {
      return _ruleEngine.generate(
        repos: repos,
        todayContributions: todayContributions,
        currentStreak: currentStreak,
        daysSinceLastCommit: daysSinceLastCommit,
      );
    }
  }

  Future<String> getHeatmapSummary({
    required HeatmapStats stats,
    required String openRouterKey,
  }) async {
    final prompt = buildHeatmapSummaryPrompt(stats);
    return await _callNemotron(prompt, openRouterKey);
  }
}
