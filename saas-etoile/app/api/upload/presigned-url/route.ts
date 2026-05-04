import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: NextRequest) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) {
    return NextResponse.json({ error: "No session" }, { status: 401 });
  }

  const body = await request.json();

  const workerUrl = process.env.NEXT_PUBLIC_CLOUDFLARE_WORKER_URL;
  if (!workerUrl) {
    return NextResponse.json(
      { error: "Worker URL not configured" },
      { status: 500 }
    );
  }

  const workerResponse = await fetch(`${workerUrl}/presigned-url`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${session.access_token}`,
    },
    body: JSON.stringify(body),
  });

  const data = await workerResponse.json();

  if (!workerResponse.ok) {
    return NextResponse.json(data, { status: workerResponse.status });
  }

  return NextResponse.json(data);
}
