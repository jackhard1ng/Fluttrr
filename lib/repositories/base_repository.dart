import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../services/token_manager.dart';
import '../services/auth_event_handler.dart';
import '../services/connectivity_service.dart';
import '../services/http_utils.dart';

/// Base repository with common HTTP operations
///
/// Features:
/// - Automatic retry with exponential backoff
/// - Automatic token refresh and request retry on 401
/// - Proactive token expiry check before requests
/// - Configurable timeouts per request
/// - Response caching for GET requests
/// - Rate limiting handling
/// - Network connectivity checks
abstract class BaseRepository {
  // ==================== Token Refresh Lock ====================

  /// Prevents multiple simultaneous token refresh attempts.
  /// All concurrent 401s wait on the same Completer.
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  /// Attempt to refresh the token, with a lock so concurrent 401s
  /// all wait on a single refresh attempt.
  Future<bool> _handleTokenRefresh() async {
    // If already refreshing, wait for the result
    if (_isRefreshing && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final success = await AuthEventHandler().attemptTokenRefresh();
      _refreshCompleter!.complete(success);

      if (!success) {
        // Refresh failed — force logout
        AuthEventHandler().handleUnauthorized(
          message: 'Your session has expired. Please log in again.',
        );
      }

      return success;
    } catch (e) {
      debugPrint('BaseRepository: Token refresh error: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  // ==================== Connectivity ====================

  /// Check network connectivity before making requests
  Future<bool> _checkConnectivity() async {
    try {
      if (Get.isRegistered<ConnectivityService>()) {
        final connectivity = Get.find<ConnectivityService>();
        return await connectivity.checkConnectivity();
      }
      // If service not registered, assume connected
      return true;
    } catch (e) {
      // If check fails, proceed anyway
      return true;
    }
  }

  // ==================== Token Management ====================

  /// Get the auth token from TokenManager (single source of truth)
  Future<String?> getToken() async {
    return TokenManager.getToken();
  }

  /// Save the auth token to TokenManager
  Future<void> saveToken(String token) async {
    await TokenManager.saveToken(token);
  }

  /// Remove the auth token
  Future<void> clearToken() async {
    await TokenManager.clearToken();
  }

  /// Get headers with optional auth token.
  /// Proactively refreshes the token if it's known to be expired.
  Future<Map<String, String>> getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      // Proactively refresh if token is known to be expired
      if (await TokenManager.isTokenExpired()) {
        debugPrint('BaseRepository: Token expired, proactively refreshing');
        await _handleTokenRefresh();
      }

      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ==================== HTTP Methods ====================

  /// Perform a GET request with optional retry and caching
  Future<ApiResponse<T>> get<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    Map<String, String>? queryParams,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      // Check cache first for GET requests
      if (requestConfig.enableCache) {
        final cacheKey = HttpUtils.generateCacheKey(uri.toString(), headers);
        final cached = HttpUtils.getCachedResponse(cacheKey);
        if (cached != null) {
          return _handleResponse(cached, fromJson);
        }
      }

      // Check rate limit
      await HttpUtils.checkRateLimit(uri.host);

      // Execute with retry
      final response = await HttpUtils.executeWithRetry(
        () => http.get(uri, headers: headers),
        config: requestConfig,
      );

      // Handle 401 with token refresh and retry
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          final newHeaders = await getHeaders(requiresAuth: true);
          final retryResponse = await http.get(uri, headers: newHeaders)
              .timeout(requestConfig.timeout);
          return _handleResponse(retryResponse, fromJson);
        }
      }

      // Cache successful GET responses
      if (requestConfig.enableCache && response.statusCode >= 200 && response.statusCode < 300) {
        final cacheKey = HttpUtils.generateCacheKey(uri.toString(), headers);
        HttpUtils.cacheResponse(cacheKey, response, duration: requestConfig.cacheDuration);
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a POST request with optional retry
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await HttpUtils.executeWithRetry(
        () => http.post(uri, headers: headers, body: encodedBody),
        config: requestConfig,
      );

      // Handle 401 with token refresh and retry
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          final newHeaders = await getHeaders(requiresAuth: true);
          final retryResponse = await http.post(uri, headers: newHeaders, body: encodedBody)
              .timeout(requestConfig.timeout);
          return _handleResponse(retryResponse, fromJson);
        }
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a PUT request with optional retry
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await HttpUtils.executeWithRetry(
        () => http.put(uri, headers: headers, body: encodedBody),
        config: requestConfig,
      );

      // Handle 401 with token refresh and retry
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          final newHeaders = await getHeaders(requiresAuth: true);
          final retryResponse = await http.put(uri, headers: newHeaders, body: encodedBody)
              .timeout(requestConfig.timeout);
          return _handleResponse(retryResponse, fromJson);
        }
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a PATCH request with optional retry
  Future<ApiResponse<T>> patch<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await HttpUtils.executeWithRetry(
        () => http.patch(uri, headers: headers, body: encodedBody),
        config: requestConfig,
      );

      // Handle 401 with token refresh and retry
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          final newHeaders = await getHeaders(requiresAuth: true);
          final retryResponse = await http.patch(uri, headers: newHeaders, body: encodedBody)
              .timeout(requestConfig.timeout);
          return _handleResponse(retryResponse, fromJson);
        }
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a DELETE request with optional retry
  Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final response = await HttpUtils.executeWithRetry(
        () => http.delete(uri, headers: headers),
        config: requestConfig,
      );

      // Handle 401 with token refresh and retry
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await _handleTokenRefresh();
        if (refreshed) {
          final newHeaders = await getHeaders(requiresAuth: true);
          final retryResponse = await http.delete(uri, headers: newHeaders)
              .timeout(requestConfig.timeout);
          return _handleResponse(retryResponse, fromJson);
        }
      }

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload file with multipart request and retry logic (#52)
  Future<ApiResponse<T>> uploadFile<T>(
    String url, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    final uploadConfig = config ?? RequestConfig.fileUpload;
    int attempt = 0;
    Exception? lastException;

    while (attempt < uploadConfig.maxRetries) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse(url));

        // Add headers
        final token = await getToken();
        if (requiresAuth && token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Add file
        request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

        // Add additional fields
        if (fields != null) {
          request.fields.addAll(fields);
        }

        final streamedResponse = await request.send().timeout(uploadConfig.timeout);
        final response = await http.Response.fromStream(streamedResponse);

        // Handle 401 with token refresh and retry
        if (response.statusCode == 401 && requiresAuth) {
          final refreshed = await _handleTokenRefresh();
          if (refreshed) {
            // Retry with new token
            final retryRequest = http.MultipartRequest('POST', Uri.parse(url));
            final newToken = await getToken();
            if (newToken != null) {
              retryRequest.headers['Authorization'] = 'Bearer $newToken';
            }
            retryRequest.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
            if (fields != null) retryRequest.fields.addAll(fields);
            final retryStreamedResponse = await retryRequest.send().timeout(uploadConfig.timeout);
            final retryResponse = await http.Response.fromStream(retryStreamedResponse);
            return _handleResponse(retryResponse, fromJson);
          }
        }

        // Check if we should retry based on status code
        if (response.statusCode >= 500 || response.statusCode == 429) {
          attempt++;
          if (attempt < uploadConfig.maxRetries) {
            final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
            debugPrint('File upload retry $attempt/${uploadConfig.maxRetries} after ${delay.inMilliseconds}ms');
            await Future.delayed(delay);
            continue;
          }
        }

        return _handleResponse(response, fromJson);
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        debugPrint('File upload timeout, attempt $attempt/${uploadConfig.maxRetries}');
        if (attempt < uploadConfig.maxRetries) {
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        }
      } catch (e) {
        // Check if it's a retryable network error
        if (_isRetryableError(e) && attempt < uploadConfig.maxRetries - 1) {
          lastException = e is Exception ? e : Exception(e.toString());
          attempt++;
          debugPrint('File upload network error, attempt $attempt/${uploadConfig.maxRetries}');
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        } else {
          return _handleError(e);
        }
      }
    }

    return _handleError(lastException ?? TimeoutException('File upload failed after ${uploadConfig.maxRetries} attempts'));
  }

  /// Check if error is retryable (#52)
  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('network');
  }

  /// Upload multiple files with multipart request and retry logic (#52)
  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String url, {
    Map<String, File>? files,
    List<File>? fileList,
    String fileListFieldName = 'images',
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    final uploadConfig = config ?? RequestConfig.fileUpload;
    int attempt = 0;
    Exception? lastException;

    while (attempt < uploadConfig.maxRetries) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse(url));

        // Add headers
        final token = await getToken();
        if (requiresAuth && token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Add named files (e.g., profileImage, coverImage)
        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }

        // Add file list (e.g., gallery images)
        if (fileList != null) {
          for (int i = 0; i < fileList.length; i++) {
            request.files.add(
              await http.MultipartFile.fromPath(
                '$fileListFieldName[$i]',
                fileList[i].path,
              ),
            );
          }
        }

        // Add additional fields
        if (fields != null) {
          request.fields.addAll(fields);
        }

        final streamedResponse = await request.send().timeout(uploadConfig.timeout);
        final response = await http.Response.fromStream(streamedResponse);

        // Handle 401 with token refresh and retry
        if (response.statusCode == 401 && requiresAuth) {
          final refreshed = await _handleTokenRefresh();
          if (refreshed) {
            // Retry with new token
            final retryRequest = http.MultipartRequest('POST', Uri.parse(url));
            final newToken = await getToken();
            if (newToken != null) {
              retryRequest.headers['Authorization'] = 'Bearer $newToken';
            }
            if (files != null) {
              for (final entry in files.entries) {
                retryRequest.files.add(
                  await http.MultipartFile.fromPath(entry.key, entry.value.path),
                );
              }
            }
            if (fileList != null) {
              for (int i = 0; i < fileList.length; i++) {
                retryRequest.files.add(
                  await http.MultipartFile.fromPath(
                    '$fileListFieldName[$i]',
                    fileList[i].path,
                  ),
                );
              }
            }
            if (fields != null) retryRequest.fields.addAll(fields);
            final retryStreamedResponse = await retryRequest.send().timeout(uploadConfig.timeout);
            final retryResponse = await http.Response.fromStream(retryStreamedResponse);
            return _handleResponse(retryResponse, fromJson);
          }
        }

        // Check if we should retry based on status code
        if (response.statusCode >= 500 || response.statusCode == 429) {
          attempt++;
          if (attempt < uploadConfig.maxRetries) {
            final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
            debugPrint('Multi-file upload retry $attempt/${uploadConfig.maxRetries}');
            await Future.delayed(delay);
            continue;
          }
        }

        return _handleResponse(response, fromJson);
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        debugPrint('Multi-file upload timeout, attempt $attempt/${uploadConfig.maxRetries}');
        if (attempt < uploadConfig.maxRetries) {
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        }
      } catch (e) {
        if (_isRetryableError(e) && attempt < uploadConfig.maxRetries - 1) {
          lastException = e is Exception ? e : Exception(e.toString());
          attempt++;
          debugPrint('Multi-file upload network error, attempt $attempt/${uploadConfig.maxRetries}');
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        } else {
          return _handleError(e);
        }
      }
    }

    return _handleError(lastException ?? TimeoutException('Multi-file upload failed after ${uploadConfig.maxRetries} attempts'));
  }

  /// Perform a PUT with multipart request (for updates with images)
  Future<ApiResponse<T>> putWithFiles<T>(
    String url, {
    Map<String, File>? files,
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    RequestConfig? config,
  }) async {
    // Check connectivity first
    if (!await _checkConnectivity()) {
      return ApiResponse.failure(error: 'No internet connection');
    }

    final uploadConfig = config ?? RequestConfig.fileUpload;
    int attempt = 0;
    Exception? lastException;

    while (attempt < uploadConfig.maxRetries) {
      try {
        final request = http.MultipartRequest('PUT', Uri.parse(url));

        // Add headers
        final token = await getToken();
        if (requiresAuth && token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        // Add files
        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value.path),
            );
          }
        }

        // Add fields
        if (fields != null) {
          request.fields.addAll(fields);
        }

        final streamedResponse = await request.send().timeout(uploadConfig.timeout);
        final response = await http.Response.fromStream(streamedResponse);

        // Handle 401 with token refresh and retry (once only)
        if (response.statusCode == 401 && requiresAuth) {
          final refreshed = await _handleTokenRefresh();
          if (refreshed) {
            attempt++;
            continue; // Retry with new token
          }
        }

        // Check if we should retry based on status code
        if (response.statusCode >= 500 || response.statusCode == 429) {
          attempt++;
          if (attempt < uploadConfig.maxRetries) {
            final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
            debugPrint('putWithFiles retry $attempt/${uploadConfig.maxRetries} after ${delay.inMilliseconds}ms');
            await Future.delayed(delay);
            continue;
          }
        }

        return _handleResponse(response, fromJson);
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        debugPrint('putWithFiles timeout, attempt $attempt/${uploadConfig.maxRetries}');
        if (attempt < uploadConfig.maxRetries) {
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        }
      } catch (e) {
        if (_isRetryableError(e) && attempt < uploadConfig.maxRetries - 1) {
          lastException = e is Exception ? e : Exception(e.toString());
          attempt++;
          debugPrint('putWithFiles network error, attempt $attempt/${uploadConfig.maxRetries}');
          final delay = Duration(milliseconds: uploadConfig.baseDelayMs * (1 << (attempt - 1)));
          await Future.delayed(delay);
        } else {
          return _handleError(e);
        }
      }
    }

    return _handleError(lastException ?? TimeoutException('putWithFiles failed after ${uploadConfig.maxRetries} attempts'));
  }

  // ==================== Response Handling ====================

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    debugPrint('API Response [${response.statusCode}]: ${response.request?.url}');

    try {
      Map<String, dynamic> data;

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is List) {
          // Handle array responses by wrapping in a map
          data = {'data': decoded};
        } else {
          data = <String, dynamic>{};
        }
      } else {
        data = <String, dynamic>{};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? parsedData;
        if (fromJson != null) {
          // Server wraps response data under a 'data' key:
          // { "success": true, "data": { ...actual model fields... } }
          // Unwrap it before passing to fromJson, but only when 'data' is a Map
          // (list responses and models that read 'data' themselves are unaffected)
          final jsonForModel = data.containsKey('data') && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
          parsedData = fromJson(jsonForModel);
        } else {
          // When no fromJson provided, pass through raw data map
          // so callers can access response fields directly
          parsedData = data as T?;
        }

        return ApiResponse.success(
          data: parsedData,
          message: data['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        final errorMessage = (data['message'] is String ? data['message'] : null) ??
            (data['error'] is String ? data['error'] : null) ??
            'Request failed';

        return ApiResponse.failure(
          error: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('Response parsing error: $e');
      return ApiResponse.failure(
        error: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle errors
  ApiResponse<T> _handleError<T>(dynamic error) {
    debugPrint('API Error: ${error.runtimeType} - $error');

    String message;
    if (error is SocketException) {
      final errorMsg = error.message.toLowerCase();
      final osErrorMsg = error.osError?.message.toLowerCase() ?? '';
      if (errorMsg.contains('failed host lookup') ||
          osErrorMsg.contains('no address associated') ||
          osErrorMsg.contains('name or service not known') ||
          osErrorMsg.contains('nodename nor servname')) {
        message = 'Unable to reach server. Please check your internet connection or try again later.';
      } else if (errorMsg.contains('connection refused') ||
          osErrorMsg.contains('connection refused')) {
        message = 'Server is not responding. Please try again later.';
      } else {
        message = 'Connection error. Please check your internet and try again.';
      }
    } else if (error is TimeoutException) {
      message = 'Request timed out. Please try again.';
    } else if (error is FormatException) {
      message = 'Invalid response format';
    } else if (error is http.ClientException) {
      message = 'Network error. Please check your connection.';
    } else {
      message = 'Something went wrong. Please try again.';
    }

    return ApiResponse.failure(error: message);
  }

  // ==================== Safe Parsing Utilities ====================

  /// Safely parse a list response into typed models
  ///
  /// This method handles:
  /// - Null data
  /// - Data wrapped in 'data' key or as direct list
  /// - Invalid items that can't be cast to Map<String, dynamic>
  /// - Parsing errors for individual items (logs and skips)
  ApiResponse<List<T>> parseListResponse<T>(
    ApiResponse<dynamic> response,
    T Function(Map<String, dynamic>) fromJson, {
    String? listKey,
  }) {
    if (!response.success) {
      return ApiResponse.failure(
        error: response.error,
        statusCode: response.statusCode,
      );
    }

    if (response.data == null) {
      return ApiResponse.success(data: <T>[]);
    }

    try {
      final data = response.data;
      List<dynamic> items = extractList(data, key: listKey);

      // Parse items safely
      final parsedItems = <T>[];
      for (int i = 0; i < items.length; i++) {
        try {
          final item = items[i];
          final map = safeMapCast(item);
          if (map != null) {
            parsedItems.add(fromJson(map));
          } else {
            debugPrint('parseListResponse: Skipping item at index $i - not a Map (${item.runtimeType})');
          }
        } catch (e) {
          debugPrint('parseListResponse: Error parsing item at index $i: $e');
          // Continue parsing other items
        }
      }

      return ApiResponse.success(data: parsedItems);
    } catch (e) {
      debugPrint('parseListResponse: Fatal error: $e');
      return ApiResponse.failure(error: 'Failed to parse response data');
    }
  }

  /// Safely cast a dynamic value to Map<String, dynamic>
  ///
  /// Returns null if the value cannot be safely cast.
  Map<String, dynamic>? safeMapCast(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        debugPrint('safeMapCast: Failed to convert Map: $e');
        return null;
      }
    }
    return null;
  }

  /// Safely extract a list from a response data object
  ///
  /// Tries multiple common keys: 'data', 'items', 'results', or the value itself if it's a list.
  List<dynamic> extractList(dynamic data, {String? key}) {
    if (data == null) return [];

    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      // Try specific key first
      if (key != null && data.containsKey(key)) {
        final value = data[key];
        if (value is List) return value;
      }

      // Try common keys
      for (final commonKey in ['data', 'items', 'results', 'list']) {
        if (data.containsKey(commonKey)) {
          final value = data[commonKey];
          if (value is List) return value;
        }
      }
    }

    return [];
  }
}
