"use client";

import { Bar, BarChart, CartesianGrid, Cell, XAxis, YAxis } from "recharts";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";

interface FunnelData {
  status: string;
  count: number;
  label: string;
}

interface ConversionFunnelProps {
  data: FunnelData[];
}

/**
 * US-13.2 : Funnel visuel de conversion
 * BarChart horizontal avec couleurs custom Etoile
 */
export function ConversionFunnel({ data }: ConversionFunnelProps) {
  // Ordre et couleurs des statuts (design system Étoile)
  const STATUS_CONFIG: Record<string, { color: string; order: number }> = {
    pending: { color: "#635BFF", order: 1 },    // Violet (accent)
    contacted: { color: "#10B981", order: 2 },  // Vert (success)
    withdrawn: { color: "#EF4444", order: 3 },  // Rouge (danger)
  };

  // Trier les données dans l'ordre du funnel
  const sortedData = [...data].sort(
    (a, b) => (STATUS_CONFIG[a.status]?.order ?? 999) - (STATUS_CONFIG[b.status]?.order ?? 999)
  );

  const chartConfig = {
    count: {
      label: "Candidatures",
    },
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Funnel de conversion</CardTitle>
        <CardDescription>
          Parcours des candidatures reçues
        </CardDescription>
      </CardHeader>
      <CardContent>
        {sortedData.length === 0 ? (
          <div className="flex h-[200px] items-center justify-center text-sm text-muted-foreground">
            Aucune candidature pour le moment
          </div>
        ) : (
          <ChartContainer config={chartConfig} className="h-[200px] w-full">
            <BarChart
              data={sortedData}
              layout="vertical"
              margin={{ left: 0, right: 20, top: 5, bottom: 5 }}
            >
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" />
              <YAxis
                type="category"
                dataKey="label"
                width={80}
                tick={{ fontSize: 12 }}
              />
              <ChartTooltip content={<ChartTooltipContent />} />
              <Bar dataKey="count" radius={[0, 4, 4, 0]}>
                {sortedData.map((entry) => (
                  <Cell
                    key={entry.status}
                    fill={STATUS_CONFIG[entry.status]?.color ?? "var(--text-secondary)"}
                  />
                ))}
              </Bar>
            </BarChart>
          </ChartContainer>
        )}
      </CardContent>
    </Card>
  );
}
