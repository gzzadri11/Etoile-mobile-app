library;

/// Etats du BLoC de paiement.
///
/// Represente les differents etats du cycle de paiement :
/// initial, chargement, statut charge, succes/erreur de souscription.

import 'package:equatable/equatable.dart';

/// Classe de base des etats de paiement.
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Subscription status loaded successfully
class PaymentStatusLoaded extends PaymentState {
  final bool isPremium;
  final String? planType;
  final DateTime? currentPeriodEnd;
  final String? status; // 'active', 'canceled', 'past_due', 'expired'

  const PaymentStatusLoaded({
    required this.isPremium,
    this.planType,
    this.currentPeriodEnd,
    this.status,
  });

  @override
  List<Object?> get props => [isPremium, planType, currentPeriodEnd, status];
}

/// Payment (subscription or credit purchase) succeeded
class PaymentSuccess extends PaymentState {
  final String message;

  const PaymentSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Payment was cancelled by the user
class PaymentCancelled extends PaymentState {
  const PaymentCancelled();
}

/// Payment history loaded (subscription + purchases)
class PaymentHistoryLoaded extends PaymentState {
  final bool isPremium;
  final String? planType;
  final DateTime? currentPeriodEnd;
  final String? subscriptionStatus;
  final int videoCredits;
  final int posterCredits;
  final List<Map<String, dynamic>> transactions;

  const PaymentHistoryLoaded({
    required this.isPremium,
    this.planType,
    this.currentPeriodEnd,
    this.subscriptionStatus,
    this.videoCredits = 0,
    this.posterCredits = 0,
    this.transactions = const [],
  });

  @override
  List<Object?> get props => [
        isPremium,
        planType,
        currentPeriodEnd,
        subscriptionStatus,
        videoCredits,
        posterCredits,
        transactions,
      ];
}

/// Payment or status load failed
class PaymentError extends PaymentState {
  final String message;

  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}
