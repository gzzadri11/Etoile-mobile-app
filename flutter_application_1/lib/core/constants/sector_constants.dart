/// Centralized constants for sectors, specialties, and study levels.
///
/// Used across search, edit profile, feed, and filter UI.
class SectorConstants {
  SectorConstants._();

  // --- Sectors ---
  static const List<String> sectorOptions = [
    'commerce_vente',
    'restauration_hotellerie',
  ];

  static const Map<String, String> sectorLabels = {
    'commerce_vente': 'Commerce / Vente',
    'restauration_hotellerie': 'Restauration / Hotellerie',
  };

  // --- Specialties per sector ---
  static const Map<String, List<String>> specialtiesBySector = {
    'commerce_vente': [
      'vente_magasin',
      'caisse',
      'merchandising',
      'ecommerce',
    ],
    'restauration_hotellerie': [
      'service_salle',
      'cuisine',
      'patisserie',
      'bar_sommellerie',
    ],
  };

  static const Map<String, String> specialtyLabels = {
    'vente_magasin': 'Vente en magasin',
    'caisse': 'Caisse',
    'merchandising': 'Merchandising',
    'ecommerce': 'E-commerce',
    'service_salle': 'Service en salle',
    'cuisine': 'Cuisine',
    'patisserie': 'Patisserie',
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
    if (code == null || code.isEmpty) return 'Non defini';
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
    'sans_diplome': 'Sans diplome',
    'cap_bep': 'CAP / BEP',
    'bac': 'Bac',
    'bac+1': 'Bac+1',
    'bac+2': 'Bac+2 (BTS, DUT)',
    'bac+3': 'Bac+3 (Licence)',
    'bac+4': 'Bac+4 (Master 1)',
    'bac+5': 'Bac+5 (Master 2, Ingenieur)',
    'bac+8': 'Bac+8 (Doctorat)',
  };

  /// Returns human-readable label for a study level code.
  static String getStudyLevelLabel(String? code) {
    if (code == null || code.isEmpty) return '';
    return studyLevelLabels[code] ?? code;
  }
}
