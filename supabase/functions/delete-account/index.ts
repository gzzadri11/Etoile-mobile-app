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

    // Create authenticated client to verify the user
    const supabaseAuth = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const userId = user.id;
    console.log(`[delete-account] Soft-deleting account for user ${userId}`);

    // Use service role client for admin operations
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // 1. Mark user as deleted in user_roles
    const { error: userError } = await supabase
      .from("user_roles")
      .update({
        status: "deleted",
        updated_at: new Date().toISOString(),
      })
      .eq("user_id", userId);

    if (userError) {
      console.error("[delete-account] Error updating user_roles:", userError);
      // Try users table as fallback
      await supabase
        .from("users")
        .update({
          status: "deleted",
          updated_at: new Date().toISOString(),
        })
        .eq("id", userId);
    }

    // 2. Soft-delete all user videos
    const { error: videoError } = await supabase
      .from("videos")
      .update({ status: "deleted" })
      .eq("user_id", userId);

    if (videoError) {
      console.error("[delete-account] Error deleting videos:", videoError);
    }

    // 3. Add deleted_at metadata to auth.users
    const { error: metaError } = await supabaseAuth.auth.admin.updateUserById(
      userId,
      {
        user_metadata: {
          ...user.user_metadata,
          deleted_at: new Date().toISOString(),
        },
      }
    );

    if (metaError) {
      console.error("[delete-account] Error updating auth metadata:", metaError);
    }

    // 4. Cancel any active subscriptions
    const { data: activeSubs } = await supabase
      .from("subscriptions")
      .select("id")
      .eq("user_id", userId)
      .eq("status", "active");

    if (activeSubs && activeSubs.length > 0) {
      await supabase
        .from("subscriptions")
        .update({ status: "cancelled" })
        .eq("user_id", userId)
        .eq("status", "active");
      console.log(`[delete-account] Cancelled ${activeSubs.length} subscriptions`);
    }

    // 5. Remove device tokens (no more push notifications)
    await supabase
      .from("device_tokens")
      .delete()
      .eq("user_id", userId);

    console.log(`[delete-account] Account ${userId} soft-deleted successfully`);

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[delete-account] Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
