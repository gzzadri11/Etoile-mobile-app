import { Sidebar } from "@/components/layout/sidebar";
import { createClient } from "@/lib/supabase/server";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  let recruiterProfile = null;

  if (user) {
    const { data } = await supabase
      .from("recruiter_profiles")
      .select("company_name, photo_url")
      .eq("user_id", user.id)
      .single();

    recruiterProfile = data;
  }

  const userInfo = user && recruiterProfile
    ? {
        email: user.email || "",
        companyName: recruiterProfile.company_name || "Entreprise",
        photoUrl: recruiterProfile.photo_url || null,
      }
    : null;

  return (
    <div className="min-h-screen bg-bg-subtle">
      {/* Sidebar fixe 220px */}
      <Sidebar userInfo={userInfo} />

      {/* Contenu principal avec margin-left */}
      <main className="ml-[220px] min-h-screen p-8">
        {children}
      </main>
    </div>
  );
}
