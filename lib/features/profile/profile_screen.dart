import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techladder/core/theme/color_tokens.dart';
import 'package:techladder/core/widgets/common_widgets.dart';
import 'package:techladder/features/auth/providers/auth_provider.dart';
import 'package:techladder/features/roadmaps/roadmap_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final progressMap = ref.watch(progressProvider);

    if (user == null) {
      return _GuestProfile(onSignIn: () {
        // Sign in stub — connect to Firebase Auth
        ref.read(authUserProvider.notifier).state = const AuthUser(
          uid: 'demo-uid',
          displayName: 'Developer',
          email: 'dev@techladder.in',
        );
      });
    }
    return _LoggedInProfile(user: user, progressMap: progressMap);
  }
}

class _GuestProfile extends StatelessWidget {
  final VoidCallback onSignIn;
  const _GuestProfile({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      appBar: AppBar(
        backgroundColor: ColorTokens.bgBase,
        title: Text('Profile', style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ColorTokens.bgElevated,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: ColorTokens.bgBorder),
                ),
                child: const Icon(Icons.lock_rounded, color: ColorTokens.textSecond, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Sign in to track your progress',
                  style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Save your roadmap progress, bookmarks and streaks across devices.',
                  style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onSignIn,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorTokens.accentCyan, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: ColorTokens.bgElevated,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.login_rounded, color: ColorTokens.accentCyan, size: 18),
                      const SizedBox(width: 8),
                      Text('Sign in with Google',
                          style: GoogleFonts.ibmPlexSans(color: ColorTokens.accentCyan, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSignIn,
                child: Text('Continue as guest', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13)),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04),
        ),
      ),
    );
  }
}

class _LoggedInProfile extends ConsumerWidget {
  final AuthUser user;
  final Map<String, Set<String>> progressMap;
  const _LoggedInProfile({required this.user, required this.progressMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startedRoadmaps = allRoadmaps.where((r) {
      final c = progressMap[r.id]?.length ?? 0;
      return c > 0;
    }).toList();

    return Scaffold(
      backgroundColor: ColorTokens.bgBase,
      appBar: AppBar(
        backgroundColor: ColorTokens.bgBase,
        title: Text('Profile', style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: ColorTokens.textSecond, size: 20),
            onPressed: () => ref.read(authUserProvider.notifier).state = null,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: ColorTokens.bgElevated,
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Text(user.displayName[0].toUpperCase(),
                        style: GoogleFonts.syne(color: ColorTokens.accentCyan, fontSize: 24, fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.displayName, style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                Text(user.email, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 13)),
              ]),
            ],
          ).animate().fadeIn(duration: 250.ms),

          const SizedBox(height: 20),

          // Streak card
          TLCard(
            borderColor: ColorTokens.accentAmber,
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('7 day streak', style: GoogleFonts.syne(color: ColorTokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Last active: Today', style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 12)),
                ]),
                const Spacer(),
                AnimatedCounter(
                  target: 7,
                  suffix: ' 🔥',
                  style: GoogleFonts.syne(color: ColorTokens.accentAmber, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms, delay: 80.ms),

          const SizedBox(height: 20),

          // Progress section
          const SectionHeader(title: 'Your Progress'),
          const SizedBox(height: 10),
          if (startedRoadmaps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No roadmaps started yet.\nGo explore!',
                    style: GoogleFonts.ibmPlexSans(color: ColorTokens.textSecond, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center),
              ),
            )
          else
            ...startedRoadmaps.asMap().entries.map((e) {
              final rm = e.value;
              final completed = progressMap[rm.id]?.length ?? 0;
              final pct = rm.totalNodes > 0 ? completed / rm.totalNodes : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TLCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(rm.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rm.title, style: GoogleFonts.ibmPlexSans(color: ColorTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
                        Text('${(pct * 100).round()}%', style: GoogleFonts.jetBrainsMono(color: ColorTokens.accentGreen, fontSize: 12)),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: ColorTokens.bgBorder,
                          valueColor: const AlwaysStoppedAnimation(ColorTokens.accentGreen),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: (e.key * 50).ms).fadeIn(),
              );
            }),

          const SizedBox(height: 20),
          const SectionHeader(title: 'Settings'),
          const SizedBox(height: 10),

          TLCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(icon: Icons.notifications_rounded, label: 'Daily Reminders', onTap: () {}),
                Divider(color: ColorTokens.bgBorder, height: 1),
                _SettingsTile(icon: Icons.info_outline_rounded, label: 'About TechLadder', onTap: () {}),
                Divider(color: ColorTokens.bgBorder, height: 1),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  onTap: () => ref.read(authUserProvider.notifier).state = null,
                  color: ColorTokens.accentRed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? ColorTokens.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.ibmPlexSans(color: c, fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: ColorTokens.textSecond, size: 18),
          ],
        ),
      ),
    );
  }
}
