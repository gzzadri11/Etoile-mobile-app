"use server";

import { createClient } from "@/lib/supabase/server";
import type { MatchScore, CandidateEvaluation } from "@/lib/types/database";

/**
 * Epic 14 : Get match scores for an offer
 *
 * Fetches all match scores for a given offer video ID
 * Scores are calculated via PostgreSQL function calculate_match_score()
 * and cached in match_scores table
 *
 * @param videoId The offer video ID
 * @returns Array of match scores sorted by score DESC
 */
export async function getMatchScoresForOffer(
  videoId: string
): Promise<MatchScore[]> {
  try {
    const supabase = await createClient();

    const { data, error } = await supabase
      .from("match_scores")
      .select("*")
      .eq("video_id", videoId)
      .order("score", { ascending: false });

    if (error) {
      console.error("Error fetching match scores:", error);
      return [];
    }

    return data || [];
  } catch (error) {
    console.error("Unexpected error in getMatchScoresForOffer:", error);
    return [];
  }
}

/**
 * Epic 14 : Calculate and upsert match score for a specific seeker-video pair
 *
 * Calls PostgreSQL function calculate_match_score() and stores result
 * Uses ON CONFLICT to handle existing scores (upsert pattern)
 *
 * @param seekerId The seeker user ID
 * @param videoId The offer video ID
 * @returns The calculated score or null if error
 */
export async function calculateAndStoreMatchScore(
  seekerId: string,
  videoId: string
): Promise<number | null> {
  try {
    const supabase = await createClient();

    // Call PostgreSQL function to calculate score
    const { data: scoreData, error: scoreError } = await supabase.rpc(
      "calculate_match_score",
      {
        p_seeker_id: seekerId,
        p_video_id: videoId,
      }
    );

    if (scoreError) {
      console.error("Error calculating match score:", scoreError);
      return null;
    }

    const score = scoreData as number;

    // Store score in match_scores table (upsert)
    const { error: upsertError } = await supabase
      .from("match_scores")
      .upsert(
        {
          seeker_id: seekerId,
          video_id: videoId,
          score,
          computed_at: new Date().toISOString(),
        },
        {
          onConflict: "seeker_id,video_id",
        }
      );

    if (upsertError) {
      console.error("Error upserting match score:", upsertError);
      return null;
    }

    return score;
  } catch (error) {
    console.error("Unexpected error in calculateAndStoreMatchScore:", error);
    return null;
  }
}

/**
 * Task #2 : Save or update candidate evaluation (3-state rating + notes)
 *
 * Upserts evaluation (rating + notes) for a specific application
 * Rating can be: 'interested', 'neutral', 'not_interested', or null
 *
 * @param applicationId The application ID
 * @param rating The rating (3 states or null)
 * @param notes Private notes about the candidate
 * @returns The saved evaluation or null if error
 */
export async function saveEvaluation(
  applicationId: string,
  rating: "interested" | "neutral" | "not_interested" | null,
  notes: string | null
): Promise<CandidateEvaluation | null> {
  try {
    const supabase = await createClient();

    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from("candidate_evaluations")
      .upsert(
        {
          recruiter_id: user.id,
          application_id: applicationId,
          rating,
          notes,
          updated_at: new Date().toISOString(),
        },
        {
          onConflict: "recruiter_id,application_id",
        }
      )
      .select()
      .single();

    if (error) {
      console.error("Error saving evaluation:", error);
      return null;
    }

    return data;
  } catch (error) {
    console.error("Unexpected error in saveEvaluation:", error);
    return null;
  }
}

/**
 * Task #2 : Get candidate evaluation for an application
 *
 * Fetches existing evaluation (rating + notes) for a specific application
 *
 * @param applicationId The application ID
 * @returns The evaluation or null if not found
 */
export async function getEvaluation(
  applicationId: string
): Promise<CandidateEvaluation | null> {
  try {
    const supabase = await createClient();

    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return null;

    const { data, error } = await supabase
      .from("candidate_evaluations")
      .select("*")
      .eq("recruiter_id", user.id)
      .eq("application_id", applicationId)
      .maybeSingle();

    if (error) {
      console.error("Error fetching evaluation:", error);
      return null;
    }

    return data;
  } catch (error) {
    console.error("Unexpected error in getEvaluation:", error);
    return null;
  }
}
