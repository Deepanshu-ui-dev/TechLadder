import 'package:go_router/go_router.dart';
import 'package:techladder/core/widgets/shell_screen.dart';
import 'package:techladder/features/home/home_screen.dart';
import 'package:techladder/features/roadmaps/roadmap_list_screen.dart';
import 'package:techladder/features/roadmaps/roadmap_detail_screen.dart';
import 'package:techladder/features/resources/resources_screen.dart';
import 'package:techladder/features/community/community_screen.dart';
import 'package:techladder/features/profile/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScreen(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/roadmaps',
              builder: (context, state) => const RoadmapListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => RoadmapDetailScreen(
                    roadmapId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/resources',
              builder: (context, state) => const ResourcesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
