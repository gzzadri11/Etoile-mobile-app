"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

interface OfferData {
  title: string;
  count: number;
}

interface TopOffersChartProps {
  data: OfferData[];
}

export function TopOffersChart({ data }: TopOffersChartProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Top 5 offres</CardTitle>
        <CardDescription>Offres ayant reçu le plus de candidatures</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="h-[300px]">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
              <XAxis
                type="number"
                className="stroke-text-secondary"
                fontSize={12}
                tickLine={false}
                allowDecimals={false}
              />
              <YAxis
                type="category"
                dataKey="title"
                className="stroke-text-secondary"
                fontSize={12}
                tickLine={false}
                width={120}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "var(--bg)",
                  border: "1px solid var(--border)",
                  borderRadius: "8px",
                  fontSize: "14px",
                }}
                cursor={{ fill: "var(--bg-muted)" }}
              />
              <Bar
                dataKey="count"
                fill="var(--accent)"
                radius={[0, 4, 4, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}
