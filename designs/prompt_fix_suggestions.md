# prompt_fix_suggestions.md — Fix Suggestions Screen (3 Issues)

## Problems to Fix

1. **All cards show the same rule** — every repo shows "Missing README" repeatedly
2. **No variety in suggestions** — rule engine not diversifying across rule types
3. **No acknowledgement after Contribute** — page just silently refreshes

---

## Fix 1 & 2 — Suggestion Engine Diversity

### File: `lib/services/suggestion_engine.dart`

**Current broken behaviour:**
- Rule 3 (Missing README) fires for EVERY repo → 8 identical cards
- Same rule type appears unlimited times
- No cap per rule type

**Fix — rewrite the generate() method logic:**

```
RULE: Each repo can only match ONE rule (highest priority that applies).
RULE: Same rule type can appear MAX 2 times in final output.
RULE: Final list must have variety — spread across different rule types.
RULE: Max 5 suggestions total.
```

**New algorithm:**

```dart
List<Suggestion> generate({...}) {
  final result = <Suggestion>[];
  final usedRepos = <String>{};
  final ruleTypeCounts = <SuggestionType, int>{};

  // Step 1 — Rule 2: Streak at risk (only for repos.first)
  if (currentStreak >= 3 && todayContributions == 0) {
    result.add(streakAtRiskSuggestion(repos.first));
    usedRepos.add(repos.first.name);
    ruleTypeCounts[SuggestionType.dailyCommit] = 1;
  }

  // Step 2 — Rule 1: No commit today (only for repos.first, skip if Rule 2 already added)
  else if (todayContributions == 0 && repos.isNotEmpty) {
    result.add(noCommitTodaySuggestion(repos.first));
    usedRepos.add(repos.first.name);
    ruleTypeCounts[SuggestionType.dailyCommit] = 1;
  }

  // Step 3 — Apply remaining rules across repos, enforcing caps
  final remainingRules = [
    _tryRule3MissingReadme,   // cap: 2
    _tryRule7OpenIssues,      // cap: 2
    _tryRule5InactiveOld,     // cap: 1
    _tryRule6InactiveRecent,  // cap: 1
    _tryRule4NoDescription,   // cap: 1
    _tryRule8NoTests,         // cap: 1
  ];

  for (final repo in repos) {
    if (result.length >= 5) break;
    if (usedRepos.contains(repo.name)) continue;
    if (repo.isFork) continue;

    for (final rule in remainingRules) {
      if (result.length >= 5) break;
      final suggestion = rule(repo, ruleTypeCounts);
      if (suggestion != null) {
        result.add(suggestion);
        usedRepos.add(repo.name);
        ruleTypeCounts[suggestion.type] =
            (ruleTypeCounts[suggestion.type] ?? 0) + 1;
        break; // only ONE rule per repo
      }
    }
  }

  // Step 4 — Fallback if still empty
  if (result.isEmpty) {
    result.add(Suggestion(
      repoName: 'General',
      message: 'Great job staying active! Try adding documentation or comments to any repo today.',
      reason: 'All good!',
      type: SuggestionType.dailyCommit,
    ));
  }

  return result;
}

/// Helper — returns null if rule type cap is reached
Suggestion? _tryRule3MissingReadme(GitHubRepo repo, Map<SuggestionType, int> counts) {
  final cap = 2;
  if ((counts[SuggestionType.addReadme] ?? 0) >= cap) return null;
  if (repo.hasReadme) return null;
  return Suggestion(
    repoName: repo.name,
    message: "Add a README.md to '${repo.name}' — it takes 5 minutes and makes your profile look polished",
    reason: 'Missing README',
    type: SuggestionType.addReadme,
  );
}

/// Similar pattern for all other rules — cap enforced via counts map
```

**Expected output after fix — varied mix like:**
```
Card 1: stopwatchApp       → "Missing README"         (Rule 3)
Card 2: my-api-project     → "3 open issues"          (Rule 7)
Card 3: old-portfolio      → "Inactive 31 days"       (Rule 5)
Card 4: flutter-todo       → "No description"         (Rule 4)
Card 5: android-app        → "Missing README"         (Rule 3 — 2nd allowed)
```

---

## Fix 3 — Contribute Success Dialog

### File: `lib/widgets/suggestion_card.dart`

**Current broken behaviour:**
- After successful contribute → page silently refreshes
- User has no idea if it worked

**Fix — show a celebratory dialog on success:**

### Dialog Spec

```
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => ContributeSuccessDialog(
    repoName: repoName,
    commitUrl: result.commitUrl,
    onDone: () {
      Navigator.pop(context);       // close dialog
      ref.refresh(suggestionsProvider); // THEN refresh
    },
  ),
);
```

### ContributeSuccessDialog Widget

Create `lib/widgets/contribute_success_dialog.dart`:

```
┌─────────────────────────────────────┐
│  ▬▬▬▬▬▬▬▬▬  (green top accent bar) │
│                                     │
│         🟩  🟩  🟩                  │  ← staggered fade-in animation
│                                     │
│      Contribution Made! 🎉          │  ← bold title
│                                     │
│   Successfully committed to         │
│   '{repoName}'                      │  ← repo name in green bold
│                                     │
│   Your GitHub graph just got        │
│   a little greener today!           │
│                                     │
│  ┌──────────────┐ ┌──────────────┐  │
│  │ View Commit↗ │ │     Done     │  │  ← two buttons
│  └──────────────┘ └──────────────┘  │
└─────────────────────────────────────┘
```

### Dialog Implementation Details

```dart
class ContributeSuccessDialog extends StatefulWidget {
  final String repoName;
  final String? commitUrl;  // nullable — hide View Commit if null
  final VoidCallback onDone;
}

class _ContributeSuccessDialogState extends State<ContributeSuccessDialog>
    with TickerProviderStateMixin {

  // Stagger animate the 3 green squares on dialog open
  late List<AnimationController> _squareControllers;

  @override
  void initState() {
    super.initState();
    _squareControllers = List.generate(3, (i) =>
      AnimationController(vsync: this, duration: Duration(milliseconds: 300))
    );
    // Stagger: 0ms, 150ms, 300ms delays
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _squareControllers[i].forward();
      });
    }
  }
}
```

### Styling
- Top accent bar: `height: 5`, `color: Color(0xFF2DA44E)`, full width
- Green squares: `28×28` size, `BorderRadius.circular(4)`, color `#2DA44E`
- Repo name: `color: Color(0xFF2DA44E)`, `fontWeight: FontWeight.bold`
- "View Commit" button: outlined green border
- "Done" button: filled green
- Dialog shape: `RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))`
- No `barrierDismissible` — user must tap Done or View Commit

### "View Commit" Button
```dart
// Add url_launcher to pubspec.yaml if not present
// dependencies:
//   url_launcher: ^6.2.0

onPressed: () async {
  if (widget.commitUrl != null) {
    await launchUrl(
      Uri.parse(widget.commitUrl!),
      mode: LaunchMode.externalApplication,
    );
  }
}
```

### Hide "View Commit" if commitUrl is null
```dart
if (widget.commitUrl != null)
  OutlinedButton(...)  // show only when URL exists
```

---

## Files to Create / Modify

| Action | File |
|---|---|
| MODIFY | `lib/services/suggestion_engine.dart` — fix rule diversity logic |
| MODIFY | `lib/widgets/suggestion_card.dart` — trigger dialog on success |
| CREATE | `lib/widgets/contribute_success_dialog.dart` — new dialog widget |
| MODIFY | `pubspec.yaml` — add `url_launcher: ^6.2.0` if not present |

---

## Testing Checklist

- [ ] Suggestions show varied rule types — not all "Missing README"
- [ ] Same rule type appears max 2 times in list of 5
- [ ] Each repo appears only once across all cards
- [ ] Tapping Contribute shows the success dialog
- [ ] 🟩🟩🟩 squares animate in with stagger on dialog open
- [ ] "View Commit" opens browser to commit URL
- [ ] "Done" closes dialog then refreshes suggestions
- [ ] If commitUrl is null, "View Commit" button is hidden
