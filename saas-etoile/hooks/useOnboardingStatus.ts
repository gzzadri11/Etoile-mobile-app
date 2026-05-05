"use client";

import { useEffect, useRef, useState } from "react";
import { createClient } from "@/lib/supabase/client";

export interface OnboardingSteps {
  accountCreated: boolean;
  siretVerified: boolean;
  offerPublished: boolean;
  candidateViewed: boolean;
  firstContact: boolean;
}

export function useOnboardingStatus() {
  const supabase = useRef(createClient()).current;
  const [steps, setSteps] = useState<OnboardingSteps>({
    accountCreated: true,
    siretVerified: false,
    offerPublished: false,
    candidateViewed: false,
    firstContact: false,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function check() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setLoading(false); return; }

      const uid = user.id;
      const [
        { data: profile },
        { count: offerCount },
        { count: evalCount },
        { count: convCount },
      ] = await Promise.all([
        supabase.from("recruiter_profiles").select("siret_verified").eq("user_id", uid).maybeSingle(),
        supabase.from("videos").select("*", { count: "exact", head: true }).eq("user_id", uid).neq("status", "deleted"),
        supabase.from("candidate_evaluations").select("*", { count: "exact", head: true }).eq("recruiter_id", uid),
        supabase.from("conversations").select("*", { count: "exact", head: true }).or(`participant_1.eq.${uid},participant_2.eq.${uid}`),
      ]);

      setSteps({
        accountCreated: true,
        siretVerified: (profile as any)?.verification_status === "verified",
        offerPublished: (offerCount ?? 0) > 0,
        candidateViewed: (evalCount ?? 0) > 0,
        firstContact: (convCount ?? 0) > 0,
      });
      setLoading(false);
    }
    check();
  }, [supabase]);

  const allDone = Object.values(steps).every(Boolean);
  const completedCount = Object.values(steps).filter(Boolean).length;
  return { steps, allDone, loading, completedCount };
}
