import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/aqua_card.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), AppTheme.bgLight], // Soft aqua to white
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: const Text('MySocials'),
                    backgroundColor: Colors.transparent,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppTheme.textDark),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Profile Orb
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.oppoGreen, AppTheme.oppoBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: AppTheme.oppoBlue.withOpacity(0.3), blurRadius: 20, spreadRadius: 4),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: Text(
                                (user?.username ?? '?')[0].toUpperCase(),
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            '@${user?.username ?? "?"}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Center(
                          child: Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Action Cards
                        AquaCard(
                          onTap: () {
                            final publicUrl = '${Env.publicHost}/${user?.username}';
                            Clipboard.setData(ClipboardData(text: publicUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied: $publicUrl'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: _buildCardContent(Icons.copy_rounded, 'Copy Public Link', 'Share your profile', AppTheme.oppoBlue),
                        ),
                        AquaCard(
                          onTap: () => context.push('/u/${user?.username}'),
                          child: _buildCardContent(Icons.visibility_rounded, 'Preview Profile', 'See what visitors see', AppTheme.oppoGreen),
                        ),
                        AquaCard(
                          onTap: () => context.push('/profile/edit'),
                          child: _buildCardContent(Icons.edit_rounded, 'Edit Profile', 'Update your identity', const Color(0xFF8E24AA)), // Purple
                        ),
                        AquaCard(
                          onTap: () => context.push('/links'),
                          child: _buildCardContent(Icons.link_rounded, 'Manage Links', 'Add or reorder socials', const Color(0xFFF57C00)), // Orange
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 18),
      ],
    );
  }
}