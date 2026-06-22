import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/repos_provider.dart';
import 'repo_card.dart';

class RoadmapReposSection extends ConsumerWidget {
  final String roadmapId;

  const RoadmapReposSection({super.key, required this.roadmapId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(reposForRoadmapProvider(roadmapId));

    return reposAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox.shrink(),
      data: (repos) {
        if (repos.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GitHub Resources',
              style: GoogleFonts.ibmPlexSans(
                color: const Color(0xFF00D9FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...repos.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RepoCard(repo: r, compact: true),
                )),
          ],
        );
      },
    );
  }
}
