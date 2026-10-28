import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/public_profile.dart';
import '../data/public_repository.dart';

final publicRepositoryProvider = Provider<PublicRepository>((ref) {
  return PublicRepository(api: ref.read(apiClientProvider));
});

// Family provider: allows fetching different profiles by username
final publicProfileProvider =
    FutureProvider.family<PublicProfile, String>((ref, username) async {
  return ref.read(publicRepositoryProvider).getPublicProfile(username);
});