import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:techladder/features/roadmaps/roadmap_data.dart';

/// Represents a logged-in user (Firestore-ready, currently local only)
class AuthUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;

  const AuthUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
  });
}

/// Auth state — null = guest, non-null = signed in
final authUserProvider = StateProvider<AuthUser?>((ref) => null);

/// Progress notifier backed by Hive
class ProgressNotifier extends StateNotifier<Map<String, Set<String>>> {
  final Box _box;

  ProgressNotifier(this._box) : super(_loadAll(_box));

  static Map<String, Set<String>> _loadAll(Box box) {
    final result = <String, Set<String>>{};
    for (final roadmapId in allRoadmaps.map((r) => r.id)) {
      final list = box.get(roadmapId, defaultValue: <String>[]) as List;
      result[roadmapId] = list.cast<String>().toSet();
    }
    return result;
  }

  Set<String> getProgress(String roadmapId) => state[roadmapId] ?? {};

  double getPercent(String roadmapId) {
    final meta = allRoadmaps.firstWhere(
      (r) => r.id == roadmapId,
      orElse: () => allRoadmaps.first,
    );
    final completed = getProgress(roadmapId).length;
    return meta.totalNodes > 0 ? completed / meta.totalNodes : 0.0;
  }

  Future<void> toggleNode(String nodeId, String roadmapId) async {
    final current = Set<String>.from(state[roadmapId] ?? {});
    if (current.contains(nodeId)) {
      current.remove(nodeId);
    } else {
      current.add(nodeId);
    }
    state = {...state, roadmapId: current};
    await _box.put(roadmapId, current.toList());
  }

  bool isCompleted(String nodeId, String roadmapId) =>
      state[roadmapId]?.contains(nodeId) ?? false;
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, Map<String, Set<String>>>((ref) {
  final box = Hive.box('guest_progress');
  return ProgressNotifier(box);
});

final roadmapPercentProvider =
    Provider.family<double, String>((ref, roadmapId) {
  ref.watch(progressProvider);
  return ref.read(progressProvider.notifier).getPercent(roadmapId);
});
