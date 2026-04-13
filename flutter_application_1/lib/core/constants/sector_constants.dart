library;

/// Constantes de secteurs, specialites et niveaux d'etudes.
///
/// Utilisees dans la recherche, l'edition de profil, le feed et les filtres.

/// Secteurs, specialites par secteur et niveaux d'etudes.
class SectorConstants {
  SectorConstants._();

  // --- Sectors ---
  static const List<String> sectorOptions = [
    'restauration_hotellerie',
  ];

  static const Map<String, String> sectorLabels = {
    'restauration_hotellerie': 'Restauration / Hôtellerie',
  };

  // --- Specialties per sector ---
  static const Map<String, List<String>> specialtiesBySector = {
    'restauration_hotellerie': [
      'service_salle',
      'cuisine',
      'patisserie',
      'bar_sommellerie',
    ],
  };

  static const Map<String, String> specialtyLabels = {
    'service_salle': 'Service en salle',
    'cuisine': 'Cuisine',
    'patisserie': 'Pâtisserie',
    'bar_sommellerie': 'Bar / Sommellerie',
  };

  /// Returns specialties for a given sector, or empty list if unknown.
  static List<String> getSpecialtiesForSector(String? sector) {
    if (sector == null) return [];
    return specialtiesBySector[sector] ?? [];
  }

  /// Returns human-readable label for a specialty code.
  static String getSpecialtyLabel(String? code) {
    if (code == null) return '';
    return specialtyLabels[code] ?? code;
  }

  /// Returns human-readable label for a sector code.
  static String getSectorLabel(String? code) {
    if (code == null || code.isEmpty) return 'Non défini';
    return sectorLabels[code] ?? code;
  }

  // --- Study levels ---
  static const List<String> studyLevelOptions = [
    'sans_diplome',
    'cap_bep',
    'bac',
    'bac+1',
    'bac+2',
    'bac+3',
    'bac+4',
    'bac+5',
    'bac+8',
  ];

  static const Map<String, String> studyLevelLabels = {
    'sans_diplome': 'Sans diplôme',
    'cap_bep': 'CAP / BEP',
    'bac': 'Bac',
    'bac+1': 'Bac+1',
    'bac+2': 'Bac+2 (BTS, DUT)',
    'bac+3': 'Bac+3 (Licence)',
    'bac+4': 'Bac+4 (Master 1)',
    'bac+5': 'Bac+5 (Master 2, Ingénieur)',
    'bac+8': 'Bac+8 (Doctorat)',
  };

  /// Returns human-readable label for a study level code.
  static String getStudyLevelLabel(String? code) {
    if (code == null || code.isEmpty) return '';
    return studyLevelLabels[code] ?? code;
  }
}
