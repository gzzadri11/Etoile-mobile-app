library;

/// Modele de profil recruteur et marqueur cartographique.
///
/// Contient les informations de l'entreprise (nom, SIRET, secteur),
/// la localisation et le statut de verification.

import 'package:equatable/equatable.dart';

/// Marqueur nomme sur la carte (siege de l'entreprise).
class MapMarker extends Equatable {
  final String name;
  final double latitude;
  final double longitude;

  const MapMarker({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      name: json['name'] as String? ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': latitude,
        'lng': longitude,
      };

  @override
  List<Object?> get props => [name, latitude, longitude];
}

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
  final String? coverUrl;
  final String? description;
  final String? website;
  final String? sector;
  final String? companySize;
  final List<String> locations;
  final List<MapMarker> mapMarkers;
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
    this.coverUrl,
    this.description,
    this.website,
    this.sector,
    this.companySize,
    this.locations = const [],
    this.mapMarkers = const [],
    this.verificationStatus = 'pending',
    this.verifiedAt,
    this.rejectionReason,
    this.videoCredits = 1,
    this.posterCredits = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasMapMarkers => mapMarkers.isNotEmpty;

  /// Profile completion percentage (5 categories x 20% = 100%)
  ///
  /// - Inscription (20%): always complete (user registered)
  /// - Company (20%): companyName (not "A completer") + sector non-empty
  /// - Description (20%): description >= 50 characters
  /// - Location (20%): locations or mapMarkers non-empty
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
    if (locations.isNotEmpty || mapMarkers.isNotEmpty) score += 20;
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
      coverUrl: json['cover_url'] as String?,
      description: json['description'] as String?,
      website: json['website'] as String?,
      sector: json['sector'] as String?,
      companySize: json['company_size'] as String?,
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mapMarkers: (json['map_markers'] as List<dynamic>?)
              ?.map((e) => MapMarker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'cover_url': coverUrl,
      'description': description,
      'website': website,
      'sector': sector,
      'company_size': companySize,
      'locations': locations,
      'map_markers': mapMarkers.map((m) => m.toJson()).toList(),
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
    String? coverUrl,
    String? description,
    String? website,
    String? sector,
    String? companySize,
    List<String>? locations,
    List<MapMarker>? mapMarkers,
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
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      website: website ?? this.website,
      sector: sector ?? this.sector,
      companySize: companySize ?? this.companySize,
      locations: locations ?? this.locations,
      mapMarkers: mapMarkers ?? this.mapMarkers,
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
        coverUrl,
        description,
        website,
        sector,
        companySize,
        locations,
        mapMarkers,
        verificationStatus,
        videoCredits,
        posterCredits,
      ];
}
