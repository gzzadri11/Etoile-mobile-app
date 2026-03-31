library;

/// Traducteur d'exceptions brutes en [Failure] typees.
///
/// Convertit les exceptions Supabase, Stripe et reseau en
/// erreurs applicatives avec messages francais pour l'utilisateur.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/failures.dart';

/// Traduit les exceptions brutes en [Failure] typees avec messages FR.
abstract class ErrorTranslator {
  /// Translate any exception into a typed [Failure].
  static Failure translate(dynamic exception) {
    final failure = _doTranslate(exception);
    debugPrint(
      '[ErrorTranslator] ${exception.runtimeType} -> ${failure.runtimeType}'
      '(code: ${failure.code}, message: ${failure.message})',
    );
    return failure;
  }

  static Failure _doTranslate(dynamic exception) {
    // =========================================================================
    // Supabase Auth exceptions
    // =========================================================================
    if (exception is AuthException) {
      return _translateAuthException(exception);
    }

    // =========================================================================
    // Supabase Postgrest exceptions (DB queries)
    // =========================================================================
    if (exception is PostgrestException) {
      return _translatePostgrestException(exception);
    }

    // =========================================================================
    // Supabase Storage exceptions
    // =========================================================================
    if (exception is StorageException) {
      return ServerFailure(
        message: exception.message,
        code: 'STORAGE_ERROR',
        statusCode: exception.statusCode != null
            ? int.tryParse(exception.statusCode!)
            : null,
      );
    }

    // =========================================================================
    // Stripe exceptions
    // =========================================================================
    if (exception is StripeException) {
      return _translateStripeException(exception);
    }

    // =========================================================================
    // Network exceptions
    // =========================================================================
    if (exception is SocketException) {
      return const NetworkFailure();
    }

    if (exception is TimeoutException) {
      return const NetworkFailure(
        message: 'La requete a expire. Verifiez votre connexion.',
        code: 'TIMEOUT',
      );
    }

    if (exception is HttpException) {
      return const NetworkFailure(
        message: 'Erreur de communication avec le serveur.',
        code: 'HTTP_ERROR',
      );
    }

    // =========================================================================
    // Already a Failure — pass through
    // =========================================================================
    if (exception is Failure) {
      return exception;
    }

    // =========================================================================
    // Fallback
    // =========================================================================
    return const UnknownFailure();
  }

  // ===========================================================================
  // Supabase Auth
  // ===========================================================================
  static Failure _translateAuthException(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return AuthFailure.invalidCredentials();
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered')) {
      return AuthFailure.emailAlreadyExists();
    }
    if (msg.contains('password') && msg.contains('weak') ||
        msg.contains('at least')) {
      return AuthFailure.weakPassword();
    }
    if (msg.contains('invalid email') || msg.contains('unable to validate')) {
      return AuthFailure.invalidEmail();
    }
    if (msg.contains('email not confirmed')) {
      return AuthFailure.emailNotVerified();
    }
    if (msg.contains('session') && msg.contains('expir')) {
      return AuthFailure.sessionExpired();
    }
    if (msg.contains('disabled') || msg.contains('banned')) {
      return AuthFailure.accountDisabled();
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return ServerFailure.fromStatusCode(429);
    }

    // Generic auth failure with original message
    return AuthFailure(
      message: e.message,
      code: e.statusCode,
    );
  }

  // ===========================================================================
  // Supabase Postgrest
  // ===========================================================================
  static Failure _translatePostgrestException(PostgrestException e) {
    final code = e.code;

    // PostgreSQL error codes
    // https://www.postgresql.org/docs/current/errcodes-appendix.html
    switch (code) {
      case '23505': // unique_violation
        return const ServerFailure(
          message: 'Cette donnee existe deja.',
          code: 'DUPLICATE',
          statusCode: 409,
        );
      case '23503': // foreign_key_violation
        return const ServerFailure(
          message: 'Reference invalide. La donnee liee n\'existe pas.',
          code: 'FOREIGN_KEY',
          statusCode: 422,
        );
      case '23502': // not_null_violation
        return const ServerFailure(
          message: 'Un champ obligatoire est manquant.',
          code: 'NOT_NULL',
          statusCode: 422,
        );
      case '42501': // insufficient_privilege (RLS)
        return const ServerFailure(
          message: 'Acces refuse.',
          code: 'RLS_DENIED',
          statusCode: 403,
        );
      case 'PGRST301': // JWT expired
        return AuthFailure.sessionExpired();
      default:
        // Use HTTP status code if available
        if (e.code != null) {
          final httpCode = int.tryParse(e.code!);
          if (httpCode != null && httpCode >= 400) {
            return ServerFailure.fromStatusCode(httpCode);
          }
        }
        return ServerFailure(
          message: e.message,
          code: code ?? 'POSTGREST_ERROR',
        );
    }
  }

  // ===========================================================================
  // Stripe
  // ===========================================================================
  static Failure _translateStripeException(StripeException e) {
    final code = e.error.code;

    if (code == FailureCode.Canceled) {
      return PaymentFailure.paymentCancelled();
    }
    if (code == FailureCode.Failed) {
      final msg = e.error.localizedMessage?.toLowerCase() ?? '';
      if (msg.contains('insufficient funds')) {
        return PaymentFailure.insufficientFunds();
      }
      if (msg.contains('declined') || msg.contains('refuse')) {
        return PaymentFailure.cardDeclined();
      }
      return PaymentFailure(
        message: e.error.localizedMessage ?? 'Le paiement a echoue.',
        code: 'STRIPE_FAILED',
      );
    }

    return PaymentFailure(
      message: e.error.localizedMessage ?? 'Erreur de paiement.',
      code: 'STRIPE_ERROR',
    );
  }
}
