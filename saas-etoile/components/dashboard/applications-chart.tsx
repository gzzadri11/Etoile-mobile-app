"use client";

import {
  LineChart,
  Line,
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

interface DataPoint {
  date: string;
  count: number;
}

interface ApplicationsChartProps {
  data: DataPoint[];
}

export function ApplicationsChart({ data }: ApplicationsChartProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Évolution des candidatures</CardTitle>
        <CardDescription>Nombre de candidatures reçues sur les 7 derniers jours</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="h-[300px]">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
              <XAxis
                dataKey="date"
                className="stroke-text-secondary"
                fontSize={12}
                tickLine={false}
              />
              <YAxis
                className="stroke-text-secondary"
                fontSize={12}
                tickLine={false}
                allowDecimals={false}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "var(--bg)",
                  border: "1px solid var(--border)",
                  borderRadius: "8px",
                  fontSize: "14px",
                }}
                labelStyle={{ color: "var(--text-primary)", fontWeight: 600 }}
              />
              <Line
                type="monotone"
                dataKey="count"
                stroke="var(--accent)"
                strokeWidth={2}
                dot={{ fill: "var(--accent)", r: 4 }}
                activeDot={{ r: 6, fill: "var(--accent-dark)" }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}
