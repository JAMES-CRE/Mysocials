/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/links_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AuthStatus>(AuthStatus.unknown);

  ref.listen<AuthState>(authProvider, (prev, next) {
    if (notifier.value != next.status) notifier.value = next.status;
  });

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final status = ref.read(authProvider).status;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';

      if (status == AuthStatus.unknown) return null;
      if (status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/links',
        builder: (_, __) => const LinksScreen(),
      ),
    ],
  );
});*/



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/links_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/public/presentation/public_profile_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AuthStatus>(AuthStatus.unknown);

  ref.listen<AuthState>(authProvider, (prev, next) {
    if (notifier.value != next.status) notifier.value = next.status;
  });

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final status = ref.read(authProvider).status;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';

      // Public routes (don't require auth)
      final isPublicProfile = state.uri.pathSegments.length == 1 &&
          state.uri.pathSegments.first != 'login' &&
          state.uri.pathSegments.first != 'register' &&
          state.uri.pathSegments.first != 'links' &&
          state.uri.pathSegments.first != 'profile';

      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        if (isPublicProfile) return null; // Let them see the public profile!
        return loggingIn ? null : '/login';
      }

      if (loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/links',
        builder: (_, __) => const LinksScreen(),
      ),

      // The explicit public route (e.g., /u/kojo)
      GoRoute(
        path: '/u/:username',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return PublicProfileScreen(username: username);
        },
      ),

      // The root catch-all for deep links (e.g., /kojo)
      GoRoute(
        path: '/:username',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          // Prevent hitting this route for our actual app screens
          if (username == 'login' || username == 'register' || username == 'links' || username == 'profile') {
            return const Scaffold(body: Center(child: Text('Not found')));
          }
          return PublicProfileScreen(username: username);
        },
      ),
    ],
  );
});