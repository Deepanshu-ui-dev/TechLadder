import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models/repo_model.dart';
import '../providers/repos_provider.dart';
import '../widgets/repo_card.dart';

class ReposScreen extends ConsumerStatefulWidget {
  const ReposScreen({super.key});

  @override
  ConsumerState<ReposScreen> createState() => _ReposScreenState();
}

class _ReposScreenState extends ConsumerState<ReposScreen> {
  String? _selectedCategoryId;
  final TextEditingController _searchCtrl = TextEditingController();

  static const _bgBase = Color(0xFF0A0C10);
  static const _bgSurface = Color(0xFF111318);
  static const _bgBorder = Color(0xFF252A35);
  static const _textPrimary = Color(0xFFEDF2FF);
  static const _textSecond = Color(0xFF6E7A96);
  static const _accentCyan = Color(0xFF00D9FF);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(reposDataProvider);

    return reposAsync.when(
      loading: () => _buildSkeleton(),
      error: (e, _) => _buildError(e.toString()),
      data: (data) => _buildContent(data),
    );
  }

  Widget _buildContent(ReposData data) {
    final categories = data.categories;
    final selectedCat = _selectedCategoryId == null
        ? null
        : categories.firstWhere((c) => c.id == _selectedCategoryId,
            orElse: () => categories.first);

    return CustomScrollView(
      slivers: [
        // ── Search bar ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _bgBorder),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.ibmPlexSans(
                    color: _textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search repositories…',
                  hintStyle:
                      GoogleFonts.ibmPlexSans(color: _textSecond, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: _textSecond, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) {
                  ref.read(repoSearchQueryProvider.notifier).state = v;
                  setState(() {});
                },
              ),
            ),
          ),
        ),

        // ── Category filter chips ────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _selectedCategoryId == null,
                  onTap: () => setState(() => _selectedCategoryId = null),
                ),
                const SizedBox(width: 8),
                ...categories.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: '${c.emoji} ${c.label}',
                        selected: _selectedCategoryId == c.id,
                        onTap: () =>
                            setState(() => _selectedCategoryId = c.id),
                      ),
                    )),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── If searching, show flat filtered list ─────────────────
        if (_searchCtrl.text.isNotEmpty)
          _buildSearchResults()
        // ── Else show category sections ───────────────────────────
        else if (selectedCat == null)
          ..._buildAllCategories(data.categories)
        else
          ..._buildSingleCategory(selectedCat),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildSearchResults() {
    final filtered = ref.watch(filteredReposProvider);
    return filtered.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox()),
      error: (e, _) => SliverToBoxAdapter(child: Text(e.toString())),
      data: (repos) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RepoCard(repo: repos[i]),
            ),
            childCount: repos.length,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAllCategories(List<RepoCategory> categories) {
    final widgets = <Widget>[];
    for (final cat in categories) {
      // Category header
      widgets.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Text(cat.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                cat.label,
                style: GoogleFonts.syne(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${cat.allRepos.length} repos',
                style: GoogleFonts.jetBrainsMono(
                    color: _textSecond, fontSize: 11),
              ),
            ],
          ),
        ),
      ));

      // Repos (show first 6 per category in "All" view)
      final preview = cat.allRepos.take(6).toList();
      widgets.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Column(children: [
              RepoCard(repo: preview[i], compact: true),
              if (i < preview.length - 1)
                const Divider(color: _bgBorder, height: 1),
            ]),
            childCount: preview.length,
          ),
        ),
      ));

      // "View all" link if more
      if (cat.allRepos.length > 6) {
        widgets.add(SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = cat.id),
              child: Text(
                'View all ${cat.allRepos.length} →',
                style: GoogleFonts.ibmPlexSans(
                    color: _accentCyan, fontSize: 13),
              ),
            ),
          ),
        ));
      } else {
        widgets.add(
            const SliverToBoxAdapter(child: SizedBox(height: 20)));
      }

      // Divider between categories
      widgets.add(SliverToBoxAdapter(
        child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: _bgBorder),
      ));
      widgets.add(const SliverToBoxAdapter(child: SizedBox(height: 16)));
    }
    return widgets;
  }

  List<Widget> _buildSingleCategory(RepoCategory cat) {
    final widgets = <Widget>[];

    // Category header
    widgets.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Text(
          '${cat.emoji} ${cat.label}',
          style: GoogleFonts.syne(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
      ),
    ));

    for (final sub in cat.subcategories) {
      // Subcategory header
      widgets.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sub.label,
                style: GoogleFonts.ibmPlexSans(
                  color: _accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 1, color: _bgBorder),
            ],
          ),
        ),
      ));

      // Repos list
      widgets.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Column(children: [
              RepoCard(repo: sub.repos[i]),
              if (i < sub.repos.length - 1)
                const Divider(color: _bgBorder, height: 1),
            ]),
            childCount: sub.repos.length,
          ),
        ),
      ));

      widgets.add(
          const SliverToBoxAdapter(child: SizedBox(height: 24)));
    }
    return widgets;
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF111318),
      highlightColor: const Color(0xFF181C24),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111318),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4D4D), size: 40),
          const SizedBox(height: 12),
          Text('Failed to load repos',
              style: GoogleFonts.syne(
                  color: const Color(0xFFEDF2FF), fontSize: 16)),
          const SizedBox(height: 4),
          Text(msg,
              style: GoogleFonts.ibmPlexSans(
                  color: const Color(0xFF6E7A96), fontSize: 12)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.invalidate(reposDataProvider),
            child: Text('Retry',
                style: GoogleFonts.ibmPlexSans(
                    color: const Color(0xFF00D9FF))),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00D9FF).withOpacity(0.1)
              : const Color(0xFF111318),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? const Color(0xFF00D9FF)
                : const Color(0xFF252A35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: selected
                ? const Color(0xFF00D9FF)
                : const Color(0xFF6E7A96),
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
