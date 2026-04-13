export const SECTORS = [
  { value: "restauration_hotellerie", label: "Restauration / Hôtellerie" },
] as const;

export const SPECIALTIES_BY_SECTOR: Record<string, { value: string; label: string }[]> = {
  restauration_hotellerie: [
    { value: "service_salle", label: "Service en salle" },
    { value: "cuisine", label: "Cuisine" },
    { value: "patisserie", label: "Pâtisserie" },
    { value: "bar_sommellerie", label: "Bar / Sommellerie" },
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
