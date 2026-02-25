import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_translator.dart';
import '../../data/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(const PaymentInitial()) {
    on<PaymentLoadStatus>(_onLoadStatus);
    on<PaymentSubscribe>(_onSubscribe);
    on<PaymentBuyCredit>(_onBuyCredit);
    on<PaymentCancelSubscription>(_onCancelSubscription);
    on<PaymentLoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadStatus(
    PaymentLoadStatus event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final isPremium = await _paymentRepository.isPremium();
      final subscription = await _paymentRepository.getSubscriptionStatus();

      emit(PaymentStatusLoaded(
        isPremium: isPremium,
        planType: subscription?['plan_type'] as String?,
        currentPeriodEnd: subscription?['current_period_end'] != null
            ? DateTime.tryParse(subscription!['current_period_end'] as String)
            : null,
        status: subscription?['status'] as String?,
      ));
    } catch (e) {
      debugPrint('[PaymentBloc] Error loading status: $e');
      final failure = ErrorTranslator.translate(e);
      emit(PaymentError(message: failure.message));
    }
  }

  Future<void> _onSubscribe(
    PaymentSubscribe event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final result = await _paymentRepository.subscribe(event.planType);

      if (result.isSuccess) {
        emit(const PaymentSuccess(
          message: 'Abonnement active avec succes !',
        ));
        // Reload status to reflect the new subscription
        add(const PaymentLoadStatus());
      } else if (result.isCancelled) {
        emit(const PaymentCancelled());
        // Reload previous status
        add(const PaymentLoadStatus());
      } else {
        emit(PaymentError(
          message: result.errorMessage ?? 'Erreur lors du paiement.',
        ));
      }
    } catch (e) {
      debugPrint('[PaymentBloc] Subscribe error: $e');
      final failure = ErrorTranslator.translate(e);
      emit(PaymentError(message: failure.message));
    }
  }

  Future<void> _onBuyCredit(
    PaymentBuyCredit event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final result = await _paymentRepository.buyCredit(event.productType);

      if (result.isSuccess) {
        final label = event.productType == 'video_credit'
            ? 'Publication video'
            : 'Affiche';
        emit(PaymentSuccess(
          message: '$label achetee avec succes !',
        ));
        // Reload status
        add(const PaymentLoadStatus());
      } else if (result.isCancelled) {
        emit(const PaymentCancelled());
        // Reload previous status
        add(const PaymentLoadStatus());
      } else {
        emit(PaymentError(
          message: result.errorMessage ?? 'Erreur lors de l\'achat.',
        ));
      }
    } catch (e) {
      debugPrint('[PaymentBloc] Buy credit error: $e');
      final failure = ErrorTranslator.translate(e);
      emit(PaymentError(message: failure.message));
    }
  }

  Future<void> _onLoadHistory(
    PaymentLoadHistory event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final isPremium = await _paymentRepository.isPremium();
      final subscription = await _paymentRepository.getSubscriptionStatus();
      final transactions = await _paymentRepository.getPaymentHistory();
      final credits = await _paymentRepository.getRecruiterCredits();

      emit(PaymentHistoryLoaded(
        isPremium: isPremium,
        planType: subscription?['plan_type'] as String?,
        currentPeriodEnd: subscription?['current_period_end'] != null
            ? DateTime.tryParse(subscription!['current_period_end'] as String)
            : null,
        subscriptionStatus: subscription?['status'] as String?,
        videoCredits: credits['video_credits'] ?? 0,
        posterCredits: credits['poster_credits'] ?? 0,
        transactions: transactions,
      ));
    } catch (e) {
      debugPrint('[PaymentBloc] Error loading history: $e');
      final failure = ErrorTranslator.translate(e);
      emit(PaymentError(message: failure.message));
    }
  }

  Future<void> _onCancelSubscription(
    PaymentCancelSubscription event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final success = await _paymentRepository.cancelSubscription();

      if (success) {
        emit(const PaymentSuccess(
          message: 'Abonnement annule. Il reste actif jusqu\'a la fin de la periode.',
        ));
        // Reload status to show updated state
        add(const PaymentLoadStatus());
      } else {
        emit(const PaymentError(
          message: 'Impossible d\'annuler l\'abonnement. Reessayez plus tard.',
        ));
      }
    } catch (e) {
      debugPrint('[PaymentBloc] Cancel subscription error: $e');
      final failure = ErrorTranslator.translate(e);
      emit(PaymentError(message: failure.message));
    }
  }
}
