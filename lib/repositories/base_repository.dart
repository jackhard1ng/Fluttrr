import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/api_response.dart';
import '../services/token_manager.dart';
import '../services/auth_event_handler.dart';
import '../services/http_utils.dart';

/// Base repository with common HTTP operations
///
/// Features:
/// - Automatic retry with exponential backoff
/// - Configurable timeouts per request
/// - Response caching for GET requests
/// - Rate limiting handling
abstract class BaseRepository {
  /// Default timeout from environment config
  Duration get _defaultTimeout => Duration(seconds: AppConfig.requestTimeout);

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

  /// Get headers with optional auth token
  Future<Map<String, String>> getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Perform a GET request with optional retry and caching
  Future<ApiResponse<T>> get<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    Map<String, String>? queryParams,
    RequestConfig? config,
  }) async {
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
    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final response = await HttpUtils.executeWithRetry(
        () => http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ),
        config: requestConfig,
      );

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
    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final response = await HttpUtils.executeWithRetry(
        () => http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ),
        config: requestConfig,
      );

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
    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final response = await HttpUtils.executeWithRetry(
        () => http.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ),
        config: requestConfig,
      );

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
    try {
      final uri = Uri.parse(url);
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final requestConfig = config ?? RequestConfig.fromEnvironment();

      await HttpUtils.checkRateLimit(uri.host);

      final response = await HttpUtils.executeWithRetry(
        () => http.delete(uri, headers: headers),
        config: requestConfig,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>(
    String url, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
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

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Upload multiple files with multipart request
  Future<ApiResponse<T>> uploadMultipleFiles<T>(
    String url, {
    Map<String, File>? files,
    List<File>? fileList,
    String fileListFieldName = 'images',
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
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

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a PUT with multipart request (for updates with images)
  Future<ApiResponse<T>> putWithFiles<T>(
    String url, {
    Map<String, File>? files,
    Map<String, String>? fields,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
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

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

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
          parsedData = fromJson(data);
        }
        // Only cast if no fromJson provided and T is dynamic or Map
        // This avoids unsafe casts

        return ApiResponse.success(
          data: parsedData,
          message: data['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        final errorMessage = (data['message'] ?? data['error'] ?? 'Request failed') as String;

        // Handle 401 Unauthorized - trigger global auth handler
        if (response.statusCode == 401) {
          debugPrint('BaseRepository: 401 Unauthorized - triggering auth handler');
          // Fire and forget - don't await to avoid blocking the response
          AuthEventHandler().handleUnauthorized(message: errorMessage);
        }

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
    debugPrint('API Error: ${error.runtimeType}');

    String message;
    if (error is SocketException) {
      message = 'No internet connection';
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
  ///
  /// Example usage:
  /// ```dart
  /// final response = await get<dynamic>(ApiEndpoints.activities);
  /// return parseListResponse(response, ActivityModel.fromJson);
  /// ```
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
