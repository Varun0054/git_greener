class UserProfile {
  final String login;
  final String avatarUrl;

  const UserProfile({
    required this.login,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }
}
