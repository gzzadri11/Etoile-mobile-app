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
  photo_url: string | null;
  description: string | null;
  sector: string | null;
  address: string | null;
  locations: string[];
  latitude: number | null;
  longitude: number | null;
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
  latitude: number | null;
  longitude: number | null;
  domain: string | null;
  specialty: string | null;
  rhythm: string | null;
  skills: string[];
  created_at: string;
  updated_at: string;
}

export interface Video {
  id: string;
  user_id: string;
  type: "presentation" | "offer" | "poster";
  title: string | null;
  description: string | null;
  video_key: string;
  video_url: string | null;
  thumbnail_key: string | null;
  thumbnail_url: string | null;
  duration_seconds: number;
  file_size_bytes: number | null;
  resolution: string | null;
  status: "processing" | "active" | "suspended" | "deleted";
  contract_type: string | null;
  sector: string | null;
  address: string | null;
  keywords: string[];
  views_count: number;
  unique_viewers: number;
  published_at: string | null;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Application {
  id: string;
  video_id: string;
  seeker_id: string;
  recruiter_id: string;
  status: "pending" | "contacted" | "withdrawn";
  applied_at: string;
}

export interface MatchScore {
  id: string;
  seeker_id: string;
  video_id: string;
  score: number;
  computed_at: string;
}

export interface CandidateWithProfile {
  application: Application;
  seeker: SeekerProfile;
  offer: {
    id: string;
    title: string | null;
    type: "offer" | "poster";
    sector: string | null;
    contract_type: string | null;
  };
  presentation_video: {
    id: string;
    video_key: string;
    video_url: string | null;
    thumbnail_key: string | null;
    thumbnail_url: string | null;
    duration_seconds: number;
  } | null;
}

export interface Conversation {
  id: string;
  participant_1: string;
  participant_2: string;
  video_id: string | null;
  last_message_at: string | null;
  last_message_preview: string | null;
  participant_1_read_at: string | null;
  participant_2_read_at: string | null;
  created_at: string;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  content_type: "text" | "system";
  is_read: boolean;
  read_at: string | null;
  created_at: string;
}

export interface ConversationWithParticipant {
  conversation: Conversation;
  participant: SeekerProfile;
  unreadCount: number;
}

export interface ConversationWithUnread extends Conversation {
  unread_count: number;
  participant: {
    user_id: string;
    first_name: string | null;
    username: string | null;
    photo_url: string | null;
    specialty: string | null;
  };
}

export interface CandidateEvaluation {
  id: string;
  recruiter_id: string;
  application_id: string;
  rating: "interested" | "neutral" | "not_interested" | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
}
