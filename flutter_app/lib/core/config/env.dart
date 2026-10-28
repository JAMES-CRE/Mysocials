class Env {
  /// Point this at your Django dev server.
  /// - Android emulator:   http://10.0.2.2:8000
  /// - iOS simulator/web:  http://127.0.0.1:8000
  /// - Physical device:    http://<your-lan-ip>:8000
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';

  /// Used for deep links / public profiles.
  static const String publicHost = 'http://127.0.0.1:8000';
}
