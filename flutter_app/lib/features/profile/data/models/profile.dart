import 'social_link.dart';

class Profile {
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final List<SocialLink> links;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.links,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        displayName: (json['display_name'] ?? '') as String,
        bio: (json['bio'] ?? '') as String,
        avatarUrl: json['avatar_url'] as String?,
        links: (json['links'] as List<dynamic>? ?? [])
            .map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
