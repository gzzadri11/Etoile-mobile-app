library;

/// Modele d'element du feed (video + infos utilisateur).

import 'package:equatable/equatable.dart';

import '../../../video/data/models/video_model.dart';

/// Element du feed : video, nom, secteur, photo, ville.
class FeedItem extends Equatable {
  final Video video;
  final String userName;
  final String? userTitle;
  final String? userLocation;
  final String? userAvatarUrl;
  final bool isRecruiter;
  final bool isVerified;

  // Filterable fields
  final String? region;
  final String? city;
  final String? sector;
  final String? specialty;
  final String? studyLevel;

  const FeedItem({
    required this.video,
    required this.userName,
    this.userTitle,
    this.userLocation,
    this.userAvatarUrl,
    this.isRecruiter = false,
    this.isVerified = false,
    this.region,
    this.city,
    this.sector,
    this.specialty,
    this.studyLevel,
  });

  @override
  List<Object?> get props => [
        video,
        userName,
        userTitle,
        userLocation,
        userAvatarUrl,
        isRecruiter,
        isVerified,
        region,
        city,
        sector,
        specialty,
        studyLevel,
      ];
}

/// Feed filter options
class FeedFilters extends Equatable {
  final String? region;
  final String? sector;
  final String? specialty;
  final String? city;
  final String? studyLevel;

  const FeedFilters({
    this.region,
    this.sector,
    this.specialty,
    this.city,
    this.studyLevel,
  });

  const FeedFilters.empty()
      : region = null,
        sector = null,
        specialty = null,
        city = null,
        studyLevel = null;

  FeedFilters copyWith({
    String? region,
    bool clearRegion = false,
    String? sector,
    bool clearSector = false,
    String? specialty,
    bool clearSpecialty = false,
    String? city,
    bool clearCity = false,
    String? studyLevel,
    bool clearStudyLevel = false,
  }) {
    return FeedFilters(
      region: clearRegion ? null : (region ?? this.region),
      sector: clearSector ? null : (sector ?? this.sector),
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      city: clearCity ? null : (city ?? this.city),
      studyLevel: clearStudyLevel ? null : (studyLevel ?? this.studyLevel),
    );
  }

  bool get hasFilters =>
      region != null ||
      sector != null ||
      specialty != null ||
      city != null ||
      studyLevel != null;

  FeedFilters clear() => const FeedFilters.empty();

  @override
  List<Object?> get props => [
        region,
        sector,
        specialty,
        city,
        studyLevel,
      ];
}
