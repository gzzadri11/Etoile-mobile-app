export const SECTORS = [
  { value: "informatique_tech", label: "Informatique / Tech" },
  { value: "commerce_vente", label: "Commerce / Vente" },
  { value: "marketing_communication", label: "Marketing / Communication" },
  { value: "finance_comptabilite", label: "Finance / Comptabilité / Gestion" },
  { value: "ressources_humaines", label: "Ressources Humaines" },
  { value: "sante_medical", label: "Santé / Médical / Social" },
  { value: "btp_construction", label: "BTP / Construction" },
  { value: "industrie_production", label: "Industrie / Production" },
  { value: "restauration_hotellerie", label: "Hôtellerie / Restauration / Tourisme" },
  { value: "education_formation", label: "Éducation / Formation" },
  { value: "juridique_droit", label: "Droit / Juridique" },
  { value: "art_design", label: "Design / Art / Création" },
  { value: "services_personne", label: "Services à la personne" },
  { value: "transport_logistique", label: "Transport / Logistique" },
  { value: "agriculture_environnement", label: "Agriculture / Environnement" },
] as const;

export const SPECIALTIES_BY_SECTOR: Record<string, { value: string; label: string }[]> = {
  informatique_tech: [
    { value: "developpement_web", label: "Développement web" },
    { value: "developpement_mobile", label: "Développement mobile" },
    { value: "cybersecurite", label: "Cybersécurité" },
    { value: "data_ia", label: "Data / Intelligence artificielle" },
    { value: "reseaux_systemes", label: "Réseaux & systèmes" },
    { value: "cloud_devops", label: "Cloud / DevOps" },
    { value: "ux_ui_design", label: "UX / UI design" },
  ],
  commerce_vente: [
    { value: "vente_magasin", label: "Vente en magasin" },
    { value: "negociation_commerciale", label: "Négociation commerciale (BtoB / BtoC)" },
    { value: "business_development", label: "Business development" },
    { value: "relation_client", label: "Relation client" },
    { value: "immobilier", label: "Immobilier" },
    { value: "e_commerce", label: "E-commerce" },
  ],
  marketing_communication: [
    { value: "marketing_digital", label: "Marketing digital" },
    { value: "community_management", label: "Community management" },
    { value: "seo_sea", label: "SEO / SEA" },
    { value: "publicite", label: "Publicité" },
    { value: "communication_entreprise", label: "Communication d'entreprise" },
    { value: "evenementiel", label: "Événementiel" },
    { value: "branding", label: "Branding" },
  ],
  finance_comptabilite: [
    { value: "comptabilite", label: "Comptabilité" },
    { value: "controle_gestion", label: "Contrôle de gestion" },
    { value: "audit", label: "Audit" },
    { value: "banque", label: "Banque" },
    { value: "assurance", label: "Assurance" },
    { value: "gestion_patrimoine", label: "Gestion de patrimoine" },
  ],
  ressources_humaines: [
    { value: "recrutement", label: "Recrutement" },
    { value: "gestion_paie", label: "Gestion de la paie" },
    { value: "formation", label: "Formation" },
    { value: "gestion_talents", label: "Gestion des talents" },
    { value: "droit_social_rh", label: "Droit social" },
  ],
  sante_medical: [
    { value: "aide_soignant", label: "Aide-soignant" },
    { value: "secretariat_medical", label: "Secrétariat médical" },
    { value: "travail_social", label: "Travail social" },
    { value: "laboratoire_analyses", label: "Laboratoire / analyses" },
    { value: "assistance_medicale", label: "Assistance médicale" },
  ],
  btp_construction: [
    { value: "maconnerie", label: "Maçonnerie" },
    { value: "electricite_batiment", label: "Électricité bâtiment" },
    { value: "plomberie", label: "Plomberie" },
    { value: "conduite_travaux", label: "Conduite de travaux" },
    { value: "genie_civil", label: "Génie civil" },
    { value: "architecture_technique", label: "Architecture technique" },
  ],
  industrie_production: [
    { value: "maintenance_industrielle", label: "Maintenance industrielle" },
    { value: "automatisme", label: "Automatisme" },
    { value: "mecanique", label: "Mécanique" },
    { value: "electronique", label: "Électronique" },
    { value: "qualite_securite", label: "Qualité / sécurité" },
    { value: "production_industrielle", label: "Production industrielle" },
  ],
  restauration_hotellerie: [
    { value: "cuisine", label: "Cuisine" },
    { value: "service_salle", label: "Service en salle" },
    { value: "reception_hotel", label: "Réception hôtel" },
    { value: "management_hotelier", label: "Management hôtelier" },
    { value: "tourisme", label: "Tourisme / agence de voyage" },
  ],
  education_formation: [
    { value: "formation_professionnelle", label: "Formation professionnelle" },
    { value: "animation", label: "Animation" },
    { value: "education_specialisee", label: "Éducation spécialisée" },
    { value: "ingenierie_pedagogique", label: "Ingénierie pédagogique" },
  ],
  juridique_droit: [
    { value: "droit_affaires", label: "Droit des affaires" },
    { value: "droit_social", label: "Droit social" },
    { value: "juriste_entreprise", label: "Juriste d'entreprise" },
    { value: "notariat", label: "Notariat" },
    { value: "compliance", label: "Compliance" },
  ],
  art_design: [
    { value: "design_graphique", label: "Design graphique" },
    { value: "ux_ui_design_art", label: "UX / UI design" },
    { value: "animation_3d", label: "Animation 3D" },
    { value: "audiovisuel", label: "Audiovisuel" },
    { value: "mode_stylisme", label: "Mode / stylisme" },
  ],
  services_personne: [
    { value: "aide_domicile", label: "Aide à domicile" },
    { value: "petite_enfance", label: "Petite enfance" },
    { value: "assistance_vie", label: "Assistance de vie" },
    { value: "accompagnement_handicap", label: "Accompagnement du handicap" },
  ],
  transport_logistique: [
    { value: "logistique", label: "Logistique" },
    { value: "supply_chain", label: "Supply chain" },
    { value: "gestion_entrepot", label: "Gestion d'entrepôt" },
    { value: "transport_routier", label: "Transport routier" },
    { value: "import_export", label: "Import / export" },
  ],
  agriculture_environnement: [
    { value: "agriculture", label: "Agriculture" },
    { value: "paysagisme", label: "Paysagisme" },
    { value: "elevage", label: "Élevage" },
    { value: "agroalimentaire", label: "Agroalimentaire" },
    { value: "developpement_durable", label: "Développement durable" },
  ],
};

export const STUDY_LEVELS = [
  { value: "sans_diplome", label: "Sans diplôme" },
  { value: "cap_bep", label: "CAP / BEP" },
  { value: "bac", label: "Bac" },
  { value: "bac+1", label: "Bac+1" },
  { value: "bac+2", label: "Bac+2 (BTS, DUT)" },
  { value: "bac+3", label: "Bac+3 (Licence)" },
  { value: "bac+4", label: "Bac+4 (Master 1)" },
  { value: "bac+5", label: "Bac+5 (Master 2, Ingénieur)" },
  { value: "bac+8", label: "Bac+8 (Doctorat)" },
] as const;

export function getSectorLabel(code: string | null): string {
  if (!code) return "Non défini";
  return SECTORS.find((s) => s.value === code)?.label ?? code;
}

export function getSpecialtyLabel(code: string | null): string {
  if (!code) return "";
  for (const specialties of Object.values(SPECIALTIES_BY_SECTOR)) {
    const match = specialties.find((s) => s.value === code);
    if (match) return match.label;
  }
  return code;
}

export function getStudyLevelLabel(code: string | null): string {
  if (!code) return "";
  return STUDY_LEVELS.find((s) => s.value === code)?.label ?? code;
}
