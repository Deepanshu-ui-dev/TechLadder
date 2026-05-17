import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techladder/core/theme/color_tokens.dart';
import 'package:techladder/core/widgets/common_widgets.dart';
import 'package:techladder/features/auth/providers/auth_provider.dart';
import 'package:techladder/features/roadmaps/roadmap_data.dart';

class RoadmapListScreen extends ConsumerWidget {
  const RoadmapListScreen({super.key});

  static const _sections = [
    ('Placement & Career', ['placement-kit', 'placement-2026', 'aptitude', 'resume-guide']),
    ('DSA & Coding', ['dsa-2026', 'system-design', 'leetcode-150']),
    ('Web & Software', ['javascript', 'react', 'backend', 'devops']),
    ('AI & Emerging Tech', ['ai-engineer', 'ml']),
    ('Projects & Resources', ['projects']),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressMap = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      appBar: AppBar(
        title: Text(
          'Roadmaps',
          style: GoogleFonts.syne(
            color: ColorTokens.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: ColorTokens.bgBase,
      ),
      body: CustomScrollView(
        slivers: [
          for (final (sectionTitle, ids) in _sections) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  sectionTitle,
                  style: GoogleFonts.syne(
                    color: ColorTokens.textSecond,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final rm = allRoadmaps.firstWhere(
                    (r) => r.id == ids[i],
                    orElse: () => allRoadmaps.first,
                  );
                  final completed = progressMap[rm.id]?.length ?? 0;
                  final pct = rm.totalNodes > 0 ? completed / rm.totalNodes : 0.0;
                  final started = completed > 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: TLCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => context.go('/roadmaps/${rm.id}'),
                      child: Row(
                        children: [
                          Text(rm.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rm.title,
                                  style: GoogleFonts.ibmPlexSans(
                                    color: ColorTokens.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${rm.category} · ${rm.weeks}',
                                  style: GoogleFonts.ibmPlexSans(
                                    color: ColorTokens.textSecond,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (started)
                            ProgressRing(progress: pct)
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorTokens.accentCyan),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Start',
                                style: GoogleFonts.ibmPlexSans(
                                  color: ColorTokens.accentCyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: ColorTokens.textSecond, size: 16),
                        ],
                      ),
                    ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.03),
                  );
                },
                childCount: ids.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
