'use client';

import { AlertCircle, MessageSquare, Calendar, Users } from 'lucide-react';
import Link from 'next/link';
import { ROUTES } from '@/lib/constants/routes';

interface Alert {
  type: 'messages' | 'expiring' | 'pending';
  count: number;
  label: string;
  href: string;
}

interface AlertsSectionProps {
  unreadMessages: number;
  expiringOffers: number;
  pendingCandidates: number;
}

export function AlertsSection({
  unreadMessages,
  expiringOffers,
  pendingCandidates,
}: AlertsSectionProps) {
  const alerts: Alert[] = [
    {
      type: 'messages',
      count: unreadMessages,
      label: unreadMessages > 1 ? 'messages non lus' : 'message non lu',
      href: ROUTES.MESSAGES,
    },
    {
      type: 'expiring',
      count: expiringOffers,
      label: expiringOffers > 1 ? 'offres expirent bientôt' : 'offre expire bientôt',
      href: ROUTES.OFFERS,
    },
    {
      type: 'pending',
      count: pendingCandidates,
      label: pendingCandidates > 1 ? 'candidats à traiter' : 'candidat à traiter',
      href: ROUTES.CANDIDATES,
    },
  ];

  const activeAlerts = alerts.filter((a) => a.count > 0);

  if (activeAlerts.length === 0) {
    return (
      <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
        <h2 className="mb-4 text-lg font-bold text-text-primary">Actions à faire</h2>
        <div className="flex flex-col items-center justify-center py-8 text-center">
          <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-accent/10">
            ✓
          </div>
          <p className="text-sm text-text-secondary">Tout est à jour !</p>
          <p className="mt-1 text-xs text-text-tertiary">
            Aucune action urgente pour le moment.
          </p>
        </div>
      </div>
    );
  }

  const getIcon = (type: Alert['type']) => {
    switch (type) {
      case 'messages':
        return <MessageSquare className="h-5 w-5" />;
      case 'expiring':
        return <Calendar className="h-5 w-5" />;
      case 'pending':
        return <Users className="h-5 w-5" />;
    }
  };

  const getColor = (type: Alert['type']) => {
    switch (type) {
      case 'messages':
        return 'bg-blue-50 text-blue-700 border-blue-200';
      case 'expiring':
        return 'bg-orange-50 text-orange-700 border-orange-200';
      case 'pending':
        return 'bg-purple-50 text-purple-700 border-purple-200';
    }
  };

  return (
    <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
      <h2 className="mb-4 text-lg font-bold text-text-primary">
        <AlertCircle className="mb-1 mr-2 inline h-5 w-5 text-accent" />
        Actions à faire
      </h2>
      <div className="space-y-3">
        {activeAlerts.map((alert) => (
          <Link
            key={alert.type}
            href={alert.href}
            className={`flex items-center justify-between rounded-lg border p-4 transition-all hover:shadow-sm ${getColor(
              alert.type
            )}`}
          >
            <div className="flex items-center gap-3">
              {getIcon(alert.type)}
              <div>
                <p className="text-sm font-medium">
                  {alert.count} {alert.label}
                </p>
              </div>
            </div>
            <span className="text-xs font-semibold">Voir →</span>
          </Link>
        ))}
      </div>
    </div>
  );
}
