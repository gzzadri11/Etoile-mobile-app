import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Failures represent expected errors that can be handled gracefully.
/// They are used with the Either type from dartz package.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures (API errors)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure(
          message: 'Requete invalide',
          code: 'BAD_REQUEST',
          statusCode: 400,
        );
      case 401:
        return const ServerFailure(
          message: 'Non autorise. Veuillez vous reconnecter.',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      case 403:
        return const ServerFailure(
          message: 'Acces refuse',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      case 404:
        return const ServerFailure(
          message: 'Ressource introuvable',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      case 409:
        return const ServerFailure(
          message: 'Conflit de donnees',
          code: 'CONFLICT',
          statusCode: 409,
        );
      case 422:
        return const ServerFailure(
          message: 'Donnees invalides',
          code: 'UNPROCESSABLE_ENTITY',
          statusCode: 422,
        );
      case 429:
        return const ServerFailure(
          message: 'Trop de requetes. Veuillez patienter.',
          code: 'TOO_MANY_REQUESTS',
          statusCode: 429,
        );
      case 500:
        return const ServerFailure(
          message: 'Erreur serveur. Nos equipes sont informees.',
          code: 'INTERNAL_ERROR',
          statusCode: 500,
        );
      case 503:
        return const ServerFailure(
          message: 'Service temporairement indisponible',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: 503,
        );
      default:
        return ServerFailure(
          message: 'Erreur serveur ($statusCode)',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
    }
  }

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network-related failures (connectivity issues)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Oups, petit souci de connexion. Reessayez dans un instant.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache-related failures (local storage issues)
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Erreur de cache local',
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Email ou mot de passe incorrect',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.emailAlreadyExists() => const AuthFailure(
        message: 'Cet email est deja utilise',
        code: 'EMAIL_EXISTS',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Le mot de passe doit contenir au moins 8 caracteres',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.invalidEmail() => const AuthFailure(
        message: 'Veuillez entrer un email valide',
        code: 'INVALID_EMAIL',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Votre session a expire. Reconnectez-vous pour continuer.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.accountDisabled() => const AuthFailure(
        message: 'Votre compte a ete desactive',
        code: 'ACCOUNT_DISABLED',
      );

  factory AuthFailure.emailNotVerified() => const AuthFailure(
        message: 'Veuillez verifier votre email',
        code: 'EMAIL_NOT_VERIFIED',
      );
}

/// Video-related failures
class VideoFailure extends Failure {
  const VideoFailure({
    required super.message,
    super.code,
  });

  factory VideoFailure.uploadFailed() => const VideoFailure(
        message: 'Aie, la video n\'a pas pu etre envoyee. On reessaie ?',
        code: 'UPLOAD_FAILED',
      );

  factory VideoFailure.recordingFailed() => const VideoFailure(
        message: 'Erreur lors de l\'enregistrement',
        code: 'RECORDING_FAILED',
      );

  factory VideoFailure.invalidDuration() => const VideoFailure(
        message: 'La video doit durer exactement 40 secondes',
        code: 'INVALID_DURATION',
      );

  factory VideoFailure.fileTooLarge() => const VideoFailure(
        message: 'La video est trop volumineuse (max 50 MB)',
        code: 'FILE_TOO_LARGE',
      );

  factory VideoFailure.cameraPermissionDenied() => const VideoFailure(
        message: 'Acces a la camera refuse. Activez-le dans les parametres.',
        code: 'CAMERA_PERMISSION_DENIED',
      );

  factory VideoFailure.microphonePermissionDenied() => const VideoFailure(
        message: 'Acces au microphone refuse. Activez-le dans les parametres.',
        code: 'MICROPHONE_PERMISSION_DENIED',
      );
}

/// Payment-related failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code,
  });

  factory PaymentFailure.cardDeclined() => const PaymentFailure(
        message: 'Paiement refuse. Verifiez vos informations de carte.',
        code: 'CARD_DECLINED',
      );

  factory PaymentFailure.insufficientFunds() => const PaymentFailure(
        message: 'Fonds insuffisants',
        code: 'INSUFFICIENT_FUNDS',
      );

  factory PaymentFailure.paymentCancelled() => const PaymentFailure(
        message: 'Paiement annule',
        code: 'PAYMENT_CANCELLED',
      );

  factory PaymentFailure.subscriptionNotFound() => const PaymentFailure(
        message: 'Abonnement introuvable',
        code: 'SUBSCRIPTION_NOT_FOUND',
      );
}

/// Validation failures (form validation)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  factory ValidationFailure.requiredField(String fieldName) => ValidationFailure(
        message: 'Le champ $fieldName est requis',
        fieldErrors: {fieldName: 'Ce champ est requis'},
      );

  factory ValidationFailure.invalidFormat(String fieldName) => ValidationFailure(
        message: 'Format invalide pour $fieldName',
        fieldErrors: {fieldName: 'Format invalide'},
      );

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code = 'PERMISSION_DENIED',
  });
}

/// Generic/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Quelque chose s\'est mal passe. Notre equipe est sur le coup !',
    super.code = 'UNKNOWN_ERROR',
  });
}
