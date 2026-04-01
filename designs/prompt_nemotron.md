# prompt_nemotron.md — NVIDIA Nemotron AI Suggestions (Privacy-Safe)

## Overview
Replace the rule-based suggestion engine with **NVIDIA Nemotron 3 Super (120B)** via **OpenRouter API**.
Only repo **metadata** is sent — zero code, zero file contents, zero commit history.

---

## API Setup

**Endpoint:** `https://openrouter.ai/api/v1/chat/completions`
**Model:** `nvidia/nemotron-3-super-120b-a12b:free`
**Auth:** OpenRouter API key (stored in `flutter_secure_storage` under key `openrouter_key`)

---

## New Service: `lib/services/nemotron_service.dart`

```dart
class NemotronService {
  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';
  static const _model = 'nvidia/nemotron-3-super-120b-a12b:free';

  /// Generate commit suggestions — metadata only, no code sent
  Future<List<Suggestion>> getSuggestions({
    required List<GitHubRepo> repos,
    required int currentStreak,
    required int todayContributions,
    required int daysSinceLastCommit,
    required String openRouterKey,
  });

  /// Generate heatmap summary — stats only, no code sent
  Future<String> getHeatmapSummary({
    required HeatmapStats stats,
    required String openRouterKey,
  });
}
```

---

## Suggestions Prompt (Metadata Only)

Build this prompt string — **never include code, file contents, or commit messages:**

```dart
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
```

---

## Heatmap Summary Prompt

```dart
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
```

---

## API Call Implementation

```dart
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
```

---

## Parse Suggestions Response

```dart
List<Suggestion> parseSuggestions(String rawJson) {
  try {
    // Strip markdown fences if present
    final clean = rawJson
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final List<dynamic> list = jsonDecode(clean);
    return list.map((item) => Suggestion(
      repoName: item['repo'] ?? 'General',
      message: item['message'] ?? '',
      reason: 'AI Suggested',
      type: SuggestionType.aiGenerated,
    )).toList();
  } catch (_) {
    // Fallback to rule-based if parsing fails
    return [];
  }
}
```

---

## Fallback Strategy

If Nemotron call fails for any reason → **silently fall back to rule-based engine**:

```dart
Future<List<Suggestion>> getSuggestions({...}) async {
  try {
    final prompt = buildSuggestionsPrompt(repos, streak, todayCommits);
    final raw = await _callNemotron(prompt, openRouterKey);
    final suggestions = parseSuggestions(raw);
    if (suggestions.isNotEmpty) return suggestions;
    // Empty response → fallback
    return _ruleEngine.generate(...);
  } catch (_) {
    return _ruleEngine.generate(...); // always works offline
  }
}
```

---

## Settings Screen — Add OpenRouter Key Input

Add a new section in `SettingsScreen`:

```
AI Suggestions
──────────────────────────
OpenRouter API Key   [Enter key] [👁]
Get free key at openrouter.ai
Status: ● Connected / ○ Not configured
```

- Store key via `flutter_secure_storage` key: `openrouter_key`
- If no key → use rule-based suggestions silently (no error shown to user)
- Validate key with a test ping on save

---

## Privacy Guarantee (show this in Settings UI)

```
🔒 Privacy: Only repo names, languages, and 
activity counts are sent to the AI. 
Your code is never shared.
```

---

## Files to Create / Modify

| Action | File |
|---|---|
| CREATE | `lib/services/nemotron_service.dart` |
| MODIFY | `lib/models/suggestion.dart` — add `aiGenerated` type |
| MODIFY | `lib/providers/suggestions_provider.dart` — use NemotronService with fallback |
| MODIFY | `lib/screens/settings_screen.dart` — add OpenRouter key input |
| MODIFY | `lib/screens/heatmap_screen.dart` — add AI summary section |
