"use server";

import { createClient } from "@/lib/supabase/server";

/**
 * Calcule le temps moyen de réponse aux candidats (en heures)
 * Appelle la fonction PostgreSQL calculate_avg_response_time
 */
export async function getAverageResponseTime(): Promise<number> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  const { data, error } = await supabase.rpc("calculate_avg_response_time", {
    recruiter_id: user.id,
  });

  if (error) {
    console.error("Error fetching avg response time:", error);
    return 0;
  }

  return data ?? 0;
}

/**
 * Calcule le taux de shortlist (pourcentage de candidatures contactées)
 * Appelle la fonction PostgreSQL calculate_shortlist_rate
 */
export async function getShortlistRate(): Promise<number> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  const { data, error } = await supabase.rpc("calculate_shortlist_rate", {
    recruiter_id: user.id,
  });

  if (error) {
    console.error("Error fetching shortlist rate:", error);
    return 0;
  }

  return data ?? 0;
}

/**
 * Récupère les offres les plus performantes (nombre de candidatures)
 * Appelle la fonction PostgreSQL get_top_performing_offers
 */
export async function getTopPerformingOffers(
  limit = 5
): Promise<Array<{ video_id: string; title: string; applications_count: number }>> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase.rpc("get_top_performing_offers", {
    recruiter_id: user.id,
    limit_count: limit,
  });

  if (error) {
    console.error("Error fetching top performing offers:", error);
    return [];
  }

  return data ?? [];
}

/**
 * Récupère les données du funnel de conversion (applications par statut)
 * US-13.2 : Funnel visuel
 */
export async function getConversionFunnelData(): Promise<
  Array<{ status: string; count: number; label: string }>
> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase
    .from("applications")
    .select("status")
    .eq("recruiter_id", user.id);

  if (error) {
    console.error("Error fetching funnel data:", error);
    return [];
  }

  // Count by status
  const statusCounts = data.reduce(
    (acc, app) => {
      acc[app.status] = (acc[app.status] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );

  // Map to funnel format with French labels
  const STATUS_LABELS: Record<string, string> = {
    pending: "En attente",
    contacted: "Contactés",
    withdrawn: "Retirés",
  };

  return Object.entries(statusCounts).map(([status, count]) => ({
    status,
    count,
    label: STATUS_LABELS[status] || status,
  }));
}

/**
 * Compte les nouvelles candidatures depuis la dernière connexion
 * US-13.1 : Briefing quotidien
 */
export async function getNewApplicationsCount(): Promise<number> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return 0;

  // Récupérer last_login_at du recruteur
  const { data: userRole, error: userError } = await supabase
    .from("user_roles")
    .select("last_login_at")
    .eq("id", user.id)
    .single();

  if (userError || !userRole?.last_login_at) {
    return 0;
  }

  // Compter les candidatures appliquées après last_login_at
  const { count, error } = await supabase
    .from("applications")
    .select("*", { count: "exact", head: true })
    .eq("recruiter_id", user.id)
    .gt("applied_at", userRole.last_login_at);

  if (error) {
    console.error("Error counting new applications:", error);
    return 0;
  }

  return count ?? 0;
}
