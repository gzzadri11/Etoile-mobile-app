import { RecruiterProfile } from "@/lib/types/database";

/**
 * Calcule le pourcentage de complétude du profil recruteur
 *
 * 5 catégories × 20% = 100%
 * 1. Inscription (20%) : toujours 20% (email vérifié = inscrit)
 * 2. Entreprise + secteur (20%) : company_name && sector
 * 3. Description (20%) : description && description.length >= 50
 * 4. Adresse (20%) : address && address.length >= 10
 * 5. SIRET + document (20%) : siret && document_url
 *
 * @param profile - Profil recruteur depuis Supabase
 * @returns Pourcentage de complétude (0-100)
 */
export function calculateRecruiterCompletion(profile: RecruiterProfile): number {
  let completion = 0;

  // 1. Inscription (20%) — toujours acquis si profil existe
  completion += 20;

  // 2. Entreprise + secteur (20%)
  if (profile.company_name && profile.sector) {
    completion += 20;
  }

  // 3. Description (20%) — min 50 caractères
  if (profile.description && profile.description.length >= 50) {
    completion += 20;
  }

  // 4. Adresse entreprise (20%) — min 10 caractères
  if (profile.address && profile.address.length >= 10) {
    completion += 20;
  }

  // 5. SIRET + document (20%)
  if (profile.siret && profile.document_url) {
    completion += 20;
  }

  return completion;
}
