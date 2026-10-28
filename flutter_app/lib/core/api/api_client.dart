import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Prevents concurrent refresh attempts.
  Future<String?>? _refreshFuture;

  ApiClient({required TokenStorage tokenStorage, Dio? dio})
      : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  // ─── Public API ───
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _run(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _run(() => _dio.post(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) =>
      _run(() => _dio.patch(path, data: data));

  Future<dynamic> delete(String path) =>
      _run(() => _dio.delete(path));

  Future<dynamic> postForm(String path, FormData data) =>
      _run(() => _dio.post(path, data: data));

  // ─── Interceptors ───
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    // Auto-refresh on 401 (skip for the refresh call itself)
    final isRefreshCall = e.requestOptions.path.contains('/auth/refresh');
    final isLoginCall = e.requestOptions.path.contains('/auth/login');

    if (e.response?.statusCode == 401 && !isRefreshCall && !isLoginCall) {
      final newToken = await _refreshToken();
      if (newToken != null) {
        // Retry original request
        final opts = e.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (err) {
          return handler.next(e);
        }
      }
    }
    handler.next(e);
  }

  Future<String?> _refreshToken() {
    _refreshFuture ??= _doRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  Future<String?> _doRefresh() async {
    final refresh = await _tokenStorage.refreshToken;
    if (refresh == null) return null;

    try {
      final res = await Dio(BaseOptions(baseUrl: Env.apiBaseUrl)).post(
        '/auth/refresh/',
        data: {'refresh': refresh},
      );
      final access = res.data['access'] as String?;
      if (access == null) return null;

      // SimpleJWT ROTATE_REFRESH_TOKENS=True returns a new refresh too
      final newRefresh = (res.data['refresh'] as String?) ?? refresh;
      await _tokenStorage.saveTokens(access: access, refresh: newRefresh);
      return access;
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  // ─── Response handling ───
  Future<dynamic> _run(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String message = 'Something went wrong.';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      errors = data;
      if (data['detail'] is String) {
        message = data['detail'] as String;
      } else if (data.isNotEmpty) {
        // Take first field error
        final firstKey = data.keys.first;
        final value = data[firstKey];
        if (value is List && value.isNotEmpty) {
          message = '${_prettyField(firstKey)}: ${value.first}';
        } else if (value is String) {
          message = value;
        }
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      message = 'Cannot reach server. Is Django running?';
    }

    return ApiException(statusCode: status, message: message, errors: errors);
  }

  String _prettyField(String key) {
    if (key.isEmpty) return key;
    final spaced = key.replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}