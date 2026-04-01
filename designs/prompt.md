# prompt.md — GitHub Greener Flutter App

## Role
You are an expert Flutter developer. Build a production-ready Flutter mobile app called **GitHub Greener** based on the PRD provided.

---

## App Summary
A GitHub contribution graph tracker app. Users log in with a GitHub PAT, see their full-year green contribution calendar, track streaks, view a commit activity heatmap, and get AI-powered suggestions for what to commit today — all in a clean minimal light UI.

---

## What to Build

Build the complete Flutter app with the following screens and features:

### Screens
1. **OnboardingScreen** — PAT input, validate via GitHub API, show username/avatar on success, navigate to Home
2. **HomeScreen** — Contribution graph grid (full year) + streak cards (current streak, longest streak, total contributions)
3. **HeatmapScreen** — Commit activity breakdown by day-of-week / week / month with toggle
4. **SuggestionsScreen** — "Suggest commits" button → calls AI API → shows 3–5 suggestion cards with copy button
5. **SettingsScreen** — Update PAT, set notification time, toggle reminders

### Key Implementation Details

**Contribution Graph:**
- Use `CustomPainter` or a grid of colored `Container` widgets
- 53 columns × 7 rows (weeks × days)
- 5 color levels: `#EBEDF0`, `#9BE9A8`, `#40C463`, `#30A14E`, `#216E39`
- Tap a cell → `Tooltip` or bottom sheet with date + count
- Fetch via GitHub GraphQL API

**GitHub GraphQL Query:**
```graphql
query {
  viewer {
    login
    avatarUrl
    contributionsCollection {
      contributionCalendar {
        totalContributions
        weeks {
          contributionDays {
            date
            contributionCount
            color
          }
        }
      }
    }
  }
}
```
Endpoint: `POST https://api.github.com/graphql`  
Header: `Authorization: bearer <PAT>`

**Streak Logic:**
- Parse sorted `contributionDays`
- Walk backwards from today counting consecutive days with count > 0
- Store longest streak by walking full array

**Heatmap:**
- Use `fl_chart` BarChart
- Group contribution data by selected dimension (day of week / week / month)
- Show toggle chips at top to switch view

**AI Suggestions:**
- Fetch user's repos: `GET https://api.github.com/user/repos?sort=pushed&per_page=10`
- Build prompt: *"The user is a developer. Their recently active repos are: [repo names + languages]. Their last commit was [X days ago]. Suggest 4 specific, small, actionable things they can commit today to keep their GitHub contribution graph active. Be specific and practical."*
- Call Anthropic Claude API or OpenAI API
- Display as cards with repo tag + suggestion text + copy icon

**Notifications:**
- Use `flutter_local_notifications`
- Schedule daily notification at user-set time
- Message: *"Hey! Don't forget to commit something today 🟩 Keep that streak alive!"*

**Secure Storage:**
- Store PAT using `flutter_secure_storage`
- Key: `github_pat`
- Load on app start, skip onboarding if valid token exists

---

## Tech Stack

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  http: ^1.2.0
  fl_chart: ^0.68.0
  flutter_local_notifications: ^17.0.0
  go_router: ^13.0.0
  riverpod: ^2.5.0
  flutter_riverpod: ^2.5.0
  intl: ^0.19.0
  cached_network_image: ^3.3.0
```

---

## Design Tokens

```dart
// Colors
const Color kGreen0 = Color(0xFFEBEDF0); // empty
const Color kGreen1 = Color(0xFF9BE9A8);
const Color kGreen2 = Color(0xFF40C463);
const Color kGreen3 = Color(0xFF30A14E);
const Color kGreen4 = Color(0xFF216E39); // darkest
const Color kPrimary = Color(0xFF2DA44E);
const Color kBackground = Color(0xFFFFFFFF);
const Color kSurface = Color(0xFFF6F8FA);
const Color kTextPrimary = Color(0xFF1F2328);
const Color kTextSecondary = Color(0xFF636C76);

// Typography: DM Sans
// Card border radius: 8px
// Cell size: ~11x11px with 2px gap
```

---

## Folder Structure

```
lib/
├── main.dart
├── app.dart                  # GoRouter setup
├── models/
│   ├── contribution_day.dart
│   ├── user_profile.dart
│   └── suggestion.dart
├── services/
│   ├── github_service.dart   # All GitHub API calls
│   ├── ai_service.dart       # AI suggestion calls
│   └── storage_service.dart  # flutter_secure_storage wrapper
├── providers/
│   ├── auth_provider.dart
│   ├── contributions_provider.dart
│   └── suggestions_provider.dart
├── screens/
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── heatmap_screen.dart
│   ├── suggestions_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── contribution_graph.dart   # The green grid
    ├── streak_card.dart
    ├── heatmap_chart.dart
    └── suggestion_card.dart
```

---

## Constraints & Rules

- DO NOT use any mock/hardcoded data — all data must come from real API calls
- Handle loading states with shimmer or circular progress indicators
- Handle errors gracefully with retry buttons
- PAT must never be logged or sent anywhere except GitHub API and AI API
- App must work on both iOS and Android
- Use `const` constructors wherever possible for performance
- All API calls go through the service layer — no direct http calls in screens
