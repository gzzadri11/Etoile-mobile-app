import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { DashboardHomeClient } from "./_components/DashboardHomeClient";

export default async function DashboardHomePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  return <DashboardHomeClient />;
}
