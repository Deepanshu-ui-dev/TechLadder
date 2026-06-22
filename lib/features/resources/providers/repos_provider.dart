import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/repo_model.dart';

final reposDataProvider = FutureProvider<ReposData>((ref) async {
  final jsonStr =
      await rootBundle.loadString('assets/data/github_repos_data.json');
  final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
  return ReposData.fromJson(decoded);
});

// Filtered repos by category
final reposByCategoryProvider =
    Provider.family<AsyncValue<RepoCategory?>, String>((ref, categoryId) {
  return ref.watch(reposDataProvider).whenData(
        (data) => data.categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => throw Exception('Category not found: $categoryId'),
        ),
      );
});

// Repos for a specific roadmap
final reposForRoadmapProvider =
    Provider.family<AsyncValue<List<GitHubRepo>>, String>((ref, roadmapId) {
  return ref.watch(reposDataProvider).whenData(
        (data) => data.forRoadmap(roadmapId),
      );
});

// Search provider
final repoSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredReposProvider = Provider<AsyncValue<List<GitHubRepo>>>((ref) {
  final query = ref.watch(repoSearchQueryProvider).toLowerCase();
  return ref.watch(reposDataProvider).whenData((data) {
    if (query.isEmpty) return data.allRepos;
    return data.allRepos
        .where((r) =>
            r.repo.toLowerCase().contains(query) ||
            r.desc.toLowerCase().contains(query) ||
            r.owner.toLowerCase().contains(query))
        .toList();
  });
});
