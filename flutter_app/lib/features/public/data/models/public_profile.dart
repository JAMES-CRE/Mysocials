import '../../../../features/profile/data/models/social_link.dart';

class PublicProfile {
  final String username;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final List<SocialLink> links;

  PublicProfile({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.links,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
        username: json['username'] as String,
        displayName: (json['display_name'] ?? '') as String,
        bio: (json['bio'] ?? '') as String,
        avatarUrl: json['avatar_url'] as String?,
        links: (json['links'] as List<dynamic>? ?? [])
            .map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}