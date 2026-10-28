import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/profile.dart';
import '../data/models/social_link.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(api: ref.read(apiClientProvider));
});

// ─── My Profile ───
final myProfileProvider = FutureProvider<Profile>((ref) async {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

// ─── My Links ───
final myLinksProvider =
    AsyncNotifierProvider<MyLinksNotifier, List<SocialLink>>(
        MyLinksNotifier.new);

class MyLinksNotifier extends AsyncNotifier<List<SocialLink>> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<List<SocialLink>> build() async {
    return _repo.listLinks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.listLinks());
    ref.invalidate(myProfileProvider);
  }

  Future<void> add({
    required String platform,
    required String url,
    String label = '',
  }) async {
    await _repo.createLink(platform: platform, url: url, label: label);
    await refresh();
  }

  Future<void> updateLink({
    required int id,
    String? platform,
    String? url,
    String? label,
    bool? isActive,
  }) async {
    await _repo.updateLink(
      id: id,
      platform: platform,
      url: url,
      label: label,
      isActive: isActive,
    );
    await refresh();
  }

  Future<void> delete(int id) async {
    await _repo.deleteLink(id);
    await refresh();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? [];
    if (oldIndex < newIndex) newIndex -= 1;

    final reordered = [...current];
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);

    // Optimistic update
    state = AsyncData(reordered);

    try {
      await _repo.reorderLinks(reordered);
      await refresh();
    } catch (e) {
      // Rollback on failure
      state = AsyncData(current);
      rethrow;
    }
  }
}
