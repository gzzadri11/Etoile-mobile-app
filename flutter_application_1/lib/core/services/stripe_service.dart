import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode, Color;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';
import 'supabase_service.dart';

/// Service for handling Stripe payments
///
/// Provides:
/// - Stripe SDK initialization
/// - Payment sheet for subscriptions and one-time payments
/// - Customer management
/// - Payment method handling
class StripeService {
  final SupabaseService _supabaseService;
  bool _isInitialized = false;

  StripeService({
    required SupabaseService supabaseService,
  }) : _supabaseService = supabaseService;

  /// Initialize Stripe SDK
  ///
  /// Must be called before any Stripe operations.
  /// Typically called in main.dart after AppConfig.initialize()
  Future<void> initialize() async {
    if (_isInitialized) return;

    final publishableKey = AppConfig.stripePublishableKey;
    if (publishableKey.isEmpty || publishableKey.startsWith('pk_')) {
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = AppConfig.stripeMerchantId;

      // Set URL scheme for returns (iOS)
      await Stripe.instance.applySettings();

      _isInitialized = true;

      if (AppConfig.enableDebugMode) {
        debugPrint('[StripeService] Initialized successfully');
        debugPrint('[StripeService] Mode: ${_isTestMode ? "TEST" : "LIVE"}');
      }
    } else {
      if (AppConfig.enableDebugMode) {
        debugPrint('[StripeService] Skipped - No valid publishable key');
      }
    }
  }

  /// Check if running in test mode
  bool get _isTestMode =>
      AppConfig.stripePublishableKey.startsWith('pk_test_');

  /// Check if Stripe is properly configured
  bool get isConfigured =>
      AppConfig.stripePublishableKey.isNotEmpty &&
      AppConfig.stripePublishableKey.startsWith('pk_');

  // ===========================================================================
  // PAYMENT SHEET
  // ===========================================================================

  /// Create a payment sheet for subscription checkout
  ///
  /// [priceId] - Stripe Price ID for the subscription
  /// [customerId] - Stripe Customer ID (optional, will be created if null)
  ///
  /// Returns payment result after user completes checkout.
  Future<PaymentResult> presentSubscriptionPaymentSheet({
    required String priceId,
    String? customerId,
  }) async {
    _ensureInitialized();

    try {
      // Create payment intent via Edge Function
      final response = await _supabaseService.invokeFunction(
        'create-subscription-intent',
        body: {
          'priceId': priceId,
          'customerId': customerId,
          'userId': _supabaseService.userId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['error'] != null) {
        return PaymentResult.failed(data['error'] as String);
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'] as String,
          customerId: data['customerId'] as String?,
          customerEphemeralKeySecret: data['ephemeralKey'] as String?,
          merchantDisplayName: AppConfig.appName,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFFFB800), // Etoile yellow
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        subscriptionId: data['subscriptionId'] as String?,
        customerId: data['customerId'] as String?,
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled();
      }
      return PaymentResult.failed(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      debugPrint('[StripeService] Payment error: $e');
      return PaymentResult.failed('An unexpected error occurred');
    }
  }

  /// Create a payment sheet for one-time purchase (credits)
  ///
  /// [priceId] - Stripe Price ID for the product
  /// [quantity] - Number of items to purchase
  Future<PaymentResult> presentOneTimePaymentSheet({
    required String priceId,
    int quantity = 1,
  }) async {
    _ensureInitialized();

    try {
      // Create payment intent via Edge Function
      final response = await _supabaseService.invokeFunction(
        'create-payment-intent',
        body: {
          'priceId': priceId,
          'quantity': quantity,
          'userId': _supabaseService.userId,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['error'] != null) {
        return PaymentResult.failed(data['error'] as String);
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'] as String,
          customerId: data['customerId'] as String?,
          customerEphemeralKeySecret: data['ephemeralKey'] as String?,
          merchantDisplayName: AppConfig.appName,
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success(
        paymentIntentId: data['paymentIntentId'] as String?,
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled();
      }
      return PaymentResult.failed(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      debugPrint('[StripeService] Payment error: $e');
      return PaymentResult.failed('An unexpected error occurred');
    }
  }

  // ===========================================================================
  // SUBSCRIPTION MANAGEMENT
  // ===========================================================================

  /// Cancel a subscription
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final response = await _supabaseService.invokeFunction(
        'cancel-subscription',
        body: {
          'subscriptionId': subscriptionId,
          'userId': _supabaseService.userId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      debugPrint('[StripeService] Cancel subscription error: $e');
      return false;
    }
  }

  /// Get customer portal URL for subscription management
  Future<String?> getCustomerPortalUrl() async {
    try {
      final response = await _supabaseService.invokeFunction(
        'create-portal-session',
        body: {
          'userId': _supabaseService.userId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      debugPrint('[StripeService] Portal URL error: $e');
      return null;
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const PaymentFailure(
        message: 'Stripe not initialized. Call initialize() first.',
        code: 'NOT_INITIALIZED',
      );
    }
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

/// Result of a payment operation
class PaymentResult {
  final PaymentStatus status;
  final String? errorMessage;
  final String? subscriptionId;
  final String? customerId;
  final String? paymentIntentId;

  const PaymentResult._({
    required this.status,
    this.errorMessage,
    this.subscriptionId,
    this.customerId,
    this.paymentIntentId,
  });

  factory PaymentResult.success({
    String? subscriptionId,
    String? customerId,
    String? paymentIntentId,
  }) =>
      PaymentResult._(
        status: PaymentStatus.success,
        subscriptionId: subscriptionId,
        customerId: customerId,
        paymentIntentId: paymentIntentId,
      );

  factory PaymentResult.failed(String message) => PaymentResult._(
        status: PaymentStatus.failed,
        errorMessage: message,
      );

  factory PaymentResult.cancelled() => const PaymentResult._(
        status: PaymentStatus.cancelled,
      );

  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
}

/// Payment operation status
enum PaymentStatus {
  success,
  failed,
  cancelled,
}

/// Stripe product IDs (match with Stripe Dashboard)
abstract class StripeProducts {
  // Subscriptions
  static const String seekerPremium = 'seeker_premium';
  static const String recruiterPremium = 'recruiter_premium';

  // One-time purchases
  static const String videoCredit = 'video_credit';
  static const String posterCredit = 'poster_credit';
}

/// Stripe price IDs (to be set after creating products in Stripe)
abstract class StripePrices {
  // These should be replaced with actual price IDs from Stripe Dashboard
  // Format: price_XXXXXXXXXXXXXXXXXXXXXXXX

  // Subscriptions (monthly)
  static const String seekerPremiumMonthly = 'price_seeker_premium_monthly';
  static const String recruiterPremiumMonthly = 'price_recruiter_premium_monthly';

  // One-time
  static const String videoCreditUnit = 'price_video_credit';
  static const String posterCreditUnit = 'price_poster_credit';
}
