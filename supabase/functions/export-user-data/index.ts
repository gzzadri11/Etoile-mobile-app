import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verify JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Authorization header required" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const userId = user.id;
    console.log(`[export-user-data] Exporting data for user ${userId}`);

    // 1. User role info
    const { data: userRole } = await supabase
      .from("user_roles")
      .select("role, is_premium, status, created_at")
      .eq("user_id", userId)
      .maybeSingle();

    // Fallback to users table
    const { data: userData } = !userRole
      ? await supabase
          .from("users")
          .select("role, is_premium, status, created_at")
          .eq("id", userId)
          .maybeSingle()
      : { data: null };

    const userInfo = userRole || userData || {};

    // 2. Seeker profile
    const { data: seekerProfile } = await supabase
      .from("seeker_profiles")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    // 3. Recruiter profile
    const { data: recruiterProfile } = await supabase
      .from("recruiter_profiles")
      .select("*")
      .eq("user_id", userId)
      .maybeSingle();

    // 4. Videos (metadata only, not the files)
    const { data: videos } = await supabase
      .from("videos")
      .select("id, title, category, type, status, created_at, updated_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    // 5. Conversations the user is part of
    const { data: conversations } = await supabase
      .from("conversations")
      .select("id, created_at, context")
      .or(`participant_1.eq.${userId},participant_2.eq.${userId}`)
      .order("created_at", { ascending: false });

    // 6. Messages SENT by the user only (RGPD: only user's own data)
    const { data: myMessages } = await supabase
      .from("messages")
      .select("id, conversation_id, content, created_at")
      .eq("sender_id", userId)
      .order("created_at", { ascending: false });

    // 7. Subscriptions
    const { data: subscriptions } = await supabase
      .from("subscriptions")
      .select("id, plan_type, status, created_at, current_period_end")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    // 8. Purchases
    const { data: purchases } = await supabase
      .from("purchases")
      .select("id, description, amount, status, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false });

    // Build export object
    const exportData = {
      export_date: new Date().toISOString(),
      user: {
        id: userId,
        email: user.email,
        ...userInfo,
      },
      profile: seekerProfile || recruiterProfile || null,
      videos: videos || [],
      conversations: conversations || [],
      my_messages: myMessages || [],
      subscriptions: subscriptions || [],
      purchases: purchases || [],
    };

    console.log(`[export-user-data] Export complete for ${userId}: ${Object.keys(exportData).length} sections`);

    return new Response(
      JSON.stringify(exportData),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[export-user-data] Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
