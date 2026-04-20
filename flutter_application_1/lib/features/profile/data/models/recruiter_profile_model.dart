library;

/// Modele de profil recruteur.
///
/// Contient les informations de l'entreprise (nom, SIRET, secteur),
/// la localisation et le statut de verification.

import 'package:equatable/equatable.dart';

/// Model representing a recruiter's company profile
class RecruiterProfile extends Equatable {
  final String userId;
  final String companyName;
  final String? siret;
  final String? siren;
  final String? legalForm;
  final String? documentType;
  final String? documentUrl;
  final DateTime? documentUploadedAt;
  final String? logoUrl;
  final String? description;
  final String? sector;
  final List<String> locations;
  final double? latitude;
  final double? longitude;
  final String verificationStatus;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final int videoCredits;
  final int posterCredits;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecruiterProfile({
    required this.userId,
    required this.companyName,
    this.siret,
    this.siren,
    this.legalForm,
    this.documentType,
    this.documentUrl,
    this.documentUploadedAt,
    this.logoUrl,
    this.description,
    this.sector,
    this.locations = const [],
    this.latitude,
    this.longitude,
    this.verificationStatus = 'pending',
    this.verifiedAt,
    this.rejectionReason,
    this.videoCredits = 1,
    this.posterCredits = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Profile completion percentage (5 categories x 20% = 100%)
  ///
  /// - Inscription (20%): always complete (user registered)
  /// - Company (20%): companyName (not "A completer") + sector non-empty
  /// - Description (20%): description >= 50 characters
  /// - Location (20%): locations non-empty
  /// - Verification (20%): siret filled + document uploaded
  int get completionPercentage {
    // Verified by admin = profile considered 100% complete
    if (isVerified) return 100;

    int score = 20; // Inscription always complete
    if (companyName.isNotEmpty &&
        companyName != 'A completer' &&
        sector != null &&
        sector!.isNotEmpty) {
      score += 20;
    }
    if (description != null && description!.length >= 50) score += 20;
    if (locations.isNotEmpty) score += 20;
    if (siret != null &&
        siret!.isNotEmpty &&
        documentUrl != null &&
        documentUrl!.isNotEmpty) {
      score += 20;
    }
    return score;
  }

  /// Check if company is verified
  bool get isVerified => verificationStatus == 'verified';

  /// Check if verification is pending
  bool get isPending => verificationStatus == 'pending';

  /// Check if verification was rejected
  bool get isRejected => verificationStatus == 'rejected';

  /// Create from Supabase JSON
  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String? ?? '',
      siret: json['siret'] as String?,
      siren: json['siren'] as String?,
      legalForm: json['legal_form'] as String?,
      documentType: json['document_type'] as String?,
      documentUrl: json['document_url'] as String?,
      documentUploadedAt: json['document_uploaded_at'] != null
          ? DateTime.parse(json['document_uploaded_at'] as String)
          : null,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      sector: json['sector'] as String?,
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      videoCredits: json['video_credits'] as int? ?? 1,
      posterCredits: json['poster_credits'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'siret': siret,
      'siren': siren,
      'legal_form': legalForm,
      'document_type': documentType,
      'document_url': documentUrl,
      'logo_url': logoUrl,
      'description': description,
      'sector': sector,
      'locations': locations,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create a copy with updated fields
  RecruiterProfile copyWith({
    String? companyName,
    String? siret,
    String? siren,
    String? legalForm,
    String? documentType,
    String? documentUrl,
    DateTime? documentUploadedAt,
    String? logoUrl,
    String? description,
    String? sector,
    List<String>? locations,
    double? latitude,
    double? longitude,
    String? verificationStatus,
    int? videoCredits,
    int? posterCredits,
  }) {
    return RecruiterProfile(
      userId: userId,
      companyName: companyName ?? this.companyName,
      siret: siret ?? this.siret,
      siren: siren ?? this.siren,
      legalForm: legalForm ?? this.legalForm,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      documentUploadedAt: documentUploadedAt ?? this.documentUploadedAt,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      locations: locations ?? this.locations,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt,
      rejectionReason: rejectionReason,
      videoCredits: videoCredits ?? this.videoCredits,
      posterCredits: posterCredits ?? this.posterCredits,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        companyName,
        siret,
        siren,
        legalForm,
        documentType,
        documentUrl,
        logoUrl,
        description,
        sector,
        locations,
        latitude,
        longitude,
        verificationStatus,
        videoCredits,
        posterCredits,
      ];
}
