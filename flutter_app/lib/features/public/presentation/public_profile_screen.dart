import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shared/widgets/aqua_card.dart';
import '../../profile/data/models/platforms.dart';
import '../providers/public_provider.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const PublicProfileScreen({super.key, required this.username});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  _PlatformInfo getPlatformInfo(String value) {
    final platform = platforms.firstWhere(
      (item) => item.value == value.toLowerCase(),
      orElse: () => const Platform('other', 'Other'),
    );
    final icon = switch (platform.value) {
      'twitter' => Icons.alternate_email,
      'instagram' => Icons.camera_alt_outlined,
      'facebook' => Icons.facebook,
      'tiktok' => Icons.music_note,
      'linkedin' => Icons.work_outline,
      'youtube' => Icons.play_circle_outline,
      'github' => Icons.code,
      'whatsapp' || 'telegram' || 'snapchat' => Icons.chat_outlined,
      'email' => Icons.mail_outline,
      'website' => Icons.language,
      _ => Icons.link,
    };
    return _PlatformInfo(platform.label, icon);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(publicProfileProvider(widget.username));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13), // Ultra-dark premium background
      body: Stack(
        children: [
          // Ambient Glow Orb 1 (Top Left)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C853).withOpacity(0.15), // Soft Green
              ),
            ),
          ),
          // Ambient Glow Orb 2 (Bottom Right)
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2979FF).withOpacity(0.15), // Soft Blue
              ),
            ),
          ),

          SafeArea(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, _) => Center(
                child: Text('Profile not found', style: TextStyle(color: Colors.white.withOpacity(0.7))),
              ),
              data: (profile) {
                return Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Avatar with animated glow ring
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2979FF).withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: const Color(0xFF1E1E24),
                                      backgroundImage: profile.avatarUrl != null
                                          ? NetworkImage(profile.avatarUrl!)
                                          : null,
                                      child: profile.avatarUrl == null
                                          ? Text(
                                              profile.username[0].toUpperCase(),
                                              style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Name & Handle
                                Text(
                                  profile.displayName.isEmpty ? '@${profile.username}' : profile.displayName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (profile.displayName.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '@${profile.username}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],

                                // Bio
                                if (profile.bio.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    profile.bio,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 48),

                                // Staggered Links
                                ...profile.links.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final link = entry.value;
                                  final platform = getPlatformInfo(link.platform);
                                  final title = link.label.isEmpty ? platform.label : link.label;

                                  // Stagger the animation for each link
                                  final linkAnimation = CurvedAnimation(
                                    parent: _controller,
                                    curve: Interval(
                                      0.3 + (index * 0.1), // Delay each link
                                      1.0,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  );

                                  return FadeTransition(
                                    opacity: linkAnimation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.2),
                                        end: Offset.zero,
                                      ).animate(linkAnimation),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _PressableLink(
                                          icon: platform.icon,
                                          title: title,
                                          url: link.url,
                                          onTap: () => _openLink(link.url),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 40),

                                // Footer
                                Center(
                                  child: TextButton(
                                    onPressed: () => context.go('/'),
                                    child: Text(
                                      'Powered by MySocials',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformInfo {
  final String label;
  final IconData icon;

  const _PlatformInfo(this.label, this.icon);
}

/// A custom widget that adds a springy scale animation when pressed.
class _PressableLink extends StatefulWidget {
  final IconData icon;
  final String title;
  final String url;
  final VoidCallback onTap;

  const _PressableLink({
    required this.icon,
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  State<_PressableLink> createState() => _PressableLinkState();
}

class _PressableLinkState extends State<_PressableLink> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0, // Scales down to 96% when tapped
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AquaCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: Colors.white.withOpacity(0.06), // Glass effect
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}