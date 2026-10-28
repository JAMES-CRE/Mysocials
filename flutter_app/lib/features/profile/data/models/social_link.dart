class SocialLink {
  final int id;
  final String platform;
  final String platformDisplay;
  final String url;
  final String label;
  final int order;
  final bool isActive;

  SocialLink({
    required this.id,
    required this.platform,
    required this.platformDisplay,
    required this.url,
    required this.label,
    required this.order,
    required this.isActive,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        id: json['id'] as int,
        platform: json['platform'] as String,
        platformDisplay: json['platform_display'] as String,
        url: json['url'] as String,
        label: (json['label'] ?? '') as String,
        order: json['order'] as int,
        isActive: json['is_active'] as bool? ?? true,
      );

  SocialLink copyWith({
    String? platform,
    String? url,
    String? label,
    int? order,
    bool? isActive,
  }) {
    return SocialLink(
      id: id,
      platform: platform ?? this.platform,
      platformDisplay: platformDisplay,
      url: url ?? this.url,
      label: label ?? this.label,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}