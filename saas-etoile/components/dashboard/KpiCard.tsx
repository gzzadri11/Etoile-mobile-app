import { TrendingUp, TrendingDown } from "lucide-react";

export function KpiCard({
  label,
  value,
  trend,
}: {
  label: string;
  value: string | number;
  trend?: { value: string; direction: "up" | "down" };
}) {
  return (
    <div className="rounded-xl border border-border bg-white p-6 shadow-xs">
      <div className="label mb-2 text-text-tertiary">{label}</div>
      <div className="mb-1 text-3xl font-bold text-text-primary">{value}</div>
      {trend && (
        <div
          className={`flex items-center gap-1 text-sm font-medium ${
            trend.direction === "up" ? "text-success" : "text-danger"
          }`}
        >
          {trend.direction === "up" ? (
            <TrendingUp className="h-4 w-4" />
          ) : (
            <TrendingDown className="h-4 w-4" />
          )}
          <span>{trend.value}</span>
        </div>
      )}
    </div>
  );
}
