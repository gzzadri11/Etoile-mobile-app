import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_SERVICE_ACCOUNT_KEY = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY")!;

// FCM HTTP v1 API endpoint
const FCM_API_URL = "https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send";

// =============================================================================
// Types
// =============================================================================

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: Record<string, unknown>;
  schema: string;
}

interface RequestBody {
  type: "new_message" | "new_conversation" | "profile_reminder";
  record?: Record<string, unknown>;
}

// =============================================================================
// Firebase Auth (OAuth2 token from Service Account)
// =============================================================================

async function getFirebaseAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_KEY);
  const now = Math.floor(Date.now() / 1000);

  // Create JWT for Google OAuth2
  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = btoa(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  );

  // Sign JWT with service account private key
  const signInput = `${header}.${claim}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(signInput));
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");

  const jwt = `${header}.${claim}.${signatureB64}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

// =============================================================================
// Send FCM Notification
// =============================================================================

async function sendFCMNotification(
  accessToken: string,
  projectId: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<boolean> {
  const url = FCM_API_URL.replace("{PROJECT_ID}", projectId);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data,
        android: {
          priority: "high",
          notification: { channel_id: "messages", sound: "default" },
        },
        apns: {
          payload: { aps: { sound: "default", badge: 1 } },
        },
      },
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    console.error(`FCM error for token ${token.substring(0, 10)}...:`, error);

    // Token is invalid/expired - should be cleaned up
    if (
      error?.error?.code === 404 ||
      error?.error?.code === 410 ||
      error?.error?.details?.[0]?.errorCode === "UNREGISTERED"
    ) {
      return false; // Token invalid
    }
  }

  return true; // Token still valid (even if send failed for other reasons)
}

// =============================================================================
// Deduplication
// =============================================================================

async function shouldSendNotification(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  type: string,
  referenceId?: string
): Promise<boolean> {
  // Check if a notification was sent for this type + reference in the last minute
  const oneMinuteAgo = new Date(Date.now() - 60 * 1000).toISOString();

  let query = supabase
    .from("notification_log")
    .select("id")
    .eq("user_id", userId)
    .eq("type", type)
    .gte("created_at", oneMinuteAgo);

  if (referenceId) {
    query = query.eq("reference_id", referenceId);
  }

  const { data } = await query.limit(1);
  return !data || data.length === 0;
}

async function logNotification(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  type: string,
  referenceId?: string
): Promise<void> {
  await supabase.from("notification_log").insert({
    user_id: userId,
    type,
    reference_id: referenceId || null,
  });
}

// =============================================================================
// Notification Handlers
// =============================================================================

async function handleNewMessage(
  supabase: ReturnType<typeof createClient>,
  record: Record<string, unknown>,
  accessToken: string,
  projectId: string
): Promise<void> {
  const conversationId = record.conversation_id as string;
  const senderId = record.sender_id as string;
  const content = record.content as string;

  // Get conversation to find the recipient
  const { data: conversation } = await supabase
    .from("conversations")
    .select("participant_1, participant_2")
    .eq("id", conversationId)
    .single();

  if (!conversation) return;

  const recipientId =
    conversation.participant_1 === senderId
      ? conversation.participant_2
      : conversation.participant_1;

  // Don't notify sender
  if (recipientId === senderId) return;

  // Deduplication check
  const shouldSend = await shouldSendNotification(
    supabase,
    recipientId,
    "new_message",
    conversationId
  );
  if (!shouldSend) {
    console.log(`Dedup: skipping notification for conversation ${conversationId}`);
    return;
  }

  // Get sender info for notification text
  const senderName = await getSenderName(supabase, senderId);
  const preview = content.length > 80 ? content.substring(0, 80) + "..." : content;

  // Get recipient's device tokens
  const { data: tokens } = await supabase
    .from("device_tokens")
    .select("id, token")
    .eq("user_id", recipientId);

  if (!tokens || tokens.length === 0) return;

  // Send to all devices
  const invalidTokenIds: string[] = [];
  for (const deviceToken of tokens) {
    const isValid = await sendFCMNotification(
      accessToken,
      projectId,
      deviceToken.token,
      "Nouveau message",
      `${senderName} : ${preview}`,
      {
        type: "new_message",
        conversation_id: conversationId,
        click_action: "OPEN_CHAT",
      }
    );
    if (!isValid) {
      invalidTokenIds.push(deviceToken.id);
    }
  }

  // Clean up invalid tokens
  if (invalidTokenIds.length > 0) {
    await supabase.from("device_tokens").delete().in("id", invalidTokenIds);
    console.log(`Cleaned ${invalidTokenIds.length} invalid tokens`);
  }

  // Log notification
  await logNotification(supabase, recipientId, "new_message", conversationId);
}

async function handleNewConversation(
  supabase: ReturnType<typeof createClient>,
  record: Record<string, unknown>,
  accessToken: string,
  projectId: string
): Promise<void> {
  const conversationId = record.id as string;
  const participant1 = record.participant_1 as string;
  const participant2 = record.participant_2 as string;
  const context = record.context as string | undefined;

  // The initiator is participant_1, notify participant_2
  const recipientId = participant2;
  const senderId = participant1;

  // Deduplication
  const shouldSend = await shouldSendNotification(
    supabase,
    recipientId,
    "new_conversation",
    conversationId
  );
  if (!shouldSend) return;

  const senderName = await getSenderName(supabase, senderId);

  // Determine notification type based on context
  const isApplication = context === "application" || context === "postuler";
  const title = isApplication ? "Nouvelle candidature" : "Un recruteur vous contacte";
  const body = isApplication
    ? `${senderName} a postule a votre offre`
    : `${senderName} souhaite vous contacter`;

  // Get recipient tokens
  const { data: tokens } = await supabase
    .from("device_tokens")
    .select("id, token")
    .eq("user_id", recipientId);

  if (!tokens || tokens.length === 0) return;

  const invalidTokenIds: string[] = [];
  for (const deviceToken of tokens) {
    const isValid = await sendFCMNotification(
      accessToken,
      projectId,
      deviceToken.token,
      title,
      body,
      {
        type: "new_conversation",
        conversation_id: conversationId,
        click_action: "OPEN_CHAT",
      }
    );
    if (!isValid) {
      invalidTokenIds.push(deviceToken.id);
    }
  }

  if (invalidTokenIds.length > 0) {
    await supabase.from("device_tokens").delete().in("id", invalidTokenIds);
  }

  await logNotification(supabase, recipientId, "new_conversation", conversationId);
}

async function handleProfileReminder(
  supabase: ReturnType<typeof createClient>,
  accessToken: string,
  projectId: string
): Promise<void> {
  // Find users with incomplete profiles who haven't been notified in 24h
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

  // Get seekers with incomplete profiles
  const { data: seekers } = await supabase
    .from("seeker_profiles")
    .select("user_id")
    .eq("profile_complete", false);

  // Get recruiters with incomplete profiles (no company_name or no sector)
  const { data: recruiters } = await supabase
    .from("recruiter_profiles")
    .select("user_id")
    .or("company_name.is.null,sector.is.null");

  const allUsers = [
    ...(seekers || []).map((s: { user_id: string }) => ({ userId: s.user_id, role: "seeker" })),
    ...(recruiters || []).map((r: { user_id: string }) => ({ userId: r.user_id, role: "recruiter" })),
  ];

  for (const user of allUsers) {
    // Check deduplication (1 per day max)
    const { data: recentNotif } = await supabase
      .from("notification_log")
      .select("id")
      .eq("user_id", user.userId)
      .eq("type", "profile_reminder")
      .gte("created_at", oneDayAgo)
      .limit(1);

    if (recentNotif && recentNotif.length > 0) continue;

    // Get device tokens
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("id, token")
      .eq("user_id", user.userId);

    if (!tokens || tokens.length === 0) continue;

    const invalidTokenIds: string[] = [];
    for (const deviceToken of tokens) {
      const isValid = await sendFCMNotification(
        accessToken,
        projectId,
        deviceToken.token,
        "Completez votre profil",
        "Votre profil est incomplet. Completez-le pour plus de visibilite !",
        {
          type: "profile_reminder",
          user_role: user.role,
          click_action: "OPEN_PROFILE",
        }
      );
      if (!isValid) {
        invalidTokenIds.push(deviceToken.id);
      }
    }

    if (invalidTokenIds.length > 0) {
      await supabase.from("device_tokens").delete().in("id", invalidTokenIds);
    }

    await logNotification(supabase, user.userId, "profile_reminder");
  }
}

// =============================================================================
// Helpers
// =============================================================================

async function getSenderName(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<string> {
  // Try seeker profile
  const { data: seeker } = await supabase
    .from("seeker_profiles")
    .select("first_name, last_name")
    .eq("user_id", userId)
    .maybeSingle();

  if (seeker) {
    return `${seeker.first_name || ""} ${seeker.last_name || ""}`.trim() || "Utilisateur";
  }

  // Try recruiter profile
  const { data: recruiter } = await supabase
    .from("recruiter_profiles")
    .select("company_name")
    .eq("user_id", userId)
    .maybeSingle();

  if (recruiter) {
    return recruiter.company_name || "Entreprise";
  }

  return "Utilisateur";
}

// =============================================================================
// Main Handler
// =============================================================================

serve(async (req: Request) => {
  try {
    const body: RequestBody | WebhookPayload = await req.json();

    // Create Supabase admin client
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Get Firebase access token
    const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_KEY);
    const projectId = serviceAccount.project_id;
    const accessToken = await getFirebaseAccessToken();

    // Determine notification type
    let type: string;
    let record: Record<string, unknown> | undefined;

    if ("type" in body && typeof body.type === "string") {
      // Direct call (from cron or manual)
      type = body.type;
      record = (body as RequestBody).record;
    } else if ("table" in body) {
      // Webhook call
      const webhook = body as WebhookPayload;
      record = webhook.record;
      type = webhook.table === "messages" ? "new_message" : "new_conversation";
    } else {
      return new Response(JSON.stringify({ error: "Invalid payload" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Route to handler
    switch (type) {
      case "new_message":
        if (record) await handleNewMessage(supabase, record, accessToken, projectId);
        break;
      case "new_conversation":
        if (record) await handleNewConversation(supabase, record, accessToken, projectId);
        break;
      case "profile_reminder":
        await handleProfileReminder(supabase, accessToken, projectId);
        break;
      default:
        return new Response(JSON.stringify({ error: `Unknown type: ${type}` }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        });
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("send-push error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
