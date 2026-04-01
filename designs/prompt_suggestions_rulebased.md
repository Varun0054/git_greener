# prompt_suggestions_rulbased.md — Rule-Based Commit Suggestions

## Context
Replace the AI API-based suggestions feature with a fully offline, rule-based suggestion engine.
No API key required. No external calls. Pure Dart logic.

---

## What to Build

Create a `SuggestionEngine` class in `lib/services/suggestion_engine.dart` that takes the user's
repo list and contribution data, applies a set of rules, and returns a list of `Suggestion` objects.

---

## Suggestion Model

```dart
class Suggestion {
  final String repoName;
  final String message;
  final String reason; // why this was suggested (shown as a small tag)
  final SuggestionType type;

  const Suggestion({
    required this.repoName,
    required this.message,
    required this.reason,
    required this.type,
  });
}

enum SuggestionType {
  addReadme,
  pushLocalChanges,
  updateDependencies,
  addTests,
  fixOpenIssue,
  updateDescription,
  reviveOldRepo,
  dailyCommit,
}
```

---

## SuggestionEngine Class

```dart
class SuggestionEngine {
  /// Pass in the list of repos from GitHub API and today's contribution count
  List<Suggestion> generate({
    required List<GitHubRepo> repos,
    required int todayContributions,
    required int currentStreak,
    required int daysSinceLastCommit,
  });
}
```

---

## Rules to Implement (in priority order)

### Rule 1 — No commit today yet
**Condition:** `todayContributions == 0`
**Suggestion:**
```
repo: most recently pushed repo
message: "Make a small improvement to <repo> — even a comment or doc fix counts!"
reason: "No commit yet today"
type: dailyCommit
```

### Rule 2 — Streak at risk
**Condition:** `currentStreak >= 3 && todayContributions == 0`
**Suggestion:**
```
repo: most recently pushed repo
message: "Your <N>-day streak is on the line! Push anything to <repo> to keep it alive 🔥"
reason: "Streak at risk"
type: dailyCommit
```
*(Show this above Rule 1 if streak >= 3)*

### Rule 3 — Repo has no README
**Condition:** `repo.hasReadme == false`
**Suggestion:**
```
repo: that repo's name
message: "Add a README.md to '<repo>' — it takes 5 minutes and makes your profile look polished"
reason: "Missing README"
type: addReadme
```

### Rule 4 — Repo has no description
**Condition:** `repo.description == null || repo.description.isEmpty`
**Suggestion:**
```
repo: that repo's name  
message: "Add a one-line description to '<repo>' on GitHub — helps people (and you) know what it's for"
reason: "No description"
type: updateDescription
```

### Rule 5 — Repo not touched in 30+ days
**Condition:** `repo.pushedAt` is more than 30 days ago
**Suggestion:**
```
repo: that repo's name
message: "Revive '<repo>' — it hasn't been touched in <N> days. Even a small refactor or cleanup commit helps"
reason: "Inactive 30+ days"
type: reviveOldRepo
```

### Rule 6 — Repo not touched in 7–30 days
**Condition:** `repo.pushedAt` is 7–30 days ago
**Suggestion:**
```
repo: that repo's name
message: "It's been a week since you touched '<repo>'. Push those local changes or add a small feature"
reason: "Inactive this week"
type: pushLocalChanges
```

### Rule 7 — Repo has open issues
**Condition:** `repo.openIssuesCount > 0`
**Suggestion:**
```
repo: that repo's name
message: "Fix one of the <N> open issues in '<repo>' — close an issue = a commit + progress!"
reason: "<N> open issues"
type: fixOpenIssue
```

### Rule 8 — Repo is a Dart/Flutter project (no tests detected)
**Condition:** `repo.language == 'Dart' && repo.name doesn't contain 'test'`
**Suggestion:**
```
repo: that repo's name
message: "Add a simple widget test to '<repo>' — Flutter makes it easy with flutter_test"
reason: "No tests found"
type: addTests
```

---

## Priority & Limit

- Max **5 suggestions** returned at a time
- Priority order: Rule 2 → Rule 1 → Rule 3 → Rule 7 → Rule 4 → Rule 5 → Rule 6 → Rule 8
- Never show duplicate repo in two consecutive suggestions
- If no rules match → return a default:
```
message: "Great job staying active! Try adding documentation or comments to any repo today."
reason: "All good!"
type: dailyCommit
```

---

## GitHub Repo Model (fields needed from API)

Fetch from: `GET https://api.github.com/user/repos?sort=pushed&per_page=20`

```dart
class GitHubRepo {
  final String name;
  final String? description;
  final String? language;
  final DateTime pushedAt;
  final int openIssuesCount;
  final bool hasReadme; // check via: GET /repos/{owner}/{repo}/readme → 404 means no readme
  final bool isPrivate;
  final bool isFork; // skip forks in suggestions
}
```

> **Note:** To check README existence, call `GET https://api.github.com/repos/{owner}/{repo}/readme`
> — if response is 200 → has readme, if 404 → no readme.
> Do this in parallel for the top 5 most recently pushed repos only (to avoid rate limits).

---

## UI for SuggestionsScreen

- Show a **"Refresh Suggestions"** button at top (re-runs the engine)
- Each `Suggestion` renders as a card:
```
┌─────────────────────────────────────┐
│ 📁 repo-name          [reason tag]  │
│                                     │
│ Suggestion message text here        │
│ that wraps to multiple lines        │
│                                     │
│                            [Copy ⎘] │
└─────────────────────────────────────┘
```
- `reason` shown as a small pill/chip (e.g. `"Streak at risk"`, `"Missing README"`)
- Copy button copies the suggestion message to clipboard
- No loading spinner needed (fully synchronous after repo data is fetched)
- Show "Fetching your repos..." shimmer only during the initial repo API call

---

## No AI, No API Key, No Internet (after repo fetch)

The suggestion engine runs **entirely in Dart** after the repo list is fetched.
Zero external calls during suggestion generation.
Works instantly. Works offline if repos are cached.
