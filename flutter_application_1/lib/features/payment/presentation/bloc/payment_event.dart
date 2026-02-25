import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current user's subscription status
class PaymentLoadStatus extends PaymentEvent {
  const PaymentLoadStatus();
}

/// Subscribe to a premium plan (B2B: recruiter only)
class PaymentSubscribe extends PaymentEvent {
  final String planType; // 'recruiter_premium'

  const PaymentSubscribe({required this.planType});

  @override
  List<Object?> get props => [planType];
}

/// Buy credits (video or poster)
class PaymentBuyCredit extends PaymentEvent {
  final String productType; // 'video_credit' or 'poster_credit'

  const PaymentBuyCredit({required this.productType});

  @override
  List<Object?> get props => [productType];
}

/// Cancel an active subscription
class PaymentCancelSubscription extends PaymentEvent {
  const PaymentCancelSubscription();
}

/// Load payment history (subscriptions + purchases)
class PaymentLoadHistory extends PaymentEvent {
  const PaymentLoadHistory();
}
