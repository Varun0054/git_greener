enum SuggestionType {
  addReadme,
  pushLocalChanges,
  updateDependencies,
  addTests,
  fixOpenIssue,
  updateDescription,
  reviveOldRepo,
  dailyCommit,
  aiGenerated,
}

class Suggestion {
  final String owner;
  final String repoName;
  final String message;
  final String reason;
  final SuggestionType type;

  const Suggestion({
    required this.owner,
    required this.repoName,
    required this.message,
    required this.reason,
    required this.type,
  });
}
