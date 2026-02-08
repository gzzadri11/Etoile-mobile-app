import 'package:equatable/equatable.dart';

/// Model representing a job seeker's profile
class SeekerProfile extends Equatable {
  final String userId;
  final String firstName;
  final String? lastName;
  final String? phone;
  final DateTime? birthDate;
  final String? region;
  final String? city;
  final String? postalCode;
  final List<String> categories;
  final List<String> contractTypes;
  final String? experienceLevel;
  final String? availability;
  final int? salaryExpectation;
  final String? bio;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SeekerProfile({
    required this.userId,
    required this.firstName,
    this.lastName,
    this.phone,
    this.birthDate,
    this.region,
    this.city,
    this.postalCode,
    this.categories = const [],
    this.contractTypes = const [],
    this.experienceLevel,
    this.availability,
    this.salaryExpectation,
    this.bio,
    this.profileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Full name (first + last)
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Location string (city, region)
  String get location {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (region != null && region!.isNotEmpty) parts.add(region!);
    return parts.join(', ');
  }

  /// Create from Supabase JSON
  factory SeekerProfile.fromJson(Map<String, dynamic> json) {
    return SeekerProfile(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      region: json['region'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      contractTypes: (json['contract_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      experienceLevel: json['experience_level'] as String?,
      availability: json['availability'] as String?,
      salaryExpectation: json['salary_expectation'] as int?,
      bio: json['bio'] as String?,
      profileComplete: json['profile_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'region': region,
      'city': city,
      'postal_code': postalCode,
      'categories': categories,
      'contract_types': contractTypes,
      'experience_level': experienceLevel,
      'availability': availability,
      'salary_expectation': salaryExpectation,
      'bio': bio,
      'profile_complete': profileComplete,
    };
  }

  /// Create a copy with updated fields
  SeekerProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
    String? region,
    String? city,
    String? postalCode,
    List<String>? categories,
    List<String>? contractTypes,
    String? experienceLevel,
    String? availability,
    int? salaryExpectation,
    String? bio,
    bool? profileComplete,
  }) {
    return SeekerProfile(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      region: region ?? this.region,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      categories: categories ?? this.categories,
      contractTypes: contractTypes ?? this.contractTypes,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      availability: availability ?? this.availability,
      salaryExpectation: salaryExpectation ?? this.salaryExpectation,
      bio: bio ?? this.bio,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        phone,
        birthDate,
        region,
        city,
        postalCode,
        categories,
        contractTypes,
        experienceLevel,
        availability,
        salaryExpectation,
        bio,
        profileComplete,
      ];
}
