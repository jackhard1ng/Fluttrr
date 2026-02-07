import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';

class ApiService {
  static const String _baseUrl = 'https://api.fluttrr.app/v1';
  static String? _authToken;

  // Set auth token for authenticated requests
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token on logout
  static void clearAuthToken() {
    _authToken = null;
  }

  // Headers
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // GET request
  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams?.map(
            (k, v) => MapEntry(k, v.toString()),
          ));

      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(success: false, error: _getErrorMessage(e));
    }
  }

  // POST request
  static Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(success: false, error: _getErrorMessage(e));
    }
  }

  // PUT request
  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(success: false, error: _getErrorMessage(e));
    }
  }

  // PATCH request
  static Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(success: false, error: _getErrorMessage(e));
    }
  }

  // DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse<T>(success: false, error: _getErrorMessage(e));
    }
  }

  // Handle response
  static ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (statusCode >= 200 && statusCode < 300) {
      if (fromJson != null && body.isNotEmpty) {
        return ApiResponse<T>(success: true, data: fromJson(body));
      }
      return ApiResponse<T>(success: true);
    }

    // Handle error responses
    final message = body['message'] ?? body['error'] ?? 'Something went wrong';

    switch (statusCode) {
      case 400:
        return ApiResponse<T>(success: false, error: 'Bad request: $message');
      case 401:
        return ApiResponse<T>(success: false, error: 'Unauthorized: Please log in again');
      case 403:
        return ApiResponse<T>(success: false, error: 'Forbidden: You don\'t have permission');
      case 404:
        return ApiResponse<T>(success: false, error: 'Not found');
      case 422:
        return ApiResponse<T>(success: false, error: 'Validation error: $message');
      case 429:
        return ApiResponse<T>(success: false, error: 'Too many requests. Please wait.');
      case 500:
      case 502:
      case 503:
        return ApiResponse<T>(success: false, error: 'Server error. Please try again later.');
      default:
        return ApiResponse<T>(success: false, error: message);
    }
  }

  static String _getErrorMessage(dynamic error) {
    debugPrint('API Error: $error');
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out';
    }
    return 'Something went wrong';
  }
}

// API endpoints
class ApiEndpoints {
  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const refreshToken = '/auth/refresh';
  static const forgotPassword = '/auth/forgot-password';

  // Users
  static const me = '/users/me';
  static String user(String id) => '/users/$id';
  static const updateProfile = '/users/me';
  static const uploadAvatar = '/users/me/avatar';

  // Events
  static const events = '/events';
  static String event(String id) => '/events/$id';
  static String eventAttendees(String id) => '/events/$id/attendees';
  static String rsvp(String id) => '/events/$id/rsvp';
  static String checkin(String id) => '/events/$id/checkin';

  // Friends
  static const friends = '/friends';
  static const friendRequests = '/friends/requests';
  static String friend(String id) => '/friends/$id';
  static String sendRequest(String id) => '/friends/request/$id';

  // Chat
  static const chats = '/chats';
  static String chat(String id) => '/chats/$id';
  static String messages(String chatId) => '/chats/$chatId/messages';

  // Notifications
  static const notifications = '/notifications';
  static String notification(String id) => '/notifications/$id';
  static const markAllRead = '/notifications/read-all';

  // Business
  static const business = '/business';
  static String businessProfile(String id) => '/business/$id';
  static const businessEvents = '/business/events';
  static const businessAnalytics = '/business/analytics';
}
