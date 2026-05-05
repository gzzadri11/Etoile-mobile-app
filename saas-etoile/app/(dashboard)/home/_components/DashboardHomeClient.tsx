"use client";

import { OnboardingBanner } from "@/components/dashboard/OnboardingBanner";
import { KpiCard } from "@/components/dashboard/KpiCard";
import { FunnelChart } from "@/components/dashboard/FunnelChart";
import { ActivityFeed } from "@/components/dashboard/ActivityFeed";
import { AlertsSection } from "@/components/dashboard/AlertsSection";
import { LoadingSpinner } from "@/components/ui/LoadingSpinner";
import { useDashboardData } from "@/hooks/useDashboardData";

export function DashboardHomeClient() {
  const { stats, recentActivities, alertsData, funnelData, loading } = useDashboardData();

  if (loading) return <LoadingSpinner />;

  const kpis = [
    { label: "Candidatures reçues", value: stats.totalApplications },
    { label: "Shortlistés", value: stats.contacted },
    { label: "Contactés", value: stats.contacted },
    { label: "Offres actives", value: stats.activeOffers },
  ];

  return (
    <div className="space-y-8">
      <OnboardingBanner />

      <AlertsSection
        unreadMessages={alertsData.unreadMessages}
        expiringOffers={alertsData.expiringOffers}
        pendingCandidates={alertsData.pendingCandidates}
      />

      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        {kpis.map((kpi, i) => (
          <KpiCard key={i} label={kpi.label} value={kpi.value} />
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
          <h2 className="mb-6 text-lg font-bold text-text-primary">Nouvelles candidatures</h2>
          {recentActivities.length > 0 ? (
            <ActivityFeed activities={recentActivities} />
          ) : (
            <div className="py-8 text-center text-sm text-text-tertiary">Aucune candidature récente</div>
          )}
        </div>

        <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
          <h2 className="mb-6 text-lg font-bold text-text-primary">Pipeline de conversion</h2>
          {funnelData.length > 0 ? (
            <FunnelChart data={funnelData} />
          ) : (
            <div className="py-8 text-center text-sm text-text-tertiary">Aucune donnée de conversion</div>
          )}
        </div>
      </div>
    </div>
  );
}
