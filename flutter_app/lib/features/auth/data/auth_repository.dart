import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_response.dart';
import 'models/user.dart';

class AuthRepository {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthRepository({required ApiClient api, required TokenStorage storage})
      : _api = api,
        _storage = storage;

  Future<User> register({
    required String email,
    required String username,
    required String password,
  }) async {
    await _api.post('/auth/register/', data: {
      'email': email,
      'username': username,
      'password': password,
      'password2': password,
    });
    return login(email: email, password: password);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(data as Map<String, dynamic>);
    await _storage.saveTokens(access: auth.access, refresh: auth.refresh);

    final me = await _api.get('/auth/me/');
    return User.fromJson(me as Map<String, dynamic>);
  }

  Future<User?> tryRestoreSession() async {
    final refresh = await _storage.refreshToken;
    if (refresh == null) return null;

    try {
      final me = await _api.get('/auth/me/');
      return User.fromJson(me as Map<String, dynamic>);
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() => _storage.clear();
}