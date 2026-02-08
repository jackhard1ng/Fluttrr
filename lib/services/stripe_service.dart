import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import 'token_manager.dart';

/// Result of a payment operation
class PaymentResult {
  final bool success;
  final String? message;
  final String? error;
  final Map<String, dynamic>? data;

  PaymentResult({
    required this.success,
    this.message,
    this.error,
    this.data,
  });

  factory PaymentResult.success({String? message, Map<String, dynamic>? data}) {
    return PaymentResult(success: true, message: message, data: data);
  }

  factory PaymentResult.failure(String error) {
    return PaymentResult(success: false, error: error);
  }
}

/// Stripe payment service for handling payments
class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  /// Stripe publishable key from environment variable
  /// IMPORTANT: This must be set via --dart-define=STRIPE_PUBLISHABLE_KEY=your_key
  static const String? _publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  ) == '' ? null : String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  bool _isInitialized = false;
  bool _initializationFailed = false;

  /// Check if Stripe is properly configured
  static bool get isConfigured => _publishableKey != null && _publishableKey!.isNotEmpty;

  /// Initialize Stripe
  static Future<void> initialize({String? publishableKey}) async {
    await _instance._init(publishableKey);
  }

  Future<void> _init(String? publishableKey) async {
    if (_isInitialized) return;
    if (_initializationFailed) return;

    final keyToUse = publishableKey ?? _publishableKey;

    if (keyToUse == null || keyToUse.isEmpty) {
      debugPrint('Warning: Stripe publishable key not configured. Payment features will be disabled.');
      debugPrint('Set STRIPE_PUBLISHABLE_KEY via --dart-define or pass it to initialize()');
      _initializationFailed = true;
      return;
    }

    try {
      Stripe.publishableKey = keyToUse;
      Stripe.merchantIdentifier = 'merchant.com.fluttrr';
      await Stripe.instance.applySettings();
      _isInitialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Stripe: $e');
      _initializationFailed = true;
    }
  }

  /// Get auth token from TokenManager (single source of truth)
  Future<String?> _getAuthToken() async {
    return TokenManager.getToken();
  }

  /// Safely parse JSON response body
  ///
  /// Returns null if parsing fails, preventing crashes from malformed responses.
  Map<String, dynamic>? _safeJsonDecode(String body) {
    try {
      if (body.isEmpty) return null;
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } on FormatException catch (e) {
      debugPrint('StripeService: JSON parse error: $e');
      return null;
    } catch (e) {
      debugPrint('StripeService: Unexpected error parsing JSON: $e');
      return null;
    }
  }

  /// Create a payment intent on the server
  Future<PaymentResult> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return PaymentResult.failure('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.createPaymentIntent),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) {
        return PaymentResult.failure('Invalid server response');
      }

      // Check for 2xx status codes, not just 200
      if (response.statusCode >= 200 && response.statusCode < 300 && responseData['clientSecret'] != null) {
        return PaymentResult.success(
          data: {
            'clientSecret': responseData['clientSecret'],
            'paymentIntentId': responseData['paymentIntentId'],
          },
        );
      } else {
        return PaymentResult.failure(
          responseData['error']?.toString() ?? 'Failed to create payment intent',
        );
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return PaymentResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Present the payment sheet
  Future<PaymentResult> presentPaymentSheet({
    required String clientSecret,
    String merchantDisplayName = 'Fluttrr',
    Color? primaryColor,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: primaryColor ?? Colors.blue,
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
          billingDetails: const BillingDetails(
            email: null,
            phone: null,
            name: null,
            address: Address(
              city: null,
              country: null,
              line1: null,
              line2: null,
              postalCode: null,
              state: null,
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(message: 'Payment completed successfully');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.failure('Payment cancelled');
      }
      return PaymentResult.failure(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      debugPrint('Error presenting payment sheet: $e');
      return PaymentResult.failure('Payment error: ${e.toString()}');
    }
  }

  /// Complete the full payment flow
  Future<PaymentResult> processPayment({
    required int amount,
    required String currency,
    String merchantDisplayName = 'Fluttrr',
    Map<String, dynamic>? metadata,
  }) async {
    // Check if Stripe is initialized
    if (!_isInitialized) {
      return PaymentResult.failure(
        'Payment service not available. Please try again later.',
      );
    }

    // Create payment intent
    final intentResult = await createPaymentIntent(
      amount: amount,
      currency: currency,
      metadata: metadata,
    );

    if (!intentResult.success) {
      return intentResult;
    }

    final clientSecret = intentResult.data?['clientSecret'] as String?;
    final paymentIntentId = intentResult.data?['paymentIntentId'] as String?;

    if (clientSecret == null) {
      return PaymentResult.failure('Invalid payment intent response');
    }

    // Payment intent ID is required for verification
    if (paymentIntentId == null) {
      debugPrint('StripeService: Warning - No paymentIntentId received, payment cannot be verified');
      return PaymentResult.failure('Payment intent ID missing - cannot verify payment');
    }

    // Present payment sheet
    final sheetResult = await presentPaymentSheet(
      clientSecret: clientSecret,
      merchantDisplayName: merchantDisplayName,
    );

    if (!sheetResult.success) {
      return sheetResult;
    }

    // Always verify payment with server - never trust client-side success
    return await verifyPayment(paymentIntentId: paymentIntentId);
  }

  /// Verify payment with server
  Future<PaymentResult> verifyPayment({
    required String paymentIntentId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return PaymentResult.failure('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.verifyPayment),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
        }),
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) {
        return PaymentResult.failure('Invalid verification response');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return PaymentResult.success(
          message: 'Payment verified successfully',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error']?.toString() ?? 'Failed to verify payment',
        );
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return PaymentResult.failure('Verification error: ${e.toString()}');
    }
  }

  /// Upgrade user to premium
  ///
  /// SECURITY: Premium status is only saved locally after server confirmation.
  /// The local flag is used as a cache - always verify with server for critical operations.
  Future<PaymentResult> upgradeToPremium({
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return PaymentResult.failure('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.upgradeToPremium),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
        }),
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) {
        return PaymentResult.failure('Invalid upgrade response');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Only save premium status if server explicitly confirms it
        final serverConfirmedPremium = responseData['isPremium'] == true ||
            responseData['premium'] == true ||
            responseData['success'] == true;

        if (serverConfirmedPremium) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isPremium', true);
          // Also save the timestamp for cache invalidation
          await prefs.setInt('premiumVerifiedAt', DateTime.now().millisecondsSinceEpoch);
        }

        return PaymentResult.success(
          message: 'Successfully upgraded to premium',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error']?.toString() ?? 'Failed to upgrade to premium',
        );
      }
    } catch (e) {
      debugPrint('Error upgrading to premium: $e');
      return PaymentResult.failure('Upgrade error: ${e.toString()}');
    }
  }

  /// Check if user has premium status
  ///
  /// Returns cached value for quick checks. For critical operations,
  /// use [verifyPremiumStatus] to check with server.
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('isPremium') ?? false;

    if (!isPremium) return false;

    // Check if cache is older than 24 hours
    final verifiedAt = prefs.getInt('premiumVerifiedAt') ?? 0;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - verifiedAt;
    final cacheDuration = const Duration(hours: 24).inMilliseconds;

    if (cacheAge > cacheDuration) {
      debugPrint('StripeService: Premium cache expired, should re-verify');
      // Note: Don't automatically clear - let the caller decide to verify
    }

    return isPremium;
  }

  /// Verify premium status with server
  ///
  /// Use this for critical operations that require confirmed premium access.
  Future<bool> verifyPremiumStatus() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse(ApiEndpoints.subscriptionStatus),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) return false;

      final isPremium = responseData['isPremium'] == true ||
          responseData['premium'] == true ||
          responseData['active'] == true;

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', isPremium);
      await prefs.setInt('premiumVerifiedAt', DateTime.now().millisecondsSinceEpoch);

      return isPremium;
    } catch (e) {
      debugPrint('Error verifying premium status: $e');
      return false;
    }
  }

  /// Clear premium status
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isPremium');
    await prefs.remove('premiumVerifiedAt');
  }

  /// Create a subscription
  Future<PaymentResult> createSubscription({
    required String priceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return PaymentResult.failure('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.createSubscription),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'priceId': priceId,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) {
        return PaymentResult.failure('Invalid subscription response');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return PaymentResult.success(data: responseData);
      } else {
        return PaymentResult.failure(
          responseData['error']?.toString() ?? 'Failed to create subscription',
        );
      }
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return PaymentResult.failure('Subscription error: ${e.toString()}');
    }
  }

  /// Cancel a subscription
  Future<PaymentResult> cancelSubscription({
    required String subscriptionId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return PaymentResult.failure('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.cancelSubscription),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'subscriptionId': subscriptionId,
        }),
      );

      final responseData = _safeJsonDecode(response.body);
      if (responseData == null) {
        return PaymentResult.failure('Invalid cancellation response');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Clear premium status locally only after server confirmation
        await clearPremiumStatus();

        return PaymentResult.success(
          message: 'Subscription cancelled successfully',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error']?.toString() ?? 'Failed to cancel subscription',
        );
      }
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return PaymentResult.failure('Cancellation error: ${e.toString()}');
    }
  }
}
