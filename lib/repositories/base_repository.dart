import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_response.dart';

/// Base repository with common HTTP operations
abstract class BaseRepository {
  static const Duration _timeout = Duration(seconds: 30);

  /// Get the auth token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Save the auth token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Remove the auth token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
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

  /// Perform a GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a PATCH request
  Future<ApiResponse<T>> patch<T>(
    String url, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Perform a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(Map<String, dynamic>)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await getHeaders(requiresAuth: requiresAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(_timeout);

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
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final data = body is Map<String, dynamic> ? body : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: fromJson != null ? fromJson(data) : data as T?,
          message: data['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.failure(
          error: data['message'] ?? data['error'] ?? 'Request failed',
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
    debugPrint('API Error: $error');

    String message;
    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Request timed out';
    } else {
      message = 'Something went wrong';
    }

    return ApiResponse.failure(error: message);
  }
}
