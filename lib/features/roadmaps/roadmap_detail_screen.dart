import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:techladder/core/theme/color_tokens.dart';
import 'package:techladder/features/auth/providers/auth_provider.dart';

class RoadmapDetailScreen extends ConsumerStatefulWidget {
  final String roadmapId;
  const RoadmapDetailScreen({super.key, required this.roadmapId});

  @override
  ConsumerState<RoadmapDetailScreen> createState() => _RoadmapDetailScreenState();
}

class _RoadmapDetailScreenState extends ConsumerState<RoadmapDetailScreen> {
  late Future<Map<String, dynamic>?> _roadmapFuture;

  @override
  void initState() {
    super.initState();
    _roadmapFuture = _loadRoadmap();
  }

  Future<Map<String, dynamic>?> _loadRoadmap() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/roadmaps/${widget.roadmapId}.json');
      return jsonDecode(jsonStr);
    } catch (_) {
      // Fallback if not found
      return null;
    }
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _roadmapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ColorTokens.accentCyan));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              backgroundColor: ColorTokens.bgBase,
              appBar: AppBar(title: const Text('Not Found')),
              body: const Center(child: Text("Roadmap data empty or missing.", style: TextStyle(color: Colors.white))),
            );
          }

          final data = snapshot.data!;
          // Example: reading title from index if possible. For simplicity we'll hardcode or deduce
          final title = data['title'] ?? 'Roadmap Detail';
          final sections = (data['sections'] as List?) ?? [];
          final freeMaterial = (data['freeMaterial'] as List?) ?? [];
          final youtubePlaylists = (data['youtubePlaylistsBySeries'] as List?) ?? [];

          // Compute progress
          final progressMap = ref.watch(progressProvider);
          final completed = progressMap[widget.roadmapId] ?? {};
          int totalNodes = 0;
          for (var s in sections) {
            totalNodes += ((s['nodes'] as List?)?.length ?? 0);
          }
          final pct = totalNodes > 0 ? (completed.length / totalNodes) : 0.0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: ColorTokens.bgBase,
                title: Text(title,
                    style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                actions: [
                  IconButton(icon: const Icon(Icons.bookmark_border_rounded), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // 1. HERO SECTION
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip('Intermediate → Advanced', ColorTokens.accentCyan),
                            _InfoChip('16 weeks', ColorTokens.accentAmber),
                            _InfoChip('$totalNodes topics', ColorTokens.accentGreen),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Complete guide to mastering this subject. Follow the modules week by week.',
                            style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 14, height: 1.6)),
                      ],
                    ),
                  ),

                  // 2. PROGRESS CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorTokens.bgSurface,
                        border: Border.all(color: ColorTokens.bgBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Your Progress', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('${completed.length} / $totalNodes topics', style: GoogleFonts.jetBrainsMono(color: ColorTokens.accentCyan, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: ColorTokens.bgBorder,
                              valueColor: const AlwaysStoppedAnimation(ColorTokens.accentCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. SECTIONS
                  ...sections.map((section) {
                    final secTitle = section['title'] ?? 'Section';
                    final nodes = (section['nodes'] as List?) ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 1, color: ColorTokens.bgBorder),
                              const SizedBox(height: 16),
                              Text("## $secTitle", style: GoogleFonts.syne(color: ColorTokens.accentCyan, fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        ...nodes.map((node) {
                          final nId = node['id'] as String;
                          final isDone = completed.contains(nId);
                          return _buildNodeExpandable(node, isDone);
                        }),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),

                  // 4. BOTTOM SECTION
                  if (freeMaterial.isNotEmpty || youtubePlaylists.isNotEmpty) ...[
                    Container(height: 1, color: ColorTokens.bgBorder),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("## Recommended Resources", style: GoogleFonts.syne(color: ColorTokens.accentCyan, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          if (freeMaterial.isNotEmpty) ...[
                            Text("Free Material", style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...freeMaterial.map((m) => _buildBottomResource(m['title'] ?? '', m['url'] ?? '', Icons.folder_outlined, ColorTokens.accentAmber)),
                            const SizedBox(height: 16),
                          ],
                          if (youtubePlaylists.isNotEmpty) ...[
                            Text("YouTube Series", style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...youtubePlaylists.map((m) => _buildBottomResource('${m['title']} (${m['channel']})', m['url'] ?? '', Icons.play_circle_outline, const Color(0xFFFF4444))),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ]
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomResource(String title, String url, IconData icon, Color iconColor) {
    return InkWell(
      onTap: () => _launch(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 13))),
            const Icon(Icons.open_in_new, color: ColorTokens.textSecond, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeExpandable(Map<String, dynamic> node, bool isDone) {
    final diff = node['difficulty'] ?? 'Easy';
    final hrs = node['estimatedHours']?.toString() ?? '2';
    final res = (node['resources'] as List?) ?? [];
    final problems = (node['practiceProblems'] as List?) ?? [];

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        listTileTheme: const ListTileThemeData(dense: true),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        trailing: const SizedBox.shrink(), // hide default arrow
        title: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? ColorTokens.accentGreen : Colors.transparent,
                border: Border.all(color: isDone ? ColorTokens.accentGreen : ColorTokens.textSecond),
              ),
              child: isDone ? const Icon(Icons.check, color: ColorTokens.bgBase, size: 12) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(node['title'] ?? '', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            _DifficultyDot(diff),
            const SizedBox(width: 6),
            Text('~${hrs}h', style: GoogleFonts.jetBrainsMono(color: ColorTokens.textSecond, fontSize: 11)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node['description'] ?? '', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13, height: 1.5)),
                const SizedBox(height: 16),
                
                if (res.isNotEmpty) ...[
                  Text('Resources', style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentCyan, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...res.map((r) => _buildResourceTile(r)),
                  const SizedBox(height: 12),
                ],

                if (problems.isNotEmpty) ...[
                  Text('Practice Problems', style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentCyan, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: problems.map((p) => _ProblemChip(p.toString())).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                InkWell(
                  onTap: () {
                    ref.read(progressProvider.notifier).toggleNode(node['id'], widget.roadmapId);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorTokens.accentGreen),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isDone ? '✓ Completed' : 'Mark as Complete',
                      style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentGreen, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: ColorTokens.bgBorder),
        ],
      ),
    );
  }

  Widget _buildResourceTile(Map<String, dynamic> r) {
    IconData icon = Icons.article_outlined;
    Color iconColor = ColorTokens.accentCyan;
    if (r['type'] == 'youtube' || r['type'] == 'video') {
      icon = Icons.play_circle_outline;
      iconColor = const Color(0xFFFF4444);
    } else if (r['type'] == 'practice') {
      icon = Icons.code;
      iconColor = ColorTokens.accentGreen;
    }
    
    return InkWell(
      onTap: () => _launch(r['url'] ?? ''),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(r['title'] ?? '', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 12))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: ColorTokens.bgElevated, borderRadius: BorderRadius.circular(4)),
              child: Text(r['source'] ?? '', style: GoogleFonts.jetBrainsMono(color: ColorTokens.textSecond, fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemChip extends StatelessWidget {
  final String title;
  const _ProblemChip(this.title);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final query = Uri.encodeComponent(title);
        launchUrl(Uri.parse('https://leetcode.com/problemset/all/?search=$query'), mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ColorTokens.bgSurface,
          border: Border.all(color: ColorTokens.bgBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 11)),
      ),
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  final String diff;
  const _DifficultyDot(this.diff);

  @override
  Widget build(BuildContext context) {
    Color c = ColorTokens.accentGreen;
    if (diff.toLowerCase() == 'medium') c = ColorTokens.accentAmber;
    if (diff.toLowerCase() == 'hard') c = const Color(0xFFFF4444);
    
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: GoogleFonts.ibmPlexSans(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
