import { z } from "zod";

export const recruiterSettingsSchema = z.object({
  photo_url: z.string().url().nullable().optional(),
  company_name: z.string().min(2, "Le nom de l'entreprise doit contenir au moins 2 caractères").max(100, "Le nom de l'entreprise ne peut pas dépasser 100 caractères"),
  sector: z.enum([
    "informatique_tech",
    "commerce_vente",
    "marketing_communication",
    "finance_comptabilite",
    "ressources_humaines",
    "sante_medical",
    "btp_construction",
    "industrie_production",
    "restauration_hotellerie",
    "education_formation",
    "juridique_droit",
    "art_design",
    "services_personne",
    "transport_logistique",
    "agriculture_environnement",
  ]),
  description: z.string().min(50, "La description doit contenir au moins 50 caractères"),
  address: z.string().min(10, "L'adresse doit contenir au moins 10 caractères"),
  siret: z.string().length(14, "Le SIRET doit contenir exactement 14 chiffres").regex(/^\d{14}$/, "Le SIRET doit contenir uniquement des chiffres"),
  document_url: z.string().url().nullable().optional(),
});

export type RecruiterSettingsFormData = z.infer<typeof recruiterSettingsSchema>;
