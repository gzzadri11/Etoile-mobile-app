export interface UserRole {
  user_id: string;
  role: "seeker" | "recruiter" | "admin";
  created_at: string;
}

export interface RecruiterProfile {
  user_id: string;
  company_name: string;
  siret: string | null;
  siren: string | null;
  legal_form: string | null;
  document_type: string | null;
  document_url: string | null;
  document_uploaded_at: string | null;
  logo_url: string | null;
  description: string | null;
  sector: string | null;
  locations: string[];
  verification_status: "pending" | "verified" | "rejected";
  verified_at: string | null;
  rejection_reason: string | null;
  video_credits: number;
  poster_credits: number;
  created_at: string;
  updated_at: string;
}

export interface SeekerProfile {
  user_id: string;
  first_name: string | null;
  last_name: string | null;
  username: string | null;
  age: number | null;
  photo_url: string | null;
  school: string | null;
  study_level: string | null;
  city: string | null;
  domain: string | null;
  specialty: string | null;
  created_at: string;
  updated_at: string;
}
