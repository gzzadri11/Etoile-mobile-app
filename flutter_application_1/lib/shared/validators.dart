/// Validators partages pour les formulaires.
///
/// Centralise les regles de validation pour eviter la duplication
/// entre les pages login, register, forgot_password, etc.
library;

import '../core/constants/app_strings.dart';

/// Regex pour validation email (format RFC simplifie)
final _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

/// Valide un email : requis + format correct.
/// Retourne un message d'erreur ou null si valide.
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
  if (!_emailRegex.hasMatch(value)) return AppStrings.errorInvalidEmail;
  return null;
}

/// Valide un champ obligatoire (non vide).
String? validateRequired(String? value) {
  if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
  return null;
}

/// Valide un mot de passe : requis + minimum 8 caracteres.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
  if (value.length < 8) return AppStrings.errorInvalidPassword;
  return null;
}

/// Valide la confirmation de mot de passe.
String? Function(String?) validatePasswordConfirmation(String password) {
  return (String? value) {
    if (value == null || value.isEmpty) return AppStrings.errorFieldRequired;
    if (value != password) return AppStrings.errorPasswordMismatch;
    return null;
  };
}
