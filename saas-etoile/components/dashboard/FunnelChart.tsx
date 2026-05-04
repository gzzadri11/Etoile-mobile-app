export function FunnelChart({
  data,
}: {
  data: { label: string; value: number; total: number }[];
}) {
  const maxValue = Math.max(...data.map((d) => d.value));

  return (
    <div className="space-y-4">
      {data.map((item, i) => {
        const percentage = maxValue > 0 ? (item.value / maxValue) * 100 : 0;

        return (
          <div key={i}>
            <div className="mb-2 flex items-center justify-between text-sm">
              <span className="font-medium text-text-primary">{item.label}</span>
              <span className="text-text-secondary">
                {item.value} / {item.total}
              </span>
            </div>
            <div className="h-10 overflow-hidden rounded-lg bg-bg-muted">
              <div
                className="flex h-full items-center bg-accent px-4 text-sm font-semibold text-white transition-all duration-500"
                style={{ width: `${percentage}%` }}
              >
                {item.value > 0 && `${item.value}`}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
