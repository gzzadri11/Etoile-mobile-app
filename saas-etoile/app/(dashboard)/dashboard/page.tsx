"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { RecruiterProfile } from "@/lib/types/database";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function DashboardPage() {
  const [companyName, setCompanyName] = useState<string>("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadProfile() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data } = await supabase
        .from("recruiter_profiles")
        .select("company_name")
        .eq("user_id", user.id)
        .single<Pick<RecruiterProfile, "company_name">>();

      if (data) {
        setCompanyName(data.company_name);
      }
      setLoading(false);
    }

    loadProfile();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <p className="text-muted-foreground">Chargement...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-bold">
        Bonjour{companyName ? `, ${companyName}` : ""} !
      </h1>

      <div className="grid gap-6 sm:grid-cols-3">
        <Card>
          <CardHeader>
            <CardDescription>Candidatures</CardDescription>
            <CardTitle className="text-3xl">0</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Aucune candidature pour le moment
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Messages</CardDescription>
            <CardTitle className="text-3xl">0</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Aucun message non lu
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardDescription>Offres publiées</CardDescription>
            <CardTitle className="text-3xl">0</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              Publiez votre première offre pour recevoir des candidatures
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
