import 'package:flutter_test/flutter_test.dart';

import 'package:etoile/features/profile/data/models/seeker_profile_model.dart';

void main() {
  final now = DateTime.now();

  group('SeekerProfile completionPercentage', () {
    SeekerProfile buildSeeker({
      String firstName = '',
      String? lastName,
      String? age,
      String? username,
      String? school,
      String? studyLevel,
      String? city,
      String? domain,
      String? photoUrl,
    }) {
      return SeekerProfile(
        userId: 'user-1',
        firstName: firstName,
        lastName: lastName,
        age: age,
        username: username,
        school: school,
        studyLevel: studyLevel,
        city: city,
        domain: domain,
        photoUrl: photoUrl,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('returns 0% for empty profile (no photo, no fields)', () {
      final profile = buildSeeker();
      expect(profile.completionPercentage, 0);
    });

    test('returns 20% with photo only', () {
      final profile = buildSeeker(photoUrl: 'https://example.com/photo.jpg');
      expect(profile.completionPercentage, 20);
    });

    test('returns 40% with photo + identity (firstName+lastName+age+username)', () {
      final profile = buildSeeker(
        photoUrl: 'https://example.com/photo.jpg',
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
      );
      expect(profile.completionPercentage, 40);
    });

    test('identity without photo gives only 20%', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
      );
      expect(profile.completionPercentage, 20);
    });

    test('identity requires all four: firstName, lastName, age, username', () {
      // Only firstName → no identity bonus
      expect(buildSeeker(firstName: 'Jean', photoUrl: 'https://x.com/p.jpg').completionPercentage, 20);
      // firstName + lastName but no age/username → no identity bonus
      expect(
        buildSeeker(firstName: 'Jean', lastName: 'Dupont', photoUrl: 'https://x.com/p.jpg').completionPercentage,
        20,
      );
      // firstName + age but no lastName/username → no identity bonus
      expect(
        buildSeeker(firstName: 'Jean', age: '22', photoUrl: 'https://x.com/p.jpg').completionPercentage,
        20,
      );
      // firstName + lastName + age but no username → no identity bonus
      expect(
        buildSeeker(firstName: 'Jean', lastName: 'Dupont', age: '22', photoUrl: 'https://x.com/p.jpg').completionPercentage,
        20,
      );
      // username alone with photo → no identity bonus (needs all 4)
      expect(
        buildSeeker(username: 'jean', photoUrl: 'https://x.com/p.jpg').completionPercentage,
        20,
      );
    });

    test('returns 60% with photo + identity + studies (school+studyLevel)', () {
      final profile = buildSeeker(
        photoUrl: 'https://example.com/photo.jpg',
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
      );
      expect(profile.completionPercentage, 60);
    });

    test('studies require both school AND studyLevel', () {
      // Only school → no studies bonus
      expect(
        buildSeeker(
          photoUrl: 'https://example.com/photo.jpg',
          firstName: 'Jean',
          lastName: 'Dupont',
          age: '22',
          username: 'jean-dupont',
          school: 'Lycee Victor Hugo',
        ).completionPercentage,
        40,
      );
      // Only studyLevel → no studies bonus
      expect(
        buildSeeker(
          photoUrl: 'https://example.com/photo.jpg',
          firstName: 'Jean',
          lastName: 'Dupont',
          age: '22',
          username: 'jean-dupont',
          studyLevel: 'bac+2',
        ).completionPercentage,
        40,
      );
    });

    test('returns 80% with photo + identity + studies + city', () {
      final profile = buildSeeker(
        photoUrl: 'https://example.com/photo.jpg',
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
        city: 'Paris',
      );
      expect(profile.completionPercentage, 80);
    });

    test('returns 100% when all 5 categories filled (with photo)', () {
      final profile = buildSeeker(
        photoUrl: 'https://example.com/photo.jpg',
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
        city: 'Paris',
        domain: 'commerce_vente',
      );
      expect(profile.completionPercentage, 100);
    });

    test('all fields but no photo gives 80%', () {
      final profile = buildSeeker(
        firstName: 'Jean',
        lastName: 'Dupont',
        age: '22',
        username: 'jean-dupont',
        school: 'Lycee Victor Hugo',
        studyLevel: 'bac+2',
        city: 'Paris',
        domain: 'commerce_vente',
      );
      expect(profile.completionPercentage, 80);
    });

    test('domain alone adds 20%', () {
      final profile = buildSeeker(domain: 'restauration_hotellerie');
      expect(profile.completionPercentage, 20);
    });

    test('empty photoUrl does not count', () {
      final profile = buildSeeker(photoUrl: '');
      expect(profile.completionPercentage, 0);
    });
  });
}
