import 'package:flutter_test/flutter_test.dart';

import 'package:etoile/features/profile/data/models/seeker_profile_model.dart';
import 'package:etoile/features/profile/data/models/recruiter_profile_model.dart';

void main() {
  final now = DateTime.now();

  group('SeekerProfile completionPercentage', () {
    SeekerProfile buildSeeker({
      String firstName = '',
      String? lastName,
      String? age,
      String? school,
      String? studyLevel,
      String? city,
      String? domain,
    }) {
      return SeekerProfile(
        userId: 'user-1',
        firstName: firstName,
        lastName: lastName,
        age: age,
        school: school,
        studyLevel: studyLevel,
        city: city,
        domain: domain,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('returns 20% for empty profile (inscription only)', () {
      final profile = buildSeeker();
      expect(profile.completionPercentage, 20);
    });

    test('returns 40% with inscription + identity (firstName+lastName+age)', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
      );
      expect(profile.completionPercentage, 40);
    });

    test('identity requires all three: firstName, lastName, age', () {
      // Only firstName → no identity bonus
      expect(buildSeeker(firstName: 'Jean').completionPercentage, 20);
      // firstName + lastName but no age → no identity bonus
      expect(
        buildSeeker(firstName: 'Jean', lastName: 'Dupont').completionPercentage,
        20,
      );
      // firstName + age but no lastName → no identity bonus
      expect(
        buildSeeker(firstName: 'Jean', age: '22').completionPercentage,
        20,
      );
    });

    test('returns 60% with identity + studies (school+studyLevel)', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
      );
      expect(profile.completionPercentage, 60);
    });

    test('studies require both school AND studyLevel', () {
      // Only school → no studies bonus
      expect(
        buildSeeker(
          firstName: 'Jean',
          lastName: 'Dupont',
          age: '22',
          school: 'Lycee Victor Hugo',
        ).completionPercentage,
        40,
      );
      // Only studyLevel → no studies bonus
      expect(
        buildSeeker(
          firstName: 'Jean',
          lastName: 'Dupont',
          age: '22',
          studyLevel: 'bac+2',
        ).completionPercentage,
        40,
      );
    });

    test('returns 80% with identity + studies + city', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
        city: 'Paris',
      );
      expect(profile.completionPercentage, 80);
    });

    test('returns 100% when all 5 categories filled', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
        city: 'Paris',
        domain: 'commerce_vente',
      );
      expect(profile.completionPercentage, 100);
    });

    test('domain alone adds 20% to inscription', () {
      final profile = buildSeeker(domain: 'restauration_hotellerie');
      expect(profile.completionPercentage, 40);
    });
  });

  group('RecruiterProfile completionPercentage', () {
    RecruiterProfile buildRecruiter({
      String companyName = '',
      String? sector,
      String? description,
      List<String> locations = const [],
      List<MapMarker> mapMarkers = const [],
      String? siret,
      String? documentUrl,
    }) {
      return RecruiterProfile(
        userId: 'user-2',
        companyName: companyName,
        sector: sector,
        description: description,
        locations: locations,
        mapMarkers: mapMarkers,
        siret: siret,
        documentUrl: documentUrl,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('returns 20% for empty profile (inscription only)', () {
      final profile = buildRecruiter();
      expect(profile.completionPercentage, 20);
    });

    test('returns 40% with company + sector filled', () {
      final profile = buildRecruiter(
        companyName: 'ACME Corp',
        sector: 'Tech',
      );
      expect(profile.completionPercentage, 40);
    });

    test('company "A completer" does not count', () {
      final profile = buildRecruiter(
        companyName: 'A completer',
        sector: 'Tech',
      );
      expect(profile.completionPercentage, 20);
    });

    test('description requires at least 50 characters', () {
      final profile49 = buildRecruiter(
        companyName: 'ACME',
        sector: 'Tech',
        description: 'x' * 49,
      );
      expect(profile49.completionPercentage, 40);

      final profile50 = buildRecruiter(
        companyName: 'ACME',
        sector: 'Tech',
        description: 'x' * 50,
      );
      expect(profile50.completionPercentage, 60);
    });

    test('returns 100% when all categories filled', () {
      final profile = buildRecruiter(
        companyName: 'ACME Corp',
        sector: 'Tech',
        description: 'A' * 50,
        locations: ['Paris'],
        siret: '12345678901234',
        documentUrl: 'https://example.com/doc.pdf',
      );
      expect(profile.completionPercentage, 100);
    });

    test('mapMarkers count as location', () {
      final profile = buildRecruiter(
        companyName: 'ACME Corp',
        sector: 'Tech',
        description: 'A' * 50,
        mapMarkers: [
          const MapMarker(name: 'HQ', latitude: 48.85, longitude: 2.35),
        ],
        siret: '12345678901234',
        documentUrl: 'https://example.com/doc.pdf',
      );
      expect(profile.completionPercentage, 100);
    });

    test('verification requires both siret AND document', () {
      // Only siret → no verification bonus
      final profile1 = buildRecruiter(
        companyName: 'ACME',
        sector: 'Tech',
        siret: '123',
      );
      expect(profile1.completionPercentage, 40);

      // Only document → no verification bonus
      final profile2 = buildRecruiter(
        companyName: 'ACME',
        sector: 'Tech',
        documentUrl: 'https://example.com/doc.pdf',
      );
      expect(profile2.completionPercentage, 40);
    });
  });
}
