import { PageHeader } from "@/components/layout/PageHeader";
import { OnboardingBanner } from "@/components/dashboard/OnboardingBanner";
import { KpiCard } from "@/components/dashboard/KpiCard";
import { FunnelChart } from "@/components/dashboard/FunnelChart";
import { ActivityFeed } from "@/components/dashboard/ActivityFeed";
import { AlertsSection } from "@/components/dashboard/AlertsSection";
import { createClient } from "@/lib/supabase/server";
import {
  getConversionFunnelData,
  getNewApplicationsCount,
} from "@/app/(dashboard)/dashboard/actions";

async function getKpiData() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Count total applications
  const { count: totalApplications } = await supabase
    .from("applications")
    .select("*", { count: "exact", head: true })
    .eq("recruiter_id", user.id);

  // Count contacted (shortlisted)
  const { count: contacted } = await supabase
    .from("applications")
    .select("*", { count: "exact", head: true })
    .eq("recruiter_id", user.id)
    .eq("status", "contacted");

  // Count active offers
  const { count: activeOffers } = await supabase
    .from("videos")
    .select("*", { count: "exact", head: true })
    .eq("recruiter_id", user.id)
    .eq("is_deleted", false);

  // Get new applications since last login
  const newApplications = await getNewApplicationsCount();

  return {
    totalApplications: totalApplications ?? 0,
    contacted: contacted ?? 0,
    activeOffers: activeOffers ?? 0,
    newApplications,
  };
}

async function getRecentApplications() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data: applications } = await supabase
    .from("applications")
    .select(
      `
      id,
      applied_at,
      seeker:seeker_id (
        first_name,
        last_name,
        city,
        domain,
        specialty
      ),
      video:video_id (
        sector,
        specialty
      )
    `
    )
    .eq("recruiter_id", user.id)
    .order("applied_at", { ascending: false })
    .limit(4);

  if (!applications) return [];

  return applications.map((app, index) => {
    const seeker = app.seeker as any;
    const video = app.video as any;
    const firstName = seeker?.first_name || "?";
    const lastName = seeker?.last_name || "?";
    const initials = `${firstName[0]}${lastName[0]}`.toUpperCase();

    // Gradient colors rotation
    const colors = [
      "from-indigo-500 to-purple-500",
      "from-blue-500 to-cyan-500",
      "from-pink-500 to-rose-500",
      "from-green-500 to-emerald-500",
    ];

    // Calculate time ago
    const now = new Date();
    const appliedAt = new Date(app.applied_at);
    const diffHours = Math.floor(
      (now.getTime() - appliedAt.getTime()) / (1000 * 60 * 60)
    );
    let timestamp = "";
    if (diffHours < 1) timestamp = "Il y a moins d'1h";
    else if (diffHours < 24) timestamp = `Il y a ${diffHours}h`;
    else timestamp = "Hier";

    return {
      name: `${firstName} ${lastName}`,
      meta: `${video?.sector || seeker?.domain || "?"} · ${seeker?.city || "?"}`,
      score: 0, // Score will be calculated later in Epic 14
      timestamp,
      initials,
      color: colors[index % colors.length],
    };
  });
}

async function getAlertsData() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { unreadMessages: 0, expiringOffers: 0, pendingCandidates: 0 };

  // Count unread messages (messages from seekers that recruiter hasn't read)
  const { count: unreadMessages } = await supabase
    .from("messages")
    .select("*", { count: "exact", head: true })
    .eq("receiver_id", user.id)
    .eq("read", false);

  // Count offers expiring in less than 7 days
  const sevenDaysFromNow = new Date();
  sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);

  const { count: expiringOffers } = await supabase
    .from("videos")
    .select("*", { count: "exact", head: true })
    .eq("user_id", user.id)
    .eq("is_deleted", false)
    .not("expires_at", "is", null)
    .lte("expires_at", sevenDaysFromNow.toISOString());

  // Count candidates pending evaluation (applied more than 2 days ago, status still pending)
  const twoDaysAgo = new Date();
  twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

  const { count: pendingCandidates } = await supabase
    .from("applications")
    .select("*", { count: "exact", head: true })
    .eq("recruiter_id", user.id)
    .eq("status", "pending")
    .lte("applied_at", twoDaysAgo.toISOString());

  return {
    unreadMessages: unreadMessages ?? 0,
    expiringOffers: expiringOffers ?? 0,
    pendingCandidates: pendingCandidates ?? 0,
  };
}

export default async function DashboardHomePage() {
  const kpiData = await getKpiData();
  const funnelData = await getConversionFunnelData();
  const recentActivities = await getRecentApplications();
  const alertsData = await getAlertsData();

  if (!kpiData) {
    return (
      <div className="flex h-[50vh] items-center justify-center">
        <p className="text-text-secondary">
          Vous devez être connecté pour voir le tableau de bord
        </p>
      </div>
    );
  }

  const kpis = [
    {
      label: "Candidatures reçues",
      value: kpiData.totalApplications,
      trend:
        kpiData.newApplications > 0
          ? {
              value: `+${kpiData.newApplications} nouvelles`,
              direction: "up" as const,
            }
          : undefined,
    },
    {
      label: "Shortlistés",
      value: kpiData.contacted,
      trend: undefined,
    },
    {
      label: "Contactés",
      value: kpiData.contacted,
      trend: undefined,
    },
    {
      label: "Offres actives",
      value: kpiData.activeOffers,
      trend: undefined,
    },
  ];

  // Transform funnel data for chart
  const funnelChartData = funnelData.map((item) => ({
    label: item.label,
    value: item.count,
    total: kpiData.totalApplications,
  }));

  return (
    <div className="space-y-8">
      {/* Onboarding Banner */}
      <OnboardingBanner />

      {/* Alertes & Actions */}
      <AlertsSection
        unreadMessages={alertsData.unreadMessages}
        expiringOffers={alertsData.expiringOffers}
        pendingCandidates={alertsData.pendingCandidates}
      />

      {/* KPIs Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        {kpis.map((kpi, i) => (
          <KpiCard key={i} label={kpi.label} value={kpi.value} trend={kpi.trend} />
        ))}
      </div>

      {/* Grid 2 colonnes */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Nouvelles candidatures */}
        <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
          <h2 className="mb-6 text-lg font-bold text-text-primary">
            Nouvelles candidatures
          </h2>
          {recentActivities.length > 0 ? (
            <ActivityFeed activities={recentActivities} />
          ) : (
            <div className="py-8 text-center text-sm text-text-tertiary">
              Aucune candidature récente
            </div>
          )}
        </div>

        {/* Pipeline */}
        <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
          <h2 className="mb-6 text-lg font-bold text-text-primary">
            Pipeline de conversion
          </h2>
          {funnelChartData.length > 0 ? (
            <FunnelChart data={funnelChartData} />
          ) : (
            <div className="py-8 text-center text-sm text-text-tertiary">
              Aucune donnée de conversion
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
