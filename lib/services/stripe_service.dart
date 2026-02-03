import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';

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

  static const String _publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_YOUR_TEST_KEY',
  );

  bool _isInitialized = false;

  /// Initialize Stripe
  static Future<void> initialize({String? publishableKey}) async {
    await _instance._init(publishableKey);
  }

  Future<void> _init(String? publishableKey) async {
    if (_isInitialized) return;

    try {
      Stripe.publishableKey = publishableKey ?? _publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.fluttrr';
      await Stripe.instance.applySettings();
      _isInitialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Stripe: $e');
    }
  }

  /// Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['clientSecret'] != null) {
        return PaymentResult.success(
          data: {
            'clientSecret': responseData['clientSecret'],
            'paymentIntentId': responseData['paymentIntentId'],
          },
        );
      } else {
        return PaymentResult.failure(
          responseData['error'] ?? 'Failed to create payment intent',
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

    // Present payment sheet
    final sheetResult = await presentPaymentSheet(
      clientSecret: clientSecret,
      merchantDisplayName: merchantDisplayName,
    );

    if (!sheetResult.success) {
      return sheetResult;
    }

    // Verify payment and upgrade if necessary
    if (paymentIntentId != null) {
      return await verifyPayment(paymentIntentId: paymentIntentId);
    }

    return PaymentResult.success(message: 'Payment successful');
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PaymentResult.success(
          message: 'Payment verified successfully',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error'] ?? 'Failed to verify payment',
        );
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return PaymentResult.failure('Verification error: ${e.toString()}');
    }
  }

  /// Upgrade user to premium
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Save premium status locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);

        return PaymentResult.success(
          message: 'Successfully upgraded to premium',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error'] ?? 'Failed to upgrade to premium',
        );
      }
    } catch (e) {
      debugPrint('Error upgrading to premium: $e');
      return PaymentResult.failure('Upgrade error: ${e.toString()}');
    }
  }

  /// Check if user has premium status
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  /// Clear premium status
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isPremium');
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PaymentResult.success(data: responseData);
      } else {
        return PaymentResult.failure(
          responseData['error'] ?? 'Failed to create subscription',
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

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Clear premium status locally
        await clearPremiumStatus();

        return PaymentResult.success(
          message: 'Subscription cancelled successfully',
          data: responseData,
        );
      } else {
        return PaymentResult.failure(
          responseData['error'] ?? 'Failed to cancel subscription',
        );
      }
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return PaymentResult.failure('Cancellation error: ${e.toString()}');
    }
  }
}
