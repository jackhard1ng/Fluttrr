import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';

class StripeServiceNew {
  static final String _baseUrl = '${Apis.baseurl}/paymet';
  final String? stripePublishableKey;

  StripeServiceNew({this.stripePublishableKey}) {
    if (stripePublishableKey != null) {
      Stripe.publishableKey = stripePublishableKey!;
      Stripe.merchantIdentifier = 'merchant.flutter.stripe';
    }
  }

  // Create a payment intent with your server
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await http.post(
        Uri.parse('$_baseUrl/stripe/create-payment-intent'),
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

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'clientSecret': responseData['clientSecret'],
          'paymentIntentId': responseData['paymentIntentId'],
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred: ${e.toString()}',
      };
    }
  }

  // Initialize and present the PaymentSheet
  Future<Map<String, dynamic>> presentPaymentSheet({
    required String clientSecret,
    required String paymentIntentId,
    String merchantDisplayName = 'Your App Name',
  }) async {
    try {
      // 1. Initialize PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blue, // Your brand color
            ),
          ),
        ),
      );

      // 2. Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // 3. Verify payment with your server
      final verificationResponse = await verifyAndUpgrade(
        paymentMethod: 'stripe',
        transactionId: paymentIntentId,
      );

      if (verificationResponse['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        return {'success': true, 'message': 'Payment successful'};
      } else {
        return verificationResponse;
      }
    } on StripeException catch (e) {
      return {
        'success': false,
        'error': 'Stripe error: ${e.error.localizedMessage}',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred: ${e.toString()}',
      };
    }
  }

  // Complete payment flow using PaymentSheet
  Future<Map<String, dynamic>> completePaymentFlow({
    required int amount,
    required String currency,
    String merchantDisplayName = 'Your App Name',
  }) async {
    try {
      // 1. Create payment intent
      final intent = await createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      if (!intent['success']) {
        return intent;
      }

      // 2. Present PaymentSheet
      return await presentPaymentSheet(
        clientSecret: intent['clientSecret'],
        paymentIntentId: intent['paymentIntentId'],
        merchantDisplayName: merchantDisplayName,
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment failed: ${e.toString()}',
      };
    }
  }

  // Verify payment with your server and upgrade to premium
  Future<Map<String, dynamic>> verifyAndUpgrade({
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await http.post(
        Uri.parse('$_baseUrl/upgrade-to-premium'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
        }),
      );

      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': responseData,
        if (response.statusCode != 200) 'error': responseData['error'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception occurred: ${e.toString()}',
      };
    }
  }

  // Check if user is premium from SharedPreferences
  Future<bool> isUserPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  // Clear premium status
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isPremium');
  }
}
