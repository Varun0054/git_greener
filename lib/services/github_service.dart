import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/contribution_day.dart';
import '../models/github_repo.dart';

class GitHubService {
  static const String _graphqlUrl = 'https://api.github.com/graphql';
  static const String _restBaseUrl = 'https://api.github.com';

  /// Fetches UserProfile and ContributionDays
  Future<Map<String, dynamic>> fetchProfileData(String pat) async {
    const query = '''
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
    ''';

    final response = await http.post(
      Uri.parse(_graphqlUrl),
      headers: {
        'Authorization': 'bearer $pat',
        'User-Agent': 'GitHubGreener/1.0',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['errors'] != null) {
        throw Exception(jsonResponse['errors'][0]['message']);
      }
      
      final viewer = jsonResponse['data']['viewer'];
      final profile = UserProfile.fromJson(viewer);
      
      final calendar = viewer['contributionsCollection']['contributionCalendar'];
      final totalContributions = calendar['totalContributions'] as int;
      final weeks = calendar['weeks'] as List<dynamic>;
      
      final List<ContributionDay> days = [];
      for (final week in weeks) {
        final contributionDays = week['contributionDays'] as List<dynamic>;
        for (final day in contributionDays) {
          days.add(ContributionDay.fromJson(day as Map<String, dynamic>));
        }
      }

      return {
        'profile': profile,
        'totalContributions': totalContributions,
        'days': days,
      };
    } else if (response.statusCode == 401) {
      throw Exception('Invalid GitHub Personal Access Token');
    } else if (response.statusCode == 403 || response.statusCode == 429) {
      throw Exception('Rate limit reached, try again later');
    } else {
      throw Exception('Failed to fetch data from GitHub (Status: ${response.statusCode})');
    }
  }

  /// Fetches recently active repositories
  Future<List<GitHubRepo>> fetchRecentRepos(String pat) async {
    final response = await http.get(
      Uri.parse('$_restBaseUrl/user/repos?sort=pushed&per_page=10'),
      headers: {
        'Authorization': 'bearer $pat',
        'User-Agent': 'GitHubGreener/1.0',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      
      final List<GitHubRepo> repos = [];
      
      // Process only top 5 for README to avoid rate limits
      final top5 = data.take(5).toList();
      final readmeFutures = top5.map((repo) {
        final owner = repo['owner']['login'];
        final name = repo['name'];
        return http.get(
          Uri.parse('$_restBaseUrl/repos/$owner/$name/readme'),
          headers: {
             'Authorization': 'bearer $pat',
             'User-Agent': 'GitHubGreener/1.0',
             'Accept': 'application/vnd.github.v3+json',
          },
        ).then((res) => res.statusCode == 200).catchError((_) => false);
      }).toList();

      final hasReadmeResults = await Future.wait(readmeFutures);

      for (int i = 0; i < data.length; i++) {
         final repo = data[i];
         final owner = repo['owner']['login'];
         final name = repo['name'];
         
         bool hasReadme = false;
         if (i < 5) {
            hasReadme = hasReadmeResults[i];
         }

         repos.add(GitHubRepo(
           owner: owner,
           name: name,
           description: repo['description'],
           language: repo['language'],
           pushedAt: DateTime.parse(repo['pushed_at']),
           openIssuesCount: repo['open_issues_count'] ?? 0,
           hasReadme: hasReadme,
           isPrivate: repo['private'] ?? false,
           isFork: repo['fork'] ?? false,
         ));
      }
      return repos;
    } else {
      throw Exception('Failed to fetch recent repositories');
    }
  }
}
