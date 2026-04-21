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
    'agriculture_environnement',
  ];

  static const Map<String, String> sectorLabels = {
    'informatique_tech': 'Informatique / Tech',
    'commerce_vente': 'Commerce / Vente',
    'marketing_communication': 'Marketing / Communication',
    'finance_comptabilite': 'Finance / Comptabilité / Gestion',
    'ressources_humaines': 'Ressources Humaines',
    'sante_medical': 'Santé / Médical / Social',
    'btp_construction': 'BTP / Construction',
    'industrie_production': 'Industrie / Production',
    'restauration_hotellerie': 'Hôtellerie / Restauration / Tourisme',
    'education_formation': 'Éducation / Formation',
    'juridique_droit': 'Droit / Juridique',
    'art_design': 'Design / Art / Création',
    'services_personne': 'Services à la personne',
    'transport_logistique': 'Transport / Logistique',
    'agriculture_environnement': 'Agriculture / Environnement',
  };

  // --- Specialties per sector ---
  static const Map<String, List<String>> specialtiesBySector = {
    'informatique_tech': [
      'developpement_web',
      'developpement_mobile',
      'cybersecurite',
      'data_ia',
      'reseaux_systemes',
      'cloud_devops',
      'ux_ui_design',
    ],
    'commerce_vente': [
      'vente_magasin',
      'negociation_commerciale',
      'business_development',
      'relation_client',
      'immobilier',
      'e_commerce',
    ],
    'marketing_communication': [
      'marketing_digital',
      'community_management',
      'seo_sea',
      'publicite',
      'communication_entreprise',
      'evenementiel',
      'branding',
    ],
    'finance_comptabilite': [
      'comptabilite',
      'controle_gestion',
      'audit',
      'banque',
      'assurance',
      'gestion_patrimoine',
    ],
    'ressources_humaines': [
      'recrutement',
      'gestion_paie',
      'formation',
      'gestion_talents',
      'droit_social_rh',
    ],
    'sante_medical': [
      'aide_soignant',
      'secretariat_medical',
      'travail_social',
      'laboratoire_analyses',
      'assistance_medicale',
    ],
    'btp_construction': [
      'maconnerie',
      'electricite_batiment',
      'plomberie',
      'conduite_travaux',
      'genie_civil',
      'architecture_technique',
    ],
    'industrie_production': [
      'maintenance_industrielle',
      'automatisme',
      'mecanique',
      'electronique',
      'qualite_securite',
      'production_industrielle',
    ],
    'restauration_hotellerie': [
      'cuisine',
      'service_salle',
      'reception_hotel',
      'management_hotelier',
      'tourisme',
    ],
    'education_formation': [
      'formation_professionnelle',
      'animation',
      'education_specialisee',
      'ingenierie_pedagogique',
    ],
    'juridique_droit': [
      'droit_affaires',
      'droit_social',
      'juriste_entreprise',
      'notariat',
      'compliance',
    ],
    'art_design': [
      'design_graphique',
      'ux_ui_design_art',
      'animation_3d',
      'audiovisuel',
      'mode_stylisme',
    ],
    'services_personne': [
      'aide_domicile',
      'petite_enfance',
      'assistance_vie',
      'accompagnement_handicap',
    ],
    'transport_logistique': [
      'logistique',
      'supply_chain',
      'gestion_entrepot',
      'transport_routier',
      'import_export',
    ],
    'agriculture_environnement': [
      'agriculture',
      'paysagisme',
      'elevage',
      'agroalimentaire',
      'developpement_durable',
    ],
  };

  static const Map<String, String> specialtyLabels = {
    // informatique_tech
    'developpement_web': 'Développement web',
    'developpement_mobile': 'Développement mobile',
    'cybersecurite': 'Cybersécurité',
    'data_ia': 'Data / Intelligence artificielle',
    'reseaux_systemes': 'Réseaux & systèmes',
    'cloud_devops': 'Cloud / DevOps',
    'ux_ui_design': 'UX / UI design',
    // commerce_vente
    'vente_magasin': 'Vente en magasin',
    'negociation_commerciale': 'Négociation commerciale (BtoB / BtoC)',
    'business_development': 'Business development',
    'relation_client': 'Relation client',
    'immobilier': 'Immobilier',
    'e_commerce': 'E-commerce',
    // marketing_communication
    'marketing_digital': 'Marketing digital',
    'community_management': 'Community management',
    'seo_sea': 'SEO / SEA',
    'publicite': 'Publicité',
    'communication_entreprise': "Communication d'entreprise",
    'evenementiel': 'Événementiel',
    'branding': 'Branding',
    // finance_comptabilite
    'comptabilite': 'Comptabilité',
    'controle_gestion': 'Contrôle de gestion',
    'audit': 'Audit',
    'banque': 'Banque',
    'assurance': 'Assurance',
    'gestion_patrimoine': 'Gestion de patrimoine',
    // ressources_humaines
    'recrutement': 'Recrutement',
    'gestion_paie': 'Gestion de la paie',
    'formation': 'Formation',
    'gestion_talents': 'Gestion des talents',
    'droit_social_rh': 'Droit social',
    // sante_medical
    'aide_soignant': 'Aide-soignant',
    'secretariat_medical': 'Secrétariat médical',
    'travail_social': 'Travail social',
    'laboratoire_analyses': 'Laboratoire / analyses',
    'assistance_medicale': 'Assistance médicale',
    // btp_construction
    'maconnerie': 'Maçonnerie',
    'electricite_batiment': 'Électricité bâtiment',
    'plomberie': 'Plomberie',
    'conduite_travaux': 'Conduite de travaux',
    'genie_civil': 'Génie civil',
    'architecture_technique': 'Architecture technique',
    // industrie_production
    'maintenance_industrielle': 'Maintenance industrielle',
    'automatisme': 'Automatisme',
    'mecanique': 'Mécanique',
    'electronique': 'Électronique',
    'qualite_securite': 'Qualité / sécurité',
    'production_industrielle': 'Production industrielle',
    // restauration_hotellerie
    'cuisine': 'Cuisine',
    'service_salle': 'Service en salle',
    'reception_hotel': 'Réception hôtel',
    'management_hotelier': 'Management hôtelier',
    'tourisme': 'Tourisme / agence de voyage',
    // education_formation
    'formation_professionnelle': 'Formation professionnelle',
    'animation': 'Animation',
    'education_specialisee': 'Éducation spécialisée',
    'ingenierie_pedagogique': 'Ingénierie pédagogique',
    // juridique_droit
    'droit_affaires': 'Droit des affaires',
    'droit_social': 'Droit social',
    'juriste_entreprise': "Juriste d'entreprise",
    'notariat': 'Notariat',
    'compliance': 'Compliance',
    // art_design
    'design_graphique': 'Design graphique',
    'ux_ui_design_art': 'UX / UI design',
    'animation_3d': 'Animation 3D',
    'audiovisuel': 'Audiovisuel',
    'mode_stylisme': 'Mode / stylisme',
    // services_personne
    'aide_domicile': 'Aide à domicile',
    'petite_enfance': 'Petite enfance',
    'assistance_vie': 'Assistance de vie',
    'accompagnement_handicap': 'Accompagnement du handicap',
    // transport_logistique
    'logistique': 'Logistique',
    'supply_chain': 'Supply chain',
    'gestion_entrepot': "Gestion d'entrepôt",
    'transport_routier': 'Transport routier',
    'import_export': 'Import / export',
    // agriculture_environnement
    'agriculture': 'Agriculture',
    'paysagisme': 'Paysagisme',
    'elevage': 'Élevage',
    'agroalimentaire': 'Agroalimentaire',
    'developpement_durable': 'Développement durable',
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
