export function ActivityFeed({
  activities,
}: {
  activities: {
    name: string;
    meta: string;
    score: number;
    timestamp: string;
    initials: string;
    color: string;
  }[];
}) {
  return (
    <div className="space-y-4">
      {activities.map((activity, i) => (
        <div key={i} className="flex items-start gap-3">
          <div
            className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gradient-to-br ${activity.color} text-sm font-bold text-white`}
          >
            {activity.initials}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <span className="font-semibold text-text-primary">
                {activity.name}
              </span>
              {activity.score > 0 ? (
                <span
                  className={`rounded-full px-2 py-0.5 text-xs font-bold ${
                    activity.score >= 80
                      ? "bg-success/10 text-success"
                      : "bg-warning/10 text-warning"
                  }`}
                >
                  {activity.score}%
                </span>
              ) : (
                <span className="text-xs text-text-tertiary italic">Calcul en cours…</span>
              )}
            </div>
            <div className="text-sm text-text-secondary">{activity.meta}</div>
          </div>
          <div className="text-xs text-text-tertiary">{activity.timestamp}</div>
        </div>
      ))}
    </div>
  );
}
