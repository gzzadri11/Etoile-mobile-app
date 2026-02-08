import 'package:equatable/equatable.dart';

import '../../../video/data/models/video_model.dart';

/// Model representing a feed item (video + user info for display)
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
  final List<String> categories;
  final List<String> contractTypes;
  final String? availability;

  // Role-specific filterable fields
  final String? experienceLevel;
  final String? salaryExpectation;
  final String? sector;

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
    this.categories = const [],
    this.contractTypes = const [],
    this.availability,
    this.experienceLevel,
    this.salaryExpectation,
    this.sector,
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
        categories,
        contractTypes,
        availability,
        experienceLevel,
        salaryExpectation,
        sector,
      ];
}

/// Feed filter options
class FeedFilters extends Equatable {
  final String? categoryId;
  final String? categoryName;
  final String? region;
  final String? contractType;
  final String? availability;

  // Role-specific filters
  final String? sector;
  final String? experienceLevel;
  final String? salaryRange;

  const FeedFilters({
    this.categoryId,
    this.categoryName,
    this.region,
    this.contractType,
    this.availability,
    this.sector,
    this.experienceLevel,
    this.salaryRange,
  });

  const FeedFilters.empty()
      : categoryId = null,
        categoryName = null,
        region = null,
        contractType = null,
        availability = null,
        sector = null,
        experienceLevel = null,
        salaryRange = null;

  FeedFilters copyWith({
    String? categoryId,
    bool clearCategoryId = false,
    String? categoryName,
    bool clearCategoryName = false,
    String? region,
    bool clearRegion = false,
    String? contractType,
    bool clearContractType = false,
    String? availability,
    bool clearAvailability = false,
    String? sector,
    bool clearSector = false,
    String? experienceLevel,
    bool clearExperienceLevel = false,
    String? salaryRange,
    bool clearSalaryRange = false,
  }) {
    return FeedFilters(
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategoryName ? null : (categoryName ?? this.categoryName),
      region: clearRegion ? null : (region ?? this.region),
      contractType: clearContractType ? null : (contractType ?? this.contractType),
      availability: clearAvailability ? null : (availability ?? this.availability),
      sector: clearSector ? null : (sector ?? this.sector),
      experienceLevel: clearExperienceLevel ? null : (experienceLevel ?? this.experienceLevel),
      salaryRange: clearSalaryRange ? null : (salaryRange ?? this.salaryRange),
    );
  }

  bool get hasFilters =>
      categoryId != null ||
      categoryName != null ||
      region != null ||
      contractType != null ||
      availability != null ||
      sector != null ||
      experienceLevel != null ||
      salaryRange != null;

  FeedFilters clear() => const FeedFilters.empty();

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        region,
        contractType,
        availability,
        sector,
        experienceLevel,
        salaryRange,
      ];
}
