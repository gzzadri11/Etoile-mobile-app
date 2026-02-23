import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/stripe_service.dart';

/// Repository for payment and subscription data
class PaymentRepository {
  final SupabaseClient _supabaseClient;
  final StripeService _stripeService;

  PaymentRepository({
    required SupabaseClient supabaseClient,
    required StripeService stripeService,
  })  : _supabaseClient = supabaseClient,
        _stripeService = stripeService;

  /// Get the current user's active subscription status
  ///
  /// Returns null if no active subscription exists.
  Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabaseClient
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .inFilter('status', ['active', 'trialing', 'past_due'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    debugPrint('[PaymentRepository] Subscription status: $response');
    return response;
  }

  /// Check if the current user is premium (from users table)
  Future<bool> isPremium() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabaseClient
        .from('users')
        .select('is_premium')
        .eq('id', userId)
        .single();

    return response['is_premium'] == true;
  }

  /// Subscribe to a premium plan via Stripe Payment Sheet
  ///
  /// [planType] must be 'seeker_premium' or 'recruiter_premium'
  Future<PaymentResult> subscribe(String planType) async {
    final priceId = _priceIdForPlan(planType);
    debugPrint('[PaymentRepository] Subscribe: planType=$planType, priceId=$priceId');

    return _stripeService.presentSubscriptionPaymentSheet(priceId: priceId);
  }

  /// Buy credits via Stripe Payment Sheet (one-time purchase)
  ///
  /// [productType] must be 'video_credit' or 'poster_credit'
  Future<PaymentResult> buyCredit(String productType) async {
    final priceId = _priceIdForProduct(productType);
    debugPrint('[PaymentRepository] Buy credit: productType=$productType, priceId=$priceId');

    return _stripeService.presentOneTimePaymentSheet(priceId: priceId);
  }

  /// Cancel the current user's active subscription
  Future<bool> cancelSubscription() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return false;

    // Get the active subscription's Stripe ID
    final sub = await getSubscriptionStatus();
    final stripeSubId = sub?['stripe_subscription_id'] as String?;
    if (stripeSubId == null) {
      debugPrint('[PaymentRepository] No active subscription to cancel');
      return false;
    }

    debugPrint('[PaymentRepository] Cancelling subscription: $stripeSubId');
    return _stripeService.cancelSubscription(stripeSubId);
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  /// Map plan type to Stripe price ID
  String _priceIdForPlan(String planType) {
    switch (planType) {
      case 'seeker_premium':
        return StripePrices.seekerPremiumMonthly;
      case 'recruiter_premium':
        return StripePrices.recruiterPremiumMonthly;
      default:
        throw ArgumentError('Unknown plan type: $planType');
    }
  }

  /// Map product type to Stripe price ID
  String _priceIdForProduct(String productType) {
    switch (productType) {
      case 'video_credit':
        return StripePrices.videoCreditUnit;
      case 'poster_credit':
        return StripePrices.posterCreditUnit;
      default:
        throw ArgumentError('Unknown product type: $productType');
    }
  }
}
