import '../../../core/api/api_client.dart';
import 'models/public_profile.dart';

class PublicRepository {
  final ApiClient _api;

  PublicRepository({required ApiClient api}) : _api = api;

  Future<PublicProfile> getPublicProfile(String username) async {
    // This calls the unauthenticated public API endpoint
    final data = await _api.get('/u/$username/');
    return PublicProfile.fromJson(data as Map<String, dynamic>);
  }
}