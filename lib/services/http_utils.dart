import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/environment.dart';

/// HTTP request configuration
class RequestConfig {
  /// Request timeout
  final Duration timeout;

  /// Maximum retry attempts
  final int maxRetries;

  /// Whether to use exponential backoff
  final bool useExponentialBackoff;

  /// Base delay for exponential backoff (in milliseconds)
  final int baseDelayMs;

  /// Maximum delay for exponential backoff (in milliseconds)
  final int maxDelayMs;

  /// Whether this request should be cached
  final bool enableCache;

  /// Cache duration
  final Duration cacheDuration;

  const RequestConfig({
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.useExponentialBackoff = true,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 16000,
    this.enableCache = false,
    this.cacheDuration = const Duration(minutes: 5),
  });

  /// Default configuration using environment settings
  factory RequestConfig.fromEnvironment({
    int? maxRetries,
    bool? enableCache,
    Duration? cacheDuration,
  }) {
    return RequestConfig(
      timeout: Duration(seconds: AppConfig.requestTimeout),
      maxRetries: maxRetries ?? 3,
      enableCache: enableCache ?? false,
      cacheDuration: cacheDuration ?? const Duration(minutes: 5),
    );
  }

  /// Configuration for critical requests (longer timeout, more retries)
  static const RequestConfig critical = RequestConfig(
    timeout: Duration(seconds: 60),
    maxRetries: 5,
    useExponentialBackoff: true,
  );

  /// Configuration for quick requests (shorter timeout, fewer retries)
  static const RequestConfig quick = RequestConfig(
    timeout: Duration(seconds: 15),
    maxRetries: 2,
    useExponentialBackoff: true,
  );

  /// Configuration for cached GET requests
  static const RequestConfig cached = RequestConfig(
    timeout: Duration(seconds: 30),
    maxRetries: 2,
    enableCache: true,
    cacheDuration: Duration(minutes: 5),
  );

  /// Configuration for file uploads (longer timeout, more retries) (#59)
  static const RequestConfig fileUpload = RequestConfig(
    timeout: Duration(seconds: 120),
    maxRetries: 3,
    useExponentialBackoff: true,
    baseDelayMs: 2000,
    maxDelayMs: 30000,
  );

  /// Configuration for real-time operations (shorter timeout) (#59)
  static const RequestConfig realtime = RequestConfig(
    timeout: Duration(seconds: 10),
    maxRetries: 2,
    useExponentialBackoff: false,
    baseDelayMs: 500,
  );

  /// Configuration for payment operations (longer timeout, more retries) (#59)
  static const RequestConfig payment = RequestConfig(
    timeout: Duration(seconds: 60),
    maxRetries: 4,
    useExponentialBackoff: true,
    baseDelayMs: 1000,
    maxDelayMs: 16000,
  );
}

/// HTTP utilities for retry logic, caching, and rate limiting
class HttpUtils {
  static final HttpUtils _instance = HttpUtils._internal();
  factory HttpUtils() => _instance;
  HttpUtils._internal();

  // ==================== Retry Logic ====================

  /// Execute an HTTP request with retry logic and exponential backoff
  ///
  /// Returns the response or throws after all retries are exhausted.
  static Future<http.Response> executeWithRetry(
    Future<http.Response> Function() request, {
    RequestConfig config = const RequestConfig(),
  }) async {
    Exception? lastException;
    int attempt = 0;

    while (attempt < config.maxRetries) {
      try {
        final response = await request().timeout(config.timeout);

        // Check if we should retry based on status code
        if (_shouldRetry(response.statusCode)) {
          lastException = HttpRetryException(
            'Server returned ${response.statusCode}',
            response.statusCode,
          );
          attempt++;

          if (attempt < config.maxRetries) {
            final delay = _calculateDelay(attempt, config);
            debugPrint('HttpUtils: Retry $attempt/${config.maxRetries} after ${delay.inMilliseconds}ms');
            await Future.delayed(delay);
            continue;
          }
        }

        return response;
      } on TimeoutException catch (e) {
        lastException = e;
        attempt++;
        debugPrint('HttpUtils: Request timeout, attempt $attempt/${config.maxRetries}');

        if (attempt < config.maxRetries) {
          final delay = _calculateDelay(attempt, config);
          await Future.delayed(delay);
        }
      } on Exception catch (e) {
        // Check if it's a retryable network error
        if (_isRetryableError(e)) {
          lastException = e;
          attempt++;
          debugPrint('HttpUtils: Network error, attempt $attempt/${config.maxRetries}');

          if (attempt < config.maxRetries) {
            final delay = _calculateDelay(attempt, config);
            await Future.delayed(delay);
          }
        } else {
          // Non-retryable error, throw immediately
          rethrow;
        }
      }
    }

    throw lastException ?? TimeoutException('Request failed after ${config.maxRetries} attempts');
  }

  /// Check if the status code indicates we should retry
  static bool _shouldRetry(int statusCode) {
    // Retry on server errors (5xx) and rate limiting (429)
    return statusCode >= 500 || statusCode == 429 || statusCode == 408;
  }

  /// Check if the error is retryable
  static bool _isRetryableError(dynamic error) {
    // Network errors are generally retryable
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('network');
  }

  /// Calculate delay with exponential backoff and jitter
  static Duration _calculateDelay(int attempt, RequestConfig config) {
    if (!config.useExponentialBackoff) {
      return Duration(milliseconds: config.baseDelayMs);
    }

    // Exponential backoff: baseDelay * 2^attempt
    final exponentialDelay = config.baseDelayMs * pow(2, attempt - 1);

    // Cap at maxDelay
    final cappedDelay = min(exponentialDelay.toInt(), config.maxDelayMs);

    // Add jitter (0-25% of delay) to prevent thundering herd
    final jitter = Random().nextInt((cappedDelay * 0.25).toInt());

    return Duration(milliseconds: cappedDelay + jitter);
  }

  // ==================== Rate Limiting ====================

  static final Map<String, DateTime> _rateLimitResets = {};
  static final Map<String, int> _requestCounts = {};
  static const int _maxRequestsPerMinute = 60;

  /// Check if we're being rate limited and should wait
  static Future<void> checkRateLimit(String endpoint) async {
    final now = DateTime.now();
    final resetTime = _rateLimitResets[endpoint];

    // If we have a reset time in the future, wait
    if (resetTime != null && now.isBefore(resetTime)) {
      final waitTime = resetTime.difference(now);
      debugPrint('HttpUtils: Rate limited, waiting ${waitTime.inSeconds}s');
      await Future.delayed(waitTime);
    }

    // Simple client-side rate limiting
    final key = '${endpoint}_${now.minute}';
    _requestCounts[key] = (_requestCounts[key] ?? 0) + 1;

    if (_requestCounts[key]! > _maxRequestsPerMinute) {
      debugPrint('HttpUtils: Client rate limit reached for $endpoint');
      await Future.delayed(const Duration(seconds: 1));
    }

    // Clean old entries
    _requestCounts.removeWhere((k, v) => !k.contains('_${now.minute}'));
  }

  /// Handle rate limit response (429)
  static Future<Duration> handleRateLimitResponse(
    http.Response response,
    String endpoint,
  ) async {
    // Parse Retry-After header if present
    final retryAfter = response.headers['retry-after'];
    Duration waitDuration;

    if (retryAfter != null) {
      // Try parsing as seconds
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) {
        waitDuration = Duration(seconds: seconds);
      } else {
        // Default to 60 seconds
        waitDuration = const Duration(seconds: 60);
      }
    } else {
      waitDuration = const Duration(seconds: 60);
    }

    // Store reset time
    _rateLimitResets[endpoint] = DateTime.now().add(waitDuration);

    debugPrint('HttpUtils: Rate limit hit for $endpoint, reset in ${waitDuration.inSeconds}s');

    return waitDuration;
  }

  // ==================== Response Caching ====================

  static final Map<String, CacheEntry> _cache = {};
  static final Map<String, Completer<http.Response?>> _pendingRequests = {}; // #56: Prevent cache race conditions

  /// Get cached response if available and not expired
  static http.Response? getCachedResponse(String cacheKey) {
    final entry = _cache[cacheKey];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(cacheKey);
      return null;
    }

    debugPrint('HttpUtils: Cache hit for $cacheKey');
    return entry.response;
  }

  /// Cache a response with race condition prevention (#56)
  static void cacheResponse(
    String cacheKey,
    http.Response response, {
    Duration duration = const Duration(minutes: 5),
  }) {
    // Only cache successful responses
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _cache[cacheKey] = CacheEntry(
        response: response,
        expiresAt: DateTime.now().add(duration),
      );
      debugPrint('HttpUtils: Cached response for $cacheKey (expires in ${duration.inMinutes}m)');

      // Complete any pending requests waiting for this cache entry
      final pending = _pendingRequests.remove(cacheKey);
      if (pending != null && !pending.isCompleted) {
        pending.complete(response);
      }
    }
  }

  /// Check if a request is already pending for this cache key (#56)
  static bool isRequestPending(String cacheKey) {
    return _pendingRequests.containsKey(cacheKey);
  }

  /// Wait for a pending request to complete (#56)
  static Future<http.Response?> waitForPendingRequest(String cacheKey) async {
    final pending = _pendingRequests[cacheKey];
    if (pending != null) {
      debugPrint('HttpUtils: Waiting for pending request for $cacheKey');
      return pending.future;
    }
    return null;
  }

  /// Mark a request as pending (#56)
  static void markRequestPending(String cacheKey) {
    if (!_pendingRequests.containsKey(cacheKey)) {
      _pendingRequests[cacheKey] = Completer<http.Response?>();
    }
  }

  /// Complete a pending request (called on error) (#56)
  static void completePendingRequest(String cacheKey, {http.Response? response}) {
    final pending = _pendingRequests.remove(cacheKey);
    if (pending != null && !pending.isCompleted) {
      pending.complete(response);
    }
  }

  /// Generate cache key from URL and headers
  static String generateCacheKey(String url, Map<String, String>? headers) {
    final headerString = headers?.entries
            .where((e) => e.key != 'Authorization') // Don't include auth in cache key
            .map((e) => '${e.key}:${e.value}')
            .join('|') ??
        '';
    return '$url|$headerString';
  }

  /// Clear all cached responses
  static void clearCache() {
    _cache.clear();
    debugPrint('HttpUtils: Cache cleared');
  }

  /// Clear expired cache entries
  static void clearExpiredCache() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Clear cache for a specific endpoint pattern
  static void clearCachePattern(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }
}

/// Cache entry with expiration
class CacheEntry {
  final http.Response response;
  final DateTime expiresAt;

  CacheEntry({
    required this.response,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Exception for HTTP retry scenarios
class HttpRetryException implements Exception {
  final String message;
  final int statusCode;

  HttpRetryException(this.message, this.statusCode);

  @override
  String toString() => 'HttpRetryException: $message (status: $statusCode)';
}
