class GitHubRepo {
  final String owner;
  final String name;
  final String? description;
  final String? language;
  final DateTime pushedAt;
  final int openIssuesCount;
  final bool hasReadme;
  final bool isPrivate;
  final bool isFork;

  GitHubRepo({
    required this.owner,
    required this.name,
    this.description,
    this.language,
    required this.pushedAt,
    required this.openIssuesCount,
    required this.hasReadme,
    required this.isPrivate,
    required this.isFork,
  });
}
