export const SECTORS = [
  { value: "informatique_tech", label: "Informatique / Tech" },
  { value: "commerce_vente", label: "Commerce / Vente" },
  { value: "marketing_communication", label: "Marketing / Communication" },
  { value: "finance_comptabilite", label: "Finance / Comptabilité" },
  { value: "ressources_humaines", label: "Ressources Humaines" },
  { value: "sante_medical", label: "Santé / Médical" },
  { value: "btp_construction", label: "BTP / Construction" },
  { value: "industrie_production", label: "Industrie / Production" },
  { value: "restauration_hotellerie", label: "Restauration / Hôtellerie" },
  { value: "education_formation", label: "Éducation / Formation" },
  { value: "juridique_droit", label: "Juridique / Droit" },
  { value: "art_design", label: "Art / Design" },
  { value: "services_personne", label: "Services à la personne" },
  { value: "transport_logistique", label: "Transport / Logistique" },
  { value: "autre", label: "Autre" },
] as const;

export const SPECIALTIES_BY_SECTOR: Record<string, { value: string; label: string }[]> = {
  informatique_tech: [
    { value: "developpement_web", label: "Développement Web" },
    { value: "developpement_mobile", label: "Développement Mobile" },
    { value: "data_ia", label: "Data / IA" },
    { value: "cybersecurite", label: "Cybersécurité" },
    { value: "infra_devops", label: "Infra / DevOps" },
  ],
  commerce_vente: [
    { value: "vente_btob", label: "Vente B2B" },
    { value: "vente_btoc", label: "Vente B2C" },
    { value: "grande_distribution", label: "Grande distribution" },
    { value: "e_commerce", label: "E-commerce" },
  ],
  marketing_communication: [
    { value: "marketing_digital", label: "Marketing digital" },
    { value: "community_management", label: "Community Management" },
    { value: "relations_publiques", label: "Relations publiques" },
    { value: "evenementiel", label: "Événementiel" },
  ],
  finance_comptabilite: [
    { value: "comptabilite_generale", label: "Comptabilité générale" },
    { value: "audit", label: "Audit" },
    { value: "controle_gestion", label: "Contrôle de gestion" },
    { value: "banque_assurance", label: "Banque / Assurance" },
  ],
  ressources_humaines: [
    { value: "recrutement", label: "Recrutement" },
    { value: "formation", label: "Formation" },
    { value: "paie_administration", label: "Paie / Administration" },
  ],
  sante_medical: [
    { value: "infirmier", label: "Infirmier(ère)" },
    { value: "aide_soignant", label: "Aide-soignant(e)" },
    { value: "pharmacie", label: "Pharmacie" },
    { value: "kinesitherapie", label: "Kinésithérapie" },
  ],
  btp_construction: [
    { value: "gros_oeuvre", label: "Gros œuvre" },
    { value: "second_oeuvre", label: "Second œuvre" },
    { value: "electricite", label: "Électricité" },
    { value: "conduite_travaux", label: "Conduite de travaux" },
  ],
  industrie_production: [
    { value: "maintenance_industrielle", label: "Maintenance industrielle" },
    { value: "qualite", label: "Qualité" },
    { value: "logistique_supply", label: "Logistique / Supply" },
    { value: "automatisme", label: "Automatisme" },
  ],
  restauration_hotellerie: [
    { value: "service_salle", label: "Service en salle" },
    { value: "cuisine", label: "Cuisine" },
    { value: "patisserie", label: "Pâtisserie" },
    { value: "bar_sommellerie", label: "Bar / Sommellerie" },
  ],
  education_formation: [
    { value: "enseignement", label: "Enseignement" },
    { value: "animation", label: "Animation" },
    { value: "formation_professionnelle", label: "Formation professionnelle" },
  ],
  juridique_droit: [
    { value: "droit_affaires", label: "Droit des affaires" },
    { value: "droit_social", label: "Droit social" },
    { value: "notariat", label: "Notariat" },
  ],
  art_design: [
    { value: "graphisme", label: "Graphisme" },
    { value: "ux_ui_design", label: "UX / UI Design" },
    { value: "architecture_interieure", label: "Architecture intérieure" },
    { value: "photographie_video", label: "Photographie / Vidéo" },
  ],
  services_personne: [
    { value: "petite_enfance", label: "Petite enfance" },
    { value: "aide_domicile", label: "Aide à domicile" },
    { value: "coiffure_esthetique", label: "Coiffure / Esthétique" },
  ],
  transport_logistique: [
    { value: "conduite_routiere", label: "Conduite routière" },
    { value: "logistique_entrepot", label: "Logistique / Entrepôt" },
    { value: "supply_chain", label: "Supply Chain" },
  ],
  autre: [],
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
