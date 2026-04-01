# prompt_heatmap_enhanced.md — Enhanced Heatmap Screen

## Overview
Upgrade the Heatmap screen from a single bar chart to a rich, multi-section analytics dashboard
with 3 chart types + an AI-generated natural language summary powered by Nemotron.

---

## Screen Layout

```
┌─────────────────────────────────────┐
│  ← Activity Analytics               │
├─────────────────────────────────────┤
│                                     │
│  🤖 AI Summary          [Generate] │  ← Nemotron summary section
│  ┌─────────────────────────────┐   │
│  │ "You've been most active on │   │
│  │  Wednesdays with an avg of  │   │
│  │  3.2 commits. Your 14-day   │   │
│  │  streak is your 2nd best..."│   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  📅 Calendar Heatmap                │  ← Section 1
│  [mini 3-month rolling heatmap]     │
├─────────────────────────────────────┤
│  🕸️ Day of Week Radar               │  ← Section 2
│  [radar/spider chart]               │
├─────────────────────────────────────┤
│  🍩 Commits by Language             │  ← Section 3
│  [donut chart]                      │
└─────────────────────────────────────┘
```

Sections are in a **ScrollView** — user scrolls down through all charts.
No tabs. No toggles. All visible at once.

---

## Section 1 — Calendar Mini-Heatmap

### What it shows
A compact 3-month rolling contribution heatmap (last 90 days), similar to GitHub's graph
but smaller and focused on recent activity.

### Implementation
Use `CustomPainter` — draw a grid of small squares:
- 13 columns (weeks) × 7 rows (days)
- Cell size: `14×14` logical pixels, gap: `3px`
- Same 5-color scale as main graph: `#EBEDF0 → #216E39`
- Show month labels above columns
- Show day labels (M W F) on left side
- Tap a cell → show `Tooltip` with date + count

### Data
Slice the last 90 days from `contributionDays` already fetched by `contributionsProvider`.

---

## Section 2 — Day of Week Radar Chart

### What it shows
A spider/radar chart showing average commits for each day of the week (Mon–Sun).
Instantly shows if the user is a "weekday warrior" or "weekend coder".

### Implementation
Use `fl_chart` `RadarChart`:

```dart
RadarChart(
  RadarChartData(
    dataSets: [
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: avgMonday),
          RadarEntry(value: avgTuesday),
          RadarEntry(value: avgWednesday),
          RadarEntry(value: avgThursday),
          RadarEntry(value: avgFriday),
          RadarEntry(value: avgSaturday),
          RadarEntry(value: avgSunday),
        ],
        fillColor: Color(0xFF2DA44E).withOpacity(0.3),
        borderColor: Color(0xFF2DA44E),
        borderWidth: 2,
      )
    ],
    titles: RadarChartTitle(
      getTitles: (angle, index) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][index],
    ),
    radarBackgroundColor: Colors.transparent,
    gridBorderData: BorderSide(color: Color(0xFFEBEDF0), width: 1),
    tickBorderData: BorderSide(color: Color(0xFFEBEDF0), width: 1),
    tickCount: 4,
  ),
)
```

### Data calculation
```dart
Map<int, double> avgByWeekday(List<ContributionDay> days) {
  // weekday: 1=Mon ... 7=Sun
  final totals = <int, int>{};
  final counts = <int, int>{};
  for (final day in days) {
    final wd = DateTime.parse(day.date).weekday;
    totals[wd] = (totals[wd] ?? 0) + day.contributionCount;
    counts[wd] = (counts[wd] ?? 0) + 1;
  }
  return {
    for (final wd in totals.keys)
      wd: counts[wd]! > 0 ? totals[wd]! / counts[wd]! : 0.0
  };
}
```

### Insight chip below chart
```
🏆 Most active: Wednesday (avg 3.2 commits)
😴 Least active: Sunday (avg 0.4 commits)
```

---

## Section 3 — Commits by Language Donut Chart

### What it shows
A donut chart breaking down the user's repos by programming language,
sized by number of repos (not commits — we don't have that granularity).

### Implementation
Use `fl_chart` `PieChart` in donut mode:

```dart
PieChart(
  PieChartData(
    sectionsSpace: 3,
    centerSpaceRadius: 55,
    sections: languageData.entries.map((e) {
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '',               // no title inside slice
        color: colorForLanguage(e.key),
        radius: 45,
      );
    }).toList(),
  ),
)
```

Show a **legend** below the chart:
```
● Dart      8 repos
● Python    3 repos  
● JavaScript 2 repos
● HTML      1 repo
```

### Language color mapping
```dart
Color colorForLanguage(String lang) {
  return switch (lang.toLowerCase()) {
    'dart'       => Color(0xFF00B4AB),
    'python'     => Color(0xFF3572A5),
    'javascript' => Color(0xFFF1E05A),
    'typescript' => Color(0xFF2B7489),
    'java'       => Color(0xFFB07219),
    'kotlin'     => Color(0xFFA97BFF),
    'swift'      => Color(0xFFFF5733),
    'html'       => Color(0xFFE34C26),
    'css'        => Color(0xFF563D7C),
    'go'         => Color(0xFF00ADD8),
    'rust'       => Color(0xFFDEA584),
    _            => Color(0xFF636C76), // gray for unknown
  };
}
```

### Data source
Fetch from already-loaded repo list — group by `repo.language`, count repos per language.
Skip `null` languages and forks.

---

## AI Summary Section (Nemotron)

### Location
At the **top** of the screen, above all charts — first thing user sees.

### UI
```
┌─────────────────────────────────────────┐
│ 🤖 Your Activity Summary               │
│                                         │
│ [Generate Summary]   ← green button     │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Summary text appears here after     │ │  ← card, shows after generation
│ │ tapping the button. 3 sentences     │ │
│ │ of insight from Nemotron.           │ │
│ └─────────────────────────────────────┘ │
│                          🔒 Metadata only│  ← small privacy label
└─────────────────────────────────────────┘
```

### Button states
| State | UI |
|---|---|
| Idle (no key) | Button hidden, show `"Add OpenRouter key in Settings for AI insights"` |
| Idle (key set) | `"✨ Generate Summary"` green button |
| Loading | `CircularProgressIndicator` + `"Analysing your activity..."` |
| Success | Summary card fades in, button becomes `"🔄 Regenerate"` |
| Error | Snackbar with error, button resets |

### HeatmapStats model to build and pass to NemotronService
```dart
class HeatmapStats {
  final int totalContributions;
  final int currentStreak;
  final int longestStreak;
  final String mostActiveDay;     // e.g. "Wednesday"
  final String leastActiveDay;    // e.g. "Sunday"
  final String mostActiveMonth;   // e.g. "October"
  final double avgCommitsPerDay;
  final String topLanguage;
  final int zeroWeeks;            // weeks with 0 commits
  final int bestWeekCount;        // highest commits in a single week
}
```

---

## Stats Cards Row (add above charts)

Add a quick stats summary row at the top of the screen (below AI section):

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│   342    │ │    14    │ │    47    │ │  Wed     │
│  Total   │ │ Current  │ │ Longest  │ │ Best Day │
│ Commits  │ │ Streak   │ │ Streak   │ │          │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

Small cards in a horizontal `Row`, each with a number + label.

---

## Package Requirements

Make sure these are in `pubspec.yaml`:
```yaml
fl_chart: ^0.68.0        # RadarChart + PieChart + BarChart
```

No new packages needed — `fl_chart` handles all three chart types.

---

## Files to Create / Modify

| Action | File |
|---|---|
| MODIFY | `lib/screens/heatmap_screen.dart` — full rebuild of screen |
| CREATE | `lib/widgets/calendar_mini_heatmap.dart` — CustomPainter widget |
| CREATE | `lib/widgets/radar_chart_widget.dart` — day of week radar |
| CREATE | `lib/widgets/language_donut_chart.dart` — language breakdown |
| CREATE | `lib/widgets/ai_summary_card.dart` — Nemotron summary UI |
| CREATE | `lib/models/heatmap_stats.dart` — stats model |
| MODIFY | `lib/providers/contributions_provider.dart` — expose HeatmapStats |
