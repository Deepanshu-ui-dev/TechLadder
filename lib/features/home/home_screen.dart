import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techladder/core/theme/color_tokens.dart';
import 'package:techladder/core/widgets/common_widgets.dart';
import 'package:techladder/features/auth/providers/auth_provider.dart';
import 'package:techladder/features/roadmaps/roadmap_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';

  final _categories = [
    'All', 'DSA', 'Placement', 'System Design', 'React', 'Backend', 'DevOps', 'AI/ML',
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    final progressMap = ref.watch(progressProvider);

    // Find a roadmap the user has started
    RoadmapMeta? activeRoadmap;
    double activePercent = 0.0;
    for (final rm in allRoadmaps) {
      final pct = progressMap[rm.id]?.length ?? 0;
      if (pct > 0) {
        activeRoadmap = rm;
        activePercent = pct / rm.totalNodes;
        break;
      }
    }

    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: ColorTokens.bgBase,
            title: Text(
              'TechLadder',
              style: GoogleFonts.syne(
                color: ColorTokens.accentCyan,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: ColorTokens.bgElevated,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person_rounded, color: ColorTokens.textSecond, size: 18)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${user?.displayName ?? 'Developer'} 👋',
                      style: GoogleFonts.syne(
                        color: ColorTokens.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04),
                    const SizedBox(height: 4),
                    Text(
                      'Pick up where you left off',
                      style: GoogleFonts.ibmPlexSans(
                        color: ColorTokens.textSecond,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
                  ],
                ),
              ),

              // Active roadmap progress card
              if (activeRoadmap != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TLCard(
                    onTap: () => context.go('/roadmaps/${activeRoadmap!.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(activeRoadmap.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              activeRoadmap.title,
                              style: GoogleFonts.syne(
                                color: ColorTokens.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: activePercent,
                            minHeight: 6,
                            backgroundColor: ColorTokens.bgBorder,
                            valueColor: const AlwaysStoppedAnimation(ColorTokens.accentCyan),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(activePercent * activeRoadmap.totalNodes).round()} of ${activeRoadmap.totalNodes} topics complete',
                              style: GoogleFonts.ibmPlexSans(
                                color: ColorTokens.textSecond,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Continue →',
                              style: GoogleFonts.ibmPlexSans(
                                color: ColorTokens.accentCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 120.ms),
                ),

              const SizedBox(height: 20),

              // Category chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final selected = _categories[i] == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = _categories[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? ColorTokens.bgElevated : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selected ? ColorTokens.accentCyan : ColorTokens.bgBorder,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _categories[i],
                          style: GoogleFonts.ibmPlexSans(
                            color: selected ? ColorTokens.accentCyan : ColorTokens.textSecond,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Popular Roadmaps
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Popular Roadmaps',
                  action: 'See all',
                  onAction: () => context.go('/roadmaps'),
                ),
              ),
              const SizedBox(height: 12),

              // Horizontal PageView of roadmap cards
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: allRoadmaps.take(6).length,
                  itemBuilder: (context, i) {
                    final rm = allRoadmaps[i];
                    return GestureDetector(
                      onTap: () => context.go('/roadmaps/${rm.id}'),
                      child: Container(
                        width: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorTokens.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorTokens.bgBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TLBadge(rm.category, color: ColorTokens.accentCyan),
                            const Spacer(),
                            Text(rm.emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 4),
                            Text(
                              rm.title,
                              style: GoogleFonts.syne(
                                color: ColorTokens.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${rm.weeks} · ${rm.totalNodes} topics',
                                  style: GoogleFonts.ibmPlexSans(
                                    color: ColorTokens.textSecond,
                                    fontSize: 11,
                                  ),
                                ),
                                const Text('→',
                                    style: TextStyle(color: ColorTokens.accentCyan)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.05);
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Trending This Week
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const SectionHeader(title: 'Trending This Week'),
              ),
              const SizedBox(height: 12),
              ..._trendingItems().asMap().entries.map((e) {
                final item = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: TLCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => launchUrl(Uri.parse(item['url']!), mode: LaunchMode.externalApplication),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ColorTokens.bgElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(item['icon']!, style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: GoogleFonts.ibmPlexSans(
                                  color: ColorTokens.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['source']!,
                                style: GoogleFonts.ibmPlexSans(
                                  color: ColorTokens.textSecond,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded,
                            color: ColorTokens.accentCyan, size: 16),
                      ],
                    ),
                  ).animate(delay: (e.key * 60).ms).fadeIn().slideX(begin: 0.05),
                );
              }),

              const SizedBox(height: 28),

              // Stats strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: ColorTokens.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorTokens.bgBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(label: 'Students', value: '1L+'),
                      _Divider(),
                      _StatItem(label: 'Roadmaps', value: '20+'),
                      _Divider(),
                      _StatItem(label: 'Companies', value: '200+'),
                      _Divider(),
                      _StatItem(label: 'Price', value: 'Free'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _trendingItems() => [
    {
      'icon': '▶️', 
      'title': 'DSA Playlist by Striver', 
      'source': 'YouTube · takeUforward (400+ videos)',
      'url': 'https://www.youtube.com/playlist?list=PLgUwDviBIf0oF6QL8m22w1hIDC1vJ_BHz'
    },
    {
      'icon': '⭐', 
      'title': 'system-design-primer', 
      'source': 'GitHub · donnemartin (270k+ stars)',
      'url': 'https://github.com/donnemartin/system-design-primer'
    },
    {
      'icon': '📱', 
      'title': 'Flutter Roadmap 2026', 
      'source': 'Roadmap.sh · Interactive Guide',
      'url': 'https://roadmap.sh/flutter'
    },
    {
      'icon': '▶️', 
      'title': 'Laxmikant Polity Crash Course', 
      'source': 'YouTube · For UPSC/Placement prep',
      'url': 'https://www.youtube.com/watch?v=1bvwj8z9TKI'
    },
    {
      'icon': '💻', 
      'title': 'NeetCode 150 - Blind 75 Extension', 
      'source': 'Article · Premium Problems List',
      'url': 'https://neetcode.io/practice'
    },
  ];
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.syne(
            color: ColorTokens.accentCyan,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: ColorTokens.textSecond,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 32, width: 1, color: ColorTokens.bgBorder);
  }
}
