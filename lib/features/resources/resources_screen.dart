import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:techladder/core/theme/color_tokens.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor: ColorTokens.bgBase,
              title: Text('Resources',
                  style: GoogleFonts.syne(
                      color: ColorTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded,
                      color: ColorTokens.textPrimary),
                  onPressed: () {},
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: ColorTokens.accentCyan,
                indicatorWeight: 2,
                dividerColor: ColorTokens.bgBorder,
                labelColor: ColorTokens.accentCyan,
                unselectedLabelColor: ColorTokens.textSecond,
                labelStyle: GoogleFonts.ibmPlexSans(
                    fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'DSA'),
                  Tab(text: 'Placement'),
                  Tab(text: 'Web Dev'),
                  Tab(text: 'AI/ML'),
                  Tab(text: 'Projects'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            _DSATabContent(),
            _PlacementTabContent(),
            Center(child: Text('Coming Soon', style: TextStyle(color: ColorTokens.textSecond))),
            Center(child: Text('Coming Soon', style: TextStyle(color: ColorTokens.textSecond))),
            Center(child: Text('Coming Soon', style: TextStyle(color: ColorTokens.textSecond))),
          ],
        ),
      ),
    );
  }
}

// ─── Shared UI Components ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(title,
            style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorTokens.textPrimary)),
        const SizedBox(height: 8),
        Container(height: 1, color: ColorTokens.bgBorder),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String source;
  final String url;

  const _ResourceTile({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.url,
  });

  Widget _getIcon() {
    switch (type) {
      case 'youtube':
        return const Icon(Icons.play_circle_outline, color: Color(0xFFFF4444), size: 24);
      case 'github':
        return SvgPicture.asset('assets/icons/github.svg', colorFilter: const ColorFilter.mode(ColorTokens.textSecond, BlendMode.srcIn), height: 20);
      case 'article':
        return const Icon(Icons.article_outlined, color: ColorTokens.accentCyan, size: 22);
      case 'course':
        return const Icon(Icons.school_outlined, color: ColorTokens.accentAmber, size: 22);
      case 'practice':
        return const Icon(Icons.code, color: ColorTokens.accentGreen, size: 22);
      case 'drive':
        return const Icon(Icons.folder_outlined, color: ColorTokens.accentAmber, size: 22);
      case 'doc':
      case 'pdf':
      default:
        return const Icon(Icons.description_outlined, color: ColorTokens.accentCyan, size: 22);
    }
  }

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _launch,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 24, alignment: Alignment.center, child: _getIcon()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.ibmPlexSans(
                              color: ColorTokens.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorTokens.bgElevated,
                              border: Border.all(color: ColorTokens.bgBorder),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(source,
                                style: GoogleFonts.jetBrainsMono(
                                    color: ColorTokens.textSecond, fontSize: 10)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(subtitle,
                                style: GoogleFonts.ibmPlexSans(
                                    color: ColorTokens.textSecond, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: ColorTokens.textSecond, size: 18),
              ],
            ),
          ),
        ),
        Container(height: 1, color: ColorTokens.bgBorder),
      ],
    );
  }
}

// ─── DSA Tab ───────────────────────────────────────────────────────────────

class _DSATabContent extends ConsumerWidget {
  const _DSATabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: const [
        _SectionHeader('YouTube Playlists'),
        _ResourceTile(
            type: 'youtube',
            title: 'Striver A2Z DSA Course',
            subtitle: '455 videos',
            source: 'YouTube',
            url: 'https://www.youtube.com/playlist?list=PLgUwDviBIf0oF6QL8m22w1hIDC1vJ_BHz'),
        _ResourceTile(
            type: 'youtube',
            title: 'DSA with Java — Full Course',
            subtitle: '63 videos',
            source: 'YouTube (Kushwaha)',
            url: 'https://www.youtube.com/watch?v=6iCHf7OZn6c'),
        _ResourceTile(
            type: 'youtube',
            title: 'NeetCode 150 — Solutions',
            subtitle: '150 videos',
            source: 'YouTube',
            url: 'https://www.youtube.com/playlist?list=PLot-Xpze53ldVwtstag2TL4HQhAnC8ATf'),
        _ResourceTile(
            type: 'youtube',
            title: 'DSA with Python',
            subtitle: '72 videos',
            source: 'Apna College',
            url: 'https://www.youtube.com/watch?v=aWKEBEg55ps'),

        _SectionHeader('Free Study Material'),
        _ResourceTile(
            type: 'drive',
            title: 'Complete Free DSA Material',
            subtitle: 'Pdf notes & code snippets',
            source: 'Google Drive',
            url: 'https://drive.google.com/'),
        _ResourceTile(
            type: 'doc',
            title: 'Top 50 DSA Interview Questions',
            subtitle: 'Commonly asked questions',
            source: 'Google Docs',
            url: 'https://docs.google.com/'),
        _ResourceTile(
            type: 'article',
            title: 'NeetCode Roadmap',
            subtitle: 'Interactive Blind 75 / 150',
            source: 'neetcode.io',
            url: 'https://neetcode.io/roadmap'),
            
        _SectionHeader('GitHub Repositories'),
        _ResourceTile(
            type: 'github',
            title: 'coding-interview-university',
            subtitle: '308k ⭐ stars',
            source: 'GitHub',
            url: 'https://github.com/jwasham/coding-interview-university'),
        _ResourceTile(
            type: 'github',
            title: 'awesome-leetcode-resources',
            subtitle: '9.2k ⭐ stars',
            source: 'GitHub',
            url: 'https://github.com/ashishps1/awesome-leetcode-resources'),
        _ResourceTile(
            type: 'github',
            title: 'javascript-algorithms',
            subtitle: '189k ⭐ stars',
            source: 'GitHub',
            url: 'https://github.com/trekhleb/javascript-algorithms'),

        _SectionHeader('Practice Platforms'),
        _ResourceTile(
            type: 'practice',
            title: 'LeetCode',
            subtitle: 'Primary platform',
            source: 'leetcode.com',
            url: 'https://leetcode.com'),
        _ResourceTile(
            type: 'practice',
            title: 'HackerRank',
            subtitle: 'Good for beginners',
            source: 'hackerrank.com',
            url: 'https://hackerrank.com'),
        _ResourceTile(
            type: 'practice',
            title: 'Codeforces',
            subtitle: 'Competitive coding',
            source: 'codeforces.com',
            url: 'https://codeforces.com'),
            
        SizedBox(height: 40),
      ],
    );
  }
}

// ─── Placement Tab ─────────────────────────────────────────────────────────

class _PlacementTabContent extends ConsumerWidget {
  const _PlacementTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const _SectionHeader('Placement Preparation'),
        const _ResourceTile(
            type: 'article',
            title: 'A to Z Placement Kit',
            subtitle: 'Resume, apti, & HR setup',
            source: 'Article',
            url: 'https://neetcode.io/roadmap'),
        const _ResourceTile(
            type: 'article',
            title: 'ATS-Friendly Resume Templates',
            subtitle: 'LaTeX and Word formats',
            source: 'GitHub / Drive',
            url: 'https://github.com/sb2nov/resume'),
        const _ResourceTile(
            type: 'drive',
            title: 'Cold Email & Referral Templates',
            subtitle: 'Templates for LinkedIn',
            source: 'Google Docs',
            url: 'https://docs.google.com/'),
            
        const _SectionHeader('Company PYQs Quick Links'),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _CompanyChip('Amazon'),
              _CompanyChip('Microsoft'),
              _CompanyChip('Google'),
              _CompanyChip('TCS'),
              _CompanyChip('Infosys'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _ResourceTile(
            type: 'practice',
            title: 'Two Sum (Amazon)',
            subtitle: 'Easy',
            source: 'LeetCode',
            url: 'https://leetcode.com/problems/two-sum/'),
        const _ResourceTile(
            type: 'practice',
            title: 'Word Ladder (Amazon)',
            subtitle: 'Hard',
            source: 'LeetCode',
            url: 'https://leetcode.com/problems/word-ladder/'),
        const _ResourceTile(
            type: 'practice',
            title: 'Reverse Linked List (Microsoft)',
            subtitle: 'Easy',
            source: 'LeetCode',
            url: 'https://leetcode.com/problems/reverse-linked-list/'),
            
        const _SectionHeader('Aptitude'),
        const _ResourceTile(
            type: 'article',
            title: 'Aptitude Roadmap',
            subtitle: 'For TCS, Infosys, etc.',
            source: 'Article',
            url: 'https://github.com/'),
        const _ResourceTile(
            type: 'drive',
            title: 'RS Aggarwal PDF',
            subtitle: 'Verbal & Non-Verbal Math',
            source: 'Google Drive',
            url: 'https://drive.google.com/'),
        const _ResourceTile(
            type: 'practice',
            title: 'IndiaBix',
            subtitle: 'Aptitude Practice',
            source: 'Web',
            url: 'https://indiabix.com/'),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _CompanyChip extends StatelessWidget {
  final String label;
  const _CompanyChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorTokens.bgElevated,
        border: Border.all(color: ColorTokens.bgBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: GoogleFonts.ibmPlexSans(
              color: ColorTokens.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500)),
    );
  }
}


