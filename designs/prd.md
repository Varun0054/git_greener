# PRD — GitHub Greener 🟩
**Version:** 1.0  
**Platform:** Flutter (iOS + Android)  
**Auth:** GitHub Personal Access Token (PAT)  
**Theme:** Clean Minimal Light

---

## 1. Overview

GitHub Greener is a mobile app that helps developers maintain a consistently green GitHub contribution graph. It visualizes contribution activity, tracks streaks, shows a heatmap, and uses AI to suggest what to commit — so your graph stays lush and green every day.

---

## 2. Goals

- Let users connect via GitHub PAT and instantly see their contribution data
- Visualize the GitHub-style contribution calendar (the green grid)
- Show commit streak stats and motivate daily activity
- Display an activity heatmap broken down by day/week/month
- AI-powered suggestions for small, meaningful commits to stay active

---

## 3. Target User

Developers who:
- Care about their GitHub profile appearance
- Want to build consistent coding habits
- Need nudges and reminders to commit daily

---

## 4. Core Features

### 4.1 Authentication
- User enters a GitHub Personal Access Token (PAT)
- Token stored securely using `flutter_secure_storage`
- Validate token via GitHub API on entry
- Show user avatar + username after login

### 4.2 Contribution Graph (Home Screen)
- Full-year contribution calendar grid (exactly like GitHub's)
- Cells colored in 5 shades: empty, light green → dark green
- Tap a cell → show tooltip with date + commit count
- Swipeable to view current year and previous year

### 4.3 Streak Tracker
- Current streak (consecutive days with ≥1 commit)
- Longest streak ever
- "Days active this year" count
- Streak flame icon that grows intensity based on streak length
- Local push notification: daily reminder at user-set time ("Don't break your streak! 🔥")

### 4.4 Activity Heatmap
- Bar chart or heatmap showing commits per:
  - Day of week (Mon–Sun)
  - Week of year
  - Month
- Toggle between the three views
- Highlight your most productive day/month

### 4.5 AI Commit Suggestions
- One-tap "What should I commit today?" button
- Sends context (languages used, repos, last commit date) to an AI API
- Returns 3–5 actionable suggestions like:
  - "Add a README to your `flutter-todo` repo"
  - "Fix that open issue in `portfolio-site`"
  - "Push your local WIP branch for `api-project`"
- Each suggestion has a copy button for easy use

### 4.6 Settings
- Manage PAT (update/revoke)
- Set daily reminder time
- Toggle notifications on/off
- Dark mode toggle (future)

---

## 5. Screens

| Screen | Description |
|---|---|
| `OnboardingScreen` | App intro + PAT input + validation |
| `HomeScreen` | Contribution graph + streak summary cards |
| `HeatmapScreen` | Detailed activity breakdown |
| `SuggestionsScreen` | AI commit suggestions |
| `SettingsScreen` | Token management + notifications |

---

## 6. Data & API

### GitHub GraphQL API
Endpoint: `https://api.github.com/graphql`

Query needed:
```graphql
{
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

### AI Suggestions API
- Use Anthropic Claude API (`claude-sonnet-4-20250514`) or OpenAI
- Send user's repo list + last commit info as context
- Parse response and display as suggestion cards

---

## 7. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Riverpod (or Provider) |
| HTTP | `dio` or `http` package |
| Secure Storage | `flutter_secure_storage` |
| Notifications | `flutter_local_notifications` |
| Charts/Heatmap | `fl_chart` or custom `CustomPainter` |
| Navigation | `go_router` |

---

## 8. Design Specs

- **Theme:** Clean minimal light
- **Primary color:** `#2DA44E` (GitHub green)
- **Background:** `#FFFFFF`
- **Surface:** `#F6F8FA` (GitHub's light gray)
- **Text primary:** `#1F2328`
- **Text secondary:** `#636C76`
- **Font:** `DM Sans` or `Inter`
- **Contribution cell colors:** `#EBEDF0`, `#9BE9A8`, `#40C463`, `#30A14E`, `#216E39`
- Corner radius: `8px` for cards, `2px` for contribution cells

---

## 9. Non-Functional Requirements

- App loads contribution data within 2 seconds on good network
- PAT never sent to any third-party except GitHub + AI API
- Offline mode: show cached last-fetched data with a stale banner
- Accessibility: all interactive elements have semantic labels

---

## 10. Out of Scope (v1)

- OAuth login (PAT only for now)
- Creating/pushing actual commits from the app
- Social/leaderboard features
- Widget on home screen (future)
