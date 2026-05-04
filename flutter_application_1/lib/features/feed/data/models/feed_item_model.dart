library;

/// Modele d'element du feed (video + infos utilisateur).

import 'package:equatable/equatable.dart';

import '../../../video/data/models/video_model.dart';

/// Element du feed : video, nom, secteur, photo, ville, coordonnees.
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

  // Coordinates for proximity filter
  final double? latitude;
  final double? longitude;

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
    this.latitude,
    this.longitude,
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
        latitude,
        longitude,
      ];
}

/// Feed filter options
class FeedFilters extends Equatable {
  final String? region;
  final String? sector;
  final String? specialty;
  final String? city;
  final String? studyLevel;
  final String? rhythm; // Task #3
  final double? proximityKm;
  final double? userLatitude;
  final double? userLongitude;

  const FeedFilters({
    this.region,
    this.sector,
    this.specialty,
    this.city,
    this.studyLevel,
    this.rhythm,
    this.proximityKm,
    this.userLatitude,
    this.userLongitude,
  });

  const FeedFilters.empty()
      : region = null,
        sector = null,
        specialty = null,
        city = null,
        studyLevel = null,
        rhythm = null,
        proximityKm = null,
        userLatitude = null,
        userLongitude = null;

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
    String? rhythm,
    bool clearRhythm = false,
    double? proximityKm,
    bool clearProximityKm = false,
    double? userLatitude,
    bool clearUserLatitude = false,
    double? userLongitude,
    bool clearUserLongitude = false,
  }) {
    return FeedFilters(
      region: clearRegion ? null : (region ?? this.region),
      sector: clearSector ? null : (sector ?? this.sector),
      specialty: clearSpecialty ? null : (specialty ?? this.specialty),
      city: clearCity ? null : (city ?? this.city),
      studyLevel: clearStudyLevel ? null : (studyLevel ?? this.studyLevel),
      rhythm: clearRhythm ? null : (rhythm ?? this.rhythm),
      proximityKm: clearProximityKm ? null : (proximityKm ?? this.proximityKm),
      userLatitude: clearUserLatitude ? null : (userLatitude ?? this.userLatitude),
      userLongitude: clearUserLongitude ? null : (userLongitude ?? this.userLongitude),
    );
  }

  bool get hasFilters =>
      region != null ||
      sector != null ||
      specialty != null ||
      city != null ||
      studyLevel != null ||
      rhythm != null ||
      proximityKm != null;

  FeedFilters clear() => const FeedFilters.empty();

  @override
  List<Object?> get props => [
        region,
        sector,
        specialty,
        city,
        studyLevel,
        rhythm,
        proximityKm,
        userLatitude,
        userLongitude,
      ];
}
