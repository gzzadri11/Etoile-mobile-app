library;

/// Repository des paiements et abonnements.
///
/// Gere les interactions avec Stripe (creation de session checkout,
/// portail client) et Supabase (statut abonnement, historique factures).

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/stripe_service.dart';

/// Repository pour les donnees de paiement et d'abonnement.
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
        .from('user_roles')
        .select('is_premium')
        .eq('user_id', userId)
        .single();

    return response['is_premium'] == true;
  }

  /// Subscribe to a premium plan via Stripe Payment Sheet
  ///
  /// [planType] must be 'recruiter_premium' (B2B model)
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

  /// Get payment history (all subscriptions + purchases)
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final List<Map<String, dynamic>> transactions = [];

    // Subscriptions
    final subs = await _supabaseClient
        .from('subscriptions')
        .select('id, plan_type, status, created_at, current_period_end')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    for (final sub in subs) {
      transactions.add({
        'date': sub['created_at'],
        'description': 'Premium Recruteur',
        'amount': '499 EUR',
        'status': sub['status'],
        'type': 'subscription',
      });
    }

    // Purchases
    final purchases = await _supabaseClient
        .from('purchases')
        .select('id, description, amount, status, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    for (final p in purchases) {
      transactions.add({
        'date': p['created_at'],
        'description': p['description'] ?? 'Achat',
        'amount': '${p['amount']} EUR',
        'status': p['status'],
        'type': 'purchase',
      });
    }

    // Sort by date desc
    transactions.sort((a, b) =>
        (b['date'] as String).compareTo(a['date'] as String));

    debugPrint('[PaymentRepository] History: ${transactions.length} transactions');
    return transactions;
  }

  /// Get recruiter credits
  Future<Map<String, int>> getRecruiterCredits() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) return {'video_credits': 0, 'poster_credits': 0};

    final response = await _supabaseClient
        .from('recruiter_profiles')
        .select('video_credits, poster_credits')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return {'video_credits': 0, 'poster_credits': 0};

    return {
      'video_credits': (response['video_credits'] as num?)?.toInt() ?? 0,
      'poster_credits': (response['poster_credits'] as num?)?.toInt() ?? 0,
    };
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  /// Map plan type to Stripe price ID (B2B: recruiters only)
  String _priceIdForPlan(String planType) {
    switch (planType) {
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
