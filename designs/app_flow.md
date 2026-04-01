# app_flow.md — GitHub Greener Screen Flow

## User Journey

```
App Launch
    │
    ▼
[Has saved PAT?]
    │
    ├── NO  ──▶  OnboardingScreen
    │               │
    │           Enter PAT
    │               │
    │           Validate via GitHub API
    │               │
    │           ✅ Success → Save PAT → HomeScreen
    │           ❌ Fail   → Show error, retry
    │
    └── YES ──▶  HomeScreen (auto-login)
```

---

## HomeScreen Layout

```
┌─────────────────────────────────┐
│  👤 @username          ⚙️       │  ← top bar
├─────────────────────────────────┤
│  🔥 42 day streak               │
│  ┌──────┐ ┌──────┐ ┌──────┐    │
│  │Current│ │Longest│ │ Total│   │  ← streak cards
│  │streak │ │streak │ │contribs│  │
│  └──────┘ └──────┘ └──────┘    │
├─────────────────────────────────┤
│  Contribution Graph             │
│  Jan Feb Mar Apr May ...        │
│  ░░▒▒▓▓██░░▒▒▓▓██░░▒▒▓▓██░░   │  ← green grid
│  ░░▒▒▓▓██░░▒▒▓▓██░░▒▒▓▓██░░   │
│  (53 cols × 7 rows)             │
├─────────────────────────────────┤
│  [📊 Heatmap] [💡 Suggestions] │  ← bottom nav shortcuts
└─────────────────────────────────┘
```

---

## HeatmapScreen Layout

```
┌─────────────────────────────────┐
│  ← Activity Heatmap             │
├─────────────────────────────────┤
│  [By Day] [By Week] [By Month]  │  ← toggle chips
├─────────────────────────────────┤
│                                 │
│   ▁▂▃▅▇█▅▃▂▁▂▃▅▇█▅▃           │  ← bar chart
│   Mon Tue Wed Thu Fri Sat Sun   │
│                                 │
│  🏆 Most active: Wednesday      │
│  📅 Best month: October         │
└─────────────────────────────────┘
```

---

## SuggestionsScreen Layout

```
┌─────────────────────────────────┐
│  ← What to commit today? 💡     │
├─────────────────────────────────┤
│                                 │
│   [✨ Generate Suggestions]     │  ← big CTA button
│                                 │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ 📁 flutter-todo           │  │
│  │ Add unit tests for the    │  │  ← suggestion card
│  │ task completion logic     │  │
│  │                    [Copy] │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │ 📁 portfolio-site         │  │
│  │ Update the projects       │  │  ← suggestion card
│  │ section with new work     │  │
│  │                    [Copy] │  │
│  └───────────────────────────┘  │
│  (3–5 cards total)              │
└─────────────────────────────────┘
```

---

## SettingsScreen Layout

```
┌─────────────────────────────────┐
│  ← Settings ⚙️                  │
├─────────────────────────────────┤
│  Account                        │
│  ──────────────────────────     │
│  GitHub Token   [Update] [👁]   │
│  @username · Connected ✅       │
│                                 │
│  Notifications                  │
│  ──────────────────────────     │
│  Daily Reminder    [Toggle ON]  │
│  Reminder Time     [9:00 PM  ▼] │
│                                 │
│  About                          │
│  ──────────────────────────     │
│  Version 1.0.0                  │
│  Made with 🟩 by GitHub Greener │
└─────────────────────────────────┘
```

---

## Navigation Structure

- Bottom navigation bar with 3 tabs: **Home**, **Heatmap**, **Suggestions**
- Settings reachable via icon in top-right of HomeScreen
- Onboarding is a standalone full-screen flow (no nav bar)

---

## State Management Flow (Riverpod)

```
authProvider
    └── watches StorageService for PAT
    └── fetches GitHub profile on PAT change

contributionsProvider
    └── depends on authProvider
    └── calls GitHubService.fetchContributions()
    └── exposes: contributionDays, streakData, heatmapData

suggestionsProvider
    └── depends on authProvider
    └── calls AiService.getSuggestions(repoList)
    └── exposes: suggestions, isLoading, error
```
