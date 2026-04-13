library;

/// Modele de profil chercheur d'emploi (alternance beta).
///
/// Contient les informations personnelles, academiques et de
/// localisation du chercheur, ainsi que le calcul de completude.

import 'package:equatable/equatable.dart';

/// Profil chercheur : identite, etudes, localisation, domaine.
class SeekerProfile extends Equatable {
  final String userId;
  final String firstName;
  final String? lastName;
  final String? region;
  final String? city;

  // Beta pivot: new fields for alternance
  final String? age;
  final String? school;
  final String? studyLevel;
  final String? domain;
  final String? specialty;

  // Username (@pseudo unique pour identification SaaS)
  final String? username;

  // Photo
  final String? photoUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SeekerProfile({
    required this.userId,
    required this.firstName,
    this.lastName,
    this.region,
    this.city,
    this.age,
    this.school,
    this.studyLevel,
    this.domain,
    this.specialty,
    this.username,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Profile completion percentage (5 categories x 20% = 100%)
  ///
  /// - Photo (20%): photoUrl non-null and non-empty
  /// - Identity (20%): firstName + lastName + age + username
  /// - Studies (20%): school + studyLevel
  /// - Location (20%): city non-empty
  /// - Domain (20%): domain non-empty
  int get completionPercentage {
    int score = 0;
    if (photoUrl != null && photoUrl!.isNotEmpty) score += 20;
    if (firstName.isNotEmpty &&
        lastName != null &&
        lastName!.isNotEmpty &&
        age != null &&
        age!.isNotEmpty &&
        username != null &&
        username!.isNotEmpty) {
      score += 20;
    }
    if (school != null &&
        school!.isNotEmpty &&
        studyLevel != null &&
        studyLevel!.isNotEmpty) {
      score += 20;
    }
    if (city != null && city!.isNotEmpty) score += 20;
    if (domain != null && domain!.isNotEmpty) score += 20;
    return score;
  }

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
      region: json['region'] as String?,
      city: json['city'] as String?,
      age: json['age'] as String?,
      school: json['school'] as String?,
      studyLevel: json['study_level'] as String?,
      domain: json['domain'] as String?,
      specialty: json['specialty'] as String?,
      username: json['username'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'region': region,
      'city': city,
      'age': age,
      'school': school,
      'study_level': studyLevel,
      'domain': domain,
      'specialty': specialty,
      'username': username,
      'photo_url': photoUrl,
    };
  }

  /// Create a copy with updated fields
  SeekerProfile copyWith({
    String? firstName,
    String? lastName,
    String? region,
    String? city,
    String? age,
    String? school,
    String? studyLevel,
    String? domain,
    String? specialty,
    String? username,
    String? photoUrl,
  }) {
    return SeekerProfile(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      region: region ?? this.region,
      city: city ?? this.city,
      age: age ?? this.age,
      school: school ?? this.school,
      studyLevel: studyLevel ?? this.studyLevel,
      domain: domain ?? this.domain,
      specialty: specialty ?? this.specialty,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        region,
        city,
        age,
        school,
        studyLevel,
        domain,
        specialty,
        username,
        photoUrl,
      ];
}
