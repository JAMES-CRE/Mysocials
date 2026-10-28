import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/api/api_client.dart';
import 'models/profile.dart';
import 'models/social_link.dart';

class ProfileRepository {
  final ApiClient _api;

  ProfileRepository({required ApiClient api}) : _api = api;

  Future<Profile> getMyProfile() async {
    final data = await _api.get('/me/profile/');
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  Future<Profile> updateMyProfile({
    String? displayName,
    String? bio,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (bio != null) body['bio'] = bio;

    final data = await _api.patch('/me/profile/', data: body);
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  Future<Profile> uploadAvatar({
    required String filePath,
    required String fileName,
    List<int>? bytes,
  }) async {
    final multipart = kIsWeb
        ? MultipartFile.fromBytes(bytes!, filename: fileName)
        : await MultipartFile.fromFile(filePath, filename: fileName);

    final form = FormData.fromMap({'avatar': multipart});
    final data = await _api.postForm('/auth/me/avatar/', form);
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  // ─── Links ───
  Future<List<SocialLink>> listLinks() async {
    final data = await _api.get('/me/links/');
    final list = (data as List<dynamic>);
    return list
        .map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SocialLink> createLink({
    required String platform,
    required String url,
    String label = '',
  }) async {
    final data = await _api.post('/me/links/', data: {
      'platform': platform,
      'url': url,
      'label': label,
    });
    return SocialLink.fromJson(data as Map<String, dynamic>);
  }

  Future<SocialLink> updateLink({
    required int id,
    String? platform,
    String? url,
    String? label,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (platform != null) body['platform'] = platform;
    if (url != null) body['url'] = url;
    if (label != null) body['label'] = label;
    if (isActive != null) body['is_active'] = isActive;

    final data = await _api.patch('/me/links/$id/', data: body);
    return SocialLink.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteLink(int id) async {
    await _api.delete('/me/links/$id/');
  }

  Future<void> reorderLinks(List<SocialLink> links) async {
    await _api.post('/me/links/reorder/', data: {
      'items': [
        for (var i = 0; i < links.length; i++) {'id': links[i].id, 'order': i},
      ],
    });
  }
}
