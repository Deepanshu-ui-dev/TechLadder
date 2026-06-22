import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/repo_model.dart';

class RepoCard extends StatelessWidget {
  final GitHubRepo repo;
  final bool compact;

  const RepoCard({super.key, required this.repo, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openUrl(repo.url),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF252A35), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF181C24),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF252A35)),
              ),
              child: const Icon(Icons.code, color: Color(0xFF6E7A96), size: 18),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Repo name
                  Text(
                    repo.fullName,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF00D9FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    repo.desc,
                    style: GoogleFonts.ibmPlexSans(
                      color: const Color(0xFF6E7A96),
                      fontSize: 12,
                      height: 1.5,
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    // Stars badge
                    Row(
                      children: [
                        const Icon(Icons.star_outline,
                            size: 13, color: Color(0xFFFFB020)),
                        const SizedBox(width: 4),
                        Text(
                          repo.stars,
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFFFB020),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new,
                size: 16, color: Color(0xFF6E7A96)),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
