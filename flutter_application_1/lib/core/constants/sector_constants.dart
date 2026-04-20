library;

/// Constantes de secteurs, specialites et niveaux d'etudes.
///
/// Utilisees dans la recherche, l'edition de profil, le feed et les filtres.

/// Secteurs (15), specialites par secteur et niveaux d'etudes.
class SectorConstants {
  SectorConstants._();

  // --- Sectors (15) ---
  static const List<String> sectorOptions = [
    'informatique_tech',
    'commerce_vente',
    'marketing_communication',
    'finance_comptabilite',
    'ressources_humaines',
    'sante_medical',
    'btp_construction',
    'industrie_production',
    'restauration_hotellerie',
    'education_formation',
    'juridique_droit',
    'art_design',
    'services_personne',
    'transport_logistique',
    'autre',
  ];

  static const Map<String, String> sectorLabels = {
    'informatique_tech': 'Informatique / Tech',
    'commerce_vente': 'Commerce / Vente',
    'marketing_communication': 'Marketing / Communication',
    'finance_comptabilite': 'Finance / Comptabilité',
    'ressources_humaines': 'Ressources Humaines',
    'sante_medical': 'Santé / Médical',
    'btp_construction': 'BTP / Construction',
    'industrie_production': 'Industrie / Production',
    'restauration_hotellerie': 'Restauration / Hôtellerie',
    'education_formation': 'Éducation / Formation',
    'juridique_droit': 'Juridique / Droit',
    'art_design': 'Art / Design',
    'services_personne': 'Services à la personne',
    'transport_logistique': 'Transport / Logistique',
    'autre': 'Autre',
  };

  // --- Specialties per sector ---
  static const Map<String, List<String>> specialtiesBySector = {
    'informatique_tech': [
      'developpement_web',
      'developpement_mobile',
      'data_ia',
      'cybersecurite',
      'infra_devops',
    ],
    'commerce_vente': [
      'vente_btob',
      'vente_btoc',
      'grande_distribution',
      'e_commerce',
    ],
    'marketing_communication': [
      'marketing_digital',
      'community_management',
      'relations_publiques',
      'evenementiel',
    ],
    'finance_comptabilite': [
      'comptabilite_generale',
      'audit',
      'controle_gestion',
      'banque_assurance',
    ],
    'ressources_humaines': [
      'recrutement',
      'formation',
      'paie_administration',
    ],
    'sante_medical': [
      'infirmier',
      'aide_soignant',
      'pharmacie',
      'kinesitherapie',
    ],
    'btp_construction': [
      'gros_oeuvre',
      'second_oeuvre',
      'electricite',
      'conduite_travaux',
    ],
    'industrie_production': [
      'maintenance_industrielle',
      'qualite',
      'logistique_supply',
      'automatisme',
    ],
    'restauration_hotellerie': [
      'service_salle',
      'cuisine',
      'patisserie',
      'bar_sommellerie',
    ],
    'education_formation': [
      'enseignement',
      'animation',
      'formation_professionnelle',
    ],
    'juridique_droit': [
      'droit_affaires',
      'droit_social',
      'notariat',
    ],
    'art_design': [
      'graphisme',
      'ux_ui_design',
      'architecture_interieure',
      'photographie_video',
    ],
    'services_personne': [
      'petite_enfance',
      'aide_domicile',
      'coiffure_esthetique',
    ],
    'transport_logistique': [
      'conduite_routiere',
      'logistique_entrepot',
      'supply_chain',
    ],
    'autre': [],
  };

  static const Map<String, String> specialtyLabels = {
    // informatique_tech
    'developpement_web': 'Développement Web',
    'developpement_mobile': 'Développement Mobile',
    'data_ia': 'Data / IA',
    'cybersecurite': 'Cybersécurité',
    'infra_devops': 'Infra / DevOps',
    // commerce_vente
    'vente_btob': 'Vente B2B',
    'vente_btoc': 'Vente B2C',
    'grande_distribution': 'Grande distribution',
    'e_commerce': 'E-commerce',
    // marketing_communication
    'marketing_digital': 'Marketing digital',
    'community_management': 'Community Management',
    'relations_publiques': 'Relations publiques',
    'evenementiel': 'Événementiel',
    // finance_comptabilite
    'comptabilite_generale': 'Comptabilité générale',
    'audit': 'Audit',
    'controle_gestion': 'Contrôle de gestion',
    'banque_assurance': 'Banque / Assurance',
    // ressources_humaines
    'recrutement': 'Recrutement',
    'formation': 'Formation',
    'paie_administration': 'Paie / Administration',
    // sante_medical
    'infirmier': 'Infirmier(ère)',
    'aide_soignant': 'Aide-soignant(e)',
    'pharmacie': 'Pharmacie',
    'kinesitherapie': 'Kinésithérapie',
    // btp_construction
    'gros_oeuvre': 'Gros œuvre',
    'second_oeuvre': 'Second œuvre',
    'electricite': 'Électricité',
    'conduite_travaux': 'Conduite de travaux',
    // industrie_production
    'maintenance_industrielle': 'Maintenance industrielle',
    'qualite': 'Qualité',
    'logistique_supply': 'Logistique / Supply',
    'automatisme': 'Automatisme',
    // restauration_hotellerie
    'service_salle': 'Service en salle',
    'cuisine': 'Cuisine',
    'patisserie': 'Pâtisserie',
    'bar_sommellerie': 'Bar / Sommellerie',
    // education_formation
    'enseignement': 'Enseignement',
    'animation': 'Animation',
    'formation_professionnelle': 'Formation professionnelle',
    // juridique_droit
    'droit_affaires': 'Droit des affaires',
    'droit_social': 'Droit social',
    'notariat': 'Notariat',
    // art_design
    'graphisme': 'Graphisme',
    'ux_ui_design': 'UX / UI Design',
    'architecture_interieure': 'Architecture intérieure',
    'photographie_video': 'Photographie / Vidéo',
    // services_personne
    'petite_enfance': 'Petite enfance',
    'aide_domicile': 'Aide à domicile',
    'coiffure_esthetique': 'Coiffure / Esthétique',
    // transport_logistique
    'conduite_routiere': 'Conduite routière',
    'logistique_entrepot': 'Logistique / Entrepôt',
    'supply_chain': 'Supply Chain',
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
