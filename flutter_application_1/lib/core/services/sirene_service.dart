import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Result of a SIRET verification via API Sirene.
class SiretVerificationResult {
  final bool isValid;
  final String? companyName;
  final String? siren;
  final String? legalForm;
  final String? errorMessage;

  const SiretVerificationResult({
    required this.isValid,
    this.companyName,
    this.siren,
    this.legalForm,
    this.errorMessage,
  });

  factory SiretVerificationResult.valid({
    required String companyName,
    String? siren,
    String? legalForm,
  }) {
    return SiretVerificationResult(
      isValid: true,
      companyName: companyName,
      siren: siren,
      legalForm: legalForm,
    );
  }

  factory SiretVerificationResult.invalid(String message) {
    return SiretVerificationResult(isValid: false, errorMessage: message);
  }
}

/// Service for verifying SIRET numbers via the French government API.
///
/// Uses https://recherche-entreprises.api.gouv.fr (free, no auth key).
class SireneService {
  static const _baseUrl = 'https://recherche-entreprises.api.gouv.fr';

  final Dio _dio;

  SireneService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// Verify a SIRET number and return company information if valid.
  ///
  /// Returns [SiretVerificationResult] with company name if the SIRET
  /// exists and the company is active. Returns an error message otherwise.
  Future<SiretVerificationResult> verifySiret(String siret) async {
    // Format validation
    final cleaned = siret.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length != 14 || !RegExp(r'^\d{14}$').hasMatch(cleaned)) {
      return SiretVerificationResult.invalid(
        'Le SIRET doit contenir exactement 14 chiffres',
      );
    }

    try {
      debugPrint('[SireneService] Verifying SIRET: $cleaned');

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'q': cleaned, 'page': 1, 'per_page': 1},
      );

      if (response.statusCode != 200) {
        debugPrint(
          '[SireneService] API error: ${response.statusCode}',
        );
        return SiretVerificationResult.invalid(
          'Vérification impossible, réessayez plus tard',
        );
      }

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List?;

      if (results == null || results.isEmpty) {
        debugPrint('[SireneService] SIRET not found: $cleaned');
        return SiretVerificationResult.invalid(
          'Ce SIRET n\'est pas valide, vérifiez et réessayez',
        );
      }

      // Find matching etablissement with this exact SIRET
      final company = results.first as Map<String, dynamic>;

      // Check if company is active
      final matchingEtablissements =
          company['matching_etablissements'] as List?;
      if (matchingEtablissements != null &&
          matchingEtablissements.isNotEmpty) {
        final etab = matchingEtablissements.first as Map<String, dynamic>;
        final isClosed = etab['est_siege'] == false &&
            etab['etat_administratif'] == 'F';
        if (isClosed) {
          debugPrint('[SireneService] Etablissement closed: $cleaned');
          return SiretVerificationResult.invalid(
            'Cet établissement est fermé',
          );
        }
      }

      // Extract company name
      final companyName = (company['nom_complet'] as String?) ??
          (company['nom_raison_sociale'] as String?) ??
          '';

      if (companyName.isEmpty) {
        debugPrint('[SireneService] No company name found for: $cleaned');
        return SiretVerificationResult.invalid(
          'Ce SIRET n\'est pas valide, vérifiez et réessayez',
        );
      }

      // Extract SIREN (first 9 digits of SIRET)
      final siren = company['siren'] as String?;

      // Extract legal form
      final legalForm = company['nature_juridique'] as String?;

      debugPrint(
        '[SireneService] SIRET valid: $cleaned -> $companyName',
      );

      return SiretVerificationResult.valid(
        companyName: companyName,
        siren: siren,
        legalForm: legalForm,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        debugPrint('[SireneService] Network error');
        return SiretVerificationResult.invalid(
          'Vérification impossible, vérifiez votre connexion',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        debugPrint('[SireneService] Timeout');
        return SiretVerificationResult.invalid(
          'Vérification trop longue, réessayez plus tard',
        );
      }
      debugPrint('[SireneService] Dio error: $e');
      return SiretVerificationResult.invalid(
        'Vérification impossible, réessayez plus tard',
      );
    } catch (e) {
      debugPrint('[SireneService] Unexpected error: $e');
      return SiretVerificationResult.invalid(
        'Vérification impossible, réessayez plus tard',
      );
    }
  }
}
