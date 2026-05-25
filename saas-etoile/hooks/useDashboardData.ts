"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";

export interface DashboardStats {
  totalApplications: number;
  contacted: number;
  activeOffers: number;
}

export interface RecentActivity {
  name: string;
  meta: string;
  score: number;
  timestamp: string;
  initials: string;
  color: string;
}

export interface AlertsData {
  unreadMessages: number;
  expiringOffers: number;
  pendingCandidates: number;
}

export interface FunnelItem {
  label: string;
  value: number;
  total: number;
}

const COLORS = [
  "from-indigo-500 to-purple-500",
  "from-blue-500 to-cyan-500",
  "from-pink-500 to-rose-500",
  "from-green-500 to-emerald-500",
];

export function useDashboardData() {
  const supabase = useRef(createClient()).current;
  const [userId, setUserId] = useState<string | null>(null);
  const [stats, setStats] = useState<DashboardStats>({ totalApplications: 0, contacted: 0, activeOffers: 0 });
  const [recentActivities, setRecentActivities] = useState<RecentActivity[]>([]);
  const [alertsData, setAlertsData] = useState<AlertsData>({ unreadMessages: 0, expiringOffers: 0, pendingCandidates: 0 });
  const [funnelData, setFunnelData] = useState<FunnelItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (user) setUserId(user.id);
    });
  }, [supabase]);

  const fetchStats = useCallback(async (uid: string) => {
    const [{ count: total }, { count: contacted }, { count: activeOffers }] = await Promise.all([
      supabase.from("applications").select("*", { count: "exact", head: true }).eq("recruiter_id", uid),
      supabase.from("applications").select("*", { count: "exact", head: true }).eq("recruiter_id", uid).eq("status", "contacted"),
      // videos.user_id = recruiter's auth ID, status != 'deleted'
      supabase.from("videos").select("*", { count: "exact", head: true }).eq("user_id", uid).neq("status", "deleted"),
    ]);
    setStats({ totalApplications: total ?? 0, contacted: contacted ?? 0, activeOffers: activeOffers ?? 0 });
  }, [supabase]);

  const fetchRecentActivities = useCallback(async (uid: string) => {
    // Step 1: fetch applications
    const { data: apps } = await supabase
      .from("applications")
      .select("id, seeker_id, video_id, applied_at")
      .eq("recruiter_id", uid)
      .order("applied_at", { ascending: false })
      .limit(4);

    if (!apps || apps.length === 0) { setRecentActivities([]); return; }

    // Step 2: fetch seeker profiles (no FK on seeker_id → separate query)
    const seekerIds = apps.map((a: any) => a.seeker_id);
    const { data: seekers } = await supabase
      .from("seeker_profiles")
      .select("user_id, first_name, last_name, city, domain")
      .in("user_id", seekerIds);

    // Step 3: fetch video sectors
    const videoIds = apps.map((a: any) => a.video_id);
    const { data: videos } = await supabase
      .from("videos")
      .select("id, sector")
      .in("id", videoIds);

    // Step 4: fetch match scores
    const { data: matchScores } = await supabase
      .from("match_scores")
      .select("seeker_id, video_id, score")
      .in("video_id", videoIds);

    const seekerMap = Object.fromEntries((seekers ?? []).map((s: any) => [s.user_id, s]));
    const videoMap = Object.fromEntries((videos ?? []).map((v: any) => [v.id, v]));
    const scoreMap = Object.fromEntries((matchScores ?? []).map((s: any) => [`${s.seeker_id}_${s.video_id}`, s.score]));
    const now = new Date();

    setRecentActivities(
      apps.map((app: any, i: number) => {
        const s = seekerMap[app.seeker_id];
        const v = videoMap[app.video_id];
        const fn = s?.first_name || "?";
        const ln = s?.last_name || "?";
        const diffH = Math.floor((now.getTime() - new Date(app.applied_at).getTime()) / 3_600_000);
        return {
          name: `${fn} ${ln}`,
          meta: `${v?.sector || s?.domain || "?"} · ${s?.city || "?"}`,
          score: scoreMap[`${app.seeker_id}_${app.video_id}`] ?? 0,
          timestamp: diffH < 1 ? "Il y a moins d'1h" : diffH < 24 ? `Il y a ${diffH}h` : "Hier",
          initials: `${fn[0]}${ln[0]}`.toUpperCase(),
          color: COLORS[i % COLORS.length],
        };
      })
    );
  }, [supabase]);

  const fetchAlerts = useCallback(async (uid: string) => {
    const sevenDays = new Date();
    sevenDays.setDate(sevenDays.getDate() + 7);
    const twoDaysAgo = new Date();
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

    // Unread messages: count messages in my conversations where sender != me and is_read = false
    const { data: myConvs } = await supabase
      .from("conversations")
      .select("id")
      .or(`participant_1.eq.${uid},participant_2.eq.${uid}`);

    const convIds = (myConvs ?? []).map((c: any) => c.id);
    const unreadCount = convIds.length > 0
      ? (await supabase.from("messages").select("*", { count: "exact", head: true }).in("conversation_id", convIds).neq("sender_id", uid).eq("is_read", false)).count ?? 0
      : 0;

    // Expiring offers: videos.user_id = uid, not deleted, expires_at within 7 days
    const { count: expiring } = await supabase
      .from("videos")
      .select("*", { count: "exact", head: true })
      .eq("user_id", uid)
      .neq("status", "deleted")
      .not("expires_at", "is", null)
      .lte("expires_at", sevenDays.toISOString());

    // Pending candidates: applications pending for more than 2 days
    const { count: pending } = await supabase
      .from("applications")
      .select("*", { count: "exact", head: true })
      .eq("recruiter_id", uid)
      .eq("status", "pending")
      .lte("applied_at", twoDaysAgo.toISOString());

    setAlertsData({ unreadMessages: unreadCount, expiringOffers: expiring ?? 0, pendingCandidates: pending ?? 0 });
  }, [supabase]);

  const fetchFunnel = useCallback(async (uid: string) => {
    const [{ count: total }, { count: contacted }] = await Promise.all([
      supabase.from("applications").select("*", { count: "exact", head: true }).eq("recruiter_id", uid),
      supabase.from("applications").select("*", { count: "exact", head: true }).eq("recruiter_id", uid).eq("status", "contacted"),
    ]);
    const t = total ?? 0;
    setFunnelData([
      { label: "Candidatures reçues", value: t, total: t },
      { label: "Contactés", value: contacted ?? 0, total: t },
    ]);
  }, [supabase]);

  const fetchAll = useCallback(async (uid: string) => {
    await Promise.all([fetchStats(uid), fetchRecentActivities(uid), fetchAlerts(uid), fetchFunnel(uid)]);
    setLoading(false);
  }, [fetchStats, fetchRecentActivities, fetchAlerts, fetchFunnel]);

  useEffect(() => {
    if (!userId) return;
    fetchAll(userId);

    const appSub = supabase
      .channel("dashboard-applications")
      .on("postgres_changes", { event: "*", schema: "public", table: "applications", filter: `recruiter_id=eq.${userId}` }, () => fetchAll(userId))
      .subscribe();

    const msgSub = supabase
      .channel("dashboard-messages")
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "messages" }, () => fetchAlerts(userId))
      .subscribe();

    return () => {
      supabase.removeChannel(appSub);
      supabase.removeChannel(msgSub);
    };
  }, [userId, fetchAll, fetchAlerts, supabase]);

  return { stats, recentActivities, alertsData, funnelData, loading };
}
