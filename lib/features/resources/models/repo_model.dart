import 'package:flutter/material.dart';

class GitHubRepo {
  final String owner;
  final String repo;
  final String desc;
  final String stars;
  final String url;
  final String? subcategoryId;

  const GitHubRepo({
    required this.owner,
    required this.repo,
    required this.desc,
    required this.stars,
    required this.url,
    this.subcategoryId,
  });

  String get fullName => '$owner/$repo';
  String get githubApiUrl => 'https://api.github.com/repos/$owner/$repo';

  factory GitHubRepo.fromJson(Map<String, dynamic> json,
      {String? subcategoryId}) {
    return GitHubRepo(
      owner: json['owner'] as String,
      repo: json['repo'] as String,
      desc: json['desc'] as String,
      stars: json['stars'] as String,
      url: json['url'] as String,
      subcategoryId: subcategoryId,
    );
  }
}

class RepoSubcategory {
  final String id;
  final String label;
  final List<GitHubRepo> repos;

  const RepoSubcategory({
    required this.id,
    required this.label,
    required this.repos,
  });

  factory RepoSubcategory.fromJson(Map<String, dynamic> json) {
    final reposList = (json['repos'] as List)
        .map((r) => GitHubRepo.fromJson(r as Map<String, dynamic>,
            subcategoryId: json['id'] as String))
        .toList();
    return RepoSubcategory(
      id: json['id'] as String,
      label: json['label'] as String,
      repos: reposList,
    );
  }
}

class RepoCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final List<RepoSubcategory> subcategories;

  const RepoCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    required this.subcategories,
  });

  List<GitHubRepo> get allRepos =>
      subcategories.expand((s) => s.repos).toList();

  factory RepoCategory.fromJson(Map<String, dynamic> json) {
    final colorHex = (json['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));
    return RepoCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      color: color,
      subcategories: (json['subcategories'] as List)
          .map((s) => RepoSubcategory.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReposData {
  final List<RepoCategory> categories;
  final List<String> featuredKeys;
  final Map<String, List<String>> byRoadmap;

  const ReposData({
    required this.categories,
    required this.featuredKeys,
    required this.byRoadmap,
  });

  List<GitHubRepo> get allRepos =>
      categories.expand((c) => c.allRepos).toList();

  List<GitHubRepo> get featured {
    final all = allRepos;
    return featuredKeys
        .map((key) => all.firstWhere(
              (r) => r.fullName == key,
              orElse: () => GitHubRepo(
                  owner: '', repo: key, desc: '', stars: '', url: ''),
            ))
        .where((r) => r.owner.isNotEmpty)
        .toList();
  }

  List<GitHubRepo> forRoadmap(String roadmapId) {
    final keys = byRoadmap[roadmapId] ?? [];
    final all = allRepos;
    return keys
        .map((key) => all.firstWhere(
              (r) => r.fullName == key,
              orElse: () => GitHubRepo(
                  owner: '', repo: key, desc: '', stars: '', url: ''),
            ))
        .where((r) => r.owner.isNotEmpty)
        .toList();
  }

  factory ReposData.fromJson(Map<String, dynamic> json) {
    return ReposData(
      categories: (json['categories'] as List)
          .map((c) => RepoCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      featuredKeys: List<String>.from(json['featured'] as List),
      byRoadmap: (json['by_roadmap'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ),
    );
  }
}
