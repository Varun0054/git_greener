# rules.md — GitHub Greener Build Rules

## Hard Rules (Never Break)

1. **No mock data** — Every piece of data must come from a real API call
2. **No PAT logging** — Never print, log, or expose the PAT anywhere
3. **Secure storage only** — PAT must be stored via `flutter_secure_storage`, never `SharedPreferences`
4. **Service layer** — All network calls go through `lib/services/`, never directly in screens or widgets
5. **Error handling** — Every API call must have a try/catch with user-facing error message and retry option
6. **Loading states** — Every async operation must show a loading indicator
7. **No hardcoded strings** — All UI text should be in constants or localization-ready

## Code Quality Rules

- Use `const` constructors everywhere possible
- Prefer `final` over `var`
- Use named parameters for constructors with more than 2 params
- All public methods/classes must have a brief doc comment
- No business logic in widget `build()` methods — use providers or services
- Separate models, services, providers, screens, widgets cleanly

## UI Rules

- Stick to the design tokens defined in `prompt.md`
- Use `DM Sans` font via Google Fonts package
- Contribution cell size: `11×11` logical pixels, gap: `2px`
- All cards: `BorderRadius.circular(8)`
- Bottom navigation: 3 items max
- No drawer — use bottom nav + settings icon

## API Rules

- GitHub GraphQL: always use `POST https://api.github.com/graphql`
- GitHub REST: use `https://api.github.com/` base URL
- Always pass `Authorization: bearer <PAT>` header
- Always pass `User-Agent: GitHubGreener/1.0` header
- Handle 401 → invalid token → redirect to onboarding
- Handle rate limit (403/429) → show "Rate limit reached, try again later"

## Flutter/Dart Version

- Target Flutter `3.19+` / Dart `3.3+`
- Min SDK: Android API 21, iOS 12.0
- Null safety: enabled (required)
