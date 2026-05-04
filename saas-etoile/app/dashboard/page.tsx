import { redirect } from "next/navigation";

export default function DashboardRedirectPage() {
  // Redirect /dashboard to /home (dashboard home)
  redirect("/home");
}
